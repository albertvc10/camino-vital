# 🧠 Propuesta: Progresión Inteligente Adaptativa

**Fecha**: 8 Enero 2026
**Concepto**: En lugar de niveles/semanas fijas, la IA adapta cada sesión basándose en el historial real del usuario

---

## 💡 Idea Central

**Actualmente (Rígido)**:
```
Semana 1 → Contenido fijo A
Semana 2 → Contenido fijo B
Semana 3 → Contenido fijo C
...
```

**Propuesta (Adaptativo)**:
```
IA analiza:
- Últimas 3-5 sesiones completadas
- Feedback de cada una (fácil/bien/difícil)
- Perfil inicial del usuario

IA genera siguiente sesión:
- Si progreso bueno → Aumenta dificultad gradualmente
- Si dificultad alta → Mantiene o reduce
- Ajuste continuo, sin "saltos" entre niveles
```

---

## 🎯 Opciones Simples de Implementación

### OPCIÓN 1: Progresión por Feedback (Más Simple)

**Cómo funciona**:
```javascript
// Al generar siguiente sesión, la IA recibe:
const historial = {
  sesiones_completadas: 8,
  ultimas_sesiones: [
    { numero: 6, feedback: "bien", fecha: "2026-01-01" },
    { numero: 7, feedback: "bien", fecha: "2026-01-03" },
    { numero: 8, feedback: "facil", fecha: "2026-01-05" }
  ],
  perfil_inicial: {
    tiempo_sin_ejercicio: "3-6meses",
    nivel_movilidad: "normal",
    limitaciones: "ninguna"
  }
}

// Prompt a Claude:
"Genera una sesión de ejercicios.

Usuario lleva 8 sesiones completadas.
Últimas 3 sesiones: bien, bien, fácil
→ Está progresando bien, aumenta dificultad levemente.

Ajustes sugeridos:
- Repeticiones: 10-12 (antes: 8-10)
- Ejercicios: 6 (antes: 5)
- Incluye 1 variante más desafiante

Perfil inicial: [...]
Genera sesión JSON..."
```

**Ventajas**:
- ✅ Super simple de implementar
- ✅ Usa feedback real del usuario
- ✅ Progresión natural y fluida
- ✅ No necesitas generar 12 semanas de contenido

**Desventajas**:
- ⚠️ Requiere llamada a Claude cada vez (costo API)
- ⚠️ Menos predecible (contenido único cada vez)

---

### OPCIÓN 2: Sistema de "Nivel de Progreso" Invisible

**Cómo funciona**:
```javascript
// Calcular nivel de progreso del usuario
const calcularNivelProgreso = (historial) => {
  let puntos = 0;

  historial.forEach(sesion => {
    if (sesion.feedback === "facil") puntos += 15;
    if (sesion.feedback === "bien") puntos += 10;
    if (sesion.feedback === "dificil") puntos += 5;
  });

  return {
    puntos_totales: puntos,
    nivel: Math.floor(puntos / 50), // Nivel 0, 1, 2, 3...
    porcentaje_progreso: Math.min((puntos / 500) * 100, 100)
  };
}

// Usuario con 8 sesiones, todas "bien": 80 puntos → Nivel 1
// Usuario con 15 sesiones, mix feedback: 150 puntos → Nivel 3

// Prompt a Claude incluye el nivel:
"Usuario nivel de progreso: 1 (80 puntos)
Genera sesión apropiada para ese nivel.
Parámetros base para nivel 1:
- Repeticiones: 10-12
- Ejercicios por sesión: 5-6
- Complejidad: básico-intermedio
..."
```

**Ventajas**:
- ✅ Progresión cuantificable
- ✅ Fácil de visualizar al usuario ("Nivel 3 de 10")
- ✅ Predecible pero flexible

**Desventajas**:
- ⚠️ Necesitas definir parámetros de cada nivel
- ⚠️ Menos personalizado que opción 1

---

### OPCIÓN 3: Parámetros Ajustables Dinámicos (Recomendada ⭐)

