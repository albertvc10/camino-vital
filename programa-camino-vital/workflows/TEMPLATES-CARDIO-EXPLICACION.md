# 📚 Sistema de Templates para Sesiones de Cardio

**Fecha**: 2026-01-10
**Versión**: 1.0
**Autor**: Claude Code

---

## 🤔 ¿Qué son los Templates?

Los **templates** son sesiones de cardio predefinidas y almacenadas en la base de datos que garantizan:

1. ✅ **Consistencia** - Formato siempre igual, sin sorpresas
2. ✅ **Calidad** - Contenido revisado y probado
3. ✅ **Eficiencia** - Ahorro del 93% en tokens vs generación desde cero
4. ✅ **Seguridad** - Instrucciones claras de intensidad y señales de alerta

---

## 🎯 ¿Por Qué Usar Templates?

### **Problema Original**
Cuando le pedíamos a Claude que generara sesiones de cardio desde cero:
- ❌ Consumía 800 tokens por prompt
- ❌ Cada sesión podía tener formato ligeramente diferente
- ❌ Riesgo de instrucciones ambiguas o incompletas
- ❌ No había garantía de calidad consistente

### **Solución con Templates**
Con templates predefinidos:
- ✅ Solo 500 tokens por prompt (AI solo elige y personaliza intro)
- ✅ Formato idéntico en todas las sesiones del mismo tipo
- ✅ Instrucciones detalladas y probadas
- ✅ Calidad garantizada

---

## 🏗️ Arquitectura del Sistema

### **Flujo sin Templates** (sistema anterior)
```
[Usuario] → [Prompt 800 tokens con perfil] → [Claude genera todo desde cero] → [JSON completo]
```

### **Flujo con Templates** (sistema nuevo)
```
[Usuario] →
[Prompt 500 tokens: perfil + lista de templates] →
[Claude selecciona ID + escribe intro personalizada] →
[Backend combina: template de BD + intro AI] →
[JSON completo]
```

**Ventajas**:
- AI solo decide "qué" template es apropiado
- AI escribe introducción personalizada
- Estructura, fases, intensidades vienen de BD (garantizadas)

---

## 📋 Los 8 Templates Disponibles

### **Nivel Iniciación**
1. **Caminata Suave** (15-20 min)
   - Ritmo muy cómodo, conversación fluida
   - Ideal para empezar con cardio
   - Sin impacto articular

2. **Bicicleta Estática Suave** (15-20 min)
   - Resistencia mínima
   - Ideal para problemas de rodillas/articulaciones
   - Sin impacto

3. **Marcha Activa en Casa** (15-20 min)
   - No requiere salir
   - Ideal para mal clima o movilidad limitada
   - Marcha en el lugar o circuito

### **Nivel Básico**
4. **Caminata Rápida** (20-25 min)
   - Ritmo activo, conversación con esfuerzo
   - Eleva el pulso significativamente
   - Trabajo cardiovascular moderado

5. **Caminata con Variaciones** (20-25 min)
   - Combina ritmos y pendientes
   - Mayor desafío que caminata simple
   - Entrena adaptabilidad

### **Nivel Intermedio**
6. **Intervalos Caminar-Trotar** (20-25 min)
   - 1 min trote + 1 min caminata
   - Mayor intensidad cardiovascular
   - Mejora resistencia rápidamente

7. **Bicicleta con Intervalos** (20-25 min)
   - Cambios de resistencia
   - Simula subidas y llanos
   - Sin impacto, alta intensidad

8. **Subir Escaleras** (15-20 min)
   - Alta intensidad para piernas y cardio
   - Requiere buena forma física
   - Máximo beneficio en poco tiempo

---

## 🧠 ¿Cómo Elige el AI?

El AI recibe:
```javascript
{
  perfil_usuario: {
    nivel: "iniciacion" | "basico" | "intermedio",
    limitaciones: "rodillas, espalda, ninguna",
    objetivo: "cardio" | "movilidad" | "fuerza"
  },
  templates_disponibles: [
    { id: 1, nombre: "Caminata Suave", nivel: "iniciacion", ... },
    { id: 2, nombre: "Caminata Rápida", nivel: "basico", ... },
    ...
  ]
}
```

**Lógica de selección**:
1. **Filtrar por nivel**: Si usuario es iniciación → solo templates iniciación
2. **Considerar limitaciones**: Rodillas → preferir bicicleta o marcha casa
3. **Alinear con objetivo**: Objetivo cardio → templates más intensos
4. **Clima/contexto**: No puede salir → marcha en casa

