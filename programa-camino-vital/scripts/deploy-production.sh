#!/bin/bash
# ============================================
# DEPLOY A PRODUCCIÓN - Camino Vital
# ============================================
# Ejecutar desde el servidor: bash /root/camino-vital/programa-camino-vital/scripts/deploy-production.sh
#
# Este script:
# 1. Hace git pull
# 2. Reemplaza credential IDs locales por los de producción en n8n
# 3. Reemplaza API keys hardcodeadas por $env references
# 4. Verifica que todo esté correcto

set -e

echo "=========================================="
echo "  DEPLOY PRODUCCIÓN - Camino Vital"
echo "=========================================="

# Configuración
REPO_DIR="/root/camino-vital/programa-camino-vital"
DB_USER="n8n_admin"
DB_NAME="n8n"
DB_CONTAINER="n8n_postgres"

# IDs de credenciales
LOCAL_CRED_ID="nLcUOvLreXurFbBs"
LOCAL_CRED_ID_OLD="postgres-local"
PROD_CRED_ID="mb8piXWj8Fpb7MSV"

echo ""
echo ">> Paso 1: Git pull"
cd "$REPO_DIR"
git pull
echo "   OK"

echo ""
echo ">> Paso 2: Reemplazar credential IDs locales → producción"

# Reemplazar ID local principal
UPDATED=$(docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "
UPDATE workflow_entity
SET nodes = REPLACE(nodes::text, '$LOCAL_CRED_ID', '$PROD_CRED_ID')::jsonb
WHERE nodes::text LIKE '%$LOCAL_CRED_ID%'
RETURNING name;
")

if [ -z "$(echo "$UPDATED" | xargs)" ]; then
    echo "   No había workflows con ID local ($LOCAL_CRED_ID)"
else
    echo "   Actualizados:"
    echo "$UPDATED" | sed 's/^/     /'
fi

# Reemplazar ID local antiguo
UPDATED_OLD=$(docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "
UPDATE workflow_entity
SET nodes = REPLACE(nodes::text, '$LOCAL_CRED_ID_OLD', '$PROD_CRED_ID')::jsonb
WHERE nodes::text LIKE '%$LOCAL_CRED_ID_OLD%'
RETURNING name;
")

if [ -z "$(echo "$UPDATED_OLD" | xargs)" ]; then
    echo "   No había workflows con ID antiguo ($LOCAL_CRED_ID_OLD)"
else
    echo "   Actualizados (ID antiguo):"
    echo "$UPDATED_OLD" | sed 's/^/     /'
fi

echo ""
echo ">> Paso 3: Verificar API keys de Brevo no hardcodeadas"

HARDCODED=$(docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "
SELECT name FROM workflow_entity
WHERE nodes::text LIKE '%xkeysib-%'
  AND nodes::text NOT LIKE '%env.BREVO_API_KEY%';
")

if [ -z "$(echo "$HARDCODED" | xargs)" ]; then
    echo "   OK - Todas las API keys usan \$env.BREVO_API_KEY"
else
    echo "   AVISO: Estos workflows tienen API keys hardcodeadas:"
    echo "$HARDCODED" | sed 's/^/     /'
    echo "   Corrigiendo..."
    docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
    UPDATE workflow_entity
    SET nodes = regexp_replace(nodes::text, 'xkeysib-[a-f0-9]+-[a-zA-Z0-9]+', '={{\$env.BREVO_API_KEY}}', 'g')::jsonb
    WHERE nodes::text LIKE '%xkeysib-%'
      AND nodes::text NOT LIKE '%env.BREVO_API_KEY%';
    "
    echo "   Corregido"
fi

echo ""
echo ">> Paso 4: Verificación final"

ERRORS=0

# Check credential IDs
REMAINING=$(docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "
SELECT count(*) FROM workflow_entity
WHERE nodes::text LIKE '%$LOCAL_CRED_ID%'
   OR nodes::text LIKE '%$LOCAL_CRED_ID_OLD%';
")
REMAINING=$(echo "$REMAINING" | xargs)
if [ "$REMAINING" != "0" ]; then
    echo "   ERROR: Quedan $REMAINING workflows con credential IDs locales"
    ERRORS=1
else
    echo "   OK - Credential IDs correctos"
fi

# Check Brevo keys
REMAINING_BREVO=$(docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "
SELECT count(*) FROM workflow_entity
WHERE nodes::text LIKE '%xkeysib-%'
  AND nodes::text NOT LIKE '%env.BREVO_API_KEY%';
")
REMAINING_BREVO=$(echo "$REMAINING_BREVO" | xargs)
if [ "$REMAINING_BREVO" != "0" ]; then
    echo "   ERROR: Quedan $REMAINING_BREVO workflows con API keys hardcodeadas"
    ERRORS=1
else
    echo "   OK - API keys Brevo correctas"
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo "=========================================="
    echo "  DEPLOY COMPLETADO CORRECTAMENTE"
    echo "=========================================="
else
    echo "=========================================="
    echo "  DEPLOY CON ERRORES - REVISAR"
    echo "=========================================="
    exit 1
fi
