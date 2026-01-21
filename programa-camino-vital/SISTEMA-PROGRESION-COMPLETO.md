# 🎯 Sistema de Progresión Completo: Múltiples Factores

**Problema identificado**: El feedback solo ("fácil/bien/difícil") no cuenta toda la historia.

---

## 🔍 Análisis: ¿Qué nos dice cada dato?

### 1. Feedback de Dificultad (Actual)
```
"fácil" / "bien" / "difícil"
```

**Lo que nos dice**:
- ✅ Percepción subjetiva del usuario
- ✅ Si la sesión fue apropiada

**Lo que NO nos dice**:
- ❌ Si realmente completó todos los ejercicios
- ❌ Si está siendo consistente
- ❌ Si está motivado o está a punto de abandonar

### 2. Adherencia (Consistencia)
```javascript
// Datos disponibles:
sesiones_completadas_semana: 2,
sesiones_objetivo_semana: 3,
semanas_consecutivas_completas: 4
```

**Lo que nos dice**:
- ✅ Si completa lo que se propone
- ✅ Si es constante
- ✅ Nivel de compromiso real

**Ejemplo**:
```
Usuario A: Feedback "bien", pero solo completa 1/3 sesiones
→ Problema: No es dificultad, es adherencia

Usuario B: Feedback "difícil", pero completa 3/3 sesiones
→ No reducir dificultad, está comprometido
```

### 3. Cadencia (Tiempo entre sesiones)
```javascript
// Calculable con:
ultima_sesion_completada: "2026-01-06",
fecha_ultimo_envio: "2026-01-08",
dias_desde_ultima: 2
```

**Lo que nos dice**:
- ✅ Si hay problemas de motivación
- ✅ Si necesita ajustar expectativas

**Ejemplo**:
```
Usuario A: Sesiones cada 2 días → Ritmo saludable
Usuario B: Sesiones cada 7 días → Algo pasa, revisar
```

### 4. Inactividad / Abandono
```javascript
semanas_consecutivas_inactivas: 2,
fecha_pausa: null
```

**Lo que nos dice**:
- ✅ Riesgo de abandono
- ✅ Necesidad de intervención

---

## 🧠 Sistema de Progresión Multi-Factor

### Factores a considerar:

```javascript
const factoresProgresion = {
  // Factor 1: Dificultad percibida (40%)
  feedback_dificultad: {
    peso: 0.4,
    valores: {
      "facil": +1,    // Aumentar dificultad
      "bien": 0,      // Mantener
      "dificil": -1   // Reducir dificultad
    }
  },

  // Factor 2: Adherencia (30%)
  adherencia: {
    peso: 0.3,
    calculo: sesiones_completadas / sesiones_objetivo,
    valores: {
      ">= 1.0": +1,   // Completa todo → puede más
      ">= 0.7": 0,    // Completa mayoría → apropiado
      "< 0.7": -1     // No completa → reducir o problema motivación
    }
  },

  // Factor 3: Consistencia temporal (20%)
  consistencia: {
    peso: 0.2,
    calculo: semanas_consecutivas_completas,
    valores: {
      ">= 3": +1,     // Muy consistente → aumentar
      ">= 1": 0,      // Normal → mantener
      "0": -1         // Rompió racha → cuidado
    }
  },

  // Factor 4: Cadencia (10%)
  cadencia: {
    peso: 0.1,
    calculo: dias_promedio_entre_sesiones,
    valores: {
      "<= 3": +1,     // Ritmo rápido → puede más
      "3-5": 0,       // Ritmo normal → apropiado
      "> 5": -1       // Ritmo lento → no aumentar
    }
  }
}
```

---

## 📊 Ejemplos de Decisiones Multi-Factor

### Caso 1: Usuario Comprometido pero con Dificultad

