// ================================================================
// CÓDIGO OPTIMIZADO PARA NODO "Generar HTML Sesión"
// Workflow: 09 Mostrar Sesión
// ================================================================
//
// SOPORTE PARA DOS TIPOS DE SESIÓN:
// 1. FUERZA: Con videos (formato actual)
// 2. CARDIO: Instrucciones textuales (nuevo formato)
//
// ================================================================

const sesion = $input.first().json;

if (!sesion || !sesion.id) {
  throw new Error('Sesión no encontrada');
}

// Detectar tipo de sesión
const esFuerza = sesion.calentamiento && sesion.trabajo_principal;
const esCardio = sesion.tipo_actividad && sesion.actividad_principal;

console.log('📋 Tipo de sesión:', esFuerza ? 'FUERZA (con videos)' : 'CARDIO (textual)');

// Mapa de iconos
const iconosEnfoque = {
  'movilidad': '🧘',
  'fuerza': '💪',
  'cardio': '❤️',
  'equilibrio': '⚖️',
  'mixto': '🎯'
};

const iconoEnfoque = iconosEnfoque[sesion.enfoque] || '🎯';
const webhookUrl = process.env.WEBHOOK_URL || 'http://localhost:5678';

// ================================================================
// GENERAR HTML SEGÚN TIPO DE SESIÓN
// ================================================================

let contenidoPrincipal = '';

