# ✅ Sistema de Feedback Mejorado - IMPLEMENTADO

**Fecha**: 2026-01-09
**Estado**: Implementado y listo para probar

---

## 🎯 Qué se implementó

### Opción 4 - Sistema Híbrido

Se implementó el sistema híbrido de feedback que combina:
- **80% casos felices**: 3 botones directos en el email
- **20% con problemas**: 1 botón que abre landing page detallada

---

## 📊 Cambios Realizados

### 1. Base de Datos

**Tabla**: `camino_vital.programa_feedback`

**Columnas añadidas**:
```sql
ALTER TABLE programa_feedback
ADD COLUMN IF NOT EXISTS completitud VARCHAR(50),
ADD COLUMN IF NOT EXISTS razon_no_completar VARCHAR(50);
```

**Nuevos campos**:
- `completitud`: 'completa' | 'incompleta'
- `razon_no_completar`: 'tiempo' | 'muy_dificil' | 'dolor' | NULL

---

### 2. Landing Page

**Archivo**: `/landing/feedback-problemas.html`

**Función**: Captura detallada de problemas cuando el usuario no puede completar la sesión

**Opciones**:
1. ⏰ No tuve tiempo
2. 😓 Fue muy difícil
3. 🤕 Sentí molestia física

**Características**:
- Diseño responsive
- UX clara y amigable
- Envía feedback a webhook `/webhook/feedback`
- Muestra confirmación visual al enviar

---

### 3. Email Template

**Workflow**: `02-envio-programado.json`
**Nodo modificado**: "Preparar Email" (JavaScript Code)

**Nueva sección de feedback**:
```html
¿Cómo te fue la sesión?

[😊 Fácil - Podría haber hecho más]      → completa_facil
[💪 Apropiado - Nivel perfecto]          → completa_bien
[😰 Difícil - Me costó pero lo logré]   → completa_dificil

---

[⚠️ No pude completarla]                 → abre landing page
```

**URLs generadas**:
- Botones 1-3: `https://n8n.habitos-vitales.com/webhook/feedback?user_id=X&feedback=completa_facil`
- Botón 4: `https://camino-vital.habitos-vitales.com/feedback-problemas.html?user_id=X`

---

### 4. Procesamiento de Feedback

**Workflow**: `03-feedback.json`
**Nodos modificados**:
1. "Procesar Feedback" (JavaScript Code)
2. "Guardar Feedback y Actualizar" (PostgreSQL)
3. "Generar Mensaje Personalizado" (JavaScript Code)

**Mapeo de Feedback**:
```javascript
{
  'completa_facil': {
    completitud: 'completa',
    respuesta: 'facil',
    razon_no_completar: null
  },
  'completa_bien': {
    completitud: 'completa',
    respuesta: 'apropiado',
    razon_no_completar: null
  },
  'completa_dificil': {
    completitud: 'completa',
    respuesta: 'dificil',
    razon_no_completar: null
  },
  'incompleta_tiempo': {
    completitud: 'incompleta',
    respuesta: null,
    razon_no_completar: 'tiempo'
  },
  'incompleta_dificil': {
    completitud: 'incompleta',
    respuesta: null,
    razon_no_completar: 'muy_dificil'
  },
  'dolor': {
    completitud: 'incompleta',
    respuesta: null,
    razon_no_completar: 'dolor'
  }
}
```

**Lógica de Decisión Mejorada**:

| Feedback | Acción | Resultado |
|----------|--------|-----------|
| completa_facil | continuar | Avanza a siguiente semana |
| completa_bien | continuar | Avanza a siguiente semana |
| completa_dificil | mantener | Avanza pero sin aumentar dificultad |
| incompleta_tiempo | continuar | Avanza (problema no es capacidad) |
| incompleta_dificil | repetir | Repite misma semana |
| dolor | revisar_dolor | Mantiene semana + alerta manual |

**Mensajes Personalizados**:
```javascript
'continuar': {
  titulo: '¡Perfecto! 👏',
  texto: 'Completaste la sesión. En tu próximo email recibirás la Semana X.'
},
'mantener': {
  titulo: '¡Muy bien! 💪',
  texto: 'Veo que te costó pero lo lograste. Mantendremos este nivel para que te adaptes.'
},
'repetir': {
  titulo: 'Vamos con calma 🧘',
  texto: 'No hay prisa. Repetiremos la Semana X con un enfoque más suave.'
},
'revisar_dolor': {
  titulo: 'Tu seguridad es primero 🤕',
  texto: 'Hemos recibido tu reporte. Nos pondremos en contacto contigo.'
}
```

---

## 🔧 Configuración Necesaria

### Servidor Web para Landing Pages

La landing page `feedback-problemas.html` necesita estar servida en:

**Producción**:
```
https://camino-vital.habitos-vitales.com/feedback-problemas.html
```

**Local** (para testing):
```
http://localhost:8080/feedback-problemas.html
```

### Workflow n8n

Asegúrate de que los workflows están activos:
- `02-envio-programado.json` → Activar
- `03-feedback.json` → Activar

---

## 🧪 Testing

### Paso 1: Verificar Base de Datos

