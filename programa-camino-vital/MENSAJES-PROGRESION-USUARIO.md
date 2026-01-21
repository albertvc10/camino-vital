# 💬 Mensajes Personalizados de Progresión

**Concepto**: Explicar al usuario POR QUÉ su programa se está ajustando de cierta manera.

---

## 🎯 Ventajas de Comunicar la Progresión

1. ✅ **Educación**: Usuario entiende cómo funciona el sistema
2. ✅ **Motivación**: Ve que el sistema "entiende" su situación
3. ✅ **Confianza**: No es una caja negra, hay transparencia
4. ✅ **Ajuste de expectativas**: Si no progresa, sabe por qué
5. ✅ **Engagement**: Se siente acompañado, no solo

---

## 📧 Dónde Mostrar los Mensajes

### Opción 1: En el Email de la Sesión (Recomendado)

```html
<!-- Inicio del email de sesión -->
<div style="background: #e8f5e9; padding: 20px; border-left: 4px solid #4CAF50; margin-bottom: 30px;">
  <h3 style="margin: 0 0 10px 0; color: #2e7d32;">📈 Sobre tu progresión</h3>
  <p style="margin: 0; color: #555;">
    {{ mensaje_progresion }}
  </p>
</div>

<!-- Luego la sesión normal -->
<h2>Sesión de hoy: {{ titulo }}</h2>
...
```

### Opción 2: Al Completar la Sesión

```html
<!-- Después de click "Sesión completada" -->
<div class="mensaje-progresion">
  <h2>¡Genial! Sesión completada</h2>
  <div class="analisis">
    {{ mensaje_progresion }}
  </div>
  <button>Ver siguiente sesión</button>
</div>
```

### Opción 3: En Checkpoint Dominical

```html
<!-- Resumen semanal -->
<h2>Resumen de tu semana</h2>
<p>Completaste 3 de 3 sesiones 🎉</p>

<div class="proxima-semana">
  <h3>Para la próxima semana:</h3>
  <p>{{ mensaje_ajuste_proxima_semana }}</p>
</div>
```

---

## 💬 Biblioteca de Mensajes Personalizados

### Función Generadora de Mensajes

```javascript
function generarMensajeProgresion(analisis, parametros, parametrosAnteriores) {
  const { score, factores, decision } = analisis;

  // CASO 1: Aumentando dificultad
  if (decision === "AUMENTAR_DIFICULTAD") {
    return generarMensajeAumento(factores, parametros, parametrosAnteriores);
  }

  // CASO 2: Manteniendo nivel
  if (decision === "MANTENER_NIVEL") {
    return generarMensajeMantenimiento(factores, parametros);
  }

  // CASO 3: Reduciendo o interviniendo
  if (decision === "REDUCIR_O_INTERVENIR") {
    return generarMensajeIntervencion(factores, parametros);
  }

  return generarMensajeGenerico();
}
```

---

## 📝 Mensajes: Aumentando Dificultad

### Variante 1: Progreso Excelente
```javascript
function generarMensajeAumento(factores, params, paramsAnt) {
  if (factores.feedback > 0 && factores.adherencia > 0 && factores.consistencia > 0) {
    return `
      <strong>¡Estás avanzando genial! 🚀</strong><br><br>

      Has completado todas tus sesiones y las encuentras manejables.
      Es momento de subir un peldaño:<br><br>

      <ul style="margin: 10px 0; padding-left: 20px;">
        <li>Repeticiones: <strong>${paramsAnt.repeticiones_base}</strong> → <strong>${params.repeticiones_base}</strong> (+${params.repeticiones_base - paramsAnt.repeticiones_base})</li>
        ${params.ejercicios_por_sesion > paramsAnt.ejercicios_por_sesion
          ? `<li>Ejercicios: <strong>${paramsAnt.ejercicios_por_sesion}</strong> → <strong>${params.ejercicios_por_sesion}</strong></li>`
          : ''}
      </ul>

      <em>Tu cuerpo está listo para más. Vamos a por ello 💪</em>
    `;
  }

  // Variante 2: Buen progreso con racha
  if (factores.consistencia > 0) {
    return `
      <strong>¡${factores.consistencia} semanas seguidas! 🔥</strong><br><br>

      Tu constancia está dando resultados. Has demostrado que puedes con más,
      así que vamos a aumentar levemente la intensidad:<br><br>

      → Repeticiones: <strong>${params.repeticiones_base}</strong> (antes: ${paramsAnt.repeticiones_base})<br><br>

      <em>La consistencia es la clave. Sigue así 👏</em>
    `;
  }

  // Variante 3: Feedback "fácil"
  return `
    <strong>Veo que estás dominando este nivel 💪</strong><br><br>

    Tus últimas sesiones han sido "fáciles" para ti.
    Es hora de un pequeño reto:<br><br>

    → Repeticiones: <strong>${params.repeticiones_base}</strong> (antes: ${paramsAnt.repeticiones_base})<br><br>

    <em>No te preocupes, el cambio es gradual. Verás que puedes 😊</em>
  `;
}
```