if (esFuerza) {
  // ========================================
  // SESIÓN DE FUERZA (CON VIDEOS)
  // ========================================

  // Parsear JSONs
  const calentamiento = typeof sesion.calentamiento === 'string'
    ? JSON.parse(sesion.calentamiento)
    : sesion.calentamiento;

  const trabajoPrincipal = typeof sesion.trabajo_principal === 'string'
    ? JSON.parse(sesion.trabajo_principal)
    : sesion.trabajo_principal;

  console.log(`🏋️ ${calentamiento.length} ejercicios calentamiento`);
  console.log(`💪 ${trabajoPrincipal.length} ejercicios principales`);

  const firebaseBaseUrl = 'https://firebasestorage.googleapis.com/v0/b/habit-tracker-73235.appspot.com/o/ejercicios%2F';
  const firebaseToken = '?alt=media&token=6fefb8ba-de8e-44cb-a60f-f5b91c7c8f22';

  // Función para generar HTML de ejercicio
  function generarEjercicioHTML(ejercicio, index, esCalentamiento = false) {
    const videoUrl = `${firebaseBaseUrl}${encodeURIComponent(ejercicio.nombre_archivo)}${firebaseToken}`;
    const numeroEjercicio = esCalentamiento ? `C${index + 1}` : index + 1;
    const colorBorde = esCalentamiento ? '#4CAF50' : '#667eea';

    return `
      <div class="ejercicio" style="background: white; border-radius: 12px; padding: 25px; margin-bottom: 25px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border-left: 6px solid ${colorBorde};">
        <div class="ejercicio-header" style="display: flex; align-items: center; margin-bottom: 15px;">
          <div class="ejercicio-numero" style="background: ${colorBorde}; color: white; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 18px; margin-right: 15px;">
            ${numeroEjercicio}
          </div>
          <h3 style="margin: 0; color: #333; font-size: 20px; flex: 1;">${ejercicio.nombre_espanol}</h3>
        </div>

        <div class="video-container" style="position: relative; width: 100%; padding-bottom: 56.25%; background: #000; border-radius: 8px; overflow: hidden; margin-bottom: 15px;">
          <video
            controls
            playsinline
            preload="metadata"
            style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: contain;"
            poster="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100'%3E%3Crect fill='%23333' width='100' height='100'/%3E%3Ctext fill='%23fff' x='50%25' y='50%25' text-anchor='middle' dominant-baseline='middle' font-family='Arial' font-size='14'%3ECargando...%3C/text%3E%3C/svg%3E"
          >
            <source src="${videoUrl}" type="video/quicktime">
            <source src="${videoUrl}" type="video/mp4">
            Tu navegador no soporta el tag de video.
          </video>
        </div>

        <div class="ejercicio-detalles" style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
          <div style="margin-bottom: 10px;">
            <strong style="color: #667eea;">📊 Repeticiones:</strong>
            <span style="color: #555; font-size: 16px;">${ejercicio.repeticiones}</span>
          </div>
          <div style="margin-bottom: 10px;">
            <strong style="color: #667eea;">⏱️ Duración:</strong>
            <span style="color: #555; font-size: 16px;">${ejercicio.duracion_aprox}</span>
          </div>
          ${ejercicio.notas ? `
          <div style="background: #fff3cd; padding: 12px; border-radius: 6px; border-left: 3px solid #ffc107; margin-top: 10px;">
            <strong style="color: #856404;">💡 Consejo:</strong>
            <span style="color: #856404;">${ejercicio.notas}</span>
          </div>
          ` : ''}
        </div>
      </div>
    `;
  }

  const htmlCalentamiento = calentamiento.map((ej, idx) =>
    generarEjercicioHTML(ej, idx, true)
  ).join('');

  const htmlTrabajoPrincipal = trabajoPrincipal.map((ej, idx) =>
    generarEjercicioHTML(ej, idx, false)
  ).join('');

  contenidoPrincipal = `
    <!-- Calentamiento -->
    <h2 class="seccion-titulo">🔥 Calentamiento</h2>
    <p style="color: #666; margin-bottom: 25px; font-size: 16px;">
      Prepara tu cuerpo con estos ejercicios suaves. Ve a tu ritmo y respira profundamente.
    </p>
    ${htmlCalentamiento}

    <!-- Trabajo Principal -->
    <h2 class="seccion-titulo">💪 Trabajo Principal</h2>
    <p style="color: #666; margin-bottom: 25px; font-size: 16px;">
      Estos son los ejercicios principales de tu sesión. Recuerda: calidad sobre cantidad.
    </p>
    ${htmlTrabajoPrincipal}
  `;

} else if (esCardio) {
  // ========================================
  // SESIÓN DE CARDIO (TEXTUAL)
  // ========================================

  const actividad = typeof sesion.actividad_principal === 'string'
    ? JSON.parse(sesion.actividad_principal)
    : sesion.actividad_principal;

  console.log(`❤️ Sesión de cardio: ${sesion.tipo_actividad}`);

  // Generar HTML de fases
  const htmlFases = actividad.fases ? actividad.fases.map((fase, idx) => `
    <div class="fase-cardio" style="background: white; border-radius: 12px; padding: 25px; margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border-left: 6px solid #FF6B6B;">
      <div style="display: flex; align-items: center; margin-bottom: 15px;">
        <div style="background: #FF6B6B; color: white; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 18px; margin-right: 15px;">
          ${idx + 1}
        </div>
        <h3 style="margin: 0; color: #333; font-size: 20px; flex: 1;">${fase.fase}</h3>
      </div>

      <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 15px;">
        <div style="margin-bottom: 10px;">
          <strong style="color: #FF6B6B;">⏱️ Duración:</strong>
          <span style="color: #555; font-size: 16px;">${fase.duracion}</span>
        </div>
        <div style="margin-bottom: 10px;">
          <strong style="color: #FF6B6B;">💪 Intensidad:</strong>
          <span style="color: #555; font-size: 16px;">${fase.intensidad}</span>
        </div>
      </div>

      <p style="color: #555; font-size: 16px; line-height: 1.6; margin: 0;">
        ${fase.descripcion}
      </p>
    </div>
  `).join('') : '';

  // Señales de alerta
  const htmlAlertas = sesion.senales_de_alerta ? `
    <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 20px; border-radius: 8px; margin: 30px 0;">
      <h3 style="margin: 0 0 15px 0; color: #856404; font-size: 18px;">⚠️ Señales de Alerta - Detente si sientes:</h3>
      <ul style="margin: 0; padding-left: 20px; color: #856404; line-height: 2;">
        ${sesion.senales_de_alerta.map(senal => `<li>${senal}</li>`).join('')}
      </ul>
    </div>
  ` : '';

  // Consejos de seguridad
  const htmlConsejos = sesion.consejos_seguridad ? `
    <div style="background: #e8f5e9; border-left: 4px solid #4CAF50; padding: 20px; border-radius: 8px; margin: 30px 0;">
      <h3 style="margin: 0 0 15px 0; color: #2e7d32; font-size: 18px;">✅ Consejos de Seguridad:</h3>
      <ul style="margin: 0; padding-left: 20px; color: #2e7d32; line-height: 2;">
        ${sesion.consejos_seguridad.map(consejo => `<li>${consejo}</li>`).join('')}
      </ul>
    </div>
  ` : '';

  contenidoPrincipal = `
    <!-- Tipo de Actividad -->
    <div style="background: linear-gradient(135deg, #FF6B6B 0%, #FF8E53 100%); color: white; padding: 25px; border-radius: 12px; margin-bottom: 30px; text-align: center;">
      <h2 style="margin: 0; font-size: 28px; text-transform: capitalize;">
        ${sesion.tipo_actividad || 'Actividad Cardiovascular'}
      </h2>
      <p style="margin: 10px 0 0; opacity: 0.9; font-size: 16px;">
        ${actividad.duracion} · Intensidad ${actividad.intensidad_objetivo}
      </p>
    </div>

    <!-- Calentamiento -->
    <h2 class="seccion-titulo">🔥 Calentamiento</h2>
    <div style="background: #f0f7ff; border-left: 5px solid #667eea; padding: 20px; border-radius: 8px; margin-bottom: 30px;">
      <p style="margin: 0; color: #333; font-size: 16px; line-height: 1.8;">
        ${sesion.calentamiento_texto || 'Comienza con movimientos suaves durante 3-5 minutos.'}
      </p>
    </div>

    <!-- Actividad Principal -->
    <h2 class="seccion-titulo">❤️ Actividad Principal</h2>
    <div style="background: #fff5f5; border-left: 5px solid #FF6B6B; padding: 20px; border-radius: 8px; margin-bottom: 25px;">
      <h3 style="margin: 0 0 10px 0; color: #333; font-size: 18px;">📝 Descripción:</h3>
      <p style="margin: 0 0 15px 0; color: #555; font-size: 16px; line-height: 1.8;">
        ${actividad.descripcion}
      </p>
      <h3 style="margin: 20px 0 10px 0; color: #333; font-size: 18px;">💭 Cómo debes sentirte:</h3>
      <p style="margin: 0; color: #555; font-size: 16px; line-height: 1.8;">
        ${actividad.como_debe_sentirse}
      </p>
    </div>

    <!-- Fases de la Actividad -->
    <h3 style="color: #333; font-size: 22px; margin: 30px 0 20px;">📊 Fases de tu Sesión:</h3>
    ${htmlFases}

    <!-- Señales de Alerta -->
    ${htmlAlertas}

    <!-- Consejos de Seguridad -->
    ${htmlConsejos}

    <!-- Progresión -->
    ${sesion.progresion_sugerida ? `
    <div style="background: #e3f2fd; border-left: 4px solid #2196F3; padding: 20px; border-radius: 8px; margin: 30px 0;">
      <h3 style="margin: 0 0 10px 0; color: #1565C0; font-size: 18px;">🚀 Para la Próxima Vez:</h3>
      <p style="margin: 0; color: #1565C0; font-size: 16px; line-height: 1.8;">
        ${sesion.progresion_sugerida}
      </p>
    </div>
    ` : ''}
  `;
}

