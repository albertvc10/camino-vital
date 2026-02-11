#!/bin/bash
# ============================================
# DEPLOY A PRODUCCIÓN - Camino Vital
# ============================================
# Ejecutar desde el servidor: bash /root/camino-vital/programa-camino-vital/scripts/deploy-production.sh
#
# Este script:
# 1. Hace git pull
# 2. Reemplaza credential IDs locales por los de producción
# 3. Reemplaza $env.* y process.env.* por valores reales de producción
#    (n8n 2.x bloquea acceso a $env y process.env en task runners)
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
PROD_ENV="/root/n8n/.env"

# IDs de credenciales
LOCAL_CRED_ID="nLcUOvLreXurFbBs"
LOCAL_CRED_ID_OLD="postgres-local"
PROD_CRED_ID="mb8piXWj8Fpb7MSV"

# IDs de workflows (para Execute Workflow nodes)
LOCAL_WF_01A="jOAMKOPOez9lOK0r"
PROD_WF_01A="91AOC0TOGBkijdGV"
LOCAL_WF_01B="dq6hrmEPgNoHjuxt"
PROD_WF_01B="VR27PpYFMXzYP5Vo"

# Valores de producción (leídos de .env)
BREVO_API_KEY=$(grep '^BREVO_API_KEY=' $PROD_ENV | cut -d'=' -f2)
BREVO_LIST_LEADS=$(grep '^BREVO_LIST_LEADS=' $PROD_ENV | cut -d'=' -f2)
BREVO_LIST_ACTIVO=$(grep '^BREVO_LIST_ACTIVO=' $PROD_ENV | cut -d'=' -f2)
SENDER_EMAIL=$(grep '^SENDER_EMAIL=' $PROD_ENV | cut -d'=' -f2)
SENDER_NAME=$(grep '^SENDER_NAME=' $PROD_ENV | cut -d'=' -f2)
N8N_HOST=$(grep '^N8N_HOST=' $PROD_ENV | cut -d'=' -f2)
WEBHOOK_URL="https://$N8N_HOST"

echo "   Valores de producción cargados desde $PROD_ENV"

echo ""
echo ">> Paso 1: Git pull"
cd "$REPO_DIR"
git pull
echo "   OK"

