# 🎬 Guía: Configurar Vizard.ai con n8n - Automatización de Video

## Objetivo
Automatizar la creación de clips cortos desde videos largos usando Vizard.ai, con revisión manual y publicación programada en Instagram Reels, YouTube Shorts y YouTube.

---

## 📋 Requisitos Previos

### 1. Cuenta de Vizard.ai Business
- [x] Tienes plan Business de Vizard.ai ✅
- [ ] Acceso a Workspace Settings
- [ ] API Key generada

### 2. Telegram Bot (para notificaciones)
- [ ] Crear bot con BotFather
- [ ] Obtener Bot Token
- [ ] Obtener tu Chat ID

### 3. Google Drive
- [ ] Cuenta de Google
- [ ] Carpeta específica para videos
- [ ] Credenciales OAuth o Service Account

### 4. YouTube (opcional, para publicación)
- [ ] Canal de YouTube
- [ ] Google Cloud Project
- [ ] YouTube Data API v3 habilitada

---

## 🔑 Paso 1: Obtener API Key de Vizard.ai

### 1.1 Acceder a configuración
1. Ve a: https://app.vizard.ai
2. Login con tu cuenta Business
3. Click en tu perfil (esquina superior derecha)
4. **Settings** → **Workspace Settings** → **API tab**

### 1.2 Generar API Key
1. Click en **"Generate API Key"** o **"Create New Key"**
2. Copia la key (empieza con algo como `vzd_...`)
3. **⚠️ IMPORTANTE**: Guarda esta key de forma segura, no se mostrará de nuevo

### 1.3 Guardar en .env
Añade al archivo `.env`:
```env
VIZARD_API_KEY=vzd_tu_key_aqui
```

---

## 🤖 Paso 2: Crear Telegram Bot

### 2.1 Crear el bot
1. Abre Telegram
2. Busca: **@BotFather**
3. Envía: `/newbot`
4. Sigue las instrucciones:
   - Nombre del bot: `Vizard Clips Bot` (o el que prefieras)
   - Username: `habitos_vitales_clips_bot` (debe terminar en `_bot`)

### 2.2 Guardar Bot Token
BotFather te dará un token como:
```
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
```

Guárdalo en `.env`:
```env
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz
```

### 2.3 Obtener tu Chat ID
1. Busca en Telegram: **@userinfobot**
2. Envía cualquier mensaje
3. El bot te responderá con tu **Chat ID** (ej: `123456789`)

Guárdalo en `.env`:
```env
TELEGRAM_CHAT_ID=123456789
```

### 2.4 Iniciar conversación con tu bot
1. Busca tu bot por el username que creaste
2. Click en **Start** o envía `/start`
3. Ya puedes recibir mensajes de tu bot

---

## 📁 Paso 3: Configurar Google Drive

### 3.1 Crear carpeta para videos
1. Ve a: https://drive.google.com
2. Crea una carpeta: **"Vizard - Videos"** (o el nombre que prefieras)
3. Copia el ID de la carpeta de la URL:
   ```
   https://drive.google.com/drive/folders/1ABC...XYZ
                                            ↑ Este es el ID
   ```

### 3.2 Configurar credenciales en n8n

**Opción A: OAuth2 (Recomendada)**
1. En n8n: **Credentials** → **Add Credential**
2. Busca: **Google Drive OAuth2 API**
3. Click en **Sign in with Google**
4. Autoriza el acceso
5. Guarda con nombre: `Google Drive - Vizard`

**Opción B: Service Account (Avanzado)**
1. Ve a: https://console.cloud.google.com
2. Crea un Service Account
3. Descarga el JSON de credenciales
4. En n8n: **Credentials** → **Google Service Account**
5. Pega el contenido del JSON

---

## 🔗 Paso 4: Configurar Webhook de Vizard

### 4.1 Obtener URL del webhook
Con ngrok corriendo:
```bash
ngrok http 5678
```

Tu URL de webhook será:
```
https://tu-ngrok-url.ngrok-free.app/webhook/vizard-webhook
```

### 4.2 Configurar en Vizard.ai
1. Ve a: https://app.vizard.ai
2. **Settings** → **Workspace Settings** → **Webhooks**
3. Click en **"Add Webhook"** o **"Configure Webhook"**
4. **Webhook URL**: `https://tu-ngrok-url.ngrok-free.app/webhook/vizard-webhook`
5. **Events**: Selecciona `project.completed` o similar
6. **Save**

### 4.3 (Opcional) Para producción
Cuando despliegues en servidor con dominio:
```
https://tu-dominio.com/webhook/vizard-webhook
```

---

## 🎬 Paso 5: Importar y Configurar Workflow en n8n

### 5.1 Importar workflow
1. Abre n8n: http://localhost:5678
2. **Workflows** → **Add workflow** → **Import from File**
3. Selecciona: `workflows/04-vizard-video-automation.json`
4. Click **Import**

