-- ============================================
-- MIGRACIÓN: Modelo de Sesiones Bajo Demanda
-- Fecha: 2024-12-30
-- ============================================

-- Añadir campos para gestión de sesiones
ALTER TABLE programa_users
ADD COLUMN IF NOT EXISTS sesiones_objetivo_semana INTEGER DEFAULT 3,
ADD COLUMN IF NOT EXISTS sesiones_completadas_semana INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS sesion_actual_dentro_semana INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS ultima_sesion_completada TIMESTAMP,
ADD COLUMN IF NOT EXISTS semanas_consecutivas_completas INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS semanas_consecutivas_inactivas INTEGER DEFAULT 0;

-- Añadir campos para pausas/reactivación
ALTER TABLE programa_users
ADD COLUMN IF NOT EXISTS fecha_pausa TIMESTAMP,
ADD COLUMN IF NOT EXISTS fecha_reactivacion_prevista TIMESTAMP,
ADD COLUMN IF NOT EXISTS motivo_pausa VARCHAR(100);

-- Comentarios en las columnas para documentación
COMMENT ON COLUMN programa_users.sesiones_objetivo_semana IS 'Número de sesiones que el usuario eligió hacer esta semana (2-5)';
COMMENT ON COLUMN programa_users.sesiones_completadas_semana IS 'Contador de sesiones completadas en la semana actual';
COMMENT ON COLUMN programa_users.sesion_actual_dentro_semana IS 'Número de la próxima sesión a enviar (1-5)';
COMMENT ON COLUMN programa_users.ultima_sesion_completada IS 'Timestamp de la última sesión completada';
COMMENT ON COLUMN programa_users.semanas_consecutivas_completas IS 'Racha de semanas completadas (para gamificación)';
COMMENT ON COLUMN programa_users.semanas_consecutivas_inactivas IS 'Contador de semanas sin actividad';

-- Actualizar tabla de feedback para incluir número de sesión
ALTER TABLE programa_feedback
ADD COLUMN IF NOT EXISTS numero_sesion INTEGER;

COMMENT ON COLUMN programa_feedback.numero_sesion IS 'Número de sesión dentro de la semana (1-5)';

-- Crear tabla para contenido de sesiones individuales
-- (por ahora usaremos programa_contenido existente, pero preparamos para futuro)
CREATE TABLE IF NOT EXISTS programa_sesiones (
    id SERIAL PRIMARY KEY,

    -- Referencia a semana completa (opcional, para cuando dividamos contenido)
    semana_completa_id INTEGER REFERENCES programa_contenido(id),

    -- O identificación directa
    etapa VARCHAR(50) NOT NULL,
    nivel VARCHAR(50) NOT NULL,
    semana INTEGER NOT NULL,
    numero_sesion INTEGER NOT NULL, -- 1, 2, 3, 4, 5

    -- Contenido de la sesión
    titulo VARCHAR(255),
    descripcion TEXT,
    ejercicios JSONB,

    -- Metadatos
    duracion_estimada INTEGER, -- minutos
    enfoque VARCHAR(100),

    -- Para futuro con IA
    generado_con_ia BOOLEAN DEFAULT false,
    prompt_ia TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(etapa, nivel, semana, numero_sesion)
);

COMMENT ON TABLE programa_sesiones IS 'Contenido de sesiones individuales. Por ahora opcional, se usará programa_contenido para MVP';

