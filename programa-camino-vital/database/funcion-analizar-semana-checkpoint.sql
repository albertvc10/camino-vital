-- ============================================
-- Función: analizar_semana_para_checkpoint
-- ============================================
-- Analiza el rendimiento semanal de un usuario y devuelve:
-- - Datos del usuario
-- - Porcentaje de adherencia (sesiones completadas vs objetivo)
-- - Feedback mayoritario de la semana
-- - Acción recomendada (subir/mantener/bajar nivel)
-- - Mensaje personalizado para el usuario
--
-- Usada por: workflow 06-Checkpoint Dominical
-- Fecha creación: 2026-01-XX (documentado 2026-02-05)

CREATE OR REPLACE FUNCTION public.analizar_semana_para_checkpoint(p_user_id integer)
 RETURNS TABLE(
   out_user_id integer,
   out_email character varying,
   out_nombre character varying,
   out_nivel_actual character varying,
   out_semana_actual integer,
   out_sesiones_objetivo integer,
   out_sesiones_completadas integer,
   out_intensidad_actual integer,
   adherencia_porcentaje integer,
   adherencia_nivel character varying,
   feedback_mayoritario character varying,
   accion_nivel character varying,
   accion_intensidad integer,
   sesiones_recomendadas integer,
   mensaje_usuario text,
   explicacion_corta text
 )
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_user RECORD;
  v_feedback_counts RECORD;
  v_adherencia_pct INTEGER;
  v_adherencia_nivel VARCHAR;
  v_feedback_mayor VARCHAR;
  v_accion_nivel VARCHAR;
  v_accion_intensidad INTEGER;
  v_sesiones_rec INTEGER;
  v_mensaje TEXT;
  v_explicacion TEXT;
