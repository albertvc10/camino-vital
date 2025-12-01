#!/bin/bash
set -e

# Script de inicialización de PostgreSQL
# Se ejecuta automáticamente la primera vez que arranca el contenedor

echo "🚀 Inicializando base de datos para n8n..."

# Crear el usuario no-root y darle permisos
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Crear extensiones útiles
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

    -- Dar permisos completos al usuario de n8n
    GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};

    -- Confirmar configuración
    SELECT 'Base de datos n8n configurada correctamente ✅' AS status;
EOSQL

echo "✅ Base de datos inicializada correctamente"
