-- ============================================
-- Migración 004: Cambiar intensidad_nivel a INTEGER
-- Fecha: 2026-02-05
-- ============================================
-- La columna intensidad_nivel debe ser INTEGER (0-100) no VARCHAR.
-- Esta migración convierte valores texto a números y cambia el tipo.
-- Requerido por: función analizar_semana_para_checkpoint()

-- Paso 1: Convertir valores texto a números
UPDATE programa_users
SET intensidad_nivel = CASE
  WHEN intensidad_nivel = 'normal' THEN '50'
  WHEN intensidad_nivel = 'bajo' THEN '30'
  WHEN intensidad_nivel = 'alto' THEN '70'
  WHEN intensidad_nivel ~ '^[0-9]+$' THEN intensidad_nivel
  ELSE '50'
END
WHERE intensidad_nivel IS NOT NULL;

-- Paso 2: Quitar default antiguo, cambiar tipo, poner nuevo default
ALTER TABLE programa_users ALTER COLUMN intensidad_nivel DROP DEFAULT;
ALTER TABLE programa_users ALTER COLUMN intensidad_nivel TYPE INTEGER USING intensidad_nivel::INTEGER;
ALTER TABLE programa_users ALTER COLUMN intensidad_nivel SET DEFAULT 50;

-- Verificación:
-- SELECT column_name, data_type, column_default
-- FROM information_schema.columns
-- WHERE table_name = 'programa_users' AND column_name = 'intensidad_nivel';
-- Esperado: integer, 50