// ================================================================
// HTML COMPLETO DE LA PÁGINA
// ================================================================

const paginaHTML = `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${sesion.titulo} - Camino Vital</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #333;
      padding: 20px;
      min-height: 100vh;
    }

    .container {
      max-width: 900px;
      margin: 0 auto;
      background: white;
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 10px 40px rgba(0,0,0,0.2);
    }

    .header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 40px 30px;
      text-align: center;
    }

    .header h1 {
      font-size: 32px;
      margin-bottom: 10px;
      text-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }

    .header-meta {
      display: flex;
      justify-content: center;
      gap: 25px;
      margin-top: 20px;
      flex-wrap: wrap;
    }

    .meta-item {
      background: rgba(255,255,255,0.2);
      padding: 10px 20px;
      border-radius: 20px;
      font-size: 14px;
      backdrop-filter: blur(10px);
    }

    .content {
      padding: 40px 30px;
    }

    .introduccion {
      background: linear-gradient(135deg, #f0f7ff 0%, #e8f4f8 100%);
      border-left: 5px solid #667eea;
      padding: 25px;
      border-radius: 8px;
      margin-bottom: 40px;
      line-height: 1.8;
      font-size: 16px;
      color: #333;
    }

    .seccion-titulo {
      font-size: 28px;
      color: #333;
      margin: 40px 0 25px;
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .seccion-titulo::before {
      content: '';
      width: 6px;
      height: 35px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border-radius: 3px;
    }

    /* Sistema de feedback mejorado */
    .feedback-container {
      background: #f5f5f5;
      padding: 30px;
      border-radius: 12px;
      margin: 50px 0 40px;
    }

    .feedback-container h3 {
      text-align: center;
      margin: 0 0 25px 0;
      color: #333;
      font-size: 22px;
    }

    .feedback-btn {
      display: block;
      width: 100%;
      padding: 18px;
      margin: 12px 0;
      border-radius: 8px;
      text-decoration: none;
      text-align: center;
      font-size: 16px;
      font-weight: 600;
      transition: all 0.3s ease;
      color: white;
    }

    .feedback-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }

    .feedback-btn.facil {
      background: #4CAF50;
    }

    .feedback-btn.facil:hover {
      background: #45a049;
    }

    .feedback-btn.bien {
      background: #2196F3;
    }

    .feedback-btn.bien:hover {
      background: #1976D2;
    }

    .feedback-btn.dificil {
      background: #FF9800;
    }

    .feedback-btn.dificil:hover {
      background: #F57C00;
    }

    .feedback-btn.problemas {
      background: #f44336;
    }

    .feedback-btn.problemas:hover {
      background: #d32f2f;
    }

    .separador {
      border-top: 2px solid #ddd;
      margin: 20px 0;
    }

    .feedback-nota {
      text-align: center;
      color: #999;
      font-size: 13px;
      margin-top: 15px;
    }

    .footer {
      text-align: center;
      padding: 30px;
      color: #999;
      font-size: 14px;
      border-top: 1px solid #eee;
      background: #f9f9f9;
    }

    @media (max-width: 768px) {
      body {
        padding: 10px;
      }

      .header {
        padding: 30px 20px;
      }

      .header h1 {
        font-size: 24px;
      }

      .content {
        padding: 20px 15px;
      }

      .feedback-container {
        padding: 20px 15px;
      }

      .feedback-btn {
        font-size: 15px;
        padding: 16px;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <!-- Header -->
    <div class="header">
      <div style="font-size: 48px; margin-bottom: 10px;">${iconoEnfoque}</div>
      <h1>${sesion.titulo}</h1>
      <p style="opacity: 0.9; margin-top: 10px; font-size: 18px;">Hola ${sesion.user_nombre}, ¡es hora de moverte!</p>

      <div class="header-meta">
        <div class="meta-item">⏱️ ${sesion.duracion_estimada}</div>
        <div class="meta-item">📊 Nivel ${sesion.nivel_actual}</div>
        <div class="meta-item">🎯 ${sesion.enfoque}</div>
        <div class="meta-item">📅 Sesión ${sesion.numero_sesion} de ${sesion.sesiones_objetivo_semana}</div>
      </div>
    </div>

    <!-- Contenido -->
    <div class="content">
      <!-- Introducción -->
      <div class="introduccion">
        <strong style="font-size: 18px; color: #667eea; display: block; margin-bottom: 12px;">✨ Tu sesión personalizada</strong>
        ${sesion.introduccion_personalizada}
      </div>

      <!-- Contenido Principal (Fuerza o Cardio) -->
      ${contenidoPrincipal}

      <!-- Sistema de Feedback Mejorado -->
      <div class="feedback-container">
        <h3>¿Cómo te fue la sesión?</h3>

        <a href="${webhookUrl}/webhook/sesion-completada?user_id=${sesion.user_id}&sesion=${sesion.numero_sesion}&feedback=completa_facil" class="feedback-btn facil">
          😊 Fácil - Podría haber hecho más
        </a>

        <a href="${webhookUrl}/webhook/sesion-completada?user_id=${sesion.user_id}&sesion=${sesion.numero_sesion}&feedback=completa_bien" class="feedback-btn bien">
          💪 Apropiado - Nivel perfecto
        </a>

        <a href="${webhookUrl}/webhook/sesion-completada?user_id=${sesion.user_id}&sesion=${sesion.numero_sesion}&feedback=completa_dificil" class="feedback-btn dificil">
          😰 Difícil - Me costó pero lo logré
        </a>

        <div class="separador"></div>

        <a href="http://localhost:8000/feedback-problemas.html?user_id=${sesion.user_id}&sesion=${sesion.numero_sesion}" class="feedback-btn problemas">
          ⚠️ No pude completarla
        </a>

        <p class="feedback-nota">
          Tu siguiente sesión llegará inmediatamente después de responder
        </p>
      </div>
    </div>

    <!-- Footer -->
    <div class="footer">
      <p><strong>Camino Vital</strong> | Hábitos Vitales</p>
      <p style="margin-top: 10px;">Programa personalizado de ejercicio</p>
    </div>
  </div>

  <script>
    // Auto-pause de videos cuando no están visibles (solo para sesiones con video)
    const videos = document.querySelectorAll('video');

    if (videos.length > 0) {
      const observerOptions = {
        threshold: 0.5
      };

      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          const video = entry.target;
          if (!entry.isIntersecting) {
            video.pause();
          }
        });
      }, observerOptions);

      videos.forEach(video => observer.observe(video));
    }

    // Log para debugging
    console.log('Sesión cargada:', {
      titulo: '${sesion.titulo}',
      enfoque: '${sesion.enfoque}',
      tipo: ${esFuerza ? "'fuerza'" : "'cardio'"},
      user_id: ${sesion.user_id},
      sesion_numero: ${sesion.numero_sesion}
    });
  </script>
</body>
</html>
`;

return {
  json: {
    sesion_id: sesion.id,
    html: paginaHTML
  }
};
