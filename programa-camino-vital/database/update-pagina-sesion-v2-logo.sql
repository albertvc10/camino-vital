-- ============================================
-- Actualización pagina_sesion_v2 - Logo izquierda + Camino Vital derecha
-- Fecha: 2026-02-13
-- ============================================
-- Header: Logo HV (izq) | Progreso (centro) | Camino Vital (der)
-- Responsive: "Camino Vital" se oculta en móvil

-- Paso 1: Actualizar CSS del logo y añadir brand-name
UPDATE email_templates
SET html_template = REPLACE(
  html_template,
  '    .logo {
      font-size: 18px;
      font-weight: 700;
      color: var(--hv-accent-gold);
    }',
  '    .logo {
      display: flex;
      align-items: center;
    }

    .logo img {
      height: 36px;
      width: auto;
    }

    .brand-name {
      font-size: 16px;
      font-weight: 600;
      color: var(--hv-accent-gold);
      letter-spacing: 0.5px;
    }

    @media (max-width: 768px) {
      .brand-name {
        display: none;
      }
    }'
)
WHERE nombre = 'pagina_sesion_v2';

-- Paso 2: Actualizar HTML - logo con imagen
UPDATE email_templates
SET html_template = REPLACE(
  html_template,
  '<div class="logo">Camino Vital</div>',
  '<div class="logo"><img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales"></div>'
)
WHERE nombre = 'pagina_sesion_v2';

-- Paso 3: Reemplazar spacer por brand-name a la derecha
UPDATE email_templates
SET html_template = REPLACE(
  html_template,
  '<div style="width: 100px;"></div>',
  '<div class="brand-name">Camino Vital</div>'
)
WHERE nombre = 'pagina_sesion_v2';

-- Verificación
SELECT
  CASE
    WHEN html_template LIKE '%<img src="https://habitos-vitales.com%' THEN 'Logo imagen OK'
    ELSE 'Logo imagen NO'
  END as logo_check,
  CASE
    WHEN html_template LIKE '%class="brand-name">Camino Vital%' THEN 'Brand name OK'
    ELSE 'Brand name NO'
  END as brand_check,
  CASE
    WHEN html_template LIKE '%.brand-name {%' THEN 'CSS brand-name OK'
    ELSE 'CSS brand-name NO'
  END as css_check
FROM email_templates
WHERE nombre = 'pagina_sesion_v2';
