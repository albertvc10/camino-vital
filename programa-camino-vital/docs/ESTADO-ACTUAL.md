# 📊 Estado Actual del Deployment - Camino Vital

**Última actualización:** 21 Enero 2026
**Servidor:** Digital Ocean (167.71.51.148)
**Estado general:** ✅ MVP funcional con sistema adaptativo + fin de programa

---

## ✅ Componentes Funcionando

### 1. Infraestructura Base
- ✅ **Servidor Digital Ocean** - IP: 167.71.51.148
- ✅ **Docker Compose** - n8n + PostgreSQL + Caddy
- ✅ **Caddy** - Reverse proxy con SSL automático
- ✅ **PostgreSQL** - Base de datos operativa con schema completo
- ✅ **n8n** - Plataforma de automatización activa

### 2. Dominios y DNS
- ✅ **n8n.habitos-vitales.com** - Panel de n8n
- ✅ **camino-vital.habitos-vitales.com** - Landing pages
- ✅ **Certificados SSL** - Let's Encrypt automático vía Caddy

### 3. Landing Pages Desplegadas
- ✅ `/landing/index.html` - Landing principal
- ✅ `/landing/cuestionario.html` - Cuestionario multi-paso (guarda lead ANTES de pago)
- ✅ `/landing/resultados.html` - Resultados personalizados + botón Stripe
- ✅ `/landing/gracias.html` - Confirmación post-pago

### 4. Workflows n8n

#### ✅ **01-onboarding** - FUNCIONANDO 100%
**Flujo:** Stripe webhook → Activar usuario → Mover lista Brevo → Email bienvenida

**Estado:** ✅ Probado con pago real de test

#### ✅ **04-guardar-lead** - FUNCIONANDO
**Flujo:** Webhook cuestionario → INSERT usuario como lead → Añadir a lista Brevo #14

**Estado:** ✅ Probado - Leads se guardan correctamente

#### ✅ **06-checkpoint-dominical** - FUNCIONANDO
**Flujo:** Cron domingo 18:00 → Reset flags → Analizar semana usuarios → Enviar email interactivo

**Funcionalidad:**
- **Resetea `ajustado_esta_semana = FALSE`** para todos los usuarios activos al inicio
- Obtiene usuarios activos (semanas 1-12)
- Obtiene templates de email (checkpoint + fin de programa)
- **Detecta semana 12**: Envía email especial de fin de programa (sin botones)
- Para semanas 1-11: Genera email con resumen + botones para elegir sesiones
- **Marca usuarios semana 12** como `estado = 'completado'`

**Nodos clave:**
1. Cron domingo 18:00
2. **Resetear Flag Semanal** - UPDATE con `alwaysOutputData: true`
3. Obtener Usuarios Activos
4. Obtener Template Email (checkpoint)
5. Obtener Template Fin Programa
6. Preparar Email Checkpoint (detecta semana 12)
7. Enviar vía UTIL Email
8. IF es_fin_programa → Marcar Usuario Completado

**Estado:** ✅ Probado - Emails se envían correctamente, fin de programa funciona

#### ✅ **07-procesar-checkpoint** - FUNCIONANDO
**Flujo:** Webhook elección usuario → Respuesta inmediata → Procesar checkpoint → Generar sesión IA → Email

**Funcionalidad:**
- Recibe elección de sesiones del usuario (2, 3 o 4)
- **Responde inmediatamente** al usuario (no espera procesamiento)
- Llama a `procesar_checkpoint_interactivo()`
- Idempotente: detecta si ya fue procesado
- Genera primera sesión de la semana con IA
- Envía email con la sesión (cabecera "Sesión 1 de X")

**Mejoras UX:**
- Respuesta HTML inmediata (no JSON)
- Cabecera `Content-Type: text/html; charset=utf-8`
- Procesamiento en background después de responder

**Estado:** ✅ Probado - Progresión correcta (nivel, intensidad, semana)

#### ✅ **09-generador-sesion-ia** - FUNCIONANDO
**Flujo:** Recibe parámetros → OpenAI genera sesión → Guarda en DB → Devuelve contenido

**Funcionalidad:**
- Usa perfil del usuario (limitaciones, objetivo, nivel, intensidad)
- Genera ejercicios personalizados con OpenAI
- Guarda en tabla `programa_sesiones`

