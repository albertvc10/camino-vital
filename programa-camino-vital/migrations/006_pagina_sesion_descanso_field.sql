-- Migración 006: Añadir campo descanso al template pagina_sesion_v2
-- Fecha: 2026-02-15
-- Descripción: Añade el bloque de visualización del campo "descanso" en las métricas de ejercicios
-- El campo descanso ahora se genera en las sesiones de fuerza (ej: "45 segundos entre series")

UPDATE email_templates
SET html_template = REPLACE(
  html_template,
  'if (ex.duracion_aprox) {',
  'if (ex.descanso) {
        metricsContainer.innerHTML += `
          <div class="metric-item">
            <div class="icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="6" y="4" width="4" height="16"></rect>
                <rect x="14" y="4" width="4" height="16"></rect>
              </svg>
            </div>
            <div class="content">
              <div class="label">Descanso</div>
              <div class="value">${ex.descanso}</div>
            </div>
          </div>
        `;
      }

      if (ex.duracion_aprox) {'
)
WHERE nombre = 'pagina_sesion_v2';
