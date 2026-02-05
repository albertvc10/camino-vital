-- ============================================
-- Migración 003: Añadir columna ajustado_esta_semana
-- Fecha: 2026-02-05
-- ============================================
-- Esta columna es usada por el workflow 06-Checkpoint Dominical
-- para evitar ajustar el nivel de un usuario más de una vez por semana.
-- Se resetea a FALSE cada domingo antes de enviar los checkpoints.

ALTER TABLE programa_users
ADD COLUMN IF NOT EXISTS ajustado_esta_semana BOOLEAN DEFAULT FALSE;

-- Verificación
-- SELECT column_name, data_type, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'programa_users' AND column_name = 'ajustado_esta_semana';