**Estado:** ✅ Probado - Sesiones se generan correctamente

#### ✅ **03-bis Feedback y Siguiente Sesión** - FUNCIONANDO
**Flujo:** Webhook feedback → Registra → Incrementa sesiones → Envía siguiente (si quedan)

**Funcionalidad:**
- Registra feedback en programa_feedback
- Incrementa sesiones_completadas_semana
- Si quedan sesiones → Envía siguiente inmediatamente
- Si no quedan → Muestra "Semana completada"

**Mejoras recientes:**
- **Emails incluyen número de semana**: "Semana X - Sesión Y de Z"
- **Mensaje de reconocimiento de feedback**: Informa al usuario que su feedback se usará para ajustes semanales
- Asunto del email: `🎯 Semana X - Sesión Y de Z: [título]`

**Estado:** ✅ Workflow completo y activo

#### ⏸️ **05-remarketing-leads** - PENDIENTE TESTING
**Propósito:** Emails día 3 y día 7 a leads que no pagaron

**NOTA:** No hay workflow de "envíos programados L/M/V". Las sesiones se envían bajo demanda cuando el usuario da feedback.

### 5. Integraciones Configuradas

#### ✅ Stripe (Modo Test)
- **Product ID:** Camino Vital - Base Vital
- **Price ID:** price_1Sg2jvAY3mlcRJjrPNn3yxmg
- **Payment Link:** https://buy.stripe.com/test_aFa00igC741Zcjxfn5eZ200
- **Webhook:** https://n8n.habitos-vitales.com/webhook/camino-vital-pago
- **Webhook Secret:** whsec_sK4y75T4PutHsiXzkJBMiJbwPQZmKq2g
- **Redirect URL:** https://camino-vital.habitos-vitales.com/gracias.html
- **Cupón descuento:** ULTIMAOPORTUNIDAD (8€ off para remarketing día 7)

#### ✅ Brevo
- **API Key:** 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
- **Lista #13:** Clientes Activos (Base Vital)
- **Lista #14:** Leads (no compradores)
- **IP autorizada:** 167.71.51.148
- **Sender:** hola@habitos-vitales.com

#### ✅ PostgreSQL
- **Host:** postgres (dentro de Docker)
- **Port:** 5432
- **Database:** n8n
- **User:** n8n
- **Credencial n8n:** "PostgreSQL local"

### 6. Base de Datos

#### Tablas creadas:
- ✅ `programa_users` - Usuarios del programa (con campos adaptativos)
- ✅ `programa_feedback` - Historial de feedback por sesión
- ✅ `programa_contenido` - Biblioteca de ejercicios (estático, legacy)
- ✅ `programa_sesiones` - **NUEVO** Sesiones generadas por IA
- ✅ `programa_envios` - Log de emails enviados
- ✅ `email_templates` - Templates de email dinámicos

#### Funciones SQL:
- ✅ `analizar_semana_para_checkpoint(user_id)` - Análisis semanal
- ✅ `procesar_checkpoint_interactivo(...)` - Procesa elección del usuario
- ✅ `get_email_template(nombre)` - Obtiene template de email por nombre

#### Templates de Email (tabla `email_templates`):
- ✅ `checkpoint_semanal` - Email dominical con resumen y botones
- ✅ `programa_completado` - Email de felicitación semana 12 (sin botones, branding "Camino Vital")

#### Campos clave en `programa_users`:
- `sesiones_objetivo_semana` - Sesiones a hacer (2-5)
- `sesiones_completadas_semana` - Sesiones hechas
- `intensidad_nivel` - Intensidad actual (50-100%)
- `ajustado_esta_semana` - TRUE si ya pasó checkpoint

---

## 🔧 Configuraciones Técnicas Importantes

### Variables de Entorno (.env)
```bash
N8N_ENCRYPTION_KEY=<existente>
POSTGRES_PASSWORD=<existente>
BREVO_API_KEY=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
STRIPE_WEBHOOK_SECRET=whsec_sK4y75T4PutHsiXzkJBMiJbwPQZmKq2g
N8N_PUSH_BACKEND=websocket
N8N_BLOCK_ENV_ACCESS_TO_N8N=false
```

**NOTA IMPORTANTE:** Los workflows usan API keys directas, NO `{{$env.BREVO_API_KEY}}` porque n8n bloqueaba el acceso.

