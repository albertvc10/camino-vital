-- ============================================
-- Función: procesar_checkpoint_interactivo
-- ============================================
-- Procesa la respuesta del usuario al checkpoint semanal.
-- Aplica los ajustes de intensidad/nivel y prepara la siguiente semana.
--
-- Parámetros:
--   p_user_id: ID del usuario
--   p_sesiones_elegidas: Número de sesiones que el usuario eligió para la semana
--   p_accion_nivel: Acción recomendada (subir/mantener/bajar)
--   p_delta_intensidad: Cambio de intensidad (+10, +5, 0, -5, -10)
--   p_adherencia_nivel: Nivel de adherencia (alta/media/baja)
--   p_feedback_mayoritario: Feedback predominante (facil/apropiado/dificil)
--   p_explicacion: Razón del ajuste para registrar en historial
--
-- Usada por: workflow 07-Procesar Checkpoint Semanal
-- Fecha creación: 2026-01-XX (documentado 2026-02-05)

CREATE OR REPLACE FUNCTION public.procesar_checkpoint_interactivo(
  p_user_id integer,
  p_sesiones_elegidas integer,
  p_accion_nivel character varying,
  p_delta_intensidad integer,
  p_adherencia_nivel character varying,
  p_feedback_mayoritario character varying,
  p_explicacion character varying
)
RETURNS TABLE(
  id integer,
  email character varying,
  nombre character varying,
  etapa character varying,
  nivel_actual character varying,
  intensidad_nivel integer,
  volumen_extra integer,
  semana_actual integer,
  sesiones_completadas_semana integer,
  sesiones_objetivo_semana integer,
  ajuste_nivel character varying,
  ajuste_intensidad integer,
  intensidad_delta integer,
  sesiones_nuevas integer,
  adherencia_nivel character varying,
  feedback_mayoritario character varying,
  ajuste_razon character varying,
  estado_checkpoint character varying,
  accion_tomada character varying
)
LANGUAGE plpgsql
AS $function$
DECLARE
  v_ya_procesado BOOLEAN;
  v_semana_actual INTEGER;
  v_intensidad_actual INTEGER;
  v_sesiones_actual INTEGER;
  v_nueva_intensidad INTEGER;
  v_intensidad_final INTEGER;
  v_cambio_nivel BOOLEAN := FALSE;
BEGIN
  -- Obtener estado actual del usuario
  SELECT
    COALESCE(programa_users.ajustado_esta_semana, FALSE),
    programa_users.semana_actual,
    programa_users.intensidad_nivel,
    programa_users.sesiones_objetivo_semana
  INTO v_ya_procesado, v_semana_actual, v_intensidad_actual, v_sesiones_actual
  FROM programa_users WHERE programa_users.id = p_user_id;

  -- Solo procesar si no se ha procesado ya esta semana
  IF NOT v_ya_procesado THEN
    -- Calcular nueva intensidad (entre 50 y 100)
    v_nueva_intensidad := LEAST(100, GREATEST(50, v_intensidad_actual + p_delta_intensidad));

    -- Determinar si hay cambio de nivel
    IF p_accion_nivel IN ('subir', 'subir_mucho') AND v_nueva_intensidad >= 90 THEN
      v_cambio_nivel := TRUE;
    ELSIF p_accion_nivel IN ('bajar', 'bajar_mucho') AND v_intensidad_actual <= 55 THEN
      v_cambio_nivel := TRUE;
    END IF;

    -- Calcular intensidad final (resetear a 60 u 80 si hay cambio de nivel)
    v_intensidad_final := CASE
      WHEN v_cambio_nivel AND p_accion_nivel IN ('subir', 'subir_mucho') THEN 60
      WHEN v_cambio_nivel AND p_accion_nivel IN ('bajar', 'bajar_mucho') THEN 80
      ELSE v_nueva_intensidad
    END;

    -- Actualizar usuario
    UPDATE programa_users u
    SET
      nivel_actual = CASE
        WHEN v_cambio_nivel AND p_accion_nivel IN ('subir', 'subir_mucho') THEN
          CASE u.nivel_actual
            WHEN 'iniciacion' THEN 'intermedio'
            WHEN 'intermedio' THEN 'avanzado'
            ELSE u.nivel_actual
          END
        WHEN v_cambio_nivel AND p_accion_nivel IN ('bajar', 'bajar_mucho') THEN
          CASE u.nivel_actual
            WHEN 'avanzado' THEN 'intermedio'
            WHEN 'intermedio' THEN 'iniciacion'
            ELSE u.nivel_actual
          END
        ELSE u.nivel_actual
      END,
      intensidad_nivel = v_intensidad_final,
      semana_ultimo_checkpoint = u.semana_actual,
      semana_actual = u.semana_actual + 1,
      sesiones_objetivo_semana = p_sesiones_elegidas,
      ajustado_esta_semana = TRUE,
      sesiones_completadas_semana = 0,
      sesion_actual_dentro_semana = 1,
      updated_at = NOW()
    WHERE u.id = p_user_id;

    -- Registrar en historial
    INSERT INTO programa_historial_ajustes (
      user_id, semana, intensidad_anterior, intensidad_nueva,
      sesiones_anterior, sesiones_nuevas, razon
    ) VALUES (
      p_user_id, v_semana_actual, v_intensidad_actual, v_intensidad_final,
      v_sesiones_actual, p_sesiones_elegidas, p_explicacion
    );
  END IF;

  -- Retornar datos actualizados
  RETURN QUERY
  SELECT
    u.id, u.email, u.nombre, u.etapa, u.nivel_actual, u.intensidad_nivel,
    u.volumen_extra, u.semana_actual, u.sesiones_completadas_semana,
    u.sesiones_objetivo_semana, u.nivel_actual as ajuste_nivel,
    u.intensidad_nivel as ajuste_intensidad, p_delta_intensidad as intensidad_delta,
    p_sesiones_elegidas as sesiones_nuevas, p_adherencia_nivel as adherencia_nivel,
    p_feedback_mayoritario as feedback_mayoritario, p_explicacion as ajuste_razon,
    (CASE WHEN v_ya_procesado THEN 'ya_procesado' ELSE 'nuevo' END)::VARCHAR as estado_checkpoint,
    p_accion_nivel as accion_tomada
  FROM programa_users u
  WHERE u.id = p_user_id;
END;
$function$;
