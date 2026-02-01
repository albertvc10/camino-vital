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

---

## Verificación de Texto en Español (OBLIGATORIO)

Antes de commitear cambios en archivos con texto visible al usuario, verificar:

### Checklist ortográfico
- [ ] **Tildes correctas** - á, é, í, ó, ú (especialmente en: qué, cómo, cuándo, más, después, también, día, información)
- [ ] **Eñes** - ñ en palabras como: año, español, diseño, pequeño, señal, niño, compañía
- [ ] **Signos de apertura** - ¿pregunta? y ¡exclamación! (no solo al final)
- [ ] **Sin anglicismos innecesarios** - usar términos en español cuando existan

### Palabras frecuentes con tilde (referencia rápida)
```
qué, cómo, cuándo, dónde, por qué    (interrogativos)
más, además, después, también         (adverbios)
día, días, todavía, energía           (palabras con -ía)
información, sesión, acción           (palabras con -ión)
fácil, difícil, útil                  (palabras con -il)
está, estás, están                    (verbo estar)
será, serás, podrá, tendrá            (futuros)
```

### Archivos que requieren esta verificación
- `landing/*.html` - Páginas web
- `templates/*.html` - Templates de email
- `email_templates` en BD - Contenido de emails
- Cualquier texto que vea el usuario final

### Qué NO revisar (excluir del checklist)
- URLs y enlaces (`https://...`)
- Código JavaScript/CSS
- Atributos HTML (`class`, `id`, `data-*`)
- Variables y placeholders (`{{nombre}}`, `$json.email`)
- Nombres de archivo (`config.js`, `index.html`)

### Audiencia objetivo
El público es **60-70 años**. Los errores ortográficos generan desconfianza.
Revisar siempre antes de commitear.

---

## Sistema de Validación de Cambios en Workflows (OBLIGATORIO)

### Antes de modificar CUALQUIER workflow o tabla de BD:

**PASO 1: Leer el mapa de dependencias**
```
Leer: docs/WORKFLOW-DEPENDENCIES.md
```

**PASO 2: Identificar recursos afectados**

Preguntarse:
- ¿Qué tablas de BD voy a modificar?
- ¿Qué campos estoy añadiendo/cambiando/eliminando?
- ¿Qué webhooks/endpoints estoy tocando?
- ¿Qué funciones PostgreSQL uso?

**PASO 3: Listar workflows impactados**

Consultar las secciones relevantes del mapa de dependencias:
- Si toco `programa_users` → revisar workflows 00, 01, 03, 04, 05, 06, 07, 09, Generador
- Si toco `programa_sesiones` → revisar workflows 03, 07, 09, Generador
- Si toco `email_templates` → revisar workflows 06, 07, 09
- Si toco funciones PostgreSQL → revisar workflows que las llaman

**PASO 4: Verificar compatibilidad**

Para cada workflow impactado:
- [ ] ¿Los campos que uso siguen existiendo?
- [ ] ¿Los tipos de datos son compatibles?
- [ ] ¿Las queries SQL siguen funcionando?
- [ ] ¿Los webhooks mantienen el mismo contrato de entrada/salida?

**PASO 5: Probar flujos críticos**

Después de cualquier cambio, probar SIEMPRE estos flujos en local:

1. **Flujo Onboarding**:
   - Landing → 04-guardar-lead → 01-bis-onboarding → Generador → email

2. **Flujo Feedback**:
   - 03-bis-feedback → ajuste intensidad → siguiente sesión

3. **Flujo Checkpoint**:
   - 06-checkpoint → 07-procesar → nueva semana

### Checklist Rápido de Impacto

```
┌─────────────────────────────────────────────────────────────────┐
│  CAMBIO EN                    │  REVISAR WORKFLOWS              │
├─────────────────────────────────────────────────────────────────┤
│  programa_users               │  TODOS (00-09, Generador, UTIL) │
│  programa_users.estado        │  00, 01, 05, 06, 07             │
│  programa_users.nivel_actual  │  01, 03, 06, 07, 09, Generador  │
│  programa_users.intensidad    │  03, 06, 07, Generador          │
│  programa_users.semana_actual │  06, 07, Generador              │
│  programa_sesiones            │  03, 07, 09, Generador          │
│  programa_feedback            │  03, 06, 07                     │
│  ejercicios_biblioteca        │  08, 09, Generador              │
│  email_templates              │  06, 07, 09                     │
│  Función analizar_semana_*    │  06, 07                         │
│  Función procesar_checkpoint* │  07                             │
│  Función procesar_feedback*   │  03                             │
│  Webhook /generar-sesion-ia   │  01, 03, 07 (todos lo llaman)   │
│  Webhook /util/enviar-email   │  03, 06, 07 (todos lo llaman)   │
└─────────────────────────────────────────────────────────────────┘
```

### Cambios de Alto Riesgo (requieren revisión exhaustiva)

⚠️ **ALTO RIESGO - Probar TODO antes de deploy:**
- Cambios en `programa_users` (tabla central)
- Cambios en funciones PostgreSQL `analizar_semana_*` o `procesar_checkpoint_*`
- Cambios en el Generador Sesion IA (afecta 3 workflows)
- Cambios en UTIL-enviar-email (afecta 3 workflows)
- Cambios en estructura de `email_templates`

⚠️ **NUNCA hacer estos cambios sin backup:**
- Eliminar columnas de `programa_users`
- Cambiar nombres de campos usados en queries
- Modificar el contrato de webhooks (parámetros entrada/salida)
- Eliminar templates de email activos

### Ejemplo de Análisis de Impacto

```
TAREA: Añadir campo "telefono" a programa_users

1. LEER docs/WORKFLOW-DEPENDENCIES.md ✓

2. RECURSOS AFECTADOS:
   - Tabla: programa_users
   - Campo nuevo: telefono (nullable)

3. WORKFLOWS IMPACTADOS:
   - Ninguno actualmente usa "telefono"
   - Si quiero guardarlo: modificar 04-guardar-lead

4. VERIFICACIÓN:
   - ALTER TABLE es compatible (campo nullable)
   - No rompe queries existentes
   - Webhooks no cambian

5. PLAN:
   a) ALTER TABLE programa_users ADD COLUMN telefono VARCHAR(20);
   b) Modificar 04-guardar-lead para capturar telefono
   c) Probar flujo de cuestionario completo
   d) Deploy
```

### Regla de Oro

> **Antes de tocar un workflow, SIEMPRE preguntarse:**
> "¿Qué otros workflows dependen de esto que voy a cambiar?"
>
> Si no lo sabes, consulta `docs/WORKFLOW-DEPENDENCIES.md`
