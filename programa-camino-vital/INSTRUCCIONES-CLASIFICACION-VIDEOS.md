# Instrucciones: Clasificación de Videos con IA

## 📋 Resumen

Este sistema clasifica automáticamente tus videos de ejercicios usando IA (Claude) basándose únicamente en el nombre del archivo.

## 🎯 Flujo Completo

```
1. Lista de videos
   ↓
2. Para cada video → Preparar prompt con nombre
   ↓
3. Llamar a Claude API → Clasificar ejercicio
   ↓
4. Parsear JSON de respuesta
   ↓
5. Insertar en tabla ejercicios_biblioteca
   ↓
6. Resumen de ejercicios clasificados
```

## 🚀 Pasos para Ejecutar

### 1. Importar Workflow

En n8n:
- Workflows → Import from File
- Selecciona: `/programa-camino-vital/workflows/08-clasificar-ejercicios-ia.json`
- Importar

### 2. Configurar Credenciales Anthropic API

El workflow necesita tu API key de Claude:

1. En n8n, ve a **Credentials** (menú izquierdo)
2. Crea nueva credencial: **Anthropic API**
3. Introduce tu API key de Anthropic
4. Guarda con el nombre: `anthropic-api`

**Nota:** Si no tienes API key, obtén una en: https://console.anthropic.com/

### 3. Revisar Lista de Videos de Prueba

El workflow tiene 8 videos de ejemplo en el nodo "Input: Lista de Videos":

```javascript
const videos = [
  "Alligator_Push-ups.mov",
  "Archer_Push-ups.mov",
  "Arm_Circles_Backward.mov",
  "Arm_Circles_Forward.mov",
  "Assisted_Triceps_Extension.mov",
  "Backward_Lunges.mov",
  "Beetle.mov",
  "Bent_Knee_Leg_Raises.mov"
];
```

Estos son los que viste en Firebase Storage.

### 4. Importar el Workflow en n8n

1. En n8n, ve a **Workflows** en el menú superior
2. Click en el botón **Import from File**
3. Selecciona el archivo que acabas de crear
4. El workflow aparecerá con todos los nodos configurados

### 5. Ejecutar el Workflow

1. Click en **Execute Workflow**
2. El workflow procesará los 8 videos en secuencia
3. Para cada video:
   - Llama a Claude API (~$0.01-0.02 por video)
   - Clasifica el ejercicio
   - Inserta en la base de datos

**Tiempo estimado:** 2-3 minutos para 8 videos

### 6. Verificar Resultados

Después de la ejecución:

**En n8n:**
- El nodo "Resumen Final" mostrará cuántos ejercicios se clasificaron

**En la base de datos:**
```sql
SET search_path TO camino_vital;

-- Ver todos los ejercicios clasificados
SELECT
  nombre_archivo,
  nombre_espanol,
  nivel,
  areas_cuerpo,
  tipo_ejercicio,
  posicion
FROM ejercicios_biblioteca
ORDER BY created_at DESC;

-- Ver detalles de un ejercicio
SELECT
  nombre_espanol,
  descripcion_completa,
  instrucciones_clave,
  beneficios,
  precauciones
FROM ejercicios_biblioteca
WHERE nombre_archivo = 'Arm_Circles_Backward.mov';
```

## 📊 Qué se Almacena

Para cada video, la IA genera y almacena:

### Clasificación Básica
- **nombre_espanol**: "Círculos de Brazos Hacia Atrás"
- **nivel**: iniciacion | intermedio | avanzado
- **areas_cuerpo**: ['hombros', 'brazos']
- **tipo_ejercicio**: ['movilidad', 'estiramiento']
- **posicion**: 'de_pie'
- **requiere_equipo**: false
- **equipo_necesario**: []

### Compatibilidad
- **evitar_si_limitacion**: ['hombros'] (si no es compatible con esa limitación)
- **objetivos**: ['movilidad', 'postura', 'confianza']

### Contenido Generado
- **descripcion_corta**: 1-2 líneas
- **descripcion_completa**: Párrafo detallado
- **instrucciones_clave**: Array de pasos
- **beneficios**: Array de beneficios
- **precauciones**: Array de precauciones

## 🔄 Expandir a TODOS tus Videos

Una vez que hayas probado con los 8 videos de ejemplo y estés satisfecho con la calidad de la clasificación:

### Opción 1: Lista Manual (si tienes la lista)

Edita el nodo "Input: Lista de Videos" y reemplaza el array con todos tus videos:

```javascript
const videos = [
  "video1.mov",
  "video2.mov",
  // ... todos tus videos
  "video500.mov"
];
```

### Opción 2: Obtener desde Firebase (más automatizado)

Necesitarías:
1. Añadir un nodo al inicio que llame a Firebase Storage API
2. Listar todos los videos en tu bucket
3. Extraer los nombres de archivo
4. Pasar al resto del flujo

**Código ejemplo para Firebase:**
```javascript
// Usar Firebase Admin SDK o REST API
const admin = require('firebase-admin');
const bucket = admin.storage().bucket();

const [files] = await bucket.getFiles({
  prefix: 'ejercicios/'  // Tu carpeta
});

const videos = files.map(file => file.name);
return videos.map(nombre => ({ json: { nombre_archivo: nombre } }));
```

## 💰 Estimación de Costos

**Costos de API de Claude:**
- ~$0.01-0.02 por video clasificado
- 100 videos = ~$1-2
- 500 videos = ~$5-10

**Total estimado para clasificar toda tu biblioteca:** $5-15

## ⚠️ Notas Importantes

1. **Verificación Manual**: Después de clasificar, revisa una muestra de ejercicios para verificar la calidad
2. **Re-clasificación**: Si ejecutas el workflow de nuevo con los mismos videos, los actualizará (ON CONFLICT DO UPDATE)
3. **Errores de Parsing**: Si Claude devuelve un formato incorrecto, el workflow fallará en ese video específico
4. **Rate Limits**: La API de Anthropic tiene límites de tasa. Para muchos videos, considera añadir un delay entre llamadas

## 📝 Próximos Pasos

Después de clasificar los videos:

1. **Revisar clasificaciones** en la base de datos
2. **Ajustar manualmente** si es necesario (marca `verificado_manualmente = true`)
3. **Actualizar Workflow 01-bis** para seleccionar ejercicios personalizados
4. **Generar sesiones con IA** usando esta biblioteca clasificada

## 🔍 Troubleshooting

### Error: "API key not found"
→ Configura la credencial Anthropic API en n8n

### Error: "Cannot read file /workflows/..."
→ Verifica que el archivo de prompts existe en la ruta correcta

### Error: "JSON parse error"
→ Claude devolvió un formato incorrecto. Revisa el log del nodo "Parsear Respuesta JSON"

### Los ejercicios no se insertan
→ Verifica que la tabla ejercicios_biblioteca existe ejecutando el script SQL

## 📞 Soporte

Si encuentras problemas, revisa:
1. Logs de cada nodo en n8n
2. Logs de PostgreSQL
3. Respuesta raw de Claude en el nodo "Parsear Respuesta JSON"