BEGIN
  -- Obtener datos del usuario
  SELECT
    u.id, u.email, u.nombre, u.nivel_actual, u.semana_actual,
    u.sesiones_objetivo_semana, u.sesiones_completadas_semana,
    u.intensidad_nivel
  INTO v_user
  FROM programa_users u
  WHERE u.id = p_user_id;

  -- Calcular adherencia
  IF v_user.sesiones_objetivo_semana > 0 THEN
    v_adherencia_pct := ROUND((v_user.sesiones_completadas_semana::DECIMAL / v_user.sesiones_objetivo_semana) * 100);
  ELSE
    v_adherencia_pct := 0;
  END IF;

  -- Clasificar adherencia
  v_adherencia_nivel := CASE
    WHEN v_adherencia_pct >= 100 THEN 'alta'
    WHEN v_adherencia_pct >= 66 THEN 'media'
    ELSE 'baja'
  END;

  -- Contar feedback de la semana
  SELECT
    COUNT(*) FILTER (WHERE f.respuesta = 'facil') as facil,
    COUNT(*) FILTER (WHERE f.respuesta = 'apropiado') as apropiado,
    COUNT(*) FILTER (WHERE f.respuesta = 'dificil') as dificil,
    COUNT(*) as total
  INTO v_feedback_counts
  FROM programa_feedback f
  WHERE f.user_id = p_user_id
    AND f.semana = v_user.semana_actual
    AND f.tipo_feedback = 'sesion_completada';

  -- Determinar feedback mayoritario
  IF v_feedback_counts.total = 0 THEN
    v_feedback_mayor := 'sin_datos';
  ELSIF v_feedback_counts.facil > v_feedback_counts.apropiado AND v_feedback_counts.facil > v_feedback_counts.dificil THEN
    v_feedback_mayor := 'facil';
  ELSIF v_feedback_counts.dificil > v_feedback_counts.apropiado AND v_feedback_counts.dificil > v_feedback_counts.facil THEN
    v_feedback_mayor := 'dificil';
  ELSIF v_feedback_counts.apropiado >= v_feedback_counts.facil AND v_feedback_counts.apropiado >= v_feedback_counts.dificil THEN
    v_feedback_mayor := 'apropiado';
  ELSE
    v_feedback_mayor := 'mixto';
  END IF;

  -- Aplicar matriz de decisión
  -- Alta adherencia (100%)
  IF v_adherencia_nivel = 'alta' THEN
    CASE v_feedback_mayor
      WHEN 'facil' THEN
        v_accion_nivel := 'subir_mucho';
        v_accion_intensidad := 10;
        v_sesiones_rec := LEAST(v_user.sesiones_objetivo_semana + 1, 5);
        v_mensaje := '¡Increíble semana! Has completado todas las sesiones y te han resultado fáciles. Estás listo para subir de nivel.';
        v_explicacion := 'Subimos intensidad';
      WHEN 'apropiado' THEN
        v_accion_nivel := 'subir';
        v_accion_intensidad := 5;
        v_sesiones_rec := v_user.sesiones_objetivo_semana;
        v_mensaje := '¡Perfecta semana! Has sido muy consistente y el nivel te va bien. Vamos a progresar un poco.';
        v_explicacion := 'Progresión gradual';
      WHEN 'dificil' THEN
        v_accion_nivel := 'mantener';
        v_accion_intensidad := 0;
        v_sesiones_rec := v_user.sesiones_objetivo_semana;
        v_mensaje := '¡Gran esfuerzo! Has completado todo aunque fue exigente. Mantenemos el nivel para que consolides.';
        v_explicacion := 'Consolidamos nivel';
      ELSE
        v_accion_nivel := 'mantener';
        v_accion_intensidad := 0;
        v_sesiones_rec := v_user.sesiones_objetivo_semana;
        v_mensaje := '¡Buena semana! Has completado todas las sesiones. Seguimos en el mismo ritmo.';
        v_explicacion := 'Mantenemos ritmo';
    END CASE;

  -- Media adherencia (66%)
  ELSIF v_adherencia_nivel = 'media' THEN
    CASE v_feedback_mayor
      WHEN 'facil' THEN
        v_accion_nivel := 'subir';
        v_accion_intensidad := 5;
        v_sesiones_rec := v_user.sesiones_objetivo_semana;
        v_mensaje := 'Tienes capacidad de sobra, pero faltó una sesión. Subimos un poco la intensidad para motivarte.';
        v_explicacion := 'Subimos intensidad';
      WHEN 'apropiado' THEN
        v_accion_nivel := 'mantener';
        v_accion_intensidad := 0;
        v_sesiones_rec := v_user.sesiones_objetivo_semana;
        v_mensaje := 'Buen trabajo en las sesiones que hiciste. Mantenemos el nivel, intenta completar todas la próxima semana.';
        v_explicacion := 'Mantenemos nivel';
      WHEN 'dificil' THEN
        v_accion_nivel := 'bajar';
        v_accion_intensidad := -5;
        v_sesiones_rec := GREATEST(v_user.sesiones_objetivo_semana - 1, 2);
        v_mensaje := 'Vemos que fue una semana exigente. Ajustamos un poco para que sea más llevadero.';
        v_explicacion := 'Ajustamos carga';
      ELSE
        v_accion_nivel := 'mantener';
        v_accion_intensidad := 0;
        v_sesiones_rec := v_user.sesiones_objetivo_semana;
        v_mensaje := 'Buena semana. Mantenemos el ritmo actual.';
        v_explicacion := 'Seguimos igual';
    END CASE;

  -- Baja adherencia (≤33%)
  ELSE
    CASE v_feedback_mayor
      WHEN 'facil' THEN
        v_accion_nivel := 'mantener';
        v_accion_intensidad := 0;
        v_sesiones_rec := GREATEST(v_user.sesiones_objetivo_semana - 1, 2);
        v_mensaje := 'Esta semana fue complicado entrenar, pero cuando lo hiciste te fue bien. ¿Probamos con menos sesiones para que sea más fácil de encajar?';
        v_explicacion := 'Menos sesiones';
      WHEN 'apropiado' THEN
        v_accion_nivel := 'bajar';
        v_accion_intensidad := -5;
        v_sesiones_rec := GREATEST(v_user.sesiones_objetivo_semana - 1, 2);
        v_mensaje := 'Entendemos que no siempre es fácil encontrar tiempo. Ajustamos el programa para que sea más accesible.';
        v_explicacion := 'Reducimos barrera';
      WHEN 'dificil' THEN
        v_accion_nivel := 'bajar_mucho';
        v_accion_intensidad := -10;
        v_sesiones_rec := 2;
        v_mensaje := 'Esta semana fue difícil en todos los sentidos. Vamos a hacer el programa más accesible para que puedas retomar el ritmo.';
        v_explicacion := 'Reset suave';
      ELSE
        v_accion_nivel := 'bajar';
        v_accion_intensidad := -5;
        v_sesiones_rec := GREATEST(v_user.sesiones_objetivo_semana - 1, 2);
        v_mensaje := 'Semana complicada, lo entendemos. Ajustamos para la próxima.';
        v_explicacion := 'Ajustamos programa';
    END CASE;
  END IF;

  -- Retornar resultado
  RETURN QUERY SELECT
    v_user.id,
    v_user.email::VARCHAR,
    v_user.nombre::VARCHAR,
    v_user.nivel_actual::VARCHAR,
    v_user.semana_actual,
    v_user.sesiones_objetivo_semana,
    v_user.sesiones_completadas_semana,
    v_user.intensidad_nivel,
    v_adherencia_pct,
    v_adherencia_nivel,
    v_feedback_mayor,
    v_accion_nivel,
    v_accion_intensidad,
    v_sesiones_rec,
    v_mensaje,
    v_explicacion;
END;
$function$;

-- Verificación:
-- SELECT * FROM analizar_semana_para_checkpoint(1);