### Caddyfile
- n8n.habitos-vitales.com → reverse_proxy n8n:5678
- camino-vital.habitos-vitales.com → file_server /root/n8n/camino-vital/landing

### Docker Compose
- Volume añadido para landing pages: `./camino-vital/landing:/root/n8n/camino-vital/landing:ro`

---

## 📝 Notas de Conexión SSH

**Problema conocido:** Conexión SSH solo funciona desde **hotspot móvil**, no desde WiFi normal.

**Solución temporal:**
1. Activar hotspot en móvil
2. Conectar laptop al hotspot
3. Ejecutar comandos SSH/SCP

**Comandos útiles:**
```bash
# Conectar a servidor
ssh root@167.71.51.148

# Ver logs de n8n
docker logs n8n-n8n-1 --tail 50 -f

# Ver logs de PostgreSQL
docker logs n8n-postgres-1 --tail 50 -f

# Acceder a PostgreSQL
docker exec -it n8n-postgres-1 psql -U n8n -d n8n

# Reiniciar servicios
cd /root/n8n
docker-compose restart
```

---

## 🧪 Testing Realizado

### ✅ Test #1: Flujo completo de onboarding
- ✅ Usuario completa cuestionario
- ✅ Lead guardado en DB (estado: lead)
- ✅ Lead añadido a lista Brevo #14
- ✅ Click en "Empezar programa" → Stripe checkout
- ✅ Pago completado → Webhook recibido
- ✅ Usuario actualizado (estado: activo)
- ✅ Usuario movido de lista #14 → #13
- ✅ Email de bienvenida recibido

### ✅ Test #2: Sistema de Checkpoint Adaptativo
- ✅ Usuario con `ajustado_esta_semana = TRUE` → "Ya procesado"
- ✅ Usuario nuevo hace checkpoint con 4 sesiones elegidas
- ✅ Progresión correcta: iniciacion → intermedio
- ✅ Intensidad correcta: 60% → 65%
- ✅ Sesión generada por IA para semana 2
- ✅ Email enviado con sesión personalizada

### ✅ Test #3: Flujo completo semanas 1-12
- ✅ Reset de flag `ajustado_esta_semana` funciona cada domingo
- ✅ Emails de sesión incluyen número de semana
- ✅ Feedback de usuario registra correctamente
- ✅ Mensaje de reconocimiento de feedback mostrado
- ✅ Progresión de niveles e intensidad correcta
- ✅ Semana 12: Email de fin de programa (sin botones)
- ✅ Usuario marcado como `estado = 'completado'` al finalizar

**Resultado:** ✅ Flujo completo de 12 semanas funciona correctamente

---

## ⏭️ Próximos Pasos

### Inmediato

#### 1. Probar Flujo Completo de Sesiones
- [ ] Probar workflow 03-bis: feedback → siguiente sesión
- [ ] Verificar que se envía la siguiente sesión correctamente
- [ ] Verificar mensaje "Semana completada" cuando no quedan sesiones

#### 2. Probar Remarketing
- [ ] Crear lead de prueba que NO pague
- [ ] Verificar emails día 3 y día 7

### Corto Plazo

#### 4. Paso a Producción
- [ ] Cambiar Stripe de test a live mode
- [ ] Actualizar webhook URL en Stripe live
- [ ] Probar pago real de 1€ para verificar

#### 5. Primeros Clientes
- [ ] Primera campaña de tráfico
- [ ] Conseguir primeros 10 clientes de pago
- [ ] Monitorear checkpoint semanal

### Medio Plazo

#### 6. Optimizaciones
- [ ] Afinar prompts de generación de sesiones IA
- [ ] Dashboard de métricas (conversión, retención)
- [ ] Sistema de notificaciones para usuarios inactivos
- [ ] Backups automáticos de DB

---

## 🔧 Patrones Técnicos n8n Aprendidos

### Code Node - Acceso a datos de otros nodos
```javascript
// ❌ INCORRECTO - Solo obtiene items del input directo
const items = $input.all();

// ✅ CORRECTO - Obtiene items de un nodo específico
const items = $("Nombre del Nodo").all();
const firstItem = $("Nombre del Nodo").first().json;
```

