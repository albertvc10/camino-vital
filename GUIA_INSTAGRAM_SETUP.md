# 🚀 Guía: Configurar Instagram con n8n (Local)

## Objetivo
Automatizar respuestas a comentarios en Instagram cuando alguien escriba "GUÍA", enviando un DM con el enlace a tu newsletter.

---

## 📋 Requisitos Previos

### 1. Cuenta de Instagram Business
- [ ] Tener una cuenta de Instagram Business (no personal)
- [ ] Tu Instagram debe estar conectado a una página de Facebook
- [ ] Ser administrador de la página de Facebook

**¿Cómo verificar?**
1. Abre Instagram → Perfil → Menú (☰)
2. Settings → Account → Switch to Professional Account
3. Elige "Business"
4. Conecta a tu página de Facebook

---

## 🔧 Paso 1: Crear App de Facebook Developer

### 1.1 Acceder a Facebook Developers
1. Ve a: https://developers.facebook.com/
2. Click en **"My Apps"** (esquina superior derecha)
3. Click en **"Create App"**

### 1.2 Configurar la App
**Tipo de app:**
- Selecciona: **"Business"** (no Consumer)
- Click **"Next"**

**Detalles de la app:**
- **App Name**: `n8n Instagram Automation` (o el nombre que prefieras)
- **App Contact Email**: Tu email
- **Business Account**: Crea una si no tienes (puedes usar tu cuenta personal)
- Click **"Create App"**

### 1.3 Verificar tu cuenta
- Es posible que Meta te pida verificar tu identidad
- Sigue las instrucciones (puede requerir verificación por SMS)

---

## 🔑 Paso 2: Añadir el Producto Instagram

### 2.1 Añadir Instagram Graph API
En el dashboard de tu app:
1. Panel izquierdo → **"Add Product"**
2. Busca **"Instagram Graph API"**
3. Click en **"Set Up"**

### 2.2 Configurar permisos básicos
En la sección de Instagram:
1. Ve a **"Basic Display"** o **"Instagram Graph API"**
2. Apunta estos datos (los necesitarás):
   - **App ID**
   - **App Secret** (Click en "Show")

---

## 📱 Paso 3: Conectar tu Página de Facebook

### 3.1 Obtener Access Token
1. Ve a: https://developers.facebook.com/tools/explorer/
2. Selecciona tu app en el dropdown
3. En **"User or Page"**, selecciona tu página de Facebook
4. Click en **"Generate Access Token"**
5. Acepta los permisos solicitados

### 3.2 Permisos necesarios
Necesitas solicitar estos permisos (algunos requieren aprobación):

**Permisos básicos (suelen estar aprobados):**
- `pages_show_list`
- `pages_read_engagement`

**Permisos que necesitas solicitar:**
- `instagram_basic`
- `instagram_manage_comments`
- `instagram_manage_messages`
- `pages_manage_metadata`

### 3.3 Obtener Instagram Business Account ID
Ejecuta esta petición en Graph API Explorer:
```
GET /me/accounts
```

Busca tu página y copia:
- `page_id`
- `access_token`

Luego ejecuta:
```
GET /{page_id}?fields=instagram_business_account
```

Copia el `instagram_business_account.id` - **¡Lo necesitarás!**

---

## 🔗 Paso 4: Configurar Webhooks (Local con ngrok)

### 4.1 Instalar ngrok
```bash
# Si tienes Homebrew:
brew install ngrok

# Registrarte en ngrok.com y obtener tu authtoken
ngrok config add-authtoken TU_TOKEN_AQUI
```

### 4.2 Exponer n8n localmente
```bash
# En una terminal nueva:
ngrok http 5678
```

Verás algo como:
```
Forwarding: https://abc123.ngrok.io -> http://localhost:5678
```

**Copia esa URL** (ej: `https://abc123.ngrok.io`)

### 4.3 Configurar Webhook en Facebook
1. Ve a tu app en Facebook Developers
2. Panel izquierdo → **"Webhooks"**
3. Click **"Instagram"** → **"Subscribe to this object"**
4. **Callback URL**: `https://abc123.ngrok.io/webhook/instagram`
5. **Verify Token**: Crea uno (ej: `mi_token_secreto_123`)
6. **Subscription Fields**: Marca:
   - `comments`
   - `messages`

---

## 🤖 Paso 5: Crear el Workflow en n8n

### 5.1 Estructura del Workflow

```
[Webhook Trigger]
    → [Filtrar: Contiene "GUÍA"]
    → [HTTP Request: Obtener datos del comentario]
    → [HTTP Request: Enviar DM]
```