```javascript
{
  feedback_dificultad: "dificil" (-1),
  adherencia: 3/3 = 1.0 (+1),
  consistencia: 4 semanas (+1),
  cadencia: 2.5 días (+1)
}

Score ponderado:
(-1 × 0.4) + (+1 × 0.3) + (+1 × 0.2) + (+1 × 0.1) = +0.2

DECISIÓN: Mantener nivel actual
RAZÓN: Aunque dice "difícil", está comprometido y consistente.
       No reducir, solo dar tiempo para adaptarse.
```

### Caso 2: Usuario con Feedback "Bien" pero Baja Adherencia

```javascript
{
  feedback_dificultad: "bien" (0),
  adherencia: 1/3 = 0.33 (-1),
  consistencia: 0 semanas (-1),
  cadencia: 7 días (-1)
}

Score ponderado:
(0 × 0.4) + (-1 × 0.3) + (-1 × 0.2) + (-1 × 0.1) = -0.6

DECISIÓN: NO aumentar dificultad + revisar motivación
RAZÓN: El problema no es dificultad física, es adherencia.
       Quizás reducir expectativas o sesiones más cortas.
```

### Caso 3: Usuario Avanzando Bien

```javascript
{
  feedback_dificultad: "facil" (+1),
  adherencia: 4/3 = 1.33 (+1), // Hace sesiones extra
  consistencia: 6 semanas (+1),
  cadencia: 2 días (+1)
}

Score ponderado:
(+1 × 0.4) + (+1 × 0.3) + (+1 × 0.2) + (+1 × 0.1) = +1.0

DECISIÓN: Aumentar dificultad significativamente
RAZÓN: Usuario está dominando el nivel actual y muy motivado.
```

---

## 🛠️ Implementación: Función de Análisis

```javascript
function analizarProgresion(usuario, ultimasSesiones) {
  // 1. Calcular feedback promedio
  const feedbacks = ultimasSesiones.map(s => s.respuesta);
  const feedbackScore = calcularFeedbackScore(feedbacks);

  // 2. Calcular adherencia
  const adherencia = usuario.sesiones_completadas_semana / usuario.sesiones_objetivo_semana;
  const adherenciaScore = adherencia >= 1.0 ? 1 : adherencia >= 0.7 ? 0 : -1;

  // 3. Calcular consistencia
  const consistenciaScore = usuario.semanas_consecutivas_completas >= 3 ? 1
    : usuario.semanas_consecutivas_completas >= 1 ? 0 : -1;

  // 4. Calcular cadencia
  const diasPromedio = calcularDiasPromedio(ultimasSesiones);
  const cadenciaScore = diasPromedio <= 3 ? 1 : diasPromedio <= 5 ? 0 : -1;

  // 5. Score ponderado
  const scoreTotal =
    (feedbackScore * 0.4) +
    (adherenciaScore * 0.3) +
    (consistenciaScore * 0.2) +
    (cadenciaScore * 0.1);

  return {
    score: scoreTotal,
    factores: {
      feedback: feedbackScore,
      adherencia: adherenciaScore,
      consistencia: consistenciaScore,
      cadencia: cadenciaScore
    },
    decision: determinarDecision(scoreTotal),
    razon: generarRazon(scoreTotal, {
      feedbackScore,
      adherenciaScore,
      consistenciaScore,
      cadenciaScore
    })
  };
}

function determinarDecision(score) {
  if (score >= 0.5) return "AUMENTAR_DIFICULTAD";
  if (score >= -0.3) return "MANTENER_NIVEL";
  if (score >= -0.6) return "MANTENER_SIN_AUMENTAR";
  return "REDUCIR_O_INTERVENIR";
}

function generarRazon(score, factores) {
  if (factores.adherencia < 0 && factores.feedback >= 0) {
    return "El usuario reporta dificultad apropiada pero tiene baja adherencia. No es problema de dificultad física, sino de motivación/tiempo. Considera sesiones más cortas o menos frecuentes.";
  }

  if (factores.feedback < 0 && factores.adherencia >= 0) {
    return "El usuario encuentra las sesiones difíciles pero está comprometido. Mantén el nivel y dale tiempo para adaptarse.";
  }

  if (score >= 0.5) {
    return "El usuario está progresando muy bien en todos los aspectos. Aumenta la dificultad para mantenerlo desafiado.";
  }

  if (score < -0.6) {
    return "Detectamos señales de posible abandono. Considera intervenir con email personalizado o ajustar expectativas.";
  }

  return "El usuario progresa normalmente. Mantén el nivel actual.";
}
```

