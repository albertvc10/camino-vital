-- ============================================
-- Actualización pagina_sesion_v2 - Añadir vista de introducción
-- Fecha: 2026-02-13
-- ============================================
-- Esta migración añade una pantalla de introducción antes de empezar los ejercicios
-- que muestra: título, descripción, métricas y preview de contenido

-- Paso 1: Añadir CSS para la vista de intro (antes de </style>)
UPDATE email_templates
SET html_template = REPLACE(
  html_template,
  '  </style>
</head>',
  '    /* ============================================
       Intro View Styles
       ============================================ */
    .intro-view {
      display: flex;
      justify-content: center;
      align-items: flex-start;
      padding: 48px;
      gap: 48px;
      min-height: calc(100vh - 72px);
    }

    .intro-view.hidden {
      display: none;
    }

    .intro-card {
      background: var(--hv-bg-secondary);
      border-radius: 16px;
      padding: 32px;
      width: 100%;
      max-width: 500px;
    }

    .intro-label {
      font-size: 12px;
      font-weight: 600;
      color: var(--hv-text-muted);
      letter-spacing: 1px;
      margin-bottom: 12px;
    }

    .intro-title {
      font-size: 28px;
      font-weight: 700;
      color: var(--hv-text-primary);
      margin-bottom: 16px;
      line-height: 1.3;
    }

    .intro-description {
      font-size: 16px;
      color: var(--hv-text-secondary);
      line-height: 1.6;
      margin-bottom: 24px;
    }

    .intro-meta {
      display: flex;
      gap: 16px;
      margin-bottom: 24px;
      flex-wrap: wrap;
    }

    .intro-meta-item {
      background: var(--hv-bg-card);
      border-radius: 10px;
      padding: 14px 20px;
    }

    .intro-meta-label {
      font-size: 11px;
      color: var(--hv-text-dim);
      margin-bottom: 4px;
    }

    .intro-meta-value {
      font-size: 15px;
      font-weight: 600;
      color: var(--hv-text-primary);
    }

    .intro-meta-value.fuerza {
      color: var(--hv-accent-green);
    }

    .intro-meta-value.cardio {
      color: var(--hv-accent-red);
    }

    .intro-start-btn {
      width: 100%;
      padding: 18px 24px;
      border: none;
      border-radius: 12px;
      font-size: 17px;
      font-weight: 700;
      color: white;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 12px;
      transition: transform 0.2s, filter 0.2s;
    }

    .intro-start-btn:hover {
      transform: translateY(-2px);
      filter: brightness(1.1);
    }

    .intro-start-btn.fuerza {
      background: var(--hv-accent-green);
    }

    .intro-start-btn.cardio {
      background: var(--hv-accent-red);
    }

    /* Content Card - Exercises/Phases */
    .intro-content-card {
      background: var(--hv-bg-secondary);
      border-radius: 16px;
      padding: 32px;
      width: 100%;
      max-width: 450px;
    }

    .intro-content-label {
      font-size: 14px;
      font-weight: 600;
      margin-bottom: 20px;
    }

    .intro-content-label.fuerza {
      color: var(--hv-accent-gold);
    }

    .intro-content-label.cardio {
      color: var(--hv-accent-red);
    }

    .intro-exercise-group {
      background: rgba(255,255,255,0.04);
      border-radius: 12px;
      padding: 20px;
      margin-bottom: 16px;
    }

    .intro-exercise-group.warmup {
      background: rgba(223,202,97,0.08);
    }

    .intro-exercise-group.main {
      background: rgba(34,197,94,0.08);
    }

    .intro-exercise-group.cardio-phase {
      background: rgba(239,68,68,0.08);
    }

    .intro-group-title {
      font-size: 14px;
      font-weight: 600;
      margin-bottom: 12px;
    }

    .intro-group-title.warmup {
      color: var(--hv-accent-gold);
    }

    .intro-group-title.main {
      color: var(--hv-accent-green);
    }

    .intro-exercise-item {
      font-size: 15px;
      color: var(--hv-text-secondary);
      padding: 4px 0;
    }

    .intro-more {
      font-size: 14px;
      color: var(--hv-text-dim);
      font-style: italic;
      margin-top: 8px;
    }

    /* Cardio Phases */
    .intro-phase {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 16px 20px;
      background: rgba(239,68,68,0.08);
      border-radius: 12px;
      margin-bottom: 12px;
    }

    .intro-phase-num {
      width: 36px;
      height: 36px;
      background: var(--hv-accent-red);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 16px;
      font-weight: 700;
      color: white;
      flex-shrink: 0;
    }

    .intro-phase-info {
      flex: 1;
    }

    .intro-phase-title {
      font-size: 16px;
      font-weight: 600;
      color: var(--hv-text-primary);
    }

    .intro-phase-desc {
      font-size: 14px;
      color: var(--hv-text-muted);
    }

    .intro-warning {
      background: rgba(251,191,36,0.1);
      border-radius: 12px;
      padding: 16px 20px;
      margin-top: 16px;
    }

    .intro-warning-title {
      font-size: 14px;
      font-weight: 600;
      color: #FBBF24;
      margin-bottom: 10px;
    }

    .intro-warning-item {
      font-size: 14px;
      color: var(--hv-text-secondary);
      padding: 4px 0;
    }

    .intro-note {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 14px 18px;
      border-radius: 10px;
      margin-top: 20px;
    }

    .intro-note.fuerza {
      background: rgba(102,126,234,0.1);
    }

    .intro-note.cardio {
      background: rgba(239,68,68,0.1);
    }

    .intro-note-icon {
      font-size: 18px;
    }

    .intro-note-text {
      font-size: 14px;
      color: var(--hv-text-secondary);
    }

    /* Header when in intro mode */
    .header.intro-mode .progress-section {
      visibility: hidden;
    }

    /* Responsive */
    @media (max-width: 1024px) {
      .intro-view {
        flex-direction: column;
        align-items: center;
        padding: 24px;
        gap: 24px;
      }

      .intro-card,
      .intro-content-card {
        max-width: 100%;
      }
    }

  </style>
</head>'
)
WHERE nombre = 'pagina_sesion_v2';

