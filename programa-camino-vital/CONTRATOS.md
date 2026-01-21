# CONTRATOS - Especificaciones que DEBEN cumplirse

Este documento funciona como "unit tests" documentales. Cuando se modifica cualquier workflow o tabla, estas especificaciones DEBEN seguir cumpliéndose.

---

## Workflow 03-bis: Feedback y Siguiente Sesión

**Trigger:** Webhook `/webhook/feedback-sesion?user_id=X&sesion=Y&feedback=Z`

**Campos de entrada requeridos:**
- `user_id` (integer): ID del usuario
- `sesion` (integer): Número de sesión dentro de la semana (1-6)
- `feedback` (string): "facil", "apropiado", o "dificil"

**Flujo esperado:**
1. Obtener datos del usuario de `programa_users`
2. Registrar feedback en `programa_feedback`
3. Actualizar `programa_sesiones` marcando `completada = true`
4. Actualizar `programa_users`:
   - `sesiones_completadas_semana += 1`
   - `sesion_actual_dentro_semana += 1`
5. Evaluar si quedan más sesiones en la semana
6. Si quedan: generar siguiente sesión y enviar email
7. Si no quedan: enviar email de semana completada

**Nodos críticos que DEBEN devolver datos:**
- `Actualizar Progreso Usuario`: DEBE usar `RETURNING *`
- `Actualizar Feedback (Enviado)`: DEBE usar `RETURNING *`
- `Actualizar Feedback (Completado)`: DEBE usar `RETURNING *`

**REGLA CRÍTICA:** Todos los UPDATE en PostgreSQL DEBEN tener `RETURNING *` para que n8n continúe el flujo.

---

## Workflow 06: Checkpoint Dominical

**Trigger:** Cron cada domingo a las 18:00

**Funcionalidad:**
1. Obtener usuarios activos que completaron todas las sesiones de la semana
2. Enviar email de checkpoint con botones de feedback

**Template de email:** `checkpoint_semanal` (en tabla `email_templates`)

**Variables requeridas en el template:**
- `{{nombre}}`: Nombre del usuario
- `{{semana_actual}}`: Número de semana
- `{{sesiones_completadas}}`: Sesiones completadas
- `{{sesiones_objetivo}}`: Sesiones objetivo
- `{{user_id}}`: ID del usuario
- `{{webhook_url}}`: URL base para webhooks

**Botones de feedback en el email:**
El template DEBE incluir 3 botones que llamen a:
```
{{webhook_url}}/webhook/checkpoint-semanal?user_id={{user_id}}&semana={{semana_actual}}&feedback=facil
{{webhook_url}}/webhook/checkpoint-semanal?user_id={{user_id}}&semana={{semana_actual}}&feedback=apropiado
{{webhook_url}}/webhook/checkpoint-semanal?user_id={{user_id}}&semana={{semana_actual}}&feedback=dificil
```

---

## Workflow 07: Procesar Checkpoint Semanal

**Trigger:** Webhook `/webhook/checkpoint-semanal?user_id=X&semana=Y&feedback=Z`

**Campos de entrada requeridos:**
- `user_id` (integer): ID del usuario
- `semana` (integer): Número de semana completada
- `feedback` (string): "facil", "apropiado", o "dificil"

**Nodo "Procesar Checkpoint" - Campos OBLIGATORIOS de salida:**
```sql
-- Estos campos son REQUERIDOS por el nodo "Preparar Email Sesión"
ajuste_accion    -- 'subir', 'mantener', o 'bajar'
ajuste_nivel     -- nivel actual (string): 'iniciacion', 'intermedio', 'avanzado'
ajuste_intensidad -- porcentaje de intensidad (integer)
ajuste_razon     -- mensaje explicativo (string)
ajuste_volumen   -- volumen extra (integer, puede ser NULL)
```

