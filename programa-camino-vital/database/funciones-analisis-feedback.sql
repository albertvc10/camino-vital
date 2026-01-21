-- ============================================
-- FUNCIONES DE ANÁLISIS DE FEEDBACK
-- ============================================
-- Fecha: 2 Enero 2025
-- Propósito: Analizar feedback acumulado y recomendar ajustes
-- Nota: Usar schema public (donde n8n trabaja por defecto)

-- ============================================
-- FUNCIÓN: Analizar feedback reciente de sesiones
-- ============================================
CREATE OR REPLACE FUNCTION analizar_feedback_sesiones(
  p_user_id INTEGER,
  p_semana INTEGER DEFAULT NULL
)
RETURNS TABLE (
  total_sesiones INTEGER,
  sesiones_facil INTEGER,
  sesiones_adecuado INTEGER,
  sesiones_dificil INTEGER,
  porcentaje_facil NUMERIC,
  porcentaje_dificil NUMERIC,
  recomendacion VARCHAR(50)
) AS $$
DECLARE
  v_semana INTEGER;
BEGIN
  -- Si no se especifica semana, usar la actual del usuario
  IF p_semana IS NULL THEN
    SELECT semana_actual INTO v_semana
    FROM programa_users
    WHERE id = p_user_id;
  ELSE
    v_semana := p_semana;
  END IF;

  RETURN QUERY
  WITH feedback_conteo AS (
    SELECT
      COUNT(*) as total,
      COUNT(*) FILTER (WHERE respuesta = 'facil') as facil,
      COUNT(*) FILTER (WHERE respuesta = 'adecuado') as adecuado,
      COUNT(*) FILTER (WHERE respuesta = 'dificil') as dificil
    FROM programa_feedback
    WHERE user_id = p_user_id
      AND semana = v_semana
      AND tipo_feedback = 'sesion_completada'
  )
  SELECT
    total::INTEGER,
    facil::INTEGER,
    adecuado::INTEGER,
    dificil::INTEGER,
    CASE
      WHEN total > 0 THEN ROUND((facil::NUMERIC / total) * 100, 2)
      ELSE 0
    END as porcentaje_facil,
    CASE
      WHEN total > 0 THEN ROUND((dificil::NUMERIC / total) * 100, 2)
      ELSE 0
    END as porcentaje_dificil,
    CASE
      -- Más del 66% fueron fáciles
      WHEN total > 0 AND (facil::NUMERIC / total) > 0.66 THEN 'aumentar_dificultad'
      -- Más del 66% fueron difíciles
      WHEN total > 0 AND (dificil::NUMERIC / total) > 0.66 THEN 'reducir_dificultad'
      -- Si no completó ninguna sesión
      WHEN total = 0 THEN 'reducir_sesiones'
      -- Todo lo demás está bien
      ELSE 'mantener'
    END::VARCHAR as recomendacion
  FROM feedback_conteo;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION analizar_feedback_sesiones IS 'Analiza el feedback de sesiones de una semana y recomienda ajustes';

-- ============================================
-- FUNCIÓN: Obtener estadísticas semanales
-- ============================================
CREATE OR REPLACE FUNCTION obtener_estadisticas_semana(
  p_user_id INTEGER,
  p_semana INTEGER DEFAULT NULL
)
RETURNS TABLE (
  sesiones_objetivo INTEGER,
  sesiones_completadas INTEGER,
  porcentaje_completado NUMERIC,
  racha_completadas INTEGER,
  nivel_actual VARCHAR(50),
  etapa_actual VARCHAR(50)
) AS $$
DECLARE
  v_semana INTEGER;
