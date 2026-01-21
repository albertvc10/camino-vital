# 📋 Instrucciones: Workflow Multi-Keyword

## 🎯 Qué hemos creado

Un workflow mejorado que permite gestionar **múltiples palabras clave** y sus respectivos mensajes DM desde una tabla de n8n, sin necesidad de modificar código.

---

## 📝 Paso 1: Crear la Tabla de Palabras Clave

### En n8n:

1. **Ve al menú lateral** → Click en **"Variables"**
2. Click en **"Add table"**
3. Configura la tabla:
   - **Nombre**: `palabras_clave_instagram`
   - Click en **"Add column"** para cada columna:

#### Columnas de la tabla:

| Nombre Columna | Tipo | Descripción |
|----------------|------|-------------|
| `palabra_clave` | String | La palabra a detectar (ej: "guia", "programa") |
| `mensaje_dm` | String | El mensaje DM a enviar cuando se detecte |
| `activo` | Boolean | true/false para activar/desactivar la palabra |

4. **Guarda** la tabla

---

## 📊 Paso 2: Añadir Datos a la Tabla

Añade tu primera fila de ejemplo:

### Ejemplo de fila:

- **palabra_clave**: `guia`
- **mensaje_dm**: `¡Hola! 👋 Gracias por tu interés.

📚 Aquí está tu guía completa sobre hábitos vitales: https://habitos-vitales.com

¿Te gustaría recibir más contenido exclusivo? ¡Suscríbete a mi newsletter!

✨ Nos vemos dentro!`
- **activo**: `true`

### Añade más palabras clave:

Puedes añadir más filas para otras palabras:

| palabra_clave | mensaje_dm | activo |
|---------------|------------|---------|
| `programa` | "Aquí tienes info del programa..." | true |
| `precio` | "Los precios son..." | true |
| `info` | "Aquí tienes toda la info..." | true |

---

## 📥 Paso 3: Importar el Nuevo Workflow

1. **Ve a n8n** → Workflows
2. Click en **menú (⋮)** arriba a la derecha → **"Import from File"**
3. Selecciona el archivo: `Instagram Auto-Responder - MULTI-KEYWORD.json`
4. El workflow se importará **desactivado** (por seguridad)

---

## 🔧 Paso 4: Verificar el Workflow

Una vez importado:

1. **Abre el workflow** "Instagram Auto-Responder - MULTI-KEYWORD"
2. **Revisa la nota** (sticky note amarilla) con las instrucciones
3. **NO LO ACTIVES TODAVÍA** - primero vamos a probarlo

---

## 🧪 Paso 5: Probar el Workflow (IMPORTANTE)

Antes de activar en producción:

### Opción A: Prueba Manual con el Editor

1. Click en el nodo **"Procesar y Decidir"**
2. Click en **"Test step"**
3. Crea un JSON de prueba:

```json
{
  "body": {
    "entry": [{
      "changes": [{
        "field": "comments",
        "value": {
          "id": "12345",
          "text": "quiero la guia",
          "from": {
            "id": "67890",
            "username": "test_user"
          }
        }
      }]
    }]
  }
}
```

4. Verifica que detecte "guia" y prepare el mensaje DM correcto

### Opción B: Prueba Real (Recomendado)

1. **Activa temporalmente** el workflow nuevo
2. **Desactiva temporalmente** el workflow viejo
3. Haz un comentario de prueba en Instagram con "guia"
4. Verifica que:
   - ✅ Detecta la palabra
   - ✅ Envía el DM correcto
   - ✅ No hay errores en las ejecuciones

---

## 🚀 Paso 6: Poner en Producción

Una vez probado y funcionando:

1. **Desactiva** el workflow viejo ("Instagram Auto-Responder - GUÍA")
2. **Activa** el workflow nuevo ("Instagram Auto-Responder - MULTI-KEYWORD")
3. **Espera 24-48 horas** para confirmar que todo funciona bien
4. **Elimina** el workflow viejo si todo está OK

---

## 🎨 Cómo Añadir Nuevas Palabras Clave

Es súper fácil, **sin tocar código**:

1. Ve a **Variables** → `palabras_clave_instagram`
2. Click en **"Add row"**
3. Completa:
   - `palabra_clave`: nueva palabra (ej: "descuento")
   - `mensaje_dm`: el mensaje para esa palabra
   - `activo`: true
4. **Guarda**
5. ¡Listo! La nueva palabra ya funciona automáticamente

---

## ⚙️ Características del Nuevo Sistema

### ✅ Ventajas:

- **Sin código**: Añade palabras desde la UI
- **Múltiples keywords**: Tantas como quieras
- **Mensajes personalizados**: Cada palabra tiene su propio DM
- **Activar/desactivar**: Control con el campo `activo`
- **Normalización**: Detecta palabras con/sin acentos, mayúsculas/minúsculas

### 🔍 Cómo Funciona:

1. Webhook recibe comentario
2. Lee tabla de palabras clave
3. Normaliza el texto del comentario
4. Busca coincidencias (primera que encuentra)
5. Envía el mensaje DM correspondiente

### 📌 Notas Importantes:

- **Primera coincidencia gana**: Si el comentario tiene "guia" y "programa", enviará el DM de la primera que encuentre en la tabla
- **Palabras inactivas**: Si `activo = false`, esa palabra se ignora
- **Sin tabla = no funciona**: Asegúrate de crear la tabla antes de activar el workflow

---

## 🆘 Troubleshooting

### Error: "No hay palabras clave configuradas"
- **Solución**: Crea la tabla `palabras_clave_instagram` en Variables

### No detecta mi palabra
- **Verifica**: Que la palabra esté en la tabla
- **Verifica**: Que `activo = true`
- **Verifica**: El nombre de la tabla sea exactamente `palabras_clave_instagram`

### Envía mensaje vacío
- **Verifica**: Que el campo `mensaje_dm` tenga contenido
- **Verifica**: Que no haya errores de sintaxis en el mensaje

---

## 📝 Ejemplo de Tabla Completa

| palabra_clave | mensaje_dm | activo |
|---------------|------------|---------|
| guia | "¡Hola! 👋 Aquí está tu guía..." | true |
| programa | "🎯 Nuestro programa incluye..." | true |
| precio | "💰 Los precios son: ..." | true |
| descuento | "🎁 ¡Tenemos un descuento especial!" | true |
| info | "ℹ️ Aquí tienes toda la información..." | true |
| test | "Este es un mensaje de prueba" | false |

**Nota**: La palabra "test" no funcionará porque `activo = false`

---

## 🎉 ¡Listo!

Ya tienes un sistema profesional y escalable para gestionar respuestas automáticas en Instagram con múltiples palabras clave.

**Siguiente nivel**: Podrías añadir más columnas a la tabla como:
- `prioridad` (número) para decidir qué palabra tiene preferencia
- `contador_usos` (número) para estadísticas
- `fecha_creacion` (string) para tracking

¡Disfruta de tu nuevo workflow automatizado! 🚀
