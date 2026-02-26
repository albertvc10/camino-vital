-- Migration 007: Create ejercicios_cardio table
-- Date: 2026-02-26
-- Description: Creates the ejercicios_cardio table for low-intensity cardio activities
--              used by the "Generador Sesion IA" workflow for cardio sessions.
--              Does NOT include "Marcha sentada" or "Marcha en el sitio" (removed by design).

-- Create table if not exists
CREATE TABLE IF NOT EXISTS ejercicios_cardio (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('resistencia', 'intervalos')),
    nivel VARCHAR(20) NOT NULL CHECK (nivel IN ('iniciacion', 'intermedio', 'avanzado')),
    descripcion TEXT,
    protocolo VARCHAR(200),
    objetivo_fisiologico VARCHAR(200),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes if not exist
CREATE INDEX IF NOT EXISTS idx_ejercicios_cardio_nivel ON ejercicios_cardio(nivel);
CREATE INDEX IF NOT EXISTS idx_ejercicios_cardio_tipo ON ejercicios_cardio(tipo);

-- Insert data only if table is empty (idempotent)
INSERT INTO ejercicios_cardio (nombre, tipo, nivel, descripcion, protocolo, objetivo_fisiologico)
SELECT * FROM (VALUES
    ('Paseo corto cómodo', 'resistencia', 'iniciacion', 'Caminar a ritmo conversacional', '15-25 min total', 'Base aeróbica mínima'),
    ('Caminar rápido 30 seg', 'intervalos', 'iniciacion', 'Caminar más rápido de lo habitual', '12-18 min total (30s rápido / 1-2 min suave x 4-6)', 'Introducción al estímulo VO2'),
    ('Caminata moderada', 'resistencia', 'intermedio', 'Ritmo ligeramente más rápido pero conversacional', '25-35 min total', 'Mejora eficiencia cardiovascular'),
    ('Cambios suaves de ritmo', 'resistencia', 'intermedio', 'Acelerar 30 seg cada 3-4 min', '25-35 min total', 'Preparación para intervalos'),
    ('Cambios rápidos dirección', 'intervalos', 'intermedio', 'Caminar 10 pasos rápido, girar y repetir', '18-25 min total (bloques de 4-6 cambios)', 'Sistema cardiovascular + coordinación'),
    ('Marcha rodillas altas', 'intervalos', 'intermedio', 'Marchar rápido elevando rodillas sin saltar', '18-25 min total (20-30s trabajo / 1 min descanso x 6-8)', 'Alta intensidad segura'),
    ('Power walking', 'resistencia', 'avanzado', 'Caminata con braceo activo y zancada firme', '30-45 min total', 'Mayor estímulo cardiovascular'),
    ('Cambios rápidos dirección', 'intervalos', 'avanzado', 'Caminar 10 pasos rápido, girar y repetir', '25-35 min total (bloques de 6-8 cambios)', 'Sistema cardiovascular + coordinación'),
    ('Marcha rodillas altas', 'intervalos', 'avanzado', 'Marchar rápido elevando rodillas sin saltar', '25-35 min total (20-30s trabajo / 45s descanso x 8-10)', 'Alta intensidad segura')
) AS v(nombre, tipo, nivel, descripcion, protocolo, objetivo_fisiologico)
WHERE NOT EXISTS (SELECT 1 FROM ejercicios_cardio LIMIT 1);