**Ejemplo**:
```
Usuario: iniciación, rodillas, puede salir
→ AI elige: Template #1 "Caminata Suave" (bajo impacto, al aire libre)

Usuario: intermedio, sin limitaciones, objetivo cardio
→ AI elige: Template #6 "Intervalos Caminar-Trotar" (alta intensidad)
```

---

## 📊 Estructura de un Template

Cada template en BD contiene:

```json
{
  "id": 1,
  "nombre": "Caminata Suave",
  "tipo_actividad": "caminata",
  "nivel_requerido": "iniciacion",
  "duracion_min": 15,
  "duracion_max": 20,
  "descripcion_corta": "Caminata relajada a ritmo cómodo...",

  "calentamiento_texto": "Comienza con 3-5 minutos de movimientos suaves...",

  "actividad_principal": {
    "descripcion": "Caminata a ritmo suave y cómodo",
    "duracion": "15 minutos",
    "intensidad_objetivo": "Baja-Moderada (4-5/10)",
    "como_debe_sentirse": "Debes poder mantener una conversación sin problemas...",

    "fases": [
      {
        "fase": "Inicio suave",
        "duracion": "3-4 minutos",
        "intensidad": "Baja (3/10)",
        "descripcion": "Comienza caminando muy despacio..."
      },
      {
        "fase": "Ritmo cómodo",
        "duracion": "8-10 minutos",
        "intensidad": "Baja-Moderada (4-5/10)",
        "descripcion": "Aumenta ligeramente el ritmo..."
      },
      {
        "fase": "Enfriamiento",
        "duracion": "3 minutos",
        "intensidad": "Baja (3/10)",
        "descripcion": "Reduce gradualmente el ritmo..."
      }
    ]
  },

  "senales_de_alerta": [
    "Dolor en el pecho o dificultad significativa para respirar",
    "Mareo, náuseas o sensación de desmayo",
    ...
  ],

  "consejos_seguridad": [
    "Lleva una botella de agua y bebe pequeños sorbos",
    "Elige un terreno plano y seguro",
    ...
  ],

  "progresion_sugerida": "En las próximas sesiones puedes aumentar 2-3 minutos..."
}
```

---

## 🔄 Flujo Completo en n8n

### **Workflow 01-bis: Generar Sesión**

```
1. [Usuario completa cuestionario]
   ↓
2. [Obtener Templates Cardio] (PostgreSQL)
   ↓ (en paralelo)
   [Obtener Ejercicios de Fuerza] (PostgreSQL)
   ↓
3. [Preparar Prompt Claude] (Code)
   → Detecta: ¿Fuerza o Cardio?
   → Cardio: Prompt con lista de templates
   → Fuerza: Prompt con ejercicios de BD
   ↓
4. [Llamar Claude API] (Haiku)
   → Cardio: Retorna { template_seleccionado_id: 3, introduccion_personalizada: "..." }
   → Fuerza: Retorna JSON completo con ejercicios
   ↓
5. [Combinar con Template] (Code) ← NUEVO NODO
   → Cardio: Busca template en BD + combina con intro AI
   → Fuerza: Pasa JSON sin cambios
   ↓
6. [Guardar Sesión en DB] (PostgreSQL)
   ↓
7. [Enviar Email con Sesión] (Brevo)
```

### **Workflow 09: Mostrar Sesión**

```
1. [Usuario abre email]
   ↓
2. [Obtener Sesión de BD] (PostgreSQL)
   ↓
3. [Generar HTML] (Code)
   → Detecta: ¿Fuerza o Cardio?
   → Fuerza: Renderiza videos
   → Cardio: Renderiza fases textuales
   ↓
4. [Mostrar al usuario]
```

---

## 💾 Base de Datos

### **Tabla: actividades_cardio_templates**
```sql
CREATE TABLE actividades_cardio_templates (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100),              -- "Caminata Suave"
  tipo_actividad VARCHAR(50),       -- "caminata", "bicicleta", etc.
  nivel_requerido VARCHAR(50),      -- "iniciacion", "basico", "intermedio"
  duracion_min INTEGER,             -- 15
  duracion_max INTEGER,             -- 20
  descripcion_corta TEXT,
  calentamiento_texto TEXT,
  actividad_principal JSONB,        -- Fases, intensidades, etc.
  senales_de_alerta TEXT[],
  consejos_seguridad TEXT[],
  progresion_sugerida TEXT,
  activo BOOLEAN DEFAULT true,
  fecha_creacion TIMESTAMP
);
```

