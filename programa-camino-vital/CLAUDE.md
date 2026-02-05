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
| Caddyfile | `/root/n8n/Caddyfile` |
| Docker n8n | Container `n8n` |
| Docker PostgreSQL | Container `n8n_postgres` |
| Docker Caddy | Container `caddy` |
| DB User | `n8n_admin` |
| DB Name | `n8n` |

---

## Tipos de Cambio y Cómo Desplegarlos

| Tipo de cambio | Flujo |
|---|---|
| HTML/CSS/JS (landings) | local → git push → servidor: `deploy-production.sh` (se ve al instante) |
| Workflows n8n | Editar JSON local → git push → servidor: `deploy-production.sh` (reemplaza credentials automáticamente) |
| Templates email (BD) | SQL directo en BD del servidor |
| Variables de entorno | Editar `.env` en servidor → `docker compose down n8n && docker compose up -d n8n` |
| **Esquema BD (migraciones)** | Crear SQL en `migrations/` → git push → aplicar en servidor (ver sección Migraciones) |

---

## Sistema de Migraciones de Base de Datos (OBLIGATORIO)

### Por qué es necesario
Los esquemas de local y producción pueden desincronizarse. Las migraciones aseguran que ambos entornos tengan la misma estructura de BD.

### Ubicación
```
migrations/
├── README.md                      # Documentación del sistema
├── 001_initial_schema_sync.sql    # Primera migración
├── 002_xxx.sql                    # Futuras migraciones
└── ...
```

### Cuándo crear una migración

**SIEMPRE que hagas cambios de esquema en local:**
- `ALTER TABLE` (añadir/modificar columnas)
- `CREATE TABLE` (nuevas tablas)
- `CREATE INDEX` (nuevos índices)
- `CREATE FUNCTION` (nuevas funciones)
- Cambios en constraints

### Cómo crear una migración

1. Crear archivo con número secuencial:
   ```
   migrations/NNN_descripcion_breve.sql
   ```

2. Usar sentencias idempotentes:
   ```sql
   -- ✅ Correcto - se puede ejecutar múltiples veces
   ALTER TABLE programa_users ADD COLUMN IF NOT EXISTS nuevo_campo VARCHAR(50);

   -- ❌ Incorrecto - falla si ya existe
   ALTER TABLE programa_users ADD COLUMN nuevo_campo VARCHAR(50);
   ```

3. Incluir comentarios con fecha y descripción

### Flujo de deploy con migraciones

```
1. Cambiar esquema en LOCAL
2. Probar que funciona en LOCAL
3. Crear archivo SQL en migrations/
4. git add . && git commit && git push
5. SSH al servidor
6. Aplicar migración:
   scp migrations/NNN_xxx.sql root@164.90.222.166:/tmp/
   ssh root@164.90.222.166 "docker exec -i n8n_postgres psql -U n8n_admin -d n8n < /tmp/NNN_xxx.sql"
7. Ejecutar deploy-production.sh (para workflows)
8. Reiniciar n8n si es necesario:
   docker restart n8n
```

### Comando rápido para aplicar migración
```bash
# Desde local
scp migrations/001_initial_schema_sync.sql root@164.90.222.166:/tmp/ && \
ssh root@164.90.222.166 "docker exec -i n8n_postgres psql -U n8n_admin -d n8n < /tmp/001_initial_schema_sync.sql"
```

### Reglas importantes
- **NUNCA** hacer cambios de esquema directamente en producción sin crear migración
- **SIEMPRE** usar `IF NOT EXISTS` / `IF EXISTS` para idempotencia
- **SIEMPRE** probar la migración en local antes de aplicar en producción
- Mantener `migrations/README.md` actualizado con las migraciones aplicadas

## Configuración de Redirección Landing (Preventa → Programa)

### Estado actual (hasta 1 de marzo 2026)
- `index.html` redirige automáticamente a `preventa.html`
- Para probar index.html sin redirección: añadir `?test=1` a la URL

