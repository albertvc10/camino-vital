-- ============================================
-- MIGRACIÓN: Sistema de Templates de Email
-- ============================================
-- Fecha: 2 Enero 2025
-- Propósito: Centralizar templates de email en DB para fácil edición y mantenimiento
-- Nota: Usar schema public (donde n8n trabaja por defecto)

-- ============================================
-- TABLA: email_templates
-- ============================================
-- Almacena templates completos de emails
CREATE TABLE IF NOT EXISTS email_templates (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  tipo VARCHAR(50) NOT NULL, -- 'sesion', 'bienvenida', 'checkpoint', 'feedback'
  descripcion TEXT,
  html_template TEXT NOT NULL,
  variables_requeridas JSONB DEFAULT '[]'::jsonb,
  version INTEGER DEFAULT 1,
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(nombre, version)
);

COMMENT ON TABLE email_templates IS 'Templates HTML para emails transaccionales del programa';
COMMENT ON COLUMN email_templates.nombre IS 'Identificador único del template (ej: sesion_ejercicios, email_bienvenida)';
COMMENT ON COLUMN email_templates.tipo IS 'Categoría del template para organización';
COMMENT ON COLUMN email_templates.html_template IS 'HTML completo del email con placeholders {{variable}}';
COMMENT ON COLUMN email_templates.variables_requeridas IS 'Array JSON con nombres de variables que usa el template';
COMMENT ON COLUMN email_templates.version IS 'Versión del template para versionado y A/B testing';
COMMENT ON COLUMN email_templates.activo IS 'Si false, el template no se usa (útil para deprecar versiones antiguas)';

-- ============================================
-- TABLA: email_components
-- ============================================
-- Almacena componentes reutilizables (header, footer, botones)
CREATE TABLE IF NOT EXISTS email_components (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) UNIQUE NOT NULL,
  descripcion TEXT,
  html_snippet TEXT NOT NULL,
  variables_requeridas JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE email_components IS 'Componentes HTML reutilizables para construir emails';
COMMENT ON COLUMN email_components.nombre IS 'Identificador único (ej: header_programa, footer_contacto, botones_feedback)';
COMMENT ON COLUMN email_components.html_snippet IS 'Fragmento HTML con placeholders {{variable}}';

-- ============================================
-- ÍNDICES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_email_templates_nombre_activo ON email_templates(nombre, activo) WHERE activo = true;
CREATE INDEX IF NOT EXISTS idx_email_templates_tipo ON email_templates(tipo);

-- ============================================
-- TRIGGER: Updated_at automático
-- ============================================
CREATE OR REPLACE FUNCTION update_email_template_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_email_templates_updated_at
  BEFORE UPDATE ON email_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_email_template_updated_at();

CREATE TRIGGER trigger_email_components_updated_at
  BEFORE UPDATE ON email_components
  FOR EACH ROW
  EXECUTE FUNCTION update_email_template_updated_at();

