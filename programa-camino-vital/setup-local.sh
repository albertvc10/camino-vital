#!/bin/bash

##############################################################################
# Setup de Entorno Local para Camino Vital
#
# Este script configura el schema de Camino Vital en tu n8n local existente
# SIN afectar los workflows de Instagram que ya tienes funcionando.
##############################################################################

set -e  # Terminar si hay algún error

echo "🚀 Configurando entorno local para Camino Vital..."
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar que estamos en la carpeta correcta
if [ ! -f "../docker-compose.yml" ]; then
    echo -e "${RED}❌ Error: No se encuentra docker-compose.yml en ~/Documents/HV_n8n${NC}"
    echo "Ejecuta este script desde: ~/Documents/HV_n8n/programa-camino-vital/"
    exit 1
fi

# Verificar que PostgreSQL está corriendo
echo "📦 Verificando que n8n local está corriendo..."
if ! docker ps | grep -q n8n_postgres; then
    echo -e "${YELLOW}⚠️  n8n local no está corriendo. Iniciando...${NC}"
    cd ..
    docker-compose up -d
    echo "⏳ Esperando 10 segundos a que PostgreSQL inicie..."
    sleep 10
    cd programa-camino-vital
else
    echo -e "${GREEN}✅ n8n local está corriendo${NC}"
fi

# Crear schema camino_vital
echo ""
echo "📊 Creando schema 'camino_vital' en PostgreSQL local..."
docker exec -i n8n_postgres psql -U n8n -d n8n << 'EOF'
-- Crear schema si no existe
CREATE SCHEMA IF NOT EXISTS camino_vital;

-- Mensaje de confirmación
\echo '✅ Schema camino_vital creado'
EOF

# Crear tablas
echo ""
echo "🗄️  Creando tablas en schema camino_vital..."
docker exec -i n8n_postgres psql -U n8n -d n8n << 'EOF'
SET search_path TO camino_vital;

-- Tabla: programa_users
CREATE TABLE IF NOT EXISTS programa_users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nombre VARCHAR(255),

    -- Programa
    etapa VARCHAR(50) DEFAULT 'base_vital',
    nivel_actual VARCHAR(50) DEFAULT 'iniciacion',
    semana_actual INTEGER DEFAULT 1,

    -- Estado
    estado VARCHAR(50) DEFAULT 'activo',
    fecha_inicio TIMESTAMP,
    fecha_ultimo_envio TIMESTAMP,
    fecha_ultima_respuesta TIMESTAMP,

    -- Configuración personalizada
    dias_preferidos_envio JSONB DEFAULT NULL,
    hora_preferida_envio TIME DEFAULT '09:00:00',
    timezone VARCHAR(50) DEFAULT 'Europe/Madrid',

    -- Perfil del cuestionario
    perfil_inicial JSONB,

    -- Tracking
    envios_totales INTEGER DEFAULT 0,
    respuestas_totales INTEGER DEFAULT 0,
    tasa_respuesta DECIMAL(5,2),

    -- Pago
    stripe_customer_id VARCHAR(255),
    fecha_pago TIMESTAMP,
    monto_pagado DECIMAL(10,2),

    -- Sistema
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabla: programa_contenido
CREATE TABLE IF NOT EXISTS programa_contenido (
    id SERIAL PRIMARY KEY,
    etapa VARCHAR(50) NOT NULL,
    nivel VARCHAR(50) NOT NULL,
    semana INTEGER NOT NULL,

    titulo VARCHAR(255),
    descripcion TEXT,
    contenido_ejercicios JSONB,
    duracion_estimada INTEGER,
    enfoque VARCHAR(100),

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    UNIQUE(etapa, nivel, semana)
);

