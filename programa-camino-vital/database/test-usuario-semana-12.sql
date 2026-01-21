-- ============================================
-- TEST: Usuario en Semana 12 para probar fin de programa
-- Fecha: 2026-01-18
-- ============================================

-- Usar el schema correcto (ajustar si es necesario)
SET search_path TO public;

-- Eliminar usuario de prueba si existe (para poder re-ejecutar)
DELETE FROM programa_users WHERE email = 'test-semana12@habitos-vitales.com';

-- Insertar usuario de prueba en semana 12
INSERT INTO programa_users (
    email,
    nombre,
    etapa,
    nivel_actual,
    intensidad_nivel,
    semana_actual,
    estado,
    fecha_inicio,

    -- Sesiones de la semana (completadas para trigger checkpoint)
    sesiones_objetivo_semana,
    sesiones_completadas_semana,
    sesion_actual_dentro_semana,

    -- Progresión
    semanas_consecutivas_completas,
    semanas_consecutivas_inactivas,
    ajustado_esta_semana,

    -- Perfil simulado
    perfil_inicial,

    -- Tracking
    envios_totales,
    respuestas_totales
) VALUES (
    'test-semana12@habitos-vitales.com',
    'Usuario Test Semana 12',
    'base_vital',
    'avanzado',  -- Ha progresado durante 12 semanas
    80,          -- Intensidad alta tras 12 semanas
    12,          -- Semana actual = 12
    'activo',
    NOW() - INTERVAL '12 weeks',  -- Empezó hace 12 semanas

    -- Sesiones: 3 objetivo, 3 completadas (listo para checkpoint)
    3,
    3,
    4,  -- Ya completó las 3, siguiente sería la 4

    -- Ha completado 11 semanas consecutivas
    11,
    0,
    FALSE,  -- Importante: FALSE para que el checkpoint lo procese

    -- Perfil inicial simulado
    '{"tiempo_sin_ejercicio": "6_meses_1_ano", "limitaciones": [], "objetivos": ["movilidad", "fuerza"], "nivel_actividad": "sedentario"}'::jsonb,

    -- Ha recibido ~33 emails (11 semanas * 3 sesiones)
    33,
    33
);

-- Verificar inserción
SELECT
    id,
    email,
    nombre,
    semana_actual,
    nivel_actual,
    intensidad_nivel,
    sesiones_objetivo_semana,
    sesiones_completadas_semana,
    estado,
    ajustado_esta_semana
FROM programa_users
WHERE email = 'test-semana12@habitos-vitales.com';

-- ============================================
-- INSTRUCCIONES DE USO:
-- ============================================
-- 1. Ejecutar este script en PostgreSQL
-- 2. Ir al navegador y abrir:
--    http://localhost:5678/webhook/checkpoint-semanal?user_id=<ID_DEL_USUARIO>
--    (reemplazar <ID_DEL_USUARIO> con el ID mostrado arriba)
-- 3. Debería mostrar la página de "Programa Completado"
--    y enviar el email de felicitación
-- ============================================