```sql
-- Verificar que las columnas existen
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'camino_vital'
AND table_name = 'programa_feedback'
AND column_name IN ('completitud', 'razon_no_completar');
```

### Paso 2: Importar Workflows

```bash
# Desde n8n UI:
# 1. Settings → Import from File
# 2. Seleccionar 02-envio-programado.json
# 3. Seleccionar 03-feedback.json
# 4. Activar ambos workflows
```

### Paso 3: Servir Landing Page

**Opción A - Local con Python**:
```bash
cd /Users/albertvillanueva/Documents/HV_n8n/programa-camino-vital/landing
python3 -m http.server 8080
```

**Opción B - Docker con Nginx** (para producción):
```dockerfile
# Agregar a docker-compose.yml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./landing:/usr/share/nginx/html:ro
```

### Paso 4: Test Manual

1. **Obtener un usuario activo**:
```sql
SELECT id, email, nombre
FROM camino_vital.programa_users
WHERE estado = 'activo'
LIMIT 1;
```

2. **Test casos felices** (desde navegador):
```
https://n8n.habitos-vitales.com/webhook/feedback?user_id=1&feedback=completa_facil
https://n8n.habitos-vitales.com/webhook/feedback?user_id=1&feedback=completa_bien
https://n8n.habitos-vitales.com/webhook/feedback?user_id=1&feedback=completa_dificil
```

3. **Test problemas** (abrir en navegador):
```
http://localhost:8080/feedback-problemas.html?user_id=1
```
Luego hacer click en cada botón.

4. **Verificar datos guardados**:
```sql
SELECT
  id,
  user_id,
  tipo_feedback,
  respuesta,
  completitud,
  razon_no_completar,
  accion_tomada,
  created_at
FROM camino_vital.programa_feedback
ORDER BY created_at DESC
LIMIT 5;
```

---

## 📈 Datos Capturados

### Antes (sistema antiguo):
```sql
tipo_feedback: 'dificultad'
respuesta: 'muy_facil' | 'adecuado' | 'dificil'
```

### Después (sistema nuevo):
```sql
tipo_feedback: 'sesion_completada'
respuesta: 'facil' | 'apropiado' | 'dificil' | NULL
completitud: 'completa' | 'incompleta'
razon_no_completar: 'tiempo' | 'muy_dificil' | 'dolor' | NULL
```

**Ventajas**:
- ✅ Sabe si completó o no la sesión
- ✅ Distingue entre problemas de tiempo vs capacidad
- ✅ Detecta dolor/molestias físicas (seguridad)
- ✅ Permite intervención proactiva

---

## 🚀 Próximos Pasos

Una vez verificado el feedback mejorado:

1. **Implementar sistema de progresión multi-factor** (ver SISTEMA-PROGRESION-COMPLETO.md)
   - Usar completitud + adherencia + consistencia + cadencia
   - Ajustar parámetros de dificultad cada 3 sesiones

2. **Añadir mensajes de progresión transparente** (ver MENSAJES-PROGRESION-USUARIO.md)
   - "Vamos a aumentar porque..."
   - "Mantenemos porque..."

3. **Generar contenido para semanas 3-12**
   - Actualmente solo existen semanas 1-2
   - Necesario para progresión completa

---

## 📝 Notas Importantes

### Compatibilidad

El sistema es **retrocompatible**:
- Si `completitud` es NULL → se asume feedback antiguo
- Los feedbacks antiguos en DB no se ven afectados
- Nuevos feedbacks usan el sistema mejorado

### Monitoreo

Queries útiles para monitorear:

```sql
-- Tasa de completitud
SELECT
  completitud,
  COUNT(*) as total,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as porcentaje
FROM programa_feedback
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY completitud;

-- Razones de no completar
SELECT
  razon_no_completar,
  COUNT(*) as total
FROM programa_feedback
WHERE completitud = 'incompleta'
  AND created_at > NOW() - INTERVAL '7 days'
GROUP BY razon_no_completar
ORDER BY total DESC;

-- Reportes de dolor (ALERTA)
SELECT
  u.email,
  u.nombre,
  f.created_at,
  f.semana,
  f.nivel
FROM programa_feedback f
JOIN programa_users u ON f.user_id = u.id
WHERE f.razon_no_completar = 'dolor'
  AND f.created_at > NOW() - INTERVAL '7 days'
ORDER BY f.created_at DESC;
```

---

## ✅ Checklist de Implementación

- [x] Base de datos actualizada (columnas añadidas)
- [x] Landing page `feedback-problemas.html` creada
- [x] Workflow 02 modificado (email con 4 botones)
- [x] Workflow 03 modificado (procesamiento mejorado)
- [ ] Workflows importados y activados en n8n
- [ ] Landing page servida en servidor web
- [ ] Tests manuales completados
- [ ] Datos verificados en base de datos

---

**¿Listo para probar?** 🚀

1. Activa los workflows en n8n
2. Sirve la landing page en localhost:8080 o producción
3. Envía un email de prueba a un usuario
4. Haz click en los 4 botones de feedback
5. Verifica que los datos se guardan correctamente

**Siguiente paso**: Implementar sistema de progresión multi-factor basado en estos datos mejorados.
