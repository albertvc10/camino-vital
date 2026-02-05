-- Migration 002: Añadir DEFAULT a auth_token
-- Fecha: 2026-02-05
-- Descripción: auth_token debe generarse automáticamente con gen_random_uuid()

-- Añadir DEFAULT para que se genere automáticamente en INSERT
ALTER TABLE programa_users
ALTER COLUMN auth_token SET DEFAULT gen_random_uuid()::text;

-- Generar tokens para usuarios existentes que no tengan
UPDATE programa_users
SET auth_token = gen_random_uuid()::text
WHERE auth_token IS NULL OR auth_token = '';

SELECT 'Migration 002 completada' as status;
