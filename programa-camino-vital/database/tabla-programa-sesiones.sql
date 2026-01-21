-- ============================================
-- TABLA: programa_sesiones
-- Almacena las sesiones personalizadas generadas por IA
-- Nota: Usar schema public (donde n8n trabaja por defecto)
-- ============================================

CREATE TABLE IF NOT EXISTS programa_sesiones (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES programa_users(id) ON DELETE CASCADE,

  -- Metadatos de la sesión
  titulo VARCHAR(255) NOT NULL,
  descripcion TEXT,
  introduccion_personalizada TEXT, -- Explicación personalizada generada por IA
  enfoque VARCHAR(100), -- 'movilidad', 'fuerza', 'equilibrio', 'mixto'
  duracion_estimada VARCHAR(50), -- '25-30 minutos'

  -- Estructura de la sesión (JSON)
  calentamiento JSONB NOT NULL, -- Array de ejercicios de calentamiento
  trabajo_principal JSONB NOT NULL, -- Array de ejercicios principales

  -- Control de sesión
  numero_sesion INTEGER NOT NULL, -- 1, 2, 3... dentro de la semana
  semana INTEGER NOT NULL, -- Semana del programa
  completada BOOLEAN DEFAULT false,
  fecha_completada TIMESTAMP,

  -- Auditoria
  generada_por VARCHAR(50) DEFAULT 'ia', -- 'ia' o 'manual'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),

  -- Índices para consultas frecuentes
  CONSTRAINT unique_sesion_usuario UNIQUE (user_id, numero_sesion, semana)
);

-- Índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_sesiones_user ON programa_sesiones(user_id);
CREATE INDEX IF NOT EXISTS idx_sesiones_completada ON programa_sesiones(completada);
CREATE INDEX IF NOT EXISTS idx_sesiones_semana ON programa_sesiones(user_id, semana);

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_sesion_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_sesion_timestamp ON programa_sesiones;
CREATE TRIGGER trigger_update_sesion_timestamp
  BEFORE UPDATE ON programa_sesiones
  FOR EACH ROW
  EXECUTE FUNCTION update_sesion_timestamp();

-- Comentarios
COMMENT ON TABLE programa_sesiones IS 'Sesiones de ejercicio personalizadas generadas por IA';
COMMENT ON COLUMN programa_sesiones.introduccion_personalizada IS 'Explicación de por qué se eligieron estos ejercicios para el usuario';
COMMENT ON COLUMN programa_sesiones.calentamiento IS 'Array JSON con ejercicios de calentamiento';
COMMENT ON COLUMN programa_sesiones.trabajo_principal IS 'Array JSON con ejercicios principales';
COMMENT ON COLUMN programa_sesiones.numero_sesion IS 'Número de sesión dentro de la semana (1, 2, 3...)';