### 5.2 Configurar nodo "Nuevo Video en Drive"
1. Click en el nodo **"🎥 Nuevo Video en Drive"**
2. **Authentication**: Selecciona tu credential de Google Drive
3. **Folder to Watch**: Pega el ID de tu carpeta
4. **File Type**: `video` (ya está configurado)
5. **Save**

### 5.3 Configurar nodo "Enviar a Vizard"
1. Click en el nodo **"🚀 Enviar a Vizard"**
2. En el header `VIZARDAI_API_KEY`:
   - Valor: Tu API key de Vizard
3. Revisa los parámetros del body:
   - `lang`: `"es"` (español)
   - `preferLength`: `[30, 60, 90]` (clips de 30s, 60s, 90s)
   - `ratioOfClip`: `[1, 4]` (9:16 y 16:9)
   - `subtitleSwitch`: `1` (activar subtítulos)
   - `removeSilenceSwitch`: `1` (eliminar silencios)
   - `emojiSwitch`: `1` (añadir emojis)
   - `maxClipNumber`: `10` (máximo 10 clips)
4. **Save**

### 5.4 Configurar nodo "Obtener Clips"
1. Click en el nodo **"📥 Obtener Clips"**
2. En el header `VIZARDAI_API_KEY`:
   - Valor: Tu API key de Vizard
3. **Save**

### 5.5 Configurar nodo "Notificar Telegram"
1. Click en el nodo **"📱 Notificar Telegram"**
2. **Credentials**: Add Credential → **Telegram API**
   - Bot Token: Tu token de Telegram
   - Save como: `Telegram Bot - Vizard`
3. **Chat ID**: Tu Chat ID de Telegram
4. **Save**

### 5.6 Configurar nodo "Respuesta Telegram"
1. Click en el nodo **"📲 Respuesta Telegram"**
2. **Credentials**: Selecciona `Telegram Bot - Vizard`
3. **Save**

### 5.7 Activar workflow
1. Click en el toggle superior derecho para **activar** el workflow
2. Verifica que diga **"Active"** en verde

---

## 🧪 Paso 6: Probar el Flujo Completo

### 6.1 Preparar test
1. Verifica que n8n está corriendo
2. Verifica que ngrok está corriendo
3. Verifica que el workflow está activo
4. Verifica que el webhook de Vizard está configurado

### 6.2 Subir video de prueba
1. Ve a tu carpeta de Google Drive configurada
2. Sube un video de prueba (recomendado: 2-5 minutos)
3. Espera a que se complete la subida

### 6.3 Monitorear el proceso
1. En n8n: **Executions** (menú lateral)
2. Deberías ver una nueva ejecución con el nombre del workflow
3. Click para ver los detalles

**Qué debería pasar:**
1. ✅ Detecta el video en Drive
2. ✅ Envía a Vizard.ai
3. ✅ Vizard responde con `projectId`
4. ⏳ Vizard procesa el video (tarda varios minutos)
5. ✅ Webhook notifica cuando está listo
6. ✅ n8n obtiene los clips
7. ✅ Recibes notificación en Telegram con botones

### 6.4 Aprobar clips
1. En Telegram, recibirás mensaje con:
   - Nombre del proyecto
   - Número de clips verticales (9:16)
   - Número de clips horizontales (16:9)
   - Botones: "✅ Aprobar todos" y "❌ Rechazar todos"
   - Enlace para ver clips en Vizard.ai
2. Click en **"🔍 Ver clips"** para revisar en Vizard
3. Si te gustan, click en **"✅ Aprobar todos"**
4. Recibirás confirmación en Telegram

### 6.5 Debugging
**Si no detecta el video:**
- Verifica que la carpeta ID es correcta
- Verifica las credenciales de Google Drive
- Checa los logs: `docker-compose logs n8n`

**Si Vizard no procesa:**
- Verifica que la API Key es correcta
- Verifica que el video es accesible públicamente o compartido
- Checa la respuesta del nodo "Enviar a Vizard"

**Si no llega el webhook:**
- Verifica que la URL del webhook en Vizard es correcta
- Verifica que ngrok está corriendo
- Checa los logs de ngrok: debería mostrar POST requests

**Si no llega notificación a Telegram:**
- Verifica el Bot Token
- Verifica tu Chat ID
- Verifica que iniciaste conversación con el bot (/start)

---

## ⚙️ Configuración Avanzada de Vizard

### Parámetros disponibles en el body