**Código en "Preparar Email Sesión" que USA estos campos:**
```javascript
// Línea ~66 - REQUIERE ajuste_nivel
${analisis.ajuste_nivel.toUpperCase()}

// Línea ~67 - REQUIERE ajuste_intensidad
${analisis.ajuste_intensidad}%

// REQUIERE ajuste_razon
${analisis.ajuste_razon}

// REQUIERE ajuste_accion
if (analisis.ajuste_accion !== 'mantener')
```

**REGLA CRÍTICA:** Si se modifica la query de "Procesar Checkpoint", DEBE devolver estos campos con estos nombres exactos.

**Idempotencia:**
- El campo `ajustado_esta_semana` en `programa_users` previene procesamiento duplicado
- Si `ya_procesado = true`, el usuario ve template `checkpoint_ya_procesado`

---

## Generador de Sesiones IA

**Tipos de sesión:**
1. **Fuerza** (enfoque='fuerza'): Generadas por Claude IA
2. **Cardio** (enfoque='cardio'): Tomadas de `actividades_cardio_templates`

**Niveles válidos:**
- `iniciacion`
- `intermedio`
- `avanzado`

**NOTA:** Los niveles son en minúscula. La tabla `actividades_cardio_templates` usa exactamente estos valores.

---

## Tabla: programa_users

**Campos críticos para el flujo:**
- `semana_actual`: Semana actual del programa (1-12)
- `sesion_actual_dentro_semana`: Sesión dentro de la semana (1-6)
- `sesiones_completadas_semana`: Contador de sesiones completadas esta semana
- `sesiones_objetivo_semana`: Objetivo de sesiones para esta semana
- `nivel_actual`: 'iniciacion', 'intermedio', 'avanzado'
- `intensidad_nivel`: Porcentaje de intensidad (60-100)
- `ajustado_esta_semana`: Flag para idempotencia de checkpoint

**Reset semanal (después de checkpoint):**
```sql
sesiones_completadas_semana = 0
sesion_actual_dentro_semana = 1
semana_actual = semana_actual + 1
ajustado_esta_semana = TRUE
```

---

## Tabla: programa_sesiones

**Estado de sesión:**
- `completada = false`: Sesión generada pero no realizada
- `completada = true`: Sesión marcada como realizada

**REGLA:** Cuando el usuario da feedback, se debe marcar `completada = true`

---

## Tabla: email_templates

**Templates críticos:**
1. `checkpoint_semanal`: Email de fin de semana con botones de feedback
2. `checkpoint_ya_procesado`: Email cuando el checkpoint ya fue procesado
3. Templates de sesión según tipo

---

## REGLAS GENERALES

### PostgreSQL en n8n
1. **SIEMPRE** usar `RETURNING *` en queries UPDATE que necesiten continuar el flujo
2. Las queries que devuelven 0 filas DETIENEN el flujo de n8n

### Modificación de workflows
1. **ANTES** de modificar un workflow, exportarlo a `/tmp/` como backup
2. Verificar que los campos de salida de un nodo coincidan con lo que espera el siguiente nodo
3. Si un nodo espera `campo_x`, la query DEBE devolver `campo_x` (no `campoX` ni `campo-x`)

### Testing
1. Usar usuario de test (ID 22+) para pruebas
2. Verificar ejecución completa en n8n (no solo base de datos)
3. Verificar `lastNodeExecuted` en caso de fallo

---

## HISTORIAL DE ERRORES (para no repetirlos)

### Error 1: Workflow se detiene en UPDATE
**Causa:** UPDATE sin RETURNING devuelve 0 filas
**Solución:** Agregar `RETURNING *` a todos los UPDATE

### Error 2: Cannot read properties of undefined (reading 'toUpperCase')
**Causa:** Query modificada que no devuelve `ajuste_nivel`
**Solución:** Mantener nombres de campos exactos: `ajuste_accion`, `ajuste_nivel`, `ajuste_intensidad`, `ajuste_razon`

### Error 3: Sesiones no marcadas como completadas
**Causa:** No se actualizaba `programa_sesiones.completada`
**Solución:** Agregar UPDATE a programa_sesiones en "Actualizar Progreso Usuario"