# ---- Función helper para reemplazar en DB ----
replace_in_db() {
    local OLD="$1"
    local NEW="$2"
    local DESC="$3"

    RESULT=$(docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "
    UPDATE workflow_entity
    SET nodes = REPLACE(nodes::text, '$OLD', '$NEW')::jsonb
    WHERE nodes::text LIKE '%$(echo "$OLD" | sed "s/'/''/g")%'
    RETURNING name;
    " 2>/dev/null)

    if [ -z "$(echo "$RESULT" | xargs 2>/dev/null)" ]; then
        echo "   $DESC: -"
    else
        echo "   $DESC: $(echo "$RESULT" | xargs | tr '\n' ', ')"
    fi
}

echo ""
echo ">> Paso 2: Reemplazar credential IDs locales → producción"
replace_in_db "$LOCAL_CRED_ID" "$PROD_CRED_ID" "ID local ($LOCAL_CRED_ID)"
replace_in_db "$LOCAL_CRED_ID_OLD" "$PROD_CRED_ID" "ID antiguo ($LOCAL_CRED_ID_OLD)"

echo ""
echo ">> Paso 2b: Reemplazar workflow IDs (Execute Workflow nodes)"
replace_in_db "$LOCAL_WF_01A" "$PROD_WF_01A" "Workflow 01a Onboarding Programa"
replace_in_db "$LOCAL_WF_01B" "$PROD_WF_01B" "Workflow 01b Onboarding Preventa"

echo ""
echo ">> Paso 3: Reemplazar \$env y process.env → valores de producción"
echo "   (n8n 2.x no permite acceso a \$env desde workflows)"

# $env.BREVO_API_KEY (dos formatos: con y sin espacios)
replace_in_db '={{\$env.BREVO_API_KEY}}' "$BREVO_API_KEY" "BREVO_API_KEY (sin espacios)"
replace_in_db '={{ \$env.BREVO_API_KEY }}' "$BREVO_API_KEY" "BREVO_API_KEY (con espacios)"

# $env.BREVO_LIST_LEADS y BREVO_LIST_ACTIVO
replace_in_db '{{ \$env.BREVO_LIST_LEADS }}' "$BREVO_LIST_LEADS" "BREVO_LIST_LEADS"
replace_in_db '{{ \$env.BREVO_LIST_ACTIVO }}' "$BREVO_LIST_ACTIVO" "BREVO_LIST_ACTIVO"

# $env.WEBHOOK_URL (varios formatos)
replace_in_db '={{ \$env.WEBHOOK_URL }}' "$WEBHOOK_URL" "WEBHOOK_URL (expresión)"
replace_in_db '\$env.WEBHOOK_URL' "'$WEBHOOK_URL'" "WEBHOOK_URL (en Code node)"

# $env.SENDER_EMAIL y SENDER_NAME
replace_in_db '={{\$env.SENDER_EMAIL}}' "$SENDER_EMAIL" "SENDER_EMAIL"
replace_in_db '={{\$env.SENDER_NAME}}' "$SENDER_NAME" "SENDER_NAME"

# $env.N8N_HOST (en Code nodes)
replace_in_db '\$env.N8N_HOST' "'$N8N_HOST'" "N8N_HOST (Code node)"

# process.env.* (en Code nodes) - con y sin fallback
replace_in_db "process.env.WEBHOOK_URL" "'$WEBHOOK_URL'" "process.env.WEBHOOK_URL"
replace_in_db "process.env.SENDER_EMAIL" "'$SENDER_EMAIL'" "process.env.SENDER_EMAIL"
replace_in_db "process.env.SENDER_NAME" "'$SENDER_NAME'" "process.env.SENDER_NAME"

# Patrones con fallback || 'default' (común en Code nodes)
# process.env.SENDER_NAME || 'Camino Vital' → 'Valor Real'
replace_in_db "process.env.SENDER_NAME || 'Camino Vital'" "'$SENDER_NAME'" "SENDER_NAME con fallback"
replace_in_db "process.env.SENDER_EMAIL || 'hola@habitos-vitales.com'" "'$SENDER_EMAIL'" "SENDER_EMAIL con fallback"
replace_in_db "process.env.WEBHOOK_URL || 'http://localhost:5678'" "'$WEBHOOK_URL'" "WEBHOOK_URL con fallback localhost"
replace_in_db "process.env.WEBHOOK_URL || 'https://n8n.habitos-vitales.com'" "'$WEBHOOK_URL'" "WEBHOOK_URL con fallback prod"

# API keys hardcodeadas antiguas
HARDCODED=$(docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "
SELECT name FROM workflow_entity
WHERE nodes::text LIKE '%xkeysib-%'
  AND nodes::text NOT LIKE '%$BREVO_API_KEY%';
" 2>/dev/null)
if [ -n "$(echo "$HARDCODED" | xargs 2>/dev/null)" ]; then
    echo ""
    echo "   Reemplazando API keys antiguas hardcodeadas..."
    docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "
    UPDATE workflow_entity
    SET nodes = regexp_replace(nodes::text, 'xkeysib-[a-f0-9]+-[a-zA-Z0-9]+', '$BREVO_API_KEY', 'g')::jsonb
    WHERE nodes::text LIKE '%xkeysib-%'
      AND nodes::text NOT LIKE '%$BREVO_API_KEY%';
    " 2>/dev/null
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

# Check $env and process.env references
REMAINING_ENV=$(docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "
SELECT count(*) FROM workflow_entity
WHERE nodes::text LIKE '%\$env.%'
   OR nodes::text LIKE '%process.env.%';
")
REMAINING_ENV=$(echo "$REMAINING_ENV" | xargs)
if [ "$REMAINING_ENV" != "0" ]; then
    echo "   AVISO: Quedan $REMAINING_ENV workflows con referencias env:"
    docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -t -c "
    SELECT name FROM workflow_entity
    WHERE nodes::text LIKE '%\$env.%'
       OR nodes::text LIKE '%process.env.%';
    " | sed 's/^/     /'
else
    echo "   OK - No hay referencias \$env ni process.env"
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