**Cómo funciona**:
```javascript
// Cada usuario tiene parámetros de dificultad (en programa_users)
{
  parametros_dificultad: {
    repeticiones_base: 10,       // 8-15
    ejercicios_por_sesion: 5,    // 4-7
    complejidad: "basico",       // basico, intermedio, avanzado
    tiempo_descanso: "amplio",   // amplio, moderado, minimo
    variantes_complejas: false   // true/false
  }
}

// Cada 3 sesiones, ajustar parámetros según feedback
const ajustarParametros = (parametros, ultimasSesiones) => {
  const feedbackMedio = calcularFeedbackMedio(ultimasSesiones);

  if (feedbackMedio === "facil") {
    // Aumentar dificultad
    return {
      ...parametros,
      repeticiones_base: Math.min(parametros.repeticiones_base + 2, 15),
      ejercicios_por_sesion: Math.min(parametros.ejercicios_por_sesion + 1, 7)
    };
  } else if (feedbackMedio === "dificil") {
    // Reducir dificultad
    return {
      ...parametros,
      repeticiones_base: Math.max(parametros.repeticiones_base - 1, 8)
    };
  }

  return parametros; // Mantener si es "bien"
}

// Prompt a Claude usa estos parámetros:
"Genera sesión con parámetros:
- Repeticiones: 10-12
- Ejercicios: 6
- Complejidad: intermedio
- Descanso: moderado
..."
```

**Ventajas**:
- ✅ **Muy flexible y personalizado**
- ✅ Ajuste gradual automático
- ✅ Fácil de ajustar manualmente si necesitas
- ✅ Usuario ve progreso tangible (parámetros aumentan)

**Desventajas**:
- ⚠️ Necesitas campo nuevo en DB (JSONB)
- ⚠️ Más lógica de ajuste

---

### OPCIÓN 4: Progresión por Familias de Ejercicios

**Cómo funciona**:
```javascript
// Base de datos tiene ejercicios con niveles de dificultad
ejercicios_db = [
  {
    familia: "sentadilla",
    ejercicios: [
      { nombre: "Sentadilla básica", nivel: 1, video: "..." },
      { nombre: "Sentadilla con pausa", nivel: 3, video: "..." },
      { nombre: "Sentadilla búlgara", nivel: 5, video: "..." },
      { nombre: "Sentadilla pistol", nivel: 8, video: "..." }
    ]
  },
  {
    familia: "plancha",
    ejercicios: [
      { nombre: "Plancha rodillas", nivel: 1, video: "..." },
      { nombre: "Plancha clásica", nivel: 3, video: "..." },
      { nombre: "Plancha lateral", nivel: 5, video: "..." },
      { nombre: "Plancha con elevación", nivel: 7, video: "..." }
    ]
  }
]

// Usuario lleva 8 sesiones → nivel_progreso = 3
// IA selecciona ejercicios de nivel 2-4 de cada familia
// Genera sesión combinando variantes apropiadas
```

**Ventajas**:
- ✅ Base de datos rica y reutilizable
- ✅ Progresión clara dentro de cada familia
- ✅ Fácil añadir nuevas variantes

**Desventajas**:
- ⚠️ Requiere trabajo previo: catalogar ejercicios
- ⚠️ Menos flexible (limitado a ejercicios en DB)

---

## 🎯 Comparativa Rápida

| Opción | Simplicidad | Personalización | Costo API | Setup Inicial |
|--------|-------------|-----------------|-----------|---------------|
| **Opción 1** - Feedback directo | ⭐⭐⭐ Muy simple | ⭐⭐⭐ Máxima | 💰💰 Media | ⭐⭐⭐ Mínimo |
| **Opción 2** - Sistema puntos | ⭐⭐ Moderada | ⭐⭐ Media | 💰💰 Media | ⭐⭐ Bajo |
| **Opción 3** - Parámetros ajustables | ⭐⭐⭐ Simple | ⭐⭐⭐ Muy alta | 💰💰 Media | ⭐⭐ Bajo |
| **Opción 4** - Familias ejercicios | ⭐ Compleja | ⭐⭐ Media | 💰 Baja | ⭐ Alto |

---

## 🚀 Implementación Recomendada: OPCIÓN 3

**Por qué**:
- Balance perfecto entre simplicidad y personalización
- Ajuste gradual y predecible
- Fácil de implementar (1 campo JSONB en DB)
- Usuario ve progreso tangible
- Fácil de ajustar manualmente si hace falta

### Paso 1: Añadir campo en DB