---

## 📝 Mensajes: Manteniendo Nivel

### Variante 1: Nivel Apropiado
```javascript
function generarMensajeMantenimiento(factores, params) {
  if (factores.feedback === 0 && factores.adherencia >= 0) {
    return `
      <strong>Estás en el nivel perfecto 🎯</strong><br><br>

      Tus sesiones están siendo desafiantes pero alcanzables.
      Vamos a mantener este nivel unas sesiones más para que
      tu cuerpo se adapte completamente.<br><br>

      → Repeticiones: <strong>${params.repeticiones_base}</strong> (mantenemos)<br>
      → Ejercicios: <strong>${params.ejercicios_por_sesion}</strong> (mantenemos)<br><br>

      <em>La progresión sostenible es más importante que la rápida 📈</em>
    `;
  }

  // Variante 2: Adaptándose
  if (factores.feedback < 0 && factores.adherencia > 0) {
    return `
      <strong>Tu cuerpo se está adaptando 💪</strong><br><br>

      Aunque encuentras las sesiones algo exigentes, estás completándolas todas.
      Eso significa que solo necesitas tiempo para adaptarte.<br><br>

      Mantenemos el nivel actual:<br>
      → Repeticiones: <strong>${params.repeticiones_base}</strong><br><br>

      <em>En 2-3 sesiones más, este nivel te parecerá más fácil. Confía en el proceso 🌱</em>
    `;
  }

  // Variante 3: Primera vez en nuevo nivel
  return `
    <strong>Consolidando tu progreso 🎯</strong><br><br>

    Acabas de subir de nivel recientemente. Es normal que las primeras
    sesiones se sientan más exigentes.<br><br>

    Mantenemos:<br>
    → Repeticiones: <strong>${params.repeticiones_base}</strong><br>
    → Ejercicios: <strong>${params.ejercicios_por_sesion}</strong><br><br>

    <em>Dale tiempo a tu cuerpo. La adaptación llega 🌟</em>
  `;
}
```

---

## 📝 Mensajes: Reduciendo o Interviniendo

