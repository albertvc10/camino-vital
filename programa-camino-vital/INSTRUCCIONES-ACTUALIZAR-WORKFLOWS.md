# 🔄 Instrucciones: Actualizar Workflows de Feedback

**Fecha**: 2026-01-09
**Archivos afectados**: 2 workflows

---

## ⚡ Método Rápido: Reimportar Workflows Completos

### Paso 1: Workflow 02 - Envío Programado

1. En n8n, ve a **Workflows**
2. Busca "Camino Vital - 02 Envío Programado"
3. Abre el workflow
4. Click en **⋮** (menú tres puntos arriba derecha)
5. Click en **Delete**
6. Confirma eliminación
7. Ve a **Workflows** → **Import from File**
8. Selecciona: `workflows/02-envio-programado.json`
9. Click **Import**
10. **Activa** el workflow

### Paso 2: Workflow 03 - Feedback

1. Busca "Camino Vital - 03 Procesamiento de Feedback"
2. Abre el workflow
3. Click en **⋮** → **Delete**
4. Confirma eliminación
5. Ve a **Workflows** → **Import from File**
6. Selecciona: `workflows/03-feedback.json`
7. Click **Import**
8. **Activa** el workflow

---

## 🎯 Método Alternativo: Copiar Solo el Código (Si prefieres no borrar)

Si no quieres borrar y reimportar, puedes copiar solo las secciones modificadas:

### Workflow 02: Nodo "Preparar Email"

**Ubicación**: Workflow "02 Envío Programado" → Nodo "Preparar Email" (JavaScript Code)

**Qué cambiar**: Busca la sección donde se genera `feedbackHTML` y reemplázala con:

```javascript
// Generar botones de feedback - Sistema Híbrido Mejorado
// 80% casos felices: 3 botones directos
// 20% con problemas: 1 botón a landing page
const feedbackHTML = `
  <div style="background: #f5f5f5; padding: 30px; border-radius: 12px; margin: 30px 0;">
    <h3 style="text-align: center; margin: 0 0 20px 0; color: #333;">¿Cómo te fue la sesión?</h3>
    
    <!-- Botones casos felices -->
    <a href="https://n8n.habitos-vitales.com/webhook/feedback?user_id=${usuario.id}&feedback=completa_facil"
       style="display: block; background: #4CAF50; color: white; padding: 15px;
              margin: 10px 0; border-radius: 8px; text-decoration: none;
              text-align: center; font-size: 16px; font-weight: 500;">
      😊 Fácil - Podría haber hecho más
    </a>
    
    <a href="https://n8n.habitos-vitales.com/webhook/feedback?user_id=${usuario.id}&feedback=completa_bien"
       style="display: block; background: #2196F3; color: white; padding: 15px;
              margin: 10px 0; border-radius: 8px; text-decoration: none;
              text-align: center; font-size: 16px; font-weight: 500;">
      💪 Apropiado - Nivel perfecto
    </a>
    
    <a href="https://n8n.habitos-vitales.com/webhook/feedback?user_id=${usuario.id}&feedback=completa_dificil"
       style="display: block; background: #FF9800; color: white; padding: 15px;
              margin: 10px 0; border-radius: 8px; text-decoration: none;
              text-align: center; font-size: 16px; font-weight: 500;">
      😰 Difícil - Me costó pero lo logré
    </a>
    
    <!-- Separador -->
    <div style="border-top: 2px solid #ddd; margin: 20px 0;"></div>
    
    <!-- Link para problemas -->
    <a href="https://camino-vital.habitos-vitales.com/feedback-problemas.html?user_id=${usuario.id}"
       style="display: block; background: #f44336; color: white; padding: 15px;
              margin: 10px 0; border-radius: 8px; text-decoration: none;
              text-align: center; font-size: 16px; font-weight: 500;">
      ⚠️ No pude completarla
    </a>
    
    <p style="text-align: center; color: #999; font-size: 12px; margin: 10px 0 0 0;">
      Tu siguiente sesión llegará inmediatamente después de responder
    </p>
  </div>
`;
```

---

### Workflow 03: Nodo "Procesar Feedback"

**Ubicación**: Workflow "03 Procesamiento de Feedback" → Nodo "Procesar Feedback" (JavaScript Code)

**Reemplazar TODO el código del nodo con**:

