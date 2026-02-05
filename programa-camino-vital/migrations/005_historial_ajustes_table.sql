-- ============================================
-- Migración 005: Tabla programa_historial_ajustes y columna semana_ultimo_checkpoint
-- Fecha: 2026-02-05
-- ============================================
-- Requerido por: función procesar_checkpoint_interactivo()

-- Tabla para registrar historial de ajustes semanales
CREATE TABLE IF NOT EXISTS programa_historial_ajustes (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES programa_users(id),
  semana INTEGER,
  intensidad_anterior INTEGER,
  intensidad_nueva INTEGER,
  sesiones_anterior INTEGER,
  sesiones_nuevas INTEGER,
  razon TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Columna para registrar última semana con checkpoint procesado
ALTER TABLE programa_users
ADD COLUMN IF NOT EXISTS semana_ultimo_checkpoint INTEGER DEFAULT 0;

-- Verificación:
-- SELECT table_name FROM information_schema.tables WHERE table_name = 'programa_historial_ajustes';
-- SELECT column_name FROM information_schema.columns WHERE table_name = 'programa_users' AND column_name = 'semana_ultimo_checkpoint';