### HTTP Request con specifyBody: "json"
```javascript
// ❌ INCORRECTO - Doble stringificación causa "email is missing"
jsonBody: "={{ JSON.stringify($json) }}"

// ✅ CORRECTO - n8n stringifica automáticamente
jsonBody: "={{ $json }}"
```

### PostgreSQL con queries que pueden devolver vacío
```json
{
  "options": {
    "alwaysOutputData": true
  }
}
```
Esto asegura que el nodo siempre produzca output aunque la query no devuelva filas.

### Response Node con HTML
```json
{
  "respondWith": "text",
  "responseBody": "={{ $json.html_content }}",
  "responseHeaders": {
    "entries": [{
      "name": "Content-Type",
      "value": "text/html; charset=utf-8"
    }]
  }
}
```

### Orden de ejecución secuencial
Los nodos de Postgres que dependen unos de otros deben ejecutarse en serie, no en paralelo. Si el nodo B necesita que A se haya ejecutado primero, conectarlos directamente (no desde un nodo común anterior).

---

## 🐛 Problemas Conocidos y Soluciones

### Problema #1: n8n "Connection Lost"
**Causa:** Falta configuración websocket
**Solución aplicada:**
- Añadido `N8N_PUSH_BACKEND=websocket` a .env y docker-compose.yml
- Caddyfile sin restricciones de protocolo HTTP

### Problema #2: Variables de entorno bloqueadas
**Causa:** n8n bloquea acceso a env vars por seguridad
**Solución aplicada:**
- Usar API keys directas en lugar de `{{$env.BREVO_API_KEY}}`
- Configurar `N8N_BLOCK_ENV_ACCESS_TO_N8N=false` (no funcionó completamente)

### Problema #3: PostgreSQL RETURNING no propagaba datos
**Causa:** Nodos HTTP Request devuelven respuesta API, no input
**Solución aplicada:**
- Añadido nodo "Formatear Datos Usuario"
- Conexión paralela desde formateador a Brevo y Email
- Evita que respuesta de Brevo borre los datos del usuario

### Problema #4: Landing pages 404
**Causa:** Caddy container sin acceso a archivos
**Solución aplicada:**
- Añadido volume mount en docker-compose.yml
- `./camino-vital/landing:/root/n8n/camino-vital/landing:ro`

### Problema #5: Timing de captura de leads
**Causa:** Lead solo se guardaba al hacer pago, no al completar cuestionario
**Solución aplicada:**
- Modificado cuestionario.html para llamar webhook ANTES de redirect
- Ahora captura lead al completar cuestionario (antes de decisión de pago)

---

## 📊 Métricas Actuales

**Usuarios totales:** 1 (albertvc10@gmail.com)
**Leads:** 0 (el único se convirtió en activo)
**Clientes activos:** 1
**Tasa de conversión:** 100% (1/1)
**Emails enviados:** 1 (bienvenida)

---

## 🔐 Credenciales y Accesos

### n8n
- **URL:** https://n8n.habitos-vitales.com
- **Usuario:** (el que configuraste)

### Servidor SSH
- **IP:** 167.71.51.148
- **Usuario:** root
- **Método:** SSH key (albertvc10)
- **Nota:** Requiere hotspot móvil

### Brevo
- **Email:** hola@habitos-vitales.com
- **Dashboard:** https://app.brevo.com

### Stripe
- **Cuenta:** (tu cuenta de Stripe)
- **Modo:** Test
- **Dashboard:** https://dashboard.stripe.com

### Digital Ocean
- **Panel:** https://cloud.digitalocean.com
- **Droplet:** n8n-habitos-vitales

---

## 📚 Documentación Relacionada

- `README.md` - Documentación técnica completa
- `SISTEMA-CHECKPOINT-ADAPTATIVO.md` - **Sistema de checkpoint semanal**
- `REGLAS-FLUJO-PROYECTO.md` - Reglas de negocio actualizadas
- `RESUMEN-EJECUTIVO.md` - Visión general del negocio
- `STRIPE-SETUP.md` - Guía configuración Stripe
- `database/schema.sql` - Schema de base de datos

---

## 🆘 Contacto y Soporte

**Email principal:** hola@habitos-vitales.com
**Email técnico:** albertvc10@gmail.com

---

**Última sesión de trabajo:** 21 Enero 2026
**Estado del proyecto:** ✅ MVP funcional con sistema adaptativo completo + manejo de fin de programa
