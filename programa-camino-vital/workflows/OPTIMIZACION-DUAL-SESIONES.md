# 🚀 Optimización: Sistema Dual de Sesiones (Fuerza + Cardio)

**Fecha**: 2026-01-10
**Estado**: Listo para implementar
**Ahorro estimado**: 85% en costos de API

---

## 📊 Resumen de Cambios

### **Antes**:
- 5 tipos de sesión (movilidad, fuerza, cardio, equilibrio, mixto)
- Todas las sesiones con ejercicios de BD
- 100 ejercicios en cada prompt
- Modelo: Sonnet 4.5
- **Costo: $0.027/sesión → $43/mes (100 usuarios)**

### **Después**:
- **2 tipos de sesión** (fuerza, cardio)
- **FUERZA**: Con ejercicios de BD (50 ejercicios filtrados)
- **CARDIO**: Instrucciones textuales (SIN ejercicios de BD)
- Modelo: Haiku
- **Costo: $0.004/sesión → $6/mes (100 usuarios)**
- **AHORRO: $37/mes (85%)**

---

## 🎯 Filosofía del Sistema Dual

### **Sesiones de FUERZA** (con videos)
```
✓ Calentamiento: Siempre ejercicios de movilidad (2 ejercicios)
✓ Trabajo Principal: Ejercicios de fuerza (4-6 ejercicios)
✓ Equilibrio: Integrado en ejercicios unilaterales
✓ Formato: JSON con nombre_archivo para videos
✓ Visualización: Workflow 09 con videos embebidos
```

**Ejemplo**:
- Calentamiento: Gato-Vaca, Círculos de Brazos
- Trabajo Principal: Sentadillas, Plancha, Flexiones de Rodillas, Puente de Glúteos

### **Sesiones de CARDIO** (instrucciones textuales)
```
✓ Sin ejercicios de base de datos
✓ Actividades cardiovasculares reales (caminar, trotar, bici)
✓ Guías de intensidad, duración, sensaciones esperadas
✓ Señales de alerta y consejos de seguridad
✓ Formato: JSON con texto plano
✓ Visualización: Workflow 09 con formato textual
```

**Ejemplo**:
- Actividad: "20 minutos de caminata rápida"
- Fases: Calentamiento 5min → Intensidad moderada 12min → Enfriamiento 3min
- Intensidad objetivo: 5-6/10
- Sensaciones: "Debes poder hablar pero con algo de esfuerzo"

---

## 📁 Archivos Modificados

### 1. **Nodo "Preparar Prompt Claude"** (Workflow 01-bis)

**Archivo**: `01-bis-CODIGO-OPTIMIZADO-preparar-prompt.js`

**Cambios principales**:
```javascript
// Matriz simplificada
const matrizDistribucion = {
  'fuerza': [fuerza, cardio, fuerza, cardio],
  'cardio': [cardio, fuerza, cardio, fuerza],
  'movilidad': [fuerza, fuerza, ...],  // Movilidad → más fuerza
  'equilibrio': [fuerza, cardio, ...], // Equilibrio integrado
  'general': [fuerza, cardio, ...]
};

// Detectar tipo de sesión
if (tipoSesion === 'cardio') {
  // Prompt SIN lista de ejercicios (90% más pequeño)
  prompt = `Crea actividad cardiovascular con instrucciones...`;
} else {
  // Prompt con 50 ejercicios filtrados (50% más pequeño)
  const ejerciciosFiltrados = ejercicios.slice(0, 50);
  prompt = `Crea sesión con estos ejercicios...`;
}
```

**Tokens**:
- Cardio: ~800 tokens (vs 7,000 antes) → **89% ahorro**
- Fuerza: ~3,500 tokens (vs 7,000 antes) → **50% ahorro**

### 2. **Nodo "Llamar Claude API"** (Workflow 01-bis)

**Cambio**: Modelo de Sonnet → **Haiku**

```javascript
// ANTES:
{
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 4096,
  ...
}

// DESPUÉS:
{
  model: 'claude-haiku-4-20250901',  // ← CAMBIO AQUÍ
  max_tokens: 4096,
  ...
}
```

**Ahorro**: 74% adicional en costos

### 3. **Nodo "Guardar Sesión en DB"** (Workflow 01-bis)