```sql
SET search_path TO camino_vital;

ALTER TABLE programa_users
ADD COLUMN parametros_dificultad JSONB DEFAULT '{
  "repeticiones_base": 10,
  "ejercicios_por_sesion": 5,
  "complejidad": "basico",
  "tiempo_descanso": "amplio",
  "variantes_complejas": false,
  "progresion_nivel": 1
}'::jsonb;
```

### Paso 2: Modificar generación de sesión (Workflow)

**Actualmente**:
```javascript
// Prompt a Claude para generar sesión
const prompt = `Genera una sesión de ejercicios para:
Perfil: ${usuario.perfil_inicial}
Nivel: ${usuario.nivel_actual}
...`;
```

**Nueva versión**:
```javascript
// Obtener parámetros de dificultad
const params = usuario.parametros_dificultad;

// Analizar últimas 3 sesiones
const ultimasSesiones = await obtenerUltimasSesiones(usuario.id, 3);
const feedbacks = ultimasSesiones.map(s => s.feedback);

// Ajustar parámetros si es necesario (cada 3 sesiones)
if (usuario.sesiones_completadas_semana % 3 === 0) {
  params = ajustarParametros(params, feedbacks);
  await actualizarParametros(usuario.id, params);
}

// Prompt con parámetros dinámicos
const prompt = `Genera una sesión de ejercicios personalizada.

PARÁMETROS DE DIFICULTAD:
- Repeticiones por ejercicio: ${params.repeticiones_base}-${params.repeticiones_base + 2}
- Número de ejercicios: ${params.ejercicios_por_sesion}
- Complejidad: ${params.complejidad}
- Tiempo de descanso: ${params.tiempo_descanso}
- Incluir variantes complejas: ${params.variantes_complejas ? 'Sí' : 'No'}

HISTORIAL RECIENTE:
${feedbacks.map((f, i) => `Sesión ${i+1}: ${f}`).join('\n')}

PERFIL USUARIO:
${JSON.stringify(usuario.perfil_inicial, null, 2)}

INSTRUCCIONES:
${feedbacks.filter(f => f === "facil").length >= 2
  ? "Usuario encuentra sesiones fáciles. Aumenta ligeramente la dificultad."
  : feedbacks.filter(f => f === "dificil").length >= 2
  ? "Usuario encuentra sesiones difíciles. Mantén nivel o reduce levemente."
  : "Usuario progresa bien. Mantén nivel actual."}

Genera sesión en formato JSON...`;
```

### Paso 3: Ajuste automático de parámetros

```javascript
function ajustarParametros(params, ultimosFeedbacks) {
  const faciles = ultimosFeedbacks.filter(f => f === "facil").length;
  const dificiles = ultimosFeedbacks.filter(f => f === "dificil").length;

  const nuevos = { ...params };

  // Si 2+ sesiones fueron fáciles → aumentar
  if (faciles >= 2) {
    nuevos.repeticiones_base = Math.min(params.repeticiones_base + 1, 15);
    nuevos.progresion_nivel += 1;

    // Cada 2 niveles, aumentar ejercicios
    if (nuevos.progresion_nivel % 2 === 0) {
      nuevos.ejercicios_por_sesion = Math.min(params.ejercicios_por_sesion + 1, 7);
    }

    // A nivel 3+, cambiar complejidad
    if (nuevos.progresion_nivel >= 3 && params.complejidad === "basico") {
      nuevos.complejidad = "intermedio";
    }

    // A nivel 6+, activar variantes
    if (nuevos.progresion_nivel >= 6) {
      nuevos.variantes_complejas = true;
      nuevos.tiempo_descanso = "moderado";
    }
  }

  // Si 2+ sesiones fueron difíciles → reducir
  if (dificiles >= 2) {
    nuevos.repeticiones_base = Math.max(params.repeticiones_base - 1, 8);
    nuevos.progresion_nivel = Math.max(nuevos.progresion_nivel - 1, 1);
  }

  return nuevos;
}
```

---

## 📊 Vista Usuario: Sin "Niveles" Visibles

**En lugar de**: "Nivel Iniciación, Semana 3"

**Mostrar**:
```
🎯 Tu progreso: 34%
💪 Sesiones completadas: 12

Próxima sesión:
→ Repeticiones: 12
→ Ejercicios: 6
→ Dificultad: Intermedia
```