### Variante 1: Baja Adherencia (Problema de Tiempo/Motivación)
```javascript
function generarMensajeIntervencion(factores, params) {
  if (factores.adherencia < 0 && factores.feedback >= 0) {
    return `
      <strong>Hemos notado algo importante 👀</strong><br><br>

      No estás pudiendo completar todas las sesiones que te propusiste.
      Esto NO es un problema de capacidad física, sino de tiempo/rutina.<br><br>

      <strong>Vamos a hacer un ajuste:</strong><br>
      → Reducimos a <strong>2 sesiones por semana</strong> (antes: 3)<br>
      → Mantenemos la dificultad actual (tu cuerpo puede con ella)<br><br>

      <div style="background: #fff3cd; padding: 15px; border-radius: 8px; margin-top: 15px;">
        💡 <strong>Consejo:</strong> Es mejor hacer 2 sesiones bien hechas
        que proponerte 3 y sentirte mal por no cumplir.
        La constancia importa más que la cantidad.
      </div><br>

      <em>Ajustamos el programa a tu realidad. Estamos contigo 🤝</em>
    `;
  }

  // Variante 2: Dificultad Alta + Baja Adherencia
  if (factores.feedback < 0 && factores.adherencia < 0) {
    return `
      <strong>Momento de ajustar el ritmo 🎯</strong><br><br>

      Vemos que las sesiones están siendo muy exigentes Y estás
      teniendo dificultad para completarlas todas.<br><br>

      <strong>Vamos a hacer 2 cambios:</strong><br>
      1. Reducimos repeticiones: <strong>${params.repeticiones_base}</strong> (antes: ${params.repeticiones_base + 1})<br>
      2. Reducimos frecuencia: <strong>2 sesiones/semana</strong> (antes: 3)<br><br>

      <div style="background: #e8f5e9; padding: 15px; border-radius: 8px; margin-top: 15px;">
        ✅ <strong>Esto NO es retroceder.</strong> Es encontrar el punto justo
        para que puedas ser constante. La progresión viene de la constancia,
        no de la intensidad.
      </div><br>

      <em>El objetivo es que disfrutes del proceso, no que te agobies 😊</em>
    `;
  }

  // Variante 3: Riesgo de Abandono
  if (factores.consistencia < 0) {
    return `
      <strong>¡Te echamos de menos! 😊</strong><br><br>

      Llevas unas semanas sin completar sesiones.
      La vida se pone complicada a veces, lo entendemos.<br><br>

      <strong>Propuesta:</strong> ¿Qué tal si empezamos de nuevo con algo
      super manejable?<br><br>

      → <strong>1 sesión de 15 minutos</strong> esta semana<br>
      → Ejercicios básicos que ya conoces<br>
      → Sin presión, solo para retomar el hábito<br><br>

      <div style="background: #fff3cd; padding: 15px; border-radius: 8px; margin-top: 15px;">
        💬 <strong>¿Necesitas ayuda?</strong><br>
        Si hay algo que podamos ajustar para que te sea más fácil,
        responde a este email. Estamos aquí para adaptarnos a ti.
      </div><br>

      <em>Un pasito es mejor que ningún paso 👣</em>
    `;
  }

  return generarMensajeGenerico();
}
```

---

## 🎨 Diseño Visual del Mensaje

```html
<!-- Mensaje con diseño atractivo -->
<div style="
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 25px;
  border-radius: 12px;
  margin: 30px 0;
">
  <div style="font-size: 24px; margin-bottom: 10px;">📈</div>
  <h3 style="margin: 0 0 15px 0; color: white; font-size: 20px;">
    Sobre tu progresión
  </h3>
  <div style="
    background: rgba(255,255,255,0.15);
    padding: 20px;
    border-radius: 8px;
    backdrop-filter: blur(10px);
  ">
    {{ mensaje_progresion_html }}
  </div>
</div>
```

---

## 🔄 Implementación en Workflow

```javascript
// En el workflow de generación de sesión
async function prepararSesion(usuario, ultimasSesiones) {
  // 1. Analizar progresión
  const analisis = analizarProgresion(usuario, ultimasSesiones);

  // 2. Ajustar parámetros
  const parametrosAnteriores = { ...usuario.parametros_dificultad };
  const parametrosNuevos = ajustarParametros(
    parametrosAnteriores,
    analisis
  );

  // 3. Generar mensaje explicativo
  const mensajeProgresion = generarMensajeProgresion(
    analisis,
    parametrosNuevos,
    parametrosAnteriores
  );

  // 4. Guardar parámetros nuevos
  await actualizarParametros(usuario.id, parametrosNuevos);

  // 5. Generar sesión con Claude (incluye mensaje en prompt)
  const sesion = await generarSesionConClaude({
    usuario,
    parametros: parametrosNuevos,
    analisis,
    mensaje_para_usuario: mensajeProgresion
  });

  // 6. Incluir mensaje en el email
  return {
    ...sesion,
    mensaje_progresion: mensajeProgresion,
    analisis_visible: {
      score: analisis.score,
      factores: analisis.factores
    }
  };
}
```

---

