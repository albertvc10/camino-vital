-- Migration 001: Sincronización inicial de esquema local -> producción
-- Fecha: 2026-02-04
-- Descripción: Correcciones aplicadas para sincronizar producción con local

-- =====================================================
-- TABLA: programa_users
-- =====================================================

-- Añadir columna auth_token para magic links
ALTER TABLE programa_users ADD COLUMN IF NOT EXISTS auth_token VARCHAR(255);

-- Generar tokens para usuarios que no tengan
UPDATE programa_users
SET auth_token = md5(random()::text || clock_timestamp()::text)
WHERE auth_token IS NULL;

-- =====================================================
-- TABLA: programa_feedback
-- =====================================================

-- Añadir columnas para tracking detallado de feedback
ALTER TABLE programa_feedback ADD COLUMN IF NOT EXISTS sesion_numero INTEGER;
ALTER TABLE programa_feedback ADD COLUMN IF NOT EXISTS completitud VARCHAR(50);
ALTER TABLE programa_feedback ADD COLUMN IF NOT EXISTS razon_no_completar VARCHAR(100);

-- Constraint único para evitar duplicados de feedback
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'unique_feedback_sesion'
  ) THEN
    ALTER TABLE programa_feedback
    ADD CONSTRAINT unique_feedback_sesion
    UNIQUE (user_id, sesion_numero, semana, tipo_feedback);
  END IF;
END
$$;

-- =====================================================
-- TABLA: programa_sesiones
-- =====================================================

-- Hacer nullable las columnas de ejercicios (cardio no las usa)
ALTER TABLE programa_sesiones ALTER COLUMN calentamiento DROP NOT NULL;
ALTER TABLE programa_sesiones ALTER COLUMN trabajo_principal DROP NOT NULL;

-- Añadir columnas para sesiones generadas por IA
ALTER TABLE programa_sesiones ADD COLUMN IF NOT EXISTS tipo_actividad VARCHAR(50);
ALTER TABLE programa_sesiones ADD COLUMN IF NOT EXISTS calentamiento_texto TEXT;
ALTER TABLE programa_sesiones ADD COLUMN IF NOT EXISTS actividad_principal JSONB;
ALTER TABLE programa_sesiones ADD COLUMN IF NOT EXISTS senales_de_alerta TEXT[];
ALTER TABLE programa_sesiones ADD COLUMN IF NOT EXISTS consejos_seguridad TEXT[];
ALTER TABLE programa_sesiones ADD COLUMN IF NOT EXISTS progresion_sugerida TEXT;
ALTER TABLE programa_sesiones ADD COLUMN IF NOT EXISTS generada_por VARCHAR(50);
ALTER TABLE programa_sesiones ADD COLUMN IF NOT EXISTS completada BOOLEAN DEFAULT false;
ALTER TABLE programa_sesiones ADD COLUMN IF NOT EXISTS fecha_completada TIMESTAMP;
ALTER TABLE programa_sesiones ADD COLUMN IF NOT EXISTS introduccion_personalizada TEXT;

-- =====================================================
-- TABLA: programa_envios
-- =====================================================

-- Crear tabla si no existe
CREATE TABLE IF NOT EXISTS programa_envios (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    sesion_id INTEGER,
    brevo_message_id VARCHAR(255),
    estado VARCHAR(50) DEFAULT 'enviado',
    fecha_envio TIMESTAMP DEFAULT NOW(),
    fecha_apertura TIMESTAMP,
    fecha_click TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Añadir columna sesion_id si falta (tablas antiguas tenían contenido_id)
ALTER TABLE programa_envios ADD COLUMN IF NOT EXISTS sesion_id INTEGER;

-- =====================================================
-- FUNCIÓN: registrar_envio
-- =====================================================

CREATE OR REPLACE FUNCTION public.registrar_envio(
    p_user_id integer,
    p_sesion_id integer DEFAULT NULL::integer
)
RETURNS TABLE(
    envio_id integer,
    user_id integer,
    sesion_id integer,
    estado character varying,
    envios_totales integer,
    fecha_envio timestamp without time zone
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_envio_id INTEGER;
  v_estado VARCHAR;
  v_fecha_envio TIMESTAMP;
  v_envios_totales INTEGER;
BEGIN
  INSERT INTO programa_envios (user_id, sesion_id, estado, fecha_envio)
  VALUES (p_user_id, p_sesion_id, 'enviado', NOW())
  RETURNING id, programa_envios.estado, programa_envios.fecha_envio
  INTO v_envio_id, v_estado, v_fecha_envio;

  UPDATE programa_users
  SET
    fecha_ultimo_envio = NOW(),
    envios_totales = COALESCE(programa_users.envios_totales, 0) + 1
  WHERE programa_users.id = p_user_id
  RETURNING programa_users.envios_totales INTO v_envios_totales;

  RETURN QUERY SELECT
    v_envio_id,
    p_user_id,
    p_sesion_id,
    v_estado,
    v_envios_totales,
    v_fecha_envio;
END;
$$;

-- =====================================================
-- VERIFICACIÓN
-- =====================================================

SELECT 'Migration 001 completada' as status;