-- Paso 2: Añadir HTML de la vista intro (después del header, antes del main-content)
UPDATE email_templates
SET html_template = REPLACE(
  html_template,
  '    <!-- FUERZA: Exercise View - 3 Column Layout -->
    <main class="main-content" id="fuerzaView">',
  '    <!-- INTRO VIEW -->
    <div class="intro-view" id="introView">
      <div class="intro-card" id="introCard">
        <div class="intro-label">TU SESIÓN DE HOY</div>
        <h1 class="intro-title" id="introTitle">Cargando...</h1>
        <p class="intro-description" id="introDescription"></p>
        <div class="intro-meta" id="introMeta"></div>
        <button class="intro-start-btn" id="introStartBtn" onclick="startSession()">
          <span>▶</span>
          <span>COMENZAR SESIÓN</span>
        </button>
      </div>
      <div class="intro-content-card" id="introContentCard">
        <!-- Filled by JS: exercises for fuerza, phases for cardio -->
      </div>
    </div>

    <!-- FUERZA: Exercise View - 3 Column Layout -->
    <main class="main-content hidden" id="fuerzaView">'
)
WHERE nombre = 'pagina_sesion_v2';

-- Paso 3: Añadir JavaScript para la intro (antes de document.addEventListener)
UPDATE email_templates
SET html_template = REPLACE(
  html_template,
  '    document.addEventListener("DOMContentLoaded", init);',
  '    // ============================================
    // Intro View Functions
    // ============================================
    function renderIntroView() {
      const isCardio = SESSION_DATA.enfoque === "cardio" ||
                       (!SESSION_DATA.calentamiento && !SESSION_DATA.trabajo_principal);

      // Set title and description
      document.getElementById("introTitle").textContent = SESSION_DATA.titulo || "Tu sesión de hoy";
      document.getElementById("introDescription").textContent = SESSION_DATA.introduccion_personalizada || "";

      // Set meta info
      const metaContainer = document.getElementById("introMeta");
      const enfoque = isCardio ? "cardio" : "fuerza";
      metaContainer.innerHTML = `
        <div class="intro-meta-item">
          <div class="intro-meta-label">Duración</div>
          <div class="intro-meta-value">${SESSION_DATA.duracion_estimada || "25-30 min"}</div>
        </div>
        <div class="intro-meta-item">
          <div class="intro-meta-label">Enfoque</div>
          <div class="intro-meta-value ${enfoque}">${isCardio ? "Cardio" : "Fuerza"}</div>
        </div>
        <div class="intro-meta-item">
          <div class="intro-meta-label">Nivel</div>
          <div class="intro-meta-value">${SESSION_DATA.nivel_actual || "Iniciación"}</div>
        </div>
      `;

      // Set button style
      const startBtn = document.getElementById("introStartBtn");
      startBtn.classList.add(enfoque);

      // Render content card
      const contentCard = document.getElementById("introContentCard");

      if (isCardio) {
        renderCardioIntro(contentCard);
      } else {
        renderFuerzaIntro(contentCard);
      }

      // Add intro-mode to header
      document.querySelector(".header").classList.add("intro-mode");
    }

    function renderFuerzaIntro(container) {
      const calentamiento = SESSION_DATA.calentamiento || [];
      const trabajoPrincipal = SESSION_DATA.trabajo_principal || [];
      const totalEjercicios = calentamiento.length + trabajoPrincipal.length;

      let html = `<div class="intro-content-label fuerza">📋 TUS EJERCICIOS (${totalEjercicios} en total)</div>`;

      // Warmup
      if (calentamiento.length > 0) {
        html += `<div class="intro-exercise-group warmup">
          <div class="intro-group-title warmup">🔥 Calentamiento (${calentamiento.length} ejercicios)</div>`;
        calentamiento.slice(0, 3).forEach(ej => {
          html += `<div class="intro-exercise-item">• ${ej.nombre || ej.ejercicio_nombre || "Ejercicio"}</div>`;
        });
        if (calentamiento.length > 3) {
          html += `<div class="intro-more">...y ${calentamiento.length - 3} más</div>`;
        }
        html += `</div>`;
      }

      // Main work
      if (trabajoPrincipal.length > 0) {
        html += `<div class="intro-exercise-group main">
          <div class="intro-group-title main">💪 Trabajo principal (${trabajoPrincipal.length} ejercicios)</div>`;
        trabajoPrincipal.slice(0, 4).forEach(ej => {
          html += `<div class="intro-exercise-item">• ${ej.nombre || ej.ejercicio_nombre || "Ejercicio"}</div>`;
        });
        if (trabajoPrincipal.length > 4) {
          html += `<div class="intro-more">...y ${trabajoPrincipal.length - 4} más</div>`;
        }
        html += `</div>`;
      }

      // Video note
      html += `<div class="intro-note fuerza">
        <span class="intro-note-icon">🎬</span>
        <span class="intro-note-text">Cada ejercicio incluye vídeo demostrativo</span>
      </div>`;

      container.innerHTML = html;
    }

    function renderCardioIntro(container) {
      const actividad = SESSION_DATA.actividad_principal || {};
      const fases = actividad.fases || [];
      const senales = SESSION_DATA.senales_de_alerta || [];

      let html = `<div class="intro-content-label cardio">⏱️ FASES DE TU SESIÓN</div>`;

      // Phases
      fases.forEach((fase, i) => {
        html += `<div class="intro-phase">
          <div class="intro-phase-num">${i + 1}</div>
          <div class="intro-phase-info">
            <div class="intro-phase-title">${fase.fase || fase.nombre || "Fase " + (i+1)}</div>
            <div class="intro-phase-desc">${fase.duracion || ""} · ${fase.descripcion || ""}</div>
          </div>
        </div>`;
      });

      // Warning signs
      if (senales.length > 0) {
        html += `<div class="intro-warning">
          <div class="intro-warning-title">⚠️ Señales de alerta</div>`;
        senales.forEach(senal => {
          html += `<div class="intro-warning-item">• ${senal}</div>`;
        });
        html += `</div>`;
      }

      // Timer note
      html += `<div class="intro-note cardio">
        <span class="intro-note-icon">⏱️</span>
        <span class="intro-note-text">Incluye temporizador para cada fase</span>
      </div>`;

      container.innerHTML = html;
    }

    function startSession() {
      // Hide intro view
      document.getElementById("introView").classList.add("hidden");

      // Remove intro-mode from header
      document.querySelector(".header").classList.remove("intro-mode");

      // Initialize the appropriate session
      const isCardio = SESSION_DATA.enfoque === "cardio" ||
                       (!SESSION_DATA.calentamiento && !SESSION_DATA.trabajo_principal);

      if (isCardio) {
        initCardioSession();
      } else {
        initFuerzaSession();
      }
    }

    // Modified init to show intro first
    function initWithIntro() {
      renderIntroView();
    }

    document.addEventListener("DOMContentLoaded", initWithIntro);'
)
WHERE nombre = 'pagina_sesion_v2';