---

## 📧 Ajustes Inteligentes Basados en Análisis

### Ajuste 1: Dificultad Física

```javascript
if (analisis.decision === "AUMENTAR_DIFICULTAD") {
  parametros.repeticiones_base += 2;
  parametros.ejercicios_por_sesion += 1;
  parametros.progresion_nivel += 1;
}

if (analisis.decision === "REDUCIR_O_INTERVENIR") {
  // Solo reducir si feedback es "dificil"
  if (analisis.factores.feedback < 0) {
    parametros.repeticiones_base -= 1;
  }
}
```

### Ajuste 2: Volumen (según adherencia)

```javascript
// Si baja adherencia pero feedback OK
if (analisis.factores.adherencia < 0 && analisis.factores.feedback >= 0) {
  // Reducir sesiones objetivo en vez de dificultad
  await actualizarUsuario(usuario.id, {
    sesiones_objetivo_semana: Math.max(usuario.sesiones_objetivo_semana - 1, 2),
    notas_internas: "Reducido objetivos por baja adherencia"
  });

  // Enviar email personalizado
  await enviarEmailMotivacion(usuario, {
    mensaje: "Hemos ajustado tu programa a 2 sesiones/semana para que sea más manejable"
  });
}
```

### Ajuste 3: Intervención Proactiva

```javascript
// Detectar riesgo de abandono
if (usuario.semanas_consecutivas_inactivas >= 2) {
  await enviarEmailIntervencion(usuario, {
    asunto: "Te echamos de menos 😊",
    contenido: "¿Qué tal si retomamos con una sesión corta y fácil?"
  });

  // Resetear progresión a algo más fácil
  parametros.repeticiones_base = Math.max(parametros.repeticiones_base - 2, 8);
  parametros.complejidad = "basico";
}
```

---

## 🎯 Prompt Mejorado a Claude

**Antes** (solo feedback):
```
"Últimas sesiones: fácil, fácil, bien
→ Aumenta dificultad"
```

**Después** (multi-factor):
```javascript
const analisis = analizarProgresion(usuario, ultimasSesiones);

const prompt = `Genera sesión personalizada.

ANÁLISIS DE PROGRESIÓN:
- Score total: ${analisis.score.toFixed(2)}
- Decisión: ${analisis.decision}
- Razón: ${analisis.razon}

FACTORES:
- Feedback dificultad: ${analisis.factores.feedback > 0 ? "Encuentra fácil" : analisis.factores.feedback < 0 ? "Encuentra difícil" : "Apropiado"}
- Adherencia: ${usuario.sesiones_completadas_semana}/${usuario.sesiones_objetivo_semana} (${(adherencia * 100).toFixed(0)}%)
- Racha: ${usuario.semanas_consecutivas_completas} semanas consecutivas
- Cadencia: Sesión cada ${diasPromedio.toFixed(1)} días

PARÁMETROS ACTUALES:
- Repeticiones: ${parametros.repeticiones_base}-${parametros.repeticiones_base + 2}
- Ejercicios: ${parametros.ejercicios_por_sesion}
- Complejidad: ${parametros.complejidad}

${analisis.decision === "AUMENTAR_DIFICULTAD"
  ? "→ Usuario progresa muy bien. AUMENTA dificultad gradualmente."
  : analisis.decision === "MANTENER_SIN_AUMENTAR"
  ? "→ Mantén nivel actual. Usuario está en proceso de adaptación."
  : analisis.decision === "REDUCIR_O_INTERVENIR"
  ? "→ Usuario tiene dificultades. Reduce complejidad o sugiere modificaciones."
  : "→ Usuario en nivel apropiado. Mantén."}