```json
{
  "lang": "es",                    // Idioma: "es", "en", "fr", etc.
  "videoUrl": "URL_DEL_VIDEO",
  "videoType": 2,
  "projectName": "Nombre del proyecto",
  "preferLength": [30, 60, 90],    // Duración preferida de clips (segundos)
  "ratioOfClip": [1, 4],           // 1=9:16, 2=1:1, 3=4:5, 4=16:9
  "subtitleSwitch": 1,             // 1=activar, 0=desactivar
  "removeSilenceSwitch": 1,        // 1=eliminar silencios
  "emojiSwitch": 1,                // 1=añadir emojis automáticos
  "highlightSwitch": 0,            // 1=highlight keywords
  "headlineSwitch": 0,             // 1=añadir hooks en primeros 3s
  "autoBrollSwitch": 0,            // 1=añadir B-roll automático
  "keywords": "",                  // Ej: "GPT-5, AI, OpenAI"
  "maxClipNumber": 10,             // Máximo número de clips (1-100)
  "templateId": ""                 // ID de template personalizado
}
```

### Opciones de aspect ratio

| Valor | Ratio | Plataformas |
|-------|-------|-------------|
| 1 | 9:16 | Instagram Reels, TikTok, YouTube Shorts |
| 2 | 1:1 | Instagram Feed, Facebook |
| 3 | 4:5 | Instagram Feed (optimizado) |
| 4 | 16:9 | YouTube, LinkedIn, Twitter |

### Keywords para detección de temas
Puedes añadir keywords para que Vizard busque momentos específicos:
```json
"keywords": "GPT-5, inteligencia artificial, OpenAI, Sam Altman"
```

Esto hará que Vizard priorice clips que hablen de esos temas.

---

## 📊 Siguiente Fase: Publicación Automática

### YouTube API (Fase 2)
1. Crear proyecto en Google Cloud Console
2. Habilitar YouTube Data API v3
3. Crear credenciales OAuth2
4. Configurar en n8n
5. Añadir nodo de YouTube Upload
6. Programar publicaciones

### Instagram (Fase 2)
**Opción A: API oficial**
- Requiere Instagram Business Account
- Requiere Facebook App Review
- Limitaciones de la API

**Opción B: Servicios de terceros**
- Buffer (tiene API)
- Hootsuite (tiene API)
- Later (tiene API)
- Publicación semi-automática

### Calendario de publicación
- Airtable/Notion como calendario
- Google Calendar integration
- Scheduling inteligente (mejores horarios)

---

## 🎯 Workflow Completo (Resumen)

```
1. 📁 Subir video a Google Drive
     ↓
2. 🔔 n8n detecta nuevo video
     ↓
3. 📤 n8n envía a Vizard.ai
     ↓
4. ⏳ Vizard procesa (minutos)
     ↓
5. 🔗 Webhook notifica a n8n
     ↓
6. 📥 n8n obtiene clips generados
     ↓
7. 📱 Telegram: notificación con preview
     ↓
8. 👤 TÚ: Revisar y aprobar
     ↓
9. ✅ Si aprobado → programar publicación
     ↓
10. 📺 YouTube + 📱 Instagram (automático)
```

---

## 💡 Tips y Mejores Prácticas

### Videos de origen
- **Duración**: 5-60 minutos ideal
- **Calidad**: Mínimo 720p, recomendado 1080p
- **Audio**: Claro y sin ruido de fondo
- **Contenido**: Conversacional, con momentos destacables

### Configuración de Vizard
- `removeSilenceSwitch: 1` → Mejora el ritmo
- `emojiSwitch: 1` → Hace los clips más atractivos
- `preferLength: [30, 60, 90]` → Variedad de duraciones
- `maxClipNumber: 10` → Balance entre cantidad y calidad

### Organización
- Carpetas separadas en Drive por tipo de contenido
- Nombres de archivo descriptivos
- Backup de videos originales

### Revisión de clips
- Revisa siempre antes de publicar
- Verifica subtítulos (pueden tener errores)
- Ajusta thumbnails si es necesario
- Personaliza títulos y descripciones

---

## 🆘 Troubleshooting

### Error: "Invalid API Key"
- Verifica que copiaste la key completa
- Verifica que la key está activa en Vizard
- Regenera la key si es necesario

### Error: "Video URL not accessible"
- El video en Google Drive debe ser accesible
- Cambia permisos a "Anyone with the link can view"
- O usa URLs públicas

### El proceso tarda mucho
- Videos largos tardan más (normal)
- 4K tarda significativamente más
- Comprueba el estado en Vizard.ai dashboard

### No recibo webhook
- Verifica que ngrok está corriendo
- Verifica la URL en Vizard Workspace Settings
- Checa los logs de ngrok
- Prueba manualmente el webhook con curl

### Clips de mala calidad
- Ajusta `preferLength` para clips más largos
- Usa `keywords` para dirigir el contenido
- Incrementa `maxClipNumber` para más opciones
- Verifica calidad del video original

---

## 📚 Recursos Útiles

- Vizard.ai Docs: https://docs.vizard.ai
- Vizard.ai Dashboard: https://app.vizard.ai
- n8n Docs: https://docs.n8n.io
- Telegram Bot API: https://core.telegram.org/bots/api
- YouTube Data API: https://developers.google.com/youtube/v3

---

**Fecha de creación**: 2025-12-04
**Tu proyecto**: HV_n8n - Vizard Video Automation