**Cambio**: Detectar tipo de sesión y guardar formato correspondiente

```sql
-- Para cardio: guardar campos adicionales
INSERT INTO programa_sesiones (
  ...
  tipo_actividad,
  calentamiento_texto,
  actividad_principal,
  senales_de_alerta,
  consejos_seguridad,
  progresion_sugerida
)
```

**NOTA**: Requiere añadir columnas a tabla `programa_sesiones`

### 4. **Workflow 09 "Mostrar Sesión"** (Requiere actualización)

**Cambio**: Detectar tipo de sesión y renderizar apropiadamente

```javascript
// Detectar tipo
const esFuerza = sesion.calentamiento && sesion.trabajo_principal;
const esCardio = sesion.actividad_principal;

if (esFuerza) {
  // Renderizar formato actual con videos
} else {
  // Renderizar formato textual para cardio
}
```

---

## 🗄️ Cambios en Base de Datos

### Añadir columnas para sesiones de cardio:

```sql
SET search_path TO camino_vital;

ALTER TABLE programa_sesiones
ADD COLUMN IF NOT EXISTS tipo_actividad VARCHAR(50),
ADD COLUMN IF NOT EXISTS calentamiento_texto TEXT,
ADD COLUMN IF NOT EXISTS actividad_principal JSONB,
ADD COLUMN IF NOT EXISTS senales_de_alerta TEXT[],
ADD COLUMN IF NOT EXISTS consejos_seguridad TEXT[],
ADD COLUMN IF NOT EXISTS progresion_sugerida TEXT;

-- Verificar
\d programa_sesiones
```

---

## 💡 Estructura JSON por Tipo

### **JSON para FUERZA** (mantiene formato actual):

```json
{
  "titulo": "Sesión 1: Fuerza Funcional",
  "introduccion_personalizada": "...",
  "enfoque": "fuerza",
  "duracion_estimada": "25-30 minutos",
  "calentamiento": [
    {
      "nombre_archivo": "Cat_Cow.mov",
      "nombre_espanol": "Gato-Vaca",
      "repeticiones": "10 repeticiones lentas",
      "duracion_aprox": "2 minutos",
      "notas": "Alterna suavemente entre arquear y redondear"
    }
  ],
  "trabajo_principal": [...]
}
```

### **JSON para CARDIO** (nuevo formato):

```json
{
  "titulo": "Sesión 2: Cardio y Resistencia",
  "introduccion_personalizada": "...",
  "enfoque": "cardio",
  "duracion_estimada": "20-30 minutos",
  "tipo_actividad": "caminata",
  "calentamiento_texto": "Comienza con 3-5 minutos de movimientos suaves...",
  "actividad_principal": {
    "descripcion": "Caminata a ritmo moderado",
    "duracion": "20 minutos",
    "intensidad_objetivo": "Moderada (5-6/10)",
    "como_debe_sentirse": "Debes poder mantener una conversación pero con algo de esfuerzo...",
    "fases": [
      {
        "fase": "Calentamiento",
        "duracion": "5 minutos",
        "intensidad": "Baja (3-4/10)",
        "descripcion": "Camina a paso lento, permitiendo que tu cuerpo se active..."
      },
      {
        "fase": "Intensidad moderada",
        "duracion": "12 minutos",
        "intensidad": "Moderada (5-6/10)",
        "descripcion": "Aumenta el paso. Debes sentir que trabajas pero puedes hablar..."
      },
      {
        "fase": "Enfriamiento",
        "duracion": "3 minutos",
        "intensidad": "Baja (3-4/10)",
        "descripcion": "Reduce gradualmente el ritmo..."
      }
    ]
  },
  "senales_de_alerta": [
    "Dolor en el pecho o dificultad para respirar",
    "Mareo o náuseas intensas",
    "Dolor articular agudo"
  ],
  "consejos_seguridad": [
    "Ten agua cerca y bebe pequeños sorbos",
    "Si necesitas parar, no hay problema",
    "Elige terreno plano y seguro"
  ],
  "progresion_sugerida": "En las próximas sesiones puedes aumentar 2-3 minutos la fase de intensidad moderada"
}
```

---

## 📋 Instrucciones de Implementación

### **Paso 1: Actualizar Base de Datos**