### URLs
| URL | Comportamiento |
|-----|----------------|
| `camino-vital.habitos-vitales.com` | Redirige a preventa.html |
| `camino-vital.habitos-vitales.com?test=1` | Muestra index.html (testing) |
| `camino-vital.habitos-vitales.com/preventa.html` | Muestra preventa.html |

### Cómo funciona
En `index.html` hay un script al inicio del `<body>`:
```javascript
// REDIRECT TEMPORAL: Hasta 1 de marzo 2026
// Para probar index.html: añadir ?test=1 a la URL
if (!window.location.search.includes('test=1')) {
    window.location.href = 'preventa.html';
}
```

### Acción el 1 de marzo 2026
1. Eliminar el bloque de script de redirección de `index.html`
2. Commit + push + deploy
3. La landing principal pasa a ser index.html (programa a 89€)

---

## Estructura del Proyecto

```
landing/           → Páginas web (servidas por Caddy)
  index.html       → Landing principal (programa a 89€) - REDIRIGE a preventa hasta 1 marzo
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

## NUNCA Actualizar Workflows Directamente en BD

### Regla absoluta
**NUNCA** actualizar workflows directamente en la base de datos. **SIEMPRE** usar el flujo:

```
Local (editar JSON) → git push → Servidor (deploy-production.sh)
```

### Por qué
El script `deploy-production.sh` hace automáticamente:
1. Reemplaza credential IDs locales → producción
2. Reemplaza `process.env.*` y `$env.*` → valores reales
3. Verifica que no queden referencias incorrectas

Si bypaseas el script, los workflows fallan con errores como:
- "Credential with ID does not exist"
- "access to env vars denied"

### Patrón correcto en archivos locales

**En Code nodes:**
```javascript
// ✅ CORRECTO - El deploy script reemplaza esto
const webhookUrl = process.env.WEBHOOK_URL || 'http://localhost:5678';
const senderName = process.env.SENDER_NAME || 'Camino Vital';
```

**En expressions (HTTP Request, etc):**
```
// ✅ CORRECTO - El deploy script reemplaza esto
={{ $env.BREVO_API_KEY }}
={{ $env.WEBHOOK_URL }}/webhook/...
```

**Credential IDs:**
```json
// ✅ CORRECTO - Siempre usar ID local
"credentials": {
  "postgres": {
    "id": "nLcUOvLreXurFbBs",
    "name": "PostgreSQL local"
  }
}
```

### IDs de referencia
| Recurso | Local | Producción |
|---------|-------|------------|
| PostgreSQL credential | `nLcUOvLreXurFbBs` | `mb8piXWj8Fpb7MSV` |

---

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

---

## Contenido HTML en Templates de BD (OBLIGATORIO)

**Todo contenido HTML (emails, páginas intermedias) DEBE estar en la tabla `email_templates` de la base de datos.**

### Razones
- **Mantenibilidad**: Cambiar un email no requiere modificar el workflow
- **Consistencia**: Un solo lugar para todo el contenido visual
- **Reutilización**: El mismo template puede usarse en varios workflows
- **Separación**: Lógica (workflow) separada de presentación (template)

### Regla
- ❌ **NUNCA** hardcodear HTML en nodos de workflows (ni en `htmlContent`, ni en `jsCode`)
- ✅ **SIEMPRE** usar templates de `email_templates` con variables `{{nombre}}`, `{{user_id}}`, etc.

### Patrón correcto en workflows
```
1. Obtener template de BD → SELECT html_template FROM email_templates WHERE nombre = '...'
2. Renderizar variables   → Nodo Code que reemplaza {{variable}} por valores reales
3. Enviar email          → Usar el HTML renderizado
```

### Templates existentes (referencia)
| Nombre | Uso |
|--------|-----|
| `email_bienvenida` | Email cuando se activa el programa (pago 89€ o activación preventa) |
| `email_plaza_reservada` | Email confirmación preventa (39€) |
| `email_primera_sesion` | Primera sesión después de seleccionar cantidad |
| `email_sesion_siguiente` | Sesiones posteriores a la primera |
| `email_checkpoint_nueva_semana` | Primera sesión de nueva semana tras checkpoint |
| `pagina_*` | Páginas intermedias (feedback, confirmaciones, etc.) |

---

## Borrar Usuario de la Base de Datos

Cuando necesites borrar un usuario para hacer pruebas, hay que borrar de **3 tablas** debido a claves foráneas y tracking de idempotencia:

### Comando completo (LOCAL)
```bash
psql -U albert -d n8n -c "
DELETE FROM programa_sesiones WHERE user_id IN (SELECT id FROM programa_users WHERE email = 'EMAIL_AQUI');
DELETE FROM stripe_events_processed WHERE email = 'EMAIL_AQUI';
DELETE FROM programa_users WHERE email = 'EMAIL_AQUI';
"
```

### Comando completo (PRODUCCIÓN)
```bash
docker exec n8n_postgres psql -U n8n_admin -d n8n -c "
DELETE FROM programa_sesiones WHERE user_id IN (SELECT id FROM programa_users WHERE email = 'EMAIL_AQUI');
DELETE FROM stripe_events_processed WHERE email = 'EMAIL_AQUI';
DELETE FROM programa_users WHERE email = 'EMAIL_AQUI';
"
```

### Por qué 3 tablas

| Tabla | Razón |
|-------|-------|
| `programa_sesiones` | Foreign key a `programa_users.id`. Si no borras primero las sesiones, el DELETE del usuario falla |
| `stripe_events_processed` | Guarda los `checkout_session_id` ya procesados para evitar duplicados. Si no la borras, al rehacer el pago con el mismo usuario Stripe piensa que ya procesó el evento y no activa el workflow de onboarding |
| `programa_users` | Tabla principal del usuario |

### Orden importante
1. Primero `programa_sesiones` (tiene FK a users)
2. Luego `stripe_events_processed` (referencia email)
3. Finalmente `programa_users`

### Ejemplo práctico
```bash
# LOCAL - borrar usuario de prueba
psql -U albert -d n8n -c "
DELETE FROM programa_sesiones WHERE user_id IN (SELECT id FROM programa_users WHERE email = 'albertvc10@gmail.com');
DELETE FROM stripe_events_processed WHERE email = 'albertvc10@gmail.com';
DELETE FROM programa_users WHERE email = 'albertvc10@gmail.com';
"
```

---

## Troubleshooting: Error "Connection lost" en n8n UI

### Síntomas
- Al abrir un workflow en la UI de n8n aparece "Connection lost to server"
- No se puede ejecutar manualmente ningún workflow
- Los webhooks funcionan pero la UI no responde

### Causa
Caddy no está configurado correctamente para pasar conexiones WebSocket a n8n. La UI de n8n usa WebSockets para comunicación en tiempo real.

### Solución
Configurar Caddy con un matcher explícito para WebSockets. El Caddyfile debe tener esta estructura:

```
n8n.habitos-vitales.com {
    @websockets {
        header Connection *Upgrade*
        header Upgrade websocket
    }

    reverse_proxy @websockets n8n:5678 {
        header_up Connection {http.request.header.Connection}
        header_up Upgrade {http.request.header.Upgrade}
    }

    reverse_proxy n8n:5678
}
```

### Cómo aplicar
```bash
# SSH al servidor
ssh root@164.90.222.166

# Editar Caddyfile
nano /root/n8n/Caddyfile

# Reiniciar Caddy
docker restart caddy
```

### Por qué funciona
- El matcher `@websockets` detecta requests con headers de WebSocket
- Las conexiones WebSocket se pasan con los headers `Connection` y `Upgrade` intactos
- Las conexiones HTTP normales van por el segundo `reverse_proxy` sin modificación

### Nota adicional
El error `ValidationError: The 'X-Forwarded-For' header is set but the Express 'trust proxy' setting is false` que aparece en los logs de n8n es un warning, **no causa el problema de Connection lost**. Puedes ignorarlo si los WebSockets funcionan.
