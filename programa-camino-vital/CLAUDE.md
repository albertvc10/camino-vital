# Camino Vital - Instrucciones del Proyecto

## Flujo de Deployment (OBLIGATORIO)

Todos los cambios siguen este flujo:

```
LOCAL (editar) → GitHub (push) → Servidor (git pull)
```

### Paso a paso:
1. **Editar en LOCAL** - Esta máquina, en este directorio
2. **Probar en LOCAL** - Verificar que funciona en n8n local / localhost
3. **Commit + push** - `git add . && git commit -m "..." && git push`
4. **SSH al servidor** - `ssh root@164.90.222.166`
5. **Ejecutar script de deploy** - `bash /root/camino-vital/programa-camino-vital/scripts/deploy-production.sh`

El script de deploy automáticamente:
- Hace `git pull`
- Reemplaza credential IDs locales por los de producción
- Verifica que no haya API keys hardcodeadas
- Muestra resultado de verificación

### Reglas
- NUNCA editar archivos directamente en producción
- NUNCA hacer push sin antes verificar que los cambios son correctos en local
- NUNCA subir a servidor sin haber probado primero que los cambios funcionan bien en local (probar workflows en n8n local, verificar landing pages en localhost, etc.)
- Siempre seguir el flujo: local → probar en local → git → servidor
- Si un cambio afecta workflows: probar ejecución en n8n local antes de desplegar
- Si un cambio afecta landing pages: verificar en http://localhost visualmente antes de desplegar

## Servidor de Producción

| Recurso | Valor |
|---------|-------|
| IP | 164.90.222.166 |
| SSH | `ssh root@164.90.222.166` |
| Landing pages | https://camino-vital.habitos-vitales.com |
| n8n UI | https://n8n.habitos-vitales.com |
| Ruta landing en servidor | `/root/camino-vital/programa-camino-vital/landing/` |
| Ruta repo en servidor | `/root/camino-vital/programa-camino-vital/` |
| Docker n8n | Container `n8n` |
| Docker PostgreSQL | Container `n8n_postgres` |
| DB User | `n8n_admin` |
| DB Name | `n8n` |

## Tipos de Cambio y Cómo Desplegarlos

| Tipo de cambio | Flujo |
|---|---|
| HTML/CSS/JS (landings) | local → git push → servidor: `deploy-production.sh` (se ve al instante) |
| Workflows n8n | Editar JSON local → git push → servidor: `deploy-production.sh` (reemplaza credentials automáticamente) |
| Templates email (BD) | SQL directo en BD del servidor |
| Variables de entorno | Editar `.env` en servidor → `docker compose down n8n && docker compose up -d n8n` |

## Estructura del Proyecto

```
landing/           → Páginas web (servidas por Caddy)
  index.html       → Landing principal (programa a 89€)
  preventa.html    → Landing preventa (39€, sube a 89€ el 1 marzo)
  cuestionario.html → Cuestionario de evaluación
  resultados.html  → Resultados + pago programa normal
  resultados-preventa.html → Resultados + pago preventa
workflows/         → Workflows n8n (JSON exportados)
templates/         → Templates de email
database/          → Scripts SQL
docs/              → Documentación interna
```

## Precios Actuales

| Concepto | Precio |
|----------|--------|
| Programa normal (a partir del 1 marzo) | 89€ |
| Preventa (hasta 1 marzo) | 39€ |
| Stripe link preventa (PROD) | https://buy.stripe.com/9B6bJ0foEgv670Z6WZ2Ry00 |
| Stripe link normal (PROD) | https://buy.stripe.com/8x2eVc90gfr2clj3KN2Ry01 |
| Stripe link preventa (TEST) | https://buy.stripe.com/test_3cIcN471xdCzcjx4IreZ203 |
| Stripe link normal (TEST) | https://buy.stripe.com/test_fZubJ00D941Zabpej1eZ204 |

## Diferencias Local vs Producción en Workflows (IMPORTANTE)

### Limitación n8n 2.x: $env bloqueado
La producción usa n8n 2.x donde los task runners **bloquean acceso a `$env` y `process.env`**.
El local usa n8n 1.x donde `$env` funciona sin problemas.

**Solución:** Los JSON locales usan `$env.*` y `process.env.*`. El script de deploy
reemplaza automáticamente estas referencias por los valores reales de producción.

### Regla para JSON de workflows
- En local: usar `$env.BREVO_API_KEY`, `$env.WEBHOOK_URL`, etc. (funciona en n8n 1.x)
- En local: usar credential ID `nLcUOvLreXurFbBs`
- NUNCA hardcodear valores de producción en los JSON del repositorio
- Al desplegar: el script `deploy-production.sh` se encarga de todo automáticamente

### Qué reemplaza el script de deploy
| Local (en JSON) | Producción (inyectado por script) |
|---|---|
| `nLcUOvLreXurFbBs` | `mb8piXWj8Fpb7MSV` (credential ID) |
| `$env.BREVO_API_KEY` | Valor real desde `/root/n8n/.env` |
| `$env.BREVO_LIST_LEADS` | `14` |
| `$env.BREVO_LIST_ACTIVO` | `13` |
| `$env.WEBHOOK_URL` | `https://n8n.habitos-vitales.com` |
| `$env.SENDER_EMAIL` | `hola@habitos-vitales.com` |
| `$env.SENDER_NAME` | `Camino Vital` |
| `$env.N8N_HOST` | `n8n.habitos-vitales.com` |
| `process.env.*` | Valores equivalentes |

## Troubleshooting: Error "access to env vars denied" en n8n

### Causa
n8n 2.x bloquea el acceso a `$env` y `process.env` en los task runners. Este error aparece cuando un workflow tiene referencias como `={{$env.BREVO_API_KEY}}` o `{{ $env.BREVO_LIST_LEADS }}`.

### Cuándo ocurre
- Al importar/actualizar un workflow directamente en la BD (bypaseando el script de deploy)
- Si el script de deploy no reemplazó correctamente alguna referencia

### Solución rápida (SSH al servidor)
```bash
# 1. Ver qué workflows tienen referencias $env
docker exec n8n_postgres psql -U n8n_admin -d n8n -t -c "
SELECT name FROM workflow_entity
WHERE nodes::text LIKE '%\$env.%' OR nodes::text LIKE '%process.env.%';"

# 2. Obtener valores de producción y reemplazar
BREVO_API_KEY=$(grep '^BREVO_API_KEY=' /root/n8n/.env | cut -d'=' -f2)
BREVO_LIST_LEADS=$(grep '^BREVO_LIST_LEADS=' /root/n8n/.env | cut -d'=' -f2)

# 3. Reemplazar en el workflow específico (ej: workflow 04)
docker exec n8n_postgres psql -U n8n_admin -d n8n -c "
UPDATE workflow_entity
SET nodes = REPLACE(
    REPLACE(nodes::text,
        '={{\$env.BREVO_API_KEY}}', '$BREVO_API_KEY'),
    '{{ \$env.BREVO_LIST_LEADS }}', '$BREVO_LIST_LEADS')::jsonb
WHERE name LIKE '%04%Guardar Lead%';"

# 4. Reiniciar n8n
docker restart n8n
```

### Prevención
- Siempre usar el script `deploy-production.sh` para desplegar workflows
- Si actualizas un workflow directamente en BD, ejecutar después las queries de reemplazo del script

---

## Detección de Entorno

Las landing pages detectan automáticamente si están en local o producción:
```javascript
const isLocal = window.location.hostname === 'localhost' || ...
```
- Local → usa webhooks y Stripe en modo test
- Producción → usa webhooks y Stripe reales