BEGIN
  -- Si no se especifica semana, usar la actual del usuario
  IF p_semana IS NULL THEN
    SELECT semana_actual INTO v_semana
    FROM programa_users
    WHERE id = p_user_id;
  ELSE
    v_semana := p_semana;
  END IF;

  RETURN QUERY
  SELECT
    u.sesiones_objetivo_semana,
    u.sesiones_completadas_semana,
    CASE
      WHEN u.sesiones_objetivo_semana > 0
      THEN ROUND((u.sesiones_completadas_semana::NUMERIC / u.sesiones_objetivo_semana) * 100, 2)
      ELSE 0
    END as porcentaje,
    u.semanas_consecutivas_completas,
    u.nivel_actual,
    u.etapa
  FROM programa_users u
  WHERE u.id = p_user_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION obtener_estadisticas_semana IS 'Obtiene estadísticas de rendimiento de la semana';

-- ============================================
-- FUNCIÓN: Recomendar ajuste de nivel
-- ============================================
CREATE OR REPLACE FUNCTION recomendar_ajuste_nivel(
  p_user_id INTEGER
)
RETURNS TABLE (
  accion VARCHAR(50),
  nuevo_nivel VARCHAR(50),
  nuevas_sesiones INTEGER,
  razon TEXT
) AS $$
DECLARE
  v_stats RECORD;
  v_feedback RECORD;
  v_nivel_actual VARCHAR(50);
  v_sesiones_actuales INTEGER;
BEGIN
  -- Obtener estadísticas
  SELECT * INTO v_stats FROM obtener_estadisticas_semana(p_user_id);
  SELECT * INTO v_feedback FROM analizar_feedback_sesiones(p_user_id);

  v_nivel_actual := v_stats.nivel_actual;
  v_sesiones_actuales := v_stats.sesiones_objetivo;

  -- CASO 1: Completó todas + fue fácil → Subir nivel o aumentar sesiones
  IF v_stats.porcentaje_completado >= 100
     AND v_feedback.recomendacion = 'aumentar_dificultad' THEN

    IF v_nivel_actual = 'iniciacion' THEN
      -- Subir a intermedio
      RETURN QUERY SELECT
        'subir_nivel'::VARCHAR,
        'intermedio'::VARCHAR,
        v_sesiones_actuales,
        'Completaste todas las sesiones y te resultaron fáciles. ¡Es hora de subir de nivel!'::TEXT;
    ELSIF v_nivel_actual = 'intermedio' THEN
      -- Subir a avanzado
      RETURN QUERY SELECT
        'subir_nivel'::VARCHAR,
        'avanzado'::VARCHAR,
        v_sesiones_actuales,
        'Excelente progreso. Pasamos a ejercicios más avanzados.'::TEXT;
    ELSE
      -- Ya está en avanzado, aumentar sesiones si es posible
      IF v_sesiones_actuales < 5 THEN
        RETURN QUERY SELECT
          'aumentar_sesiones'::VARCHAR,
          v_nivel_actual,
          v_sesiones_actuales + 1,
          '¡Vas muy bien! Añadimos una sesión más por semana.'::TEXT;
      ELSE
        RETURN QUERY SELECT
          'mantener'::VARCHAR,
          v_nivel_actual,
          v_sesiones_actuales,
          '¡Increíble! Estás en el nivel máximo.'::TEXT;
      END IF;
    END IF;

  -- CASO 2: No completó todas + fue difícil → Bajar nivel o reducir sesiones
  ELSIF v_stats.porcentaje_completado < 70
        AND v_feedback.recomendacion = 'reducir_dificultad' THEN

    IF v_nivel_actual = 'avanzado' THEN
      -- Bajar a intermedio
      RETURN QUERY SELECT
        'bajar_nivel'::VARCHAR,
        'intermedio'::VARCHAR,
        v_sesiones_actuales,
        'Vamos a bajar un poco la intensidad para que te sientas más cómodo.'::TEXT;
    ELSIF v_nivel_actual = 'intermedio' THEN
      -- Bajar a iniciación
      RETURN QUERY SELECT
        'bajar_nivel'::VARCHAR,
        'iniciacion'::VARCHAR,
        v_sesiones_actuales,
        'Sin problema, volvemos a ejercicios más suaves.'::TEXT;
    ELSE
      -- Ya está en iniciación, reducir sesiones si es posible
      IF v_sesiones_actuales > 2 THEN
        RETURN QUERY SELECT
          'reducir_sesiones'::VARCHAR,
          v_nivel_actual,
          v_sesiones_actuales - 1,
          'Vamos a reducir a menos sesiones para que sea más manejable.'::TEXT;
      ELSE
        RETURN QUERY SELECT
          'mantener'::VARCHAR,
          v_nivel_actual,
          v_sesiones_actuales,
          'Continuemos al mismo ritmo. La constancia es clave.'::TEXT;
      END IF;
    END IF;

  -- CASO 3: No completó ninguna sesión → Reducir sesiones
  ELSIF v_stats.sesiones_completadas = 0 THEN
    IF v_sesiones_actuales > 2 THEN
      RETURN QUERY SELECT
        'reducir_sesiones'::VARCHAR,
        v_nivel_actual,
        v_sesiones_actuales - 1,
        'Empecemos con menos sesiones para crear el hábito.'::TEXT;
    ELSE
      RETURN QUERY SELECT
        'mantener'::VARCHAR,
        v_nivel_actual,
        v_sesiones_actuales,
        'No pasa nada. Esta semana intenta hacer al menos una sesión.'::TEXT;
    END IF;

  -- CASO 4: Todo está bien → Mantener
  ELSE
    RETURN QUERY SELECT
      'mantener'::VARCHAR,
      v_nivel_actual,
      v_sesiones_actuales,
      '¡Perfecto! Continuamos al mismo ritmo.'::TEXT;
  END IF;

  RETURN;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION recomendar_ajuste_nivel IS 'Analiza rendimiento y feedback para recomendar ajuste de nivel/sesiones';