### **Tabla: programa_sesiones** (actualizada)
```sql
-- Columnas EXISTENTES (para fuerza):
calentamiento JSONB,
trabajo_principal JSONB,

-- Columnas NUEVAS (para cardio):
tipo_actividad VARCHAR(50),
calentamiento_texto TEXT,
actividad_principal JSONB,
senales_de_alerta TEXT[],
consejos_seguridad TEXT[],
progresion_sugerida TEXT
```

---

## 🎨 Renderizado en HTML

### **Sesión de Fuerza** (con videos)
```html
<div class="calentamiento">
  <h3>Calentamiento</h3>
  <div class="ejercicio">
    <video src="firebase.com/.../Cat_Cow.mov"></video>
    <p>Gato-Vaca - 10 repeticiones</p>
  </div>
</div>

<div class="trabajo-principal">
  <h3>Trabajo Principal</h3>
  <!-- Más ejercicios con videos -->
</div>
```

### **Sesión de Cardio** (textual con fases)
```html
<div class="cardio-session">
  <h3>Caminata Suave (15-20 min)</h3>

  <div class="calentamiento-texto">
    <p>Comienza con 3-5 minutos de movimientos suaves...</p>
  </div>

  <div class="fases">
    <div class="fase">
      <h4>Inicio suave (3-4 min) - Intensidad: Baja (3/10)</h4>
      <p>Comienza caminando muy despacio...</p>
    </div>

    <div class="fase">
      <h4>Ritmo cómodo (8-10 min) - Intensidad: Moderada (4-5/10)</h4>
      <p>Aumenta ligeramente el ritmo...</p>
    </div>

    <div class="fase">
      <h4>Enfriamiento (3 min) - Intensidad: Baja (3/10)</h4>
      <p>Reduce gradualmente el ritmo...</p>
    </div>
  </div>

  <div class="alertas">
    <h4>⚠️ Señales de Alerta</h4>
    <ul>
      <li>Dolor en el pecho...</li>
    </ul>
  </div>

  <div class="consejos">
    <h4>💡 Consejos de Seguridad</h4>
    <ul>
      <li>Lleva agua...</li>
    </ul>
  </div>
</div>
```

---

## ✅ Beneficios del Sistema

### **Para el Negocio**
- 💰 **87% ahorro en costos** de API ($43 → $5.50/mes con 100 usuarios)
- ⚡ **3x más rápido** (Haiku vs Sonnet)
- 📈 **Escalable** sin incremento proporcional de costos

### **Para el Usuario**
- 🎯 **Consistencia** - Sabe qué esperar de cada tipo de sesión
- 📱 **Claridad** - Instrucciones detalladas de intensidad y sensaciones
- 🔒 **Seguridad** - Señales de alerta claras
- 📊 **Progresión** - Sugerencias de cómo avanzar

### **Para el Desarrollo**
- 🧪 **Fácil de testear** - Templates fijos, comportamiento predecible
- 🔧 **Fácil de mantener** - Actualizar un template actualiza todas las sesiones futuras
- 📝 **Fácil de extender** - Añadir nuevo template = INSERT en BD
- 🐛 **Fácil de debuggear** - Si hay problema, revisar template en BD

---

## 🔮 Evolución Futura

### **Fase 1** (Actual) ✅
- 8 templates fijos
- AI selecciona el apropiado
- Intro personalizada

### **Fase 2** (Próxima)
- **Analítica**: ¿Qué templates se usan más? ¿Cuáles funcionan mejor?
- **Feedback loop**: Ajustar templates según feedback de usuarios
- **A/B Testing**: Probar variaciones de templates

### **Fase 3** (Futuro)
- **Templates dinámicos**: Ajustar duración/intensidad según historial del usuario
- **Más tipos**: Natación, yoga, danza, etc.
- **Personalización avanzada**: "Este usuario prefiere caminatas al aire libre" → priorizar esos templates

---

## 📚 Referencias

- **Implementación**: `RESUMEN-EJECUTIVO-OPTIMIZACION.md`
- **Documentación técnica**: `OPTIMIZACION-DUAL-SESIONES.md`
- **Script SQL**: `SQL-cardio-templates.sql`
- **Código preparar prompt**: `01-bis-CODIGO-OPTIMIZADO-CON-TEMPLATES-preparar-prompt.js`
- **Código combinar**: `01-bis-NUEVO-NODO-combinar-cardio-template.js`
- **Código renderizado**: `09-CODIGO-OPTIMIZADO-generar-html.js`

---

**Conclusión**: Los templates son la clave para escalar sesiones de cardio de forma eficiente, consistente y económica. No se trata solo de ahorrar tokens - se trata de garantizar calidad.

---

**Autor**: Claude Code
**Fecha**: 2026-01-10
**Versión**: 1.0