```javascript
// Procesar nuevo formato de feedback híbrido
const query = $input.first().json.query;
const usuario = $input.last().json;

const feedbackRaw = query.feedback; // completa_facil, completa_bien, completa_dificil, incompleta_tiempo, incompleta_dificil, dolor

// Parsear feedback para extraer completitud y dificultad/razón
const feedbackMapping = {
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
};

const feedbackData = feedbackMapping[feedbackRaw] || feedbackMapping['completa_bien'];
const completitud = feedbackData.completitud;
const respuesta = feedbackData.respuesta;
const razonNoCompletar = feedbackData.razon_no_completar;

let accionTomada = 'continuar';
let nuevoNivel = usuario.nivel_actual;
let nuevaSemana = usuario.semana_actual;

// Lógica de decisión mejorada basada en completitud y feedback
if (completitud === 'completa') {
  // Usuario completó la sesión
  if (respuesta === 'facil') {
    // Sesión fácil → aumentar dificultad
    accionTomada = 'continuar';
    nuevaSemana = usuario.semana_actual + 1;
  } else if (respuesta === 'apropiado') {
    // Sesión apropiada → continuar
    accionTomada = 'continuar';
    nuevaSemana = usuario.semana_actual + 1;
  } else if (respuesta === 'dificil') {
    // Sesión difícil pero completada → mantener nivel, dar tiempo para adaptarse
    accionTomada = 'mantener';
    nuevaSemana = usuario.semana_actual + 1;
  }
} else {
  // Usuario NO completó la sesión
  if (razonNoCompletar === 'tiempo') {
    // Problema de tiempo, no de capacidad → continuar
    accionTomada = 'continuar';
    nuevaSemana = usuario.semana_actual + 1;
  } else if (razonNoCompletar === 'muy_dificil') {
    // Demasiado difícil → reducir o repetir
    accionTomada = 'repetir';
    nuevaSemana = usuario.semana_actual; // Repetir misma semana
  } else if (razonNoCompletar === 'dolor') {
    // Molestia física → marcar para revisión
    accionTomada = 'revisar_dolor';
    nuevaSemana = usuario.semana_actual; // Mantener semana hasta revisar
  }
}

return {
  json: {
    user_id: usuario.id,
    user_email: usuario.email,
    user_nombre: usuario.nombre,
    tipo_feedback: 'sesion_completada',
    feedback_raw: feedbackRaw,
    completitud: completitud,
    respuesta: respuesta,
    razon_no_completar: razonNoCompletar,
    accion_tomada: accionTomada,
    nivel_actual: usuario.nivel_actual,
    semana_actual: usuario.semana_actual,
    nuevo_nivel: nuevoNivel,
    nueva_semana: nuevaSemana,
    etapa: usuario.etapa
  }
};
```

---

### Workflow 03: Nodo "Guardar Feedback y Actualizar"

**Ubicación**: Workflow "03 Procesamiento de Feedback" → Nodo "Guardar Feedback y Actualizar" (PostgreSQL)

**Reemplazar la query SQL con**:

```sql
-- Registrar feedback con nuevos campos
INSERT INTO programa_feedback (user_id, semana, etapa, nivel, tipo_feedback, respuesta, completitud, razon_no_completar, accion_tomada)
VALUES (
  {{ $json.user_id }},
  {{ $json.semana_actual }},
  '{{ $json.etapa }}',
  '{{ $json.nivel_actual }}',
  '{{ $json.tipo_feedback }}',
  {{ $json.respuesta ? "'" + $json.respuesta + "'" : "NULL" }},
  '{{ $json.completitud }}',
  {{ $json.razon_no_completar ? "'" + $json.razon_no_completar + "'" : "NULL" }},
  '{{ $json.accion_tomada }}'
);

-- Actualizar usuario con nueva semana/nivel
UPDATE programa_users
SET 
  nivel_actual = '{{ $json.nuevo_nivel }}',
  semana_actual = {{ $json.nueva_semana }},
  fecha_ultima_respuesta = CURRENT_TIMESTAMP,
  respuestas_totales = respuestas_totales + 1,
  tasa_respuesta = CASE 
    WHEN envios_totales > 0 
    THEN (respuestas_totales + 1::decimal) / envios_totales * 100 
    ELSE 0 
  END
WHERE id = {{ $json.user_id }}
RETURNING *;
```

---

### Workflow 03: Nodo "Generar Mensaje Personalizado"

**Ubicación**: Workflow "03 Procesamiento de Feedback" → Nodo "Generar Mensaje Personalizado" (JavaScript Code)

**Reemplazar TODO el código con**:

```javascript
// Generar mensaje personalizado basado en la acción y feedback
const data = $input.first().json;

const mensajes = {
  'continuar': {
    titulo: '¡Perfecto! 👏',
    texto: `${data.completitud === 'completa' ? 'Completaste la sesión' : 'Gracias por tu feedback'}. En tu próximo email recibirás la Semana ${data.nueva_semana}.`,
    color: '#4CAF50'
  },
  'mantener': {
    titulo: '¡Muy bien! 💪',
    texto: `Veo que te costó pero lo lograste. Mantendremos este nivel para que te adaptes. Próxima sesión: Semana ${data.nueva_semana}.`,
    color: '#2196F3'
  },
  'repetir': {
    titulo: 'Vamos con calma 🧘',
    texto: `No hay prisa. Repetiremos la Semana ${data.nueva_semana} con un enfoque más suave para que te sientas cómodo.`,
    color: '#9C27B0'
  },
  'revisar_dolor': {
    titulo: 'Tu seguridad es primero 🤕',
    texto: `Hemos recibido tu reporte de molestia física. Nos pondremos en contacto contigo para revisar los ejercicios. Mientras tanto, descansa.`,
    color: '#F44336'
  }
};

const mensaje = mensajes[data.accion_tomada] || mensajes.continuar;

return {
  json: {
    ...data,
    mensaje_titulo: mensaje.titulo,
    mensaje_texto: mensaje.texto,
    mensaje_color: mensaje.color
  }
};
```

---

## ✅ Verificación

Después de actualizar, verifica que:

1. **Workflow 02** tiene el nodo "Preparar Email" con los 4 botones nuevos
2. **Workflow 03** tiene el nodo "Procesar Feedback" con el mapping de feedback híbrido
3. Ambos workflows están **ACTIVOS** (toggle verde)

---

## 🧪 Test Rápido

```bash
# Test webhook (reemplaza user_id con uno real):
curl "http://localhost:5678/webhook/feedback?user_id=1&feedback=completa_bien"
```

Deberías ver:
- Página de confirmación bonita
- Datos guardados en `programa_feedback` con `completitud` y `razon_no_completar`

---

**Recomendación**: Usa el **Método Rápido** (reimportar completo) para evitar errores de copiar/pegar. Es más seguro.