-- ============================================
-- FUNCIÓN: Resetear contadores semanales
-- ============================================
CREATE OR REPLACE FUNCTION resetear_semana(
  p_user_id INTEGER
)
RETURNS TABLE (
  user_id INTEGER,
  nueva_semana INTEGER,
  sesiones_completadas_anterior INTEGER
) AS $$
DECLARE
  v_completadas INTEGER;
  v_objetivo INTEGER;
BEGIN
  -- Guardar sesiones completadas de la semana que termina
  SELECT
    sesiones_completadas_semana,
    sesiones_objetivo_semana
  INTO v_completadas, v_objetivo
  FROM programa_users
  WHERE id = p_user_id;

  -- Actualizar racha si completó todas las sesiones
  IF v_completadas >= v_objetivo THEN
    UPDATE programa_users
    SET
      semanas_consecutivas_completas = semanas_consecutivas_completas + 1,
      semanas_consecutivas_inactivas = 0
    WHERE id = p_user_id;
  ELSE
    UPDATE programa_users
    SET
      semanas_consecutivas_completas = 0,
      semanas_consecutivas_inactivas = CASE
        WHEN v_completadas = 0 THEN semanas_consecutivas_inactivas + 1
        ELSE 0
      END
    WHERE id = p_user_id;
  END IF;

  -- Resetear contadores y avanzar semana
  UPDATE programa_users
  SET
    sesiones_completadas_semana = 0,
    sesion_actual_dentro_semana = 1,
    semana_actual = semana_actual + 1,
    updated_at = NOW()
  WHERE id = p_user_id;

  RETURN QUERY
  SELECT
    u.id,
    u.semana_actual,
    v_completadas
  FROM programa_users u
  WHERE u.id = p_user_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION resetear_semana IS 'Resetea contadores semanales y avanza a la siguiente semana';

-- ============================================
-- Verificación
-- ============================================
SELECT
  'Función creada: ' || proname as resultado
FROM pg_proc
WHERE pronamespace = 'camino_vital'::regnamespace
  AND proname IN (
    'analizar_feedback_sesiones',
    'obtener_estadisticas_semana',
    'recomendar_ajuste_nivel',
    'resetear_semana'
  )
ORDER BY proname;