-- Tabla: programa_feedback
CREATE TABLE IF NOT EXISTS programa_feedback (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES camino_vital.programa_users(id),

    semana INTEGER NOT NULL,
    etapa VARCHAR(50) NOT NULL,
    nivel VARCHAR(50) NOT NULL,

    tipo_feedback VARCHAR(50),
    respuesta VARCHAR(50),
    respuesta_extendida TEXT,

    accion_tomada VARCHAR(50),

    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla: programa_envios
CREATE TABLE IF NOT EXISTS programa_envios (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES camino_vital.programa_users(id),
    contenido_id INTEGER REFERENCES camino_vital.programa_contenido(id),

    brevo_message_id VARCHAR(255),
    estado VARCHAR(50) DEFAULT 'enviado',

    fecha_envio TIMESTAMP DEFAULT NOW(),
    fecha_apertura TIMESTAMP,
    fecha_click TIMESTAMP,

    created_at TIMESTAMP DEFAULT NOW()
);

\echo '✅ Tablas creadas correctamente'
EOF

# Insertar datos de prueba
echo ""
echo "🧪 Insertando datos de prueba..."
docker exec -i n8n_postgres psql -U n8n -d n8n << 'EOF'
SET search_path TO camino_vital;

-- Usuario de prueba 1: Lead
INSERT INTO programa_users (email, nombre, estado, nivel_actual, semana_actual, perfil_inicial)
VALUES (
    'test-lead@camino-vital.local',
    'Lead de Prueba',
    'lead',
    'iniciacion',
    1,
    '{"tiempo_sin_ejercicio": "1-2anos", "nivel_movilidad": "limitada", "objetivo_principal": "movilidad"}'::jsonb
)
ON CONFLICT (email) DO NOTHING;

-- Usuario de prueba 2: Activo
INSERT INTO programa_users (email, nombre, estado, nivel_actual, semana_actual, fecha_inicio, envios_totales, respuestas_totales, tasa_respuesta)
VALUES (
    'test-activo@camino-vital.local',
    'Usuario Activo Test',
    'activo',
    'iniciacion',
    2,
    NOW() - INTERVAL '1 week',
    3,
    2,
    66.67
)
ON CONFLICT (email) DO NOTHING;

-- Usuario de prueba 3: Intermedio
INSERT INTO programa_users (email, nombre, estado, nivel_actual, semana_actual, fecha_inicio)
VALUES (
    'test-intermedio@camino-vital.local',
    'Usuario Intermedio Test',
    'activo',
    'intermedio',
    1,
    NOW()
)
ON CONFLICT (email) DO NOTHING;

-- Contenido de ejemplo: Semana 1 Iniciación
INSERT INTO programa_contenido (etapa, nivel, semana, titulo, descripcion, contenido_ejercicios, duracion_estimada, enfoque)
VALUES (
    'base_vital',
    'iniciacion',
    1,
    'Semana 1: Despertando el Cuerpo',
    'Ejercicios suaves para reconectar con tu cuerpo',
    '{
        "ejercicios": [
            {
                "nombre": "Respiración diafragmática",
                "descripcion": "Ejercicio básico de respiración profunda",
                "repeticiones": "10 respiraciones lentas",
                "video_url": "[TEST-LOCAL]",
                "notas": "Hazlo sentado cómodamente"
            },
            {
                "nombre": "Movilidad de cuello",
                "descripcion": "Rotaciones suaves del cuello",
                "repeticiones": "5 veces cada lado",
                "video_url": "[TEST-LOCAL]",
                "notas": "Sin forzar, movimientos suaves"
            }
        ]
    }'::jsonb,
    15,
    'movilidad'
)
ON CONFLICT (etapa, nivel, semana) DO NOTHING;

-- Contenido de ejemplo: Semana 2 Iniciación
INSERT INTO programa_contenido (etapa, nivel, semana, titulo, descripcion, contenido_ejercicios, duracion_estimada, enfoque)
VALUES (
    'base_vital',
    'iniciacion',
    2,
    'Semana 2: Fortaleciendo la Base',
    'Añadimos ejercicios de estabilidad',
    '{
        "ejercicios": [
            {
                "nombre": "Sentadillas asistidas",
                "descripcion": "Con apoyo de silla",
                "repeticiones": "8-10 repeticiones",
                "video_url": "[TEST-LOCAL]",
                "notas": "Usa la silla solo si lo necesitas"
            }
        ]
    }'::jsonb,
    20,
    'fuerza'
)
ON CONFLICT (etapa, nivel, semana) DO NOTHING;

\echo '✅ Datos de prueba insertados'
EOF

# Verificar instalación
echo ""
echo "🔍 Verificando instalación..."
docker exec -i n8n_postgres psql -U n8n -d n8n << 'EOF'
SET search_path TO camino_vital;

\echo ''
\echo '📊 Tablas creadas:'
\dt

\echo ''
\echo '👥 Usuarios de prueba:'
SELECT id, email, nombre, estado, nivel_actual, semana_actual FROM programa_users;

\echo ''
\echo '📚 Contenido disponible:'
SELECT id, etapa, nivel, semana, titulo FROM programa_contenido;
EOF

# Resumen final
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Setup completado exitosamente!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "📝 Próximos pasos:"
echo ""
echo "1. Abrir n8n local:"
echo -e "   ${YELLOW}open http://localhost:5678${NC}"
echo ""
echo "2. Importar workflows de Camino Vital:"
echo "   - Ir a Workflows → Import from File"
echo "   - Seleccionar workflows desde: ~/Documents/HV_n8n/programa-camino-vital/workflows/"
echo "   - RENOMBRAR con prefijo [TEST-CV] para distinguirlos"
echo ""
echo "3. Configurar credenciales PostgreSQL en workflows:"
echo "   - Crear nueva credencial: 'PostgreSQL Camino Vital Local'"
echo "   - Host: postgres"
echo "   - Port: 5432"
echo "   - Database: n8n"
echo "   - User: n8n"
echo "   - Password: (ver archivo ~/Documents/HV_n8n/.env)"
echo "   - Schema: camino_vital"
echo ""
echo "4. Modificar queries en workflows para usar schema:"
echo -e "   ${YELLOW}SELECT * FROM camino_vital.programa_users${NC}"
echo ""
echo "5. Conectar a DB para verificar:"
echo -e "   ${YELLOW}docker exec -it n8n_postgres psql -U n8n -d n8n${NC}"
echo -e "   ${YELLOW}SET search_path TO camino_vital;${NC}"
echo ""
echo -e "${GREEN}¡Listo para desarrollar! 🚀${NC}"
echo ""