## 📊 Ejemplo Completo en Email

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Tu sesión de hoy</title>
</head>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">

  <!-- Mensaje de progresión -->
  <div style="background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%); color: white; padding: 25px; border-radius: 12px; margin-bottom: 30px;">
    <div style="font-size: 32px; margin-bottom: 10px;">📈</div>
    <h3 style="margin: 0 0 15px 0; color: white;">Sobre tu progresión</h3>
    <div style="background: rgba(255,255,255,0.2); padding: 20px; border-radius: 8px;">
      <strong>¡Estás avanzando genial! 🚀</strong><br><br>

      Has completado todas tus sesiones y las encuentras manejables.
      Es momento de subir un peldaño:<br><br>

      <ul style="margin: 10px 0; padding-left: 20px;">
        <li>Repeticiones: <strong>10</strong> → <strong>12</strong> (+2)</li>
        <li>Ejercicios: <strong>5</strong> → <strong>6</strong></li>
      </ul>

      <em>Tu cuerpo está listo para más. Vamos a por ello 💪</em>
    </div>
  </div>

  <!-- Sesión normal -->
  <h2>🎯 Sesión 13: Movilidad y Fuerza</h2>
  <p>Duración estimada: 25 minutos</p>

  <!-- Ejercicios -->
  <div style="background: #f9f9f9; padding: 20px; margin: 15px 0; border-radius: 8px;">
    <h3>1. Sentadilla con pausa</h3>
    <p>Repeticiones: <strong>12</strong> (antes hacías 10 👏)</p>
    <p>Baja lentamente, mantén 2 segundos abajo, sube con control.</p>
  </div>

  <!-- Más ejercicios... -->

</body>
</html>
```

---

## 💡 Mensajes Adicionales: Celebraciones

```javascript
// Cuando alcanza hitos específicos
function generarMensajeCelebracion(usuario) {
  const hitos = [
    {
      condicion: usuario.sesiones_completadas === 10,
      mensaje: `
        <div style="background: #fff3cd; padding: 20px; border-radius: 12px; text-align: center;">
          <div style="font-size: 64px; margin-bottom: 10px;">🎉</div>
          <h2 style="color: #856404; margin: 0 0 10px 0;">¡10 sesiones completadas!</h2>
          <p style="color: #666; margin: 0;">
            Has demostrado constancia. Esto es un logro importante.
            La mayoría de gente abandona antes de llegar aquí.
            <strong>Tú no. Sigue así 💪</strong>
          </p>
        </div>
      `
    },
    {
      condicion: usuario.semanas_consecutivas_completas === 4,
      mensaje: `
        <div style="background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%); color: white; padding: 20px; border-radius: 12px; text-align: center;">
          <div style="font-size: 64px; margin-bottom: 10px;">🔥</div>
          <h2 style="margin: 0 0 10px 0;">¡4 semanas seguidas!</h2>
          <p style="margin: 0;">
            Has creado un hábito. Estadísticamente, después de 4 semanas
            consecutivas, la probabilidad de que sigas es del 80%.
            <strong>Ya eres uno de los nuestros 🏆</strong>
          </p>
        </div>
      `
    }
  ];

  return hitos.find(h => h.condicion)?.mensaje || null;
}
```

---

## 🎯 Resumen: Comunicación Transparente

| Aspecto | Sin Mensajes | Con Mensajes Explicativos |
|---------|--------------|---------------------------|
| **Confianza** | ⭐⭐ Caja negra | ⭐⭐⭐⭐⭐ Total transparencia |
| **Motivación** | ⭐⭐ Neutral | ⭐⭐⭐⭐⭐ Alta (se siente acompañado) |
| **Educación** | ❌ No aprende | ✅ Entiende progresión |
| **Retención** | ⭐⭐ Media | ⭐⭐⭐⭐ Alta |
| **Engagement** | ⭐⭐ Bajo | ⭐⭐⭐⭐⭐ Muy alto |

---

## 💰 Costo Adicional

**Ninguno**. Los mensajes se generan con JavaScript, no requieren llamadas extra a Claude.

---

## 🎯 Implementación Recomendada

1. ✅ **Siempre incluir mensaje en email de sesión**
   - Usuario ve POR QUÉ su programa se ajusta
   - Aumenta confianza y motivación

2. ✅ **Mensajes de celebración en hitos clave**
   - 5, 10, 20 sesiones completadas
   - 2, 4, 8 semanas consecutivas
   - Subir de nivel de dificultad

3. ✅ **Mensajes de intervención cuando hay problema**
   - Baja adherencia → Explicar ajuste
   - Riesgo abandono → Email proactivo

---

**¿Te gusta la idea de comunicar la progresión al usuario? ¿Implementamos esto junto con el sistema multi-factor?**