### Error 4: columna "contenido_id" no existe
**Causa:** Workflow 07 usaba `contenido_id` pero la tabla tiene `sesion_id`
**Solución:** Cambiar `contenido_id` por `sesion_id` en "Registrar Envío"

### Error 5: "Obtener Sesión" falla con user_id vacío
**Causa:** URL de sesión no incluía el token de autenticación
**Solución:** Las URLs de sesión DEBEN incluir `?token=${auth_token}`:
```javascript
const sesionUrl = `${webhookUrl}/webhook/view-session/sesion/${sesion.id}?token=${sesion.auth_token}`;
```

### Error 6: Feedback no afectaba la progresión
**Causa:** El workflow 07 ignoraba el feedback de las sesiones
**Solución:** Implementada función `calcular_ajuste_por_feedback()` que analiza el feedback real

---

## ARQUITECTURA ACTUAL (Actualizada 2026-01-19)

### Tablas de Configuración
- `config_programa`: Parámetros globales del sistema
- `email_templates`: Templates de email (usar con `get_email_template()`)

### Funciones PostgreSQL
- `get_config(clave)`: Obtener parámetro de configuración
- `get_email_template(nombre)`: Obtener template de email
- `calcular_ajuste_por_feedback(user_id, semana, feedback_checkpoint)`: Calcular ajuste de intensidad/nivel
- `registrar_envio(user_id, sesion_id)`: Registrar envío de email y actualizar contador de usuario
- `get_usuario_completo(user_id)`: Obtener datos completos del usuario

### Lógica de Progresión
```
Si feedback_checkpoint = 'dificil' → Bajar intensidad 5%
Si >50% sesiones 'dificil' → Bajar intensidad 5%
Si feedback_checkpoint = 'facil' O >50% sesiones 'facil':
  - Si intensidad < 100% → Subir intensidad 5%
  - Si intensidad = 100% → Subir de nivel + resetear intensidad a 65%
Si feedback mixto → Mantener
```

### Variables de Entorno Requeridas (.env)
```
WEBHOOK_URL=http://localhost:5678
BREVO_API_KEY=xkeysib-...
SENDER_EMAIL=hola@habitos-vitales.com
SENDER_NAME=Camino Vital
```

### Sub-Workflows Reutilizables
- `UTIL-enviar-email-brevo.json`: Envío centralizado de emails vía Brevo
  - Webhook: `POST /webhook/util/enviar-email`
  - Entrada: `user_email`, `user_nombre`, `asunto`, `email_html`, `user_id` (opcional), `sesion_id` (opcional)
  - Si se proporciona `user_id`, registra el envío en `programa_envios`
  - Usa `$env.BREVO_API_KEY` (configurado en docker-compose.yml)

### Workflows Activos (12 principales)
1. `[TEST-CV] 01 Onboarding.json` - Registro de usuarios
2. `04-guardar-lead.json` - Guardar lead del cuestionario
3. `05-remarketing-leads.json` - Remarketing día 3 y 7
4. `06-checkpoint-dominical.json` - Email checkpoint cada domingo
5. `07-procesar-checkpoint-semanal.json` - Procesar feedback y ajustar
6. `07-verificar-limite-usuarios.json` - Verificar límite
7. `08-clasificar-ejercicios-ia.json` - Clasificar videos con IA
8. `Camino Vital - 01-bis...json` - Seleccionar sesiones
9. `Camino Vital - 03-bis...json` - Feedback y siguiente sesión
10. `Camino Vital - 09 Mostrar Sesión.json` - Visualizar sesión
11. `Camino Vital - Generador Sesion IA.json` - Generar sesiones
12. `UTIL-enviar-email-brevo.json` - Sub-workflow centralizado de emails

### Archivos Archivados (_archive/)
Versiones alternativas movidas a `workflows/_archive/` para evitar confusión.

---

*Última actualización: 2026-01-19*