### 5.2 Configuración del Webhook en n8n

1. En n8n, crea un nuevo workflow
2. Añade nodo **"Webhook"**
3. Configura:
   - **HTTP Method**: `GET` y `POST`
   - **Path**: `instagram`
   - **Respond**: `Immediately`
   - **Response Code**: `200`

4. En el nodo, añade esta expresión para verificar:
```javascript
// Verificación de Facebook
{{ $request.query['hub.verify_token'] === 'mi_token_secreto_123'
   ? $request.query['hub.challenge']
   : 'error' }}
```

### 5.3 Nodo de Filtro

Añade un nodo **"IF"** después del webhook:
```javascript
// Expresión para detectar "GUÍA"
{{ $json.entry[0].changes[0].value.text.toUpperCase().includes('GUÍA') }}
```

### 5.4 Nodo para Enviar DM

Añade un nodo **"HTTP Request"**:
- **Method**: `POST`
- **URL**: `https://graph.facebook.com/v18.0/me/messages`
- **Authentication**: `Generic Credential Type`
  - **Access Token**: Tu token de la página
- **Body Parameters**:
```json
{
  "recipient": {
    "id": "{{ $json.entry[0].changes[0].value.from.id }}"
  },
  "message": {
    "text": "¡Hola! 👋 Aquí está tu guía: https://habitos-vitales.com\n\n¿Te gustaría recibir más contenido como este? ¡Suscríbete a mi newsletter!"
  }
}
```

---

## 🧪 Paso 6: Probar el Flujo Completo

### 6.1 Activar el Workflow
1. En n8n, activa el workflow (toggle en la esquina superior derecha)
2. Verifica que ngrok esté corriendo
3. Verifica que el webhook esté subscrito en Facebook

### 6.2 Hacer una Prueba Real
1. Desde otra cuenta de Instagram (o pide a alguien)
2. Comenta "GUÍA" en uno de tus posts
3. Observa los logs en n8n
4. Deberías recibir un DM automático

### 6.3 Debugging
- Logs de n8n: Check en el panel de ejecuciones
- Logs de ngrok: En la terminal donde corre ngrok
- Graph API Explorer: Para probar endpoints manualmente

---

## ⚠️ Limitaciones y Consideraciones

### Limitaciones de la API
- **Rate Limits**: ~200 llamadas/hora por usuario
- **Aprobación de permisos**: Puede tardar días/semanas
- **Mensajes**: Solo puedes iniciar conversación si el usuario interactuó primero

### Modo de Desarrollo vs Producción
- **Desarrollo**: Solo tú y los testers pueden usar la app
- **Producción**: Necesitas pasar App Review de Meta
  - Enviar video demostrativo
  - Explicar caso de uso
  - Puede tardar 1-2 semanas

### Alternativa mientras esperas aprobación
Mientras Meta aprueba tus permisos:
1. Añádete como "Tester" en la app
2. Añade otras cuentas de prueba
3. Prueba el flujo con esas cuentas limitadas

---

## 📊 Siguiente Fase: Despliegue

Una vez validado localmente:
1. [ ] Elegir proveedor (Railway, DigitalOcean, etc.)
2. [ ] Configurar dominio propio (opcional)
3. [ ] Desplegar n8n en el servidor
4. [ ] Actualizar Webhook URL en Facebook
5. [ ] Pasar a modo producción

---

## 🆘 Troubleshooting Común

### Error: "Invalid Verify Token"
- Verifica que el token en n8n coincida con el de Facebook
- Asegúrate de que ngrok está corriendo

### Error: "Permissions Error"
- Verifica que tienes los permisos aprobados
- Regenera el Access Token con los permisos correctos

### No recibo el comentario en n8n
- Verifica que el webhook está subscrito correctamente
- Checa los logs de ngrok
- Asegúrate de que comentas desde una cuenta diferente

### El DM no se envía
- Verifica el Access Token
- Checa que tienes `instagram_manage_messages`
- La conversación debe ser iniciada por el usuario primero

---

## 📚 Recursos Útiles

- Instagram Graph API Docs: https://developers.facebook.com/docs/instagram-api
- n8n Instagram Nodes: https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.instagram/
- Graph API Explorer: https://developers.facebook.com/tools/explorer/
- ngrok Docs: https://ngrok.com/docs

---

**Fecha de creación**: 2025-12-01
**Tu proyecto**: HV_n8n - Instagram Automation
