-- ============================================
-- CAMINO VITAL - Database Schema
-- ============================================

-- Tabla principal de usuarios del programa
CREATE TABLE IF NOT EXISTS programa_users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    nombre VARCHAR(255),

    -- Control de programa
    etapa VARCHAR(50) DEFAULT 'base_vital', -- base_vital, fuerza_vital, autonomia_vital
    nivel_actual VARCHAR(50) DEFAULT 'iniciacion', -- iniciacion, intermedio, avanzado
    semana_actual INTEGER DEFAULT 1,

    -- Estado
    estado VARCHAR(50) DEFAULT 'activo', -- activo, pausado, completado, cancelado
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_ultimo_envio TIMESTAMP,
    fecha_ultima_respuesta TIMESTAMP,

    -- Configuración personalizada
    dias_preferidos_envio JSONB DEFAULT '["lunes", "miercoles", "viernes"]',
    hora_preferida_envio TIME DEFAULT '09:00:00',

    -- Perfil inicial (del cuestionario)
    perfil_inicial JSONB, -- {tiempo_sin_ejercicio, limitaciones, objetivos, etc}

    -- Tracking
    envios_totales INTEGER DEFAULT 0,
    respuestas_totales INTEGER DEFAULT 0,
    tasa_respuesta DECIMAL(5,2),

    -- Pago
    stripe_customer_id VARCHAR(255),
    fecha_pago TIMESTAMP,
    monto_pagado DECIMAL(10,2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de historial de feedback
CREATE TABLE IF NOT EXISTS programa_feedback (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES programa_users(id) ON DELETE CASCADE,

    -- Contexto
    semana INTEGER NOT NULL,
    etapa VARCHAR(50) NOT NULL,
    nivel VARCHAR(50) NOT NULL,

    -- Feedback
    tipo_feedback VARCHAR(50), -- dificultad, progreso, satisfaccion
    respuesta VARCHAR(50), -- facil, adecuado, dificil
    respuesta_extendida TEXT, -- si el usuario escribió algo

    -- Resultado
    accion_tomada VARCHAR(50), -- mantener, continuar, acelerar, retroceder

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de contenido (biblioteca de ejercicios/emails)
CREATE TABLE IF NOT EXISTS programa_contenido (
    id SERIAL PRIMARY KEY,

    -- Identificación
    etapa VARCHAR(50) NOT NULL, -- base_vital, fuerza_vital, autonomia_vital
    nivel VARCHAR(50) NOT NULL, -- iniciacion, intermedio, avanzado
    semana INTEGER NOT NULL,

    -- Contenido
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    contenido_ejercicios JSONB, -- array de ejercicios con videos, repeticiones, etc

    -- Template Brevo
    brevo_template_id INTEGER,

    -- Metadatos
    duracion_estimada INTEGER, -- minutos
    enfoque VARCHAR(100), -- movilidad, fuerza, resistencia, equilibrio

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(etapa, nivel, semana)
);

-- Tabla de log de envíos
CREATE TABLE IF NOT EXISTS programa_envios (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES programa_users(id) ON DELETE CASCADE,

    -- Detalles del envío
    contenido_id INTEGER REFERENCES programa_contenido(id),
    brevo_message_id VARCHAR(255),

    -- Estado
    estado VARCHAR(50) DEFAULT 'enviado', -- enviado, abierto, clickeado, respondido
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_apertura TIMESTAMP,
    fecha_click TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para optimización
CREATE INDEX idx_programa_users_email ON programa_users(email);
CREATE INDEX idx_programa_users_estado ON programa_users(estado);
CREATE INDEX idx_programa_users_etapa_nivel ON programa_users(etapa, nivel_actual);
CREATE INDEX idx_programa_feedback_user_id ON programa_feedback(user_id);
CREATE INDEX idx_programa_envios_user_id ON programa_envios(user_id);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar updated_at
CREATE TRIGGER update_programa_users_updated_at BEFORE UPDATE ON programa_users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_programa_contenido_updated_at BEFORE UPDATE ON programa_contenido
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