Genera sesión en formato JSON...`;
```

---

## 📊 Dashboard para el Usuario

```html
<div style="background: white; padding: 30px; border-radius: 12px;">
  <h2>Tu Progreso</h2>

  <!-- Progreso general -->
  <div style="background: linear-gradient(to right, #4CAF50 0%, #4CAF50 42%, #e0e0e0 42%); height: 30px; border-radius: 15px; margin: 20px 0;">
    <div style="padding: 5px 15px; color: white; font-weight: bold;">
      42% Completado
    </div>
  </div>

  <!-- Estadísticas -->
  <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-top: 30px;">

    <div style="background: #e8f5e9; padding: 15px; border-radius: 8px;">
      <div style="font-size: 32px; font-weight: bold; color: #4CAF50;">12</div>
      <div style="color: #666;">Sesiones completadas</div>
    </div>

    <div style="background: #fff3cd; padding: 15px; border-radius: 8px;">
      <div style="font-size: 32px; font-weight: bold; color: #856404;">4</div>
      <div style="color: #666;">Semanas consecutivas</div>
    </div>

    <div style="background: #e3f2fd; padding: 15px; border-radius: 8px;">
      <div style="font-size: 32px; font-weight: bold; color: #1976d2;">100%</div>
      <div style="color: #666;">Adherencia semana</div>
    </div>

    <div style="background: #f3e5f5; padding: 15px; border-radius: 8px;">
      <div style="font-size: 32px; font-weight: bold; color: #7b1fa2;">12</div>
      <div style="color: #666;">Repeticiones actuales</div>
    </div>

  </div>

  <!-- Progresión de dificultad -->
  <div style="margin-top: 30px; padding: 20px; background: #f5f5f5; border-radius: 8px;">
    <h3 style="margin: 0 0 15px 0;">📈 Tu Evolución</h3>
    <p style="margin: 0; color: #666;">
      Comenzaste con <strong>10 repeticiones</strong> por ejercicio.<br>
      Ahora estás en <strong>12 repeticiones</strong>.<br>
      Has aumentado tu capacidad en un <strong>20%</strong> 💪
    </p>
  </div>

</div>
```

---

## 🎯 Resumen: Multi-Factor vs Solo Feedback

| Aspecto | Solo Feedback | Multi-Factor |
|---------|---------------|--------------|
| **Precisión** | ⭐⭐ Baja | ⭐⭐⭐⭐⭐ Alta |
| **Detecta adherencia** | ❌ No | ✅ Sí |
| **Detecta abandono** | ❌ No | ✅ Sí |
| **Intervención proactiva** | ❌ No | ✅ Sí |
| **Personalización real** | ⭐⭐ Media | ⭐⭐⭐⭐⭐ Máxima |
| **Complejidad** | ⭐⭐⭐ Simple | ⭐⭐⭐ Moderada |

---

## 💡 Recomendación Final

**Usa sistema multi-factor** porque:

1. ✅ **Es más preciso**: No te guías solo por lo que dice, sino por lo que hace
2. ✅ **Detecta problemas temprano**: Puedes intervenir antes del abandono
3. ✅ **Personalización real**: Cada usuario avanza según su realidad, no su percepción
4. ✅ **Datos ya disponibles**: No necesitas añadir nada nuevo a la DB
5. ✅ **Complejidad manejable**: Solo una función de análisis

**Implementación**:
- Añadir función `analizarProgresion()` al workflow
- Llamarla cada 3 sesiones antes de ajustar parámetros
- Usar el resultado para decidir ajustes
- Incluir análisis en prompt a Claude

**Tiempo**: +1 hora adicional vs solo feedback, pero vale la pena.

---

**¿Te convence el sistema multi-factor o prefieres empezar más simple?**