-- Paso 4: Modificar la función init original para no auto-iniciar
-- (Ya no se llama init directamente, se llama initWithIntro que muestra la intro primero)
UPDATE email_templates
SET html_template = REPLACE(
  html_template,
  '    function init() {
      // Determinar si es sesión de fuerza o cardio
      state.isCardio = SESSION_DATA.enfoque === "cardio" ||
                       (!SESSION_DATA.calentamiento && !SESSION_DATA.trabajo_principal);

      if (state.isCardio) {
        initCardioSession();
      } else {
        initFuerzaSession();
      }
    }',
  '    function init() {
      // Esta función ya no se usa directamente
      // Se mantiene por compatibilidad pero initWithIntro es el nuevo punto de entrada
      state.isCardio = SESSION_DATA.enfoque === "cardio" ||
                       (!SESSION_DATA.calentamiento && !SESSION_DATA.trabajo_principal);

      if (state.isCardio) {
        initCardioSession();
      } else {
        initFuerzaSession();
      }
    }'
)
WHERE nombre = 'pagina_sesion_v2';

-- Verificación
SELECT
  CASE
    WHEN html_template LIKE '%intro-view%' THEN '✅ CSS intro añadido'
    ELSE '❌ CSS intro NO encontrado'
  END as css_check,
  CASE
    WHEN html_template LIKE '%id="introView"%' THEN '✅ HTML intro añadido'
    ELSE '❌ HTML intro NO encontrado'
  END as html_check,
  CASE
    WHEN html_template LIKE '%renderIntroView%' THEN '✅ JS intro añadido'
    ELSE '❌ JS intro NO encontrado'
  END as js_check,
  CASE
    WHEN html_template LIKE '%initWithIntro%' THEN '✅ initWithIntro añadido'
    ELSE '❌ initWithIntro NO encontrado'
  END as init_check
FROM email_templates
WHERE nombre = 'pagina_sesion_v2';
