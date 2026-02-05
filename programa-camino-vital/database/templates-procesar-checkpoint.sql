-- ============================================
-- Templates para el sistema de Procesar Checkpoint (workflow 07)
-- ============================================
-- Fecha creación: 2026-01-XX (documentado 2026-02-05)
-- Usados por: workflow 07-Procesar Checkpoint Semanal

-- ============================================
-- TEMPLATE: email_checkpoint_nueva_semana
-- ============================================
-- Email enviado cuando el usuario procesa su checkpoint y comienza nueva semana

INSERT INTO email_templates (nombre, tipo, descripcion, html_template, variables_requeridas, version)
VALUES (
  'email_checkpoint_nueva_semana',
  'email',
  'Email con la primera sesión de la nueva semana tras procesar checkpoint',
  '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, ''Segoe UI'', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; color: #E8E8E8; background: #232323;">

  <div style="text-align: center; padding: 25px 0 15px 0;">
    <img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width: 150px; height: auto;">
  </div>

  <div style="background: linear-gradient(135deg, #62B882 0%, #4CAF50 100%); color: white; padding: 40px 30px; text-align: center; border-radius: 18px 18px 0 0;">
    <h1 style="margin: 0; font-size: 28px;">🌟 ¡Nueva semana, nueva sesión!</h1>
    <p style="margin: 10px 0 0 0; opacity: 0.9; font-size: 16px;">Semana {{semana}} - Sesión 1</p>
  </div>

  <div style="background: #1C1C1C; padding: 40px 30px; border-radius: 0 0 18px 18px; border: 1px solid rgba(255,255,255,0.08); border-top: none;">

    <p style="font-size: 18px; line-height: 1.6; margin: 0 0 20px 0; color: #E8E8E8;">
      Hola <strong style="color: #DFCA61;">{{nombre}}</strong>,
    </p>

    <p style="font-size: 16px; line-height: 1.6; margin: 0 0 25px 0; color: #B5B5B5;">
      ¡Felicidades por completar la semana {{semana_anterior}}! Aquí está tu primera sesión de la semana {{semana}}.
    </p>

    {{banner_ajuste}}

    <div style="background: rgba(255,255,255,0.04); padding: 25px; border-radius: 12px; margin: 0 0 30px 0; border: 1px solid rgba(255,255,255,0.08);">
      <h3 style="margin: 0 0 15px 0; color: #E8E8E8; font-size: 18px;">📋 {{titulo}}</h3>
      <p style="margin: 0 0 15px 0; color: #B5B5B5; line-height: 1.6;">{{descripcion}}</p>
      <ul style="margin: 0; padding-left: 20px; line-height: 2; color: #B5B5B5;">
        <li><strong style="color: #E8E8E8;">Duración:</strong> {{duracion}} minutos</li>
        <li><strong style="color: #E8E8E8;">Enfoque:</strong> {{enfoque}}</li>
        <li><strong style="color: #E8E8E8;">Contenido:</strong> {{contenido}}</li>
      </ul>
    </div>

    <div style="text-align: center; margin: 40px 0;">
      <a href="{{sesion_url}}" style="display: inline-block; background: linear-gradient(135deg, #62B882 0%, #4CAF50 100%); color: white; padding: 18px 40px; text-decoration: none; border-radius: 12px; font-weight: bold; font-size: 18px; box-shadow: 0 4px 15px rgba(98, 184, 130, 0.4);">
        🎬 VER MI SESIÓN
      </a>
    </div>

    <p style="font-size: 16px; line-height: 1.6; margin: 30px 0 10px; color: #B5B5B5;">
      ¡A por la nueva semana! 💪<br>
      <strong style="color: #DFCA61;">El equipo de Camino Vital</strong>
    </p>
  </div>

  <div style="text-align: center; margin-top: 30px; padding: 20px; color: #666; font-size: 12px;">
    <p style="margin: 0;">Camino Vital | Hábitos Vitales</p>
  </div>
</body>
</html>',
  '["nombre", "semana", "semana_anterior", "titulo", "descripcion", "duracion", "enfoque", "contenido", "sesion_url", "banner_ajuste"]',
  1
)
ON CONFLICT (nombre, version) DO UPDATE SET
  html_template = EXCLUDED.html_template,
  descripcion = EXCLUDED.descripcion,
  variables_requeridas = EXCLUDED.variables_requeridas;


-- ============================================
-- TEMPLATE: componente_banner_ajuste_subir
-- ============================================
-- Componente de banner para cuando el programa sube de intensidad/nivel

INSERT INTO email_templates (nombre, tipo, descripcion, html_template, variables_requeridas, version)
VALUES (
  'componente_banner_ajuste_subir',
  'componente',
  'Banner verde que indica que el programa ha subido de intensidad/nivel',
  '<div style="background: linear-gradient(135deg, rgba(98,184,130,0.2) 0%, rgba(76,175,80,0.2) 100%); border: 1px solid rgba(98,184,130,0.3); color: white; padding: 20px; margin: 0 0 30px 0; border-radius: 12px; text-align: center;">
  <h3 style="margin: 0 0 10px 0; font-size: 20px; color: #62B882;">✅ ¡Gran trabajo la semana pasada!</h3>
  <p style="margin: 0; font-size: 15px; line-height: 1.6; color: #B5B5B5;">{{ajuste_razon}}</p>
  <p style="margin: 10px 0 0 0; font-size: 14px; color: #B5B5B5;">
    <strong style="color: #62B882;">Nivel:</strong> {{ajuste_nivel}} |
    <strong style="color: #62B882;">Intensidad:</strong> {{ajuste_intensidad}}%
  </p>
</div>',
  '["ajuste_razon", "ajuste_nivel", "ajuste_intensidad"]',
  1
)
ON CONFLICT (nombre, version) DO UPDATE SET
  html_template = EXCLUDED.html_template,
  descripcion = EXCLUDED.descripcion,
  variables_requeridas = EXCLUDED.variables_requeridas;


-- ============================================
-- TEMPLATE: componente_banner_ajuste_bajar
-- ============================================
-- Componente de banner para cuando el programa baja de intensidad/nivel

INSERT INTO email_templates (nombre, tipo, descripcion, html_template, variables_requeridas, version)
VALUES (
  'componente_banner_ajuste_bajar',
  'componente',
  'Banner amarillo que indica que el programa ha ajustado/bajado intensidad',
  '<div style="background: linear-gradient(135deg, rgba(223,202,97,0.15) 0%, rgba(223,202,97,0.1) 100%); border: 1px solid rgba(223,202,97,0.3); color: white; padding: 20px; margin: 0 0 30px 0; border-radius: 12px; text-align: center;">
  <h3 style="margin: 0 0 10px 0; font-size: 20px; color: #DFCA61;">💡 Hemos ajustado tu programa</h3>
  <p style="margin: 0; font-size: 15px; line-height: 1.6; color: #B5B5B5;">{{ajuste_razon}}</p>
  <p style="margin: 10px 0 0 0; font-size: 14px; color: #B5B5B5;">
    <strong style="color: #DFCA61;">Nivel:</strong> {{ajuste_nivel}} |
    <strong style="color: #DFCA61;">Intensidad:</strong> {{ajuste_intensidad}}%
  </p>
</div>',
  '["ajuste_razon", "ajuste_nivel", "ajuste_intensidad"]',
  1
)
ON CONFLICT (nombre, version) DO UPDATE SET
  html_template = EXCLUDED.html_template,
  descripcion = EXCLUDED.descripcion,
  variables_requeridas = EXCLUDED.variables_requeridas;