-- Crear tabla de log de sesiones generadas (para cuando usemos IA)
CREATE TABLE IF NOT EXISTS programa_sesiones_generadas (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES programa_users(id) ON DELETE CASCADE,

    -- Contexto
    semana INTEGER NOT NULL,
    numero_sesion INTEGER NOT NULL,

    -- Contenido enviado
    ejercicios_ids INTEGER[], -- IDs de biblioteca_ejercicios (cuando exista)
    ejercicios_detalle JSONB, -- Ejercicios con repeticiones ajustadas

    -- Para IA
    prompt_enviado TEXT,
    respuesta_ia TEXT,
    modelo_usado VARCHAR(100), -- claude-3-5-sonnet, gpt-4, etc

    -- Feedback
    dificultad_reportada VARCHAR(50), -- facil, adecuado, dificil

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE programa_sesiones_generadas IS 'Log de sesiones generadas dinámicamente con IA';

-- Índices para optimización
CREATE INDEX IF NOT EXISTS idx_programa_users_ultima_sesion ON programa_users(ultima_sesion_completada);
CREATE INDEX IF NOT EXISTS idx_programa_users_sesiones_semana ON programa_users(sesiones_completadas_semana, sesiones_objetivo_semana);
CREATE INDEX IF NOT EXISTS idx_programa_sesiones_lookup ON programa_sesiones(etapa, nivel, semana, numero_sesion);
CREATE INDEX IF NOT EXISTS idx_programa_sesiones_generadas_user ON programa_sesiones_generadas(user_id, semana);

-- Trigger para updated_at en nueva tabla
CREATE TRIGGER update_programa_sesiones_updated_at BEFORE UPDATE ON programa_sesiones
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Vista helper: usuarios que completaron su semana
CREATE OR REPLACE VIEW v_usuarios_semana_completa AS
SELECT
    u.id,
    u.email,
    u.nombre,
    u.semana_actual,
    u.sesiones_objetivo_semana,
    u.sesiones_completadas_semana,
    u.ultima_sesion_completada,
    CASE
        WHEN u.sesiones_completadas_semana >= u.sesiones_objetivo_semana
        THEN true
        ELSE false
    END as semana_completada
FROM programa_users u
WHERE u.estado = 'activo';

COMMENT ON VIEW v_usuarios_semana_completa IS 'Vista helper para identificar usuarios que completaron su semana';

-- Vista helper: segmentación para checkpoint dominical
CREATE OR REPLACE VIEW v_usuarios_checkpoint_dominical AS
SELECT
    u.id,
    u.email,
    u.nombre,
    u.semana_actual,
    u.sesiones_objetivo_semana,
    u.sesiones_completadas_semana,
    u.ultima_sesion_completada,
    u.estado,
    CASE
        -- Completistas: todas las sesiones hechas
        WHEN u.sesiones_completadas_semana >= u.sesiones_objetivo_semana
        THEN 'completista'

        -- Parciales: algunas sesiones pero no todas
        WHEN u.sesiones_completadas_semana > 0
            AND u.sesiones_completadas_semana < u.sesiones_objetivo_semana
        THEN 'parcial'

        -- Inactivos recientes: 0 sesiones esta semana pero activos la anterior
        WHEN u.sesiones_completadas_semana = 0
            AND u.ultima_sesion_completada >= CURRENT_DATE - INTERVAL '7 days'
        THEN 'inactivo_reciente'

        -- Inactivos crónicos: 2+ semanas sin actividad
        WHEN u.ultima_sesion_completada < CURRENT_DATE - INTERVAL '14 days'
            OR u.ultima_sesion_completada IS NULL
        THEN 'inactivo_cronico'

        ELSE 'otro'
    END as segmento
FROM programa_users u
WHERE u.estado = 'activo';

COMMENT ON VIEW v_usuarios_checkpoint_dominical IS 'Segmentación automática para emails del checkpoint dominical';

-- Función helper: resetear semana
CREATE OR REPLACE FUNCTION resetear_semana_usuario(p_user_id INTEGER)
RETURNS void AS $$
BEGIN
    UPDATE programa_users
    SET
        sesiones_completadas_semana = 0,
        sesion_actual_dentro_semana = 1,
        semana_actual = semana_actual + 1,
        semanas_consecutivas_completas = semanas_consecutivas_completas + 1,
        semanas_consecutivas_inactivas = 0
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION resetear_semana_usuario IS 'Avanza a la siguiente semana y resetea contadores de sesiones';

-- Función helper: registrar sesión completada
CREATE OR REPLACE FUNCTION registrar_sesion_completada(
    p_user_id INTEGER,
    p_dificultad VARCHAR(50)
)
RETURNS JSONB AS $$
DECLARE
    v_sesiones_completadas INTEGER;
    v_sesiones_objetivo INTEGER;
    v_semana_completa BOOLEAN;
    v_resultado JSONB;
BEGIN
    -- Incrementar contador
    UPDATE programa_users
    SET
        sesiones_completadas_semana = sesiones_completadas_semana + 1,
        sesion_actual_dentro_semana = sesion_actual_dentro_semana + 1,
        ultima_sesion_completada = CURRENT_TIMESTAMP,
        respuestas_totales = respuestas_totales + 1
    WHERE id = p_user_id
    RETURNING
        sesiones_completadas_semana,
        sesiones_objetivo_semana
    INTO v_sesiones_completadas, v_sesiones_objetivo;

    -- Verificar si completó la semana
    v_semana_completa := v_sesiones_completadas >= v_sesiones_objetivo;

    -- Preparar resultado
    v_resultado := jsonb_build_object(
        'sesiones_completadas', v_sesiones_completadas,
        'sesiones_objetivo', v_sesiones_objetivo,
        'semana_completa', v_semana_completa,
        'siguiente_accion', CASE
            WHEN v_semana_completa THEN 'esperar_domingo'
            ELSE 'enviar_siguiente_sesion'
        END
    );

    RETURN v_resultado;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION registrar_sesion_completada IS 'Registra una sesión como completada y devuelve el estado actual';

-- ============================================
-- DATOS DE MIGRACIÓN
-- ============================================

-- Inicializar campos nuevos para usuarios existentes
UPDATE programa_users
SET
    sesiones_objetivo_semana = 3,
    sesiones_completadas_semana = 0,
    sesion_actual_dentro_semana = 1,
    semanas_consecutivas_completas = 0,
    semanas_consecutivas_inactivas = 0
WHERE sesiones_objetivo_semana IS NULL;

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Mostrar resumen de la migración
DO $$
DECLARE
    v_usuarios_actualizados INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_usuarios_actualizados
    FROM programa_users
    WHERE sesiones_objetivo_semana IS NOT NULL;

    RAISE NOTICE '✅ Migración completada';
    RAISE NOTICE 'Usuarios actualizados: %', v_usuarios_actualizados;
    RAISE NOTICE 'Nuevas tablas creadas: programa_sesiones, programa_sesiones_generadas';
    RAISE NOTICE 'Vistas creadas: v_usuarios_semana_completa, v_usuarios_checkpoint_dominical';
    RAISE NOTICE 'Funciones creadas: resetear_semana_usuario, registrar_sesion_completada';
END $$;