```bash
# Conectar a PostgreSQL
docker exec -it n8n_postgres psql -U n8n -d n8n

# Ejecutar SQL
SET search_path TO camino_vital;

ALTER TABLE programa_sesiones
ADD COLUMN IF NOT EXISTS tipo_actividad VARCHAR(50),
ADD COLUMN IF NOT EXISTS calentamiento_texto TEXT,
ADD COLUMN IF NOT EXISTS actividad_principal JSONB,
ADD COLUMN IF NOT EXISTS senales_de_alerta TEXT[],
ADD COLUMN IF NOT EXISTS consejos_seguridad TEXT[],
ADD COLUMN IF NOT EXISTS progresion_sugerida TEXT;
```

### **Paso 2: Actualizar Workflow 01-bis en n8n**

1. **Abrir workflow** "01-bis Seleccionar Sesiones y Enviar Primera"

2. **Editar nodo "Preparar Prompt Claude"**:
   - Copiar código de `01-bis-CODIGO-OPTIMIZADO-preparar-prompt.js`
   - Reemplazar completamente el código JavaScript

3. **Editar nodo "Llamar Claude API"**:
   - Cambiar modelo de `claude-sonnet-4-5-20250929` a `claude-haiku-4-20250901`

4. **Editar nodo "Guardar Sesión en DB"**:
   - Actualizar SQL para incluir nuevas columnas (solo si tipo es cardio)

5. **Guardar y activar workflow**

### **Paso 3: Actualizar Workflow 09 (Mostrar Sesión)**

Crear lógica para renderizar sesiones de cardio:

```javascript
// En nodo "Generar HTML Sesión"
const esFuerza = sesion.calentamiento && sesion.trabajo_principal;
const esCardio = sesion.tipo_actividad && sesion.actividad_principal;

if (esCardio) {
  // Generar HTML textual para cardio
  const htmlCardio = `
    <div class="cardio-session">
      <h2>${sesion.tipo_actividad}</h2>
      <div class="calentamiento">${sesion.calentamiento_texto}</div>
      <div class="actividad-principal">
        ${sesion.actividad_principal.descripcion}
        <!-- Renderizar fases -->
        ${sesion.actividad_principal.fases.map(fase => `
          <div class="fase">
            <h3>${fase.fase} (${fase.duracion})</h3>
            <p>Intensidad: ${fase.intensidad}</p>
            <p>${fase.descripcion}</p>
          </div>
        `).join('')}
      </div>
      <!-- Señales de alerta, consejos, etc -->
    </div>
  `;
} else {
  // Mantener renderizado actual con videos
}
```

### **Paso 4: Probar Flujo Completo**

1. **Crear usuario de prueba**
2. **Configurar 4 sesiones semanales** → Debería generar: Fuerza, Cardio, Fuerza, Cardio
3. **Verificar sesión 1** (Fuerza): con videos
4. **Completar sesión 1**
5. **Verificar sesión 2** (Cardio): formato textual
6. **Revisar costos en Anthropic dashboard**

---

## 📊 Comparativa de Costos

| Concepto | Antes | Después | Ahorro |
|----------|-------|---------|--------|
| **Prompt Fuerza** | 7,000 tokens | 3,500 tokens | 50% |
| **Prompt Cardio** | 7,000 tokens | 800 tokens | 89% |
| **Modelo** | Sonnet 4.5 | Haiku | 74% |
| **Costo/sesión** | $0.027 | $0.004 | 85% |
| **100 usuarios/mes** | $43 | $6 | $37/mes |

---

## ✅ Ventajas Adicionales

1. **Más realista**: Cardio con actividades reales (caminar, bici)
2. **Más flexible**: No limitado a ejercicios de BD
3. **Mejor UX**: Instrucciones claras de intensidad
4. **Más escalable**: Menos dependencia de videos
5. **Más barato**: 85% ahorro en costos

---

## 🎯 Próximos Pasos (Futuro)

1. **Añadir tags a ejercicios** en BD (movilidad/fuerza)
2. **Filtrar por tags** en lugar de slice(0, 50)
3. **Implementar prompt caching** para ahorro adicional del 90%
4. **Crear librería de actividades cardio** predefinidas

---

**Estado**: ✅ Código listo
**Requiere**: Implementación en n8n + actualización BD
**Tiempo estimado**: 30-45 minutos
**Autor**: Claude Code