**O más simple**:
```
📈 Progresión: Nivel 4 de 10
Siguiente sesión adaptada a tu ritmo
```

Usuario no ve "cambios de nivel" abruptos, solo ve que las sesiones se van adaptando a su progreso.

---

## 🎨 Visualización del Progreso

### En el checkpoint dominical:

```html
<div style="background: linear-gradient(to right, #4CAF50 0%, #4CAF50 34%, #e0e0e0 34%, #e0e0e0 100%); height: 20px; border-radius: 10px;">
  <div style="padding: 2px 10px; color: white; font-weight: bold;">
    Progreso: 34%
  </div>
</div>

<p style="margin-top: 10px; color: #666;">
  🏆 Has completado 12 sesiones<br>
  📈 Tus ejercicios se han adaptado a tu progreso<br>
  💪 Repeticiones actuales: 12 (comenzaste con 10)
</p>
```

---

## 🔄 Flujo Completo Ejemplo

**Sesión 1-3** (Usuario nuevo):
```
parametros_dificultad: {
  repeticiones_base: 10,
  ejercicios_por_sesion: 5,
  complejidad: "basico",
  progresion_nivel: 1
}

Feedback: "bien", "bien", "facil"
→ Progresa bien, ajustar parámetros
```

**Sesión 4-6** (Ajuste automático):
```
parametros_dificultad: {
  repeticiones_base: 11,  // ↑ +1
  ejercicios_por_sesion: 5,
  complejidad: "basico",
  progresion_nivel: 2  // ↑ +1
}

Feedback: "bien", "facil", "facil"
→ Encuentra fácil, subir más
```

**Sesión 7-9**:
```
parametros_dificultad: {
  repeticiones_base: 12,  // ↑ +1
  ejercicios_por_sesion: 6,  // ↑ +1
  complejidad: "intermedio",  // ↑ Cambio
  progresion_nivel: 4  // ↑ +2
}

Feedback: "bien", "bien", "dificil"
→ Nivel apropiado, mantener
```

**Sesión 10-12** (Mantiene):
```
parametros_dificultad: {
  repeticiones_base: 12,  // = Mantiene
  ejercicios_por_sesion: 6,  // = Mantiene
  complejidad: "intermedio",
  progresion_nivel: 4
}
```

**Progresión visible para el usuario**:
- Sesión 1: "Progreso 3%"
- Sesión 6: "Progreso 18%"
- Sesión 12: "Progreso 36%"

---

## 💰 Estimación de Costos

**Con Opción 3**:
- 1 llamada a Claude por sesión generada
- ~1000 tokens input + ~500 output = ~$0.008 por sesión
- Usuario con 3 sesiones/semana durante 12 semanas:
  - 36 sesiones × $0.008 = **~$0.29 por usuario completo**

**Muy asumible** para 75 usuarios = ~$22/mes en generación de contenido.

---

## 🎯 Próximos Pasos (Si te gusta esta opción)

1. ✅ **Añadir campo `parametros_dificultad` a programa_users**
2. ✅ **Modificar workflow de generación de sesión** para incluir parámetros
3. ✅ **Implementar función de ajuste automático** cada 3 sesiones
4. ✅ **Actualizar email de sesión** para mostrar "Progreso X%"
5. ✅ **Probar con 1 usuario** durante 2 semanas

**Tiempo estimado**: 2-3 horas de implementación

---

## ❓ Preguntas

1. **¿Te gusta la Opción 3 (parámetros ajustables)?**
   - O prefieres Opción 1 (feedback directo - más simple)
   - O Opción 2 (sistema de puntos)

2. **¿Cómo quieres que se vea el progreso al usuario?**
   - Porcentaje (34%)
   - Nivel (Nivel 4 de 10)
   - Ambos
   - Oculto (no mostrar nada)

3. **¿Cada cuántas sesiones ajustar parámetros?**
   - Cada 3 sesiones (recomendado)
   - Cada semana (domingo en checkpoint)
   - Cada 5 sesiones

4. **¿Implementamos esto ahora o prefieres otra prioridad?**

---

**Mi recomendación**: Opción 3 es perfecta para tu caso. Simple, efectiva, personalizada y escalable.