-- ============================================
-- FUNCIÓN: Obtener template activo
-- ============================================
CREATE OR REPLACE FUNCTION get_email_template(template_name VARCHAR)
RETURNS TABLE (
  id INTEGER,
  html_template TEXT,
  variables_requeridas JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    t.id,
    t.html_template,
    t.variables_requeridas
  FROM email_templates t
  WHERE t.nombre = template_name
    AND t.activo = true
  ORDER BY t.version DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_email_template IS 'Obtiene la versión activa más reciente de un template';

-- ============================================
-- FUNCIÓN: Crear nueva versión de template
-- ============================================
CREATE OR REPLACE FUNCTION create_template_version(
  p_nombre VARCHAR,
  p_html_template TEXT
)
RETURNS INTEGER AS $$
DECLARE
  v_nueva_version INTEGER;
  v_template_id INTEGER;
BEGIN
  -- Obtener la versión más alta actual
  SELECT COALESCE(MAX(version), 0) + 1
  INTO v_nueva_version
  FROM email_templates
  WHERE nombre = p_nombre;

  -- Insertar nueva versión
  INSERT INTO email_templates (nombre, html_template, version)
  VALUES (p_nombre, p_html_template, v_nueva_version)
  RETURNING id INTO v_template_id;

  RETURN v_template_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION create_template_version IS 'Crea una nueva versión de un template existente';

-- ============================================
-- VISTA: Templates activos
-- ============================================
CREATE OR REPLACE VIEW v_email_templates_activos AS
SELECT
  nombre,
  tipo,
  descripcion,
  version,
  array_length(
    ARRAY(SELECT jsonb_array_elements_text(variables_requeridas)),
    1
  ) as num_variables,
  created_at,
  updated_at
FROM email_templates
WHERE activo = true
ORDER BY tipo, nombre, version DESC;

COMMENT ON VIEW v_email_templates_activos IS 'Vista resumen de templates activos para consulta rápida';

-- ============================================
-- DATOS INICIALES: Componentes reutilizables
-- ============================================

-- Componente: Header del programa
INSERT INTO email_components (nombre, descripcion, html_snippet, variables_requeridas)
VALUES (
  'header_sesion',
  'Encabezado para emails de sesiones de ejercicios',
  '<div style="text-align: center; margin-bottom: 20px;">
    <h1 style="color: #2e7d32; margin: 0;">🎯 Sesión {{sesion_numero}} de {{sesiones_total}}</h1>
    <p style="color: #666; margin: 5px 0;">Semana {{semana_numero}}</p>
  </div>',
  '["sesion_numero", "sesiones_total", "semana_numero"]'::jsonb
) ON CONFLICT (nombre) DO UPDATE SET
  html_snippet = EXCLUDED.html_snippet,
  variables_requeridas = EXCLUDED.variables_requeridas,
  updated_at = NOW();

-- Componente: Título de contenido
INSERT INTO email_components (nombre, descripcion, html_snippet, variables_requeridas)
VALUES (
  'titulo_contenido',
  'Bloque de título con gradiente para contenido de sesión',
  '<div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 25px; border-radius: 12px; color: white; margin-bottom: 25px;">
    <h2 style="margin: 0 0 10px 0; font-size: 22px;">{{titulo}}</h2>
    <p style="margin: 0; font-size: 15px; line-height: 1.5;">{{descripcion}}</p>
  </div>',
  '["titulo", "descripcion"]'::jsonb
) ON CONFLICT (nombre) DO UPDATE SET
  html_snippet = EXCLUDED.html_snippet,
  variables_requeridas = EXCLUDED.variables_requeridas,
  updated_at = NOW();

-- Componente: Info de duración
INSERT INTO email_components (nombre, descripcion, html_snippet, variables_requeridas)
VALUES (
  'info_duracion',
  'Bloque informativo con duración y enfoque de la sesión',
  '<div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;">
    <p style="margin: 0;"><strong>⏱️ Duración:</strong> {{duracion}} minutos</p>
    <p style="margin: 5px 0 0 0;"><strong>Enfoque:</strong> {{enfoque}}</p>
  </div>',
  '["duracion", "enfoque"]'::jsonb
) ON CONFLICT (nombre) DO UPDATE SET
  html_snippet = EXCLUDED.html_snippet,
  variables_requeridas = EXCLUDED.variables_requeridas,
  updated_at = NOW();

-- Componente: Recordatorios
INSERT INTO email_components (nombre, descripcion, html_snippet, variables_requeridas)
VALUES (
  'recordatorios',
  'Bloque de recordatorios para hacer ejercicios',
  '<div style="background: #e3f2fd; padding: 20px; margin: 30px 0; border-radius: 8px;">
    <h3 style="margin: 0 0 10px 0; color: #1565c0;">💪 Recuerda:</h3>
    <ul style="margin: 10px 0; padding-left: 20px; line-height: 1.8; color: #1565c0;">
      <li>Ve a tu ritmo, sin prisa</li>
      <li>Escucha a tu cuerpo</li>
      <li>Haz pausas cuando lo necesites</li>
      <li>La constancia es clave</li>
    </ul>
  </div>',
  '[]'::jsonb
) ON CONFLICT (nombre) DO UPDATE SET
  html_snippet = EXCLUDED.html_snippet,
  updated_at = NOW();

-- Componente: Botones de feedback
INSERT INTO email_components (nombre, descripcion, html_snippet, variables_requeridas)
VALUES (
  'botones_feedback',
  'Sección completa de feedback con botones para recibir siguiente sesión',
  '<div style="background: #4CAF50; padding: 30px; border-radius: 12px; text-align: center; margin: 30px 0;">
    <div style="font-size: 48px; margin-bottom: 15px;">🎉</div>
    <h3 style="color: white; margin: 0 0 10px 0; font-size: 24px;">¡Genial! ¿Completaste la sesión?</h3>
    <p style="color: white; margin: 0 0 25px 0; font-size: 16px;">Cuéntanos cómo te sentiste y recibirás la siguiente de inmediato</p>
    <div style="display: flex; flex-direction: column; gap: 12px; max-width: 400px; margin: 0 auto;">
      <a href="{{webhook_url}}?user_id={{user_id}}&sesion={{sesion_numero}}&dificultad=facil"
         style="background: white; color: #4CAF50; padding: 18px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; display: block; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
        <div style="font-size: 18px; margin-bottom: 5px;">😊 Fue fácil</div>
        <div style="font-size: 14px; color: #2e7d32;">→ Recibir siguiente sesión</div>
      </a>
      <a href="{{webhook_url}}?user_id={{user_id}}&sesion={{sesion_numero}}&dificultad=adecuado"
         style="background: white; color: #4CAF50; padding: 18px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; display: block; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
        <div style="font-size: 18px; margin-bottom: 5px;">✅ Estuvo adecuado</div>
        <div style="font-size: 14px; color: #2e7d32;">→ Recibir siguiente sesión</div>
      </a>
      <a href="{{webhook_url}}?user_id={{user_id}}&sesion={{sesion_numero}}&dificultad=dificil"
         style="background: white; color: #4CAF50; padding: 18px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; display: block; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
        <div style="font-size: 18px; margin-bottom: 5px;">😓 Fue difícil</div>
        <div style="font-size: 14px; color: #2e7d32;">→ Recibir siguiente sesión</div>
      </a>
    </div>
    <p style="color: white; margin: 25px 0 0 0; font-size: 13px; opacity: 0.9;">💡 Tu feedback nos ayuda a personalizar tu programa</p>
  </div>',
  '["webhook_url", "user_id", "sesion_numero"]'::jsonb
) ON CONFLICT (nombre) DO UPDATE SET
  html_snippet = EXCLUDED.html_snippet,
  variables_requeridas = EXCLUDED.variables_requeridas,
  updated_at = NOW();

-- Componente: Footer de contacto
INSERT INTO email_components (nombre, descripcion, html_snippet, variables_requeridas)
VALUES (
  'footer_contacto',
  'Footer con información de contacto',
  '<div style="text-align: center; padding: 20px; background: #f5f5f5; border-radius: 8px;">
    <p style="margin: 0; color: #666;">¿Dudas o necesitas ayuda?</p>
    <p style="margin: 10px 0 0 0;"><a href="mailto:hola@habitos-vitales.com" style="color: #4CAF50;">Escríbenos →</a></p>
  </div>',
  '[]'::jsonb
) ON CONFLICT (nombre) DO UPDATE SET
  html_snippet = EXCLUDED.html_snippet,
  updated_at = NOW();

-- Componente: Footer final
INSERT INTO email_components (nombre, descripcion, html_snippet, variables_requeridas)
VALUES (
  'footer_final',
  'Footer final con info del programa',
  '<p style="text-align: center; color: #999; font-size: 12px; margin-top: 40px; border-top: 1px solid #ddd; padding-top: 20px;">
    Camino Vital | Hábitos Vitales<br>
    Sesión {{sesion_numero}} de {{sesiones_total}} - Semana {{semana_numero}}
  </p>',
  '["sesion_numero", "sesiones_total", "semana_numero"]'::jsonb
) ON CONFLICT (nombre) DO UPDATE SET
  html_snippet = EXCLUDED.html_snippet,
  variables_requeridas = EXCLUDED.variables_requeridas,
  updated_at = NOW();

-- ============================================
-- Verificación
-- ============================================
SELECT
  'Templates creados: ' || COUNT(*) as resultado
FROM email_templates;

SELECT
  'Componentes creados: ' || COUNT(*) as resultado
FROM email_components;

SELECT * FROM v_email_templates_activos;
