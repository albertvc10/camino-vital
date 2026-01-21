-- ============================================
-- TEMPLATES INICIALES DE EMAIL
-- ============================================
-- Templates completos para el sistema de emails
-- Nota: Usar schema public (donde n8n trabaja por defecto)

-- ============================================
-- TEMPLATE: Sesión de ejercicios
-- ============================================
INSERT INTO email_templates (
  nombre,
  tipo,
  descripcion,
  html_template,
  variables_requeridas,
  version
)
VALUES (
  'sesion_ejercicios',
  'sesion',
  'Email con ejercicios de una sesión y botones de feedback',
  '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>{{titulo}}</title>
</head>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; color: #333;">

  <!-- Header -->
  <div style="text-align: center; margin-bottom: 20px;">
    <h1 style="color: #2e7d32; margin: 0;">🎯 Sesión {{sesion_numero}} de {{sesiones_total}}</h1>
    <p style="color: #666; margin: 5px 0;">Semana {{semana_numero}}</p>
  </div>

  <!-- Título del contenido -->
  <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 25px; border-radius: 12px; color: white; margin-bottom: 25px;">
    <h2 style="margin: 0 0 10px 0; font-size: 22px;">{{titulo}}</h2>
    <p style="margin: 0; font-size: 15px; line-height: 1.5;">{{descripcion}}</p>
  </div>

  <!-- Info de duración -->
  <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;">
    <p style="margin: 0;"><strong>⏱️ Duración:</strong> {{duracion}} minutos</p>
    <p style="margin: 5px 0 0 0;"><strong>Enfoque:</strong> {{enfoque}}</p>
  </div>

  <h2 style="color: #333; margin: 30px 0 15px 0;">Tus ejercicios:</h2>

  <!-- Ejercicios (generados dinámicamente) -->
  {{ejercicios_html}}

  <!-- Recordatorios -->
  <div style="background: #e3f2fd; padding: 20px; margin: 30px 0; border-radius: 8px;">
    <h3 style="margin: 0 0 10px 0; color: #1565c0;">💪 Recuerda:</h3>
    <ul style="margin: 10px 0; padding-left: 20px; line-height: 1.8; color: #1565c0;">
      <li>Ve a tu ritmo, sin prisa</li>
      <li>Escucha a tu cuerpo</li>
      <li>Haz pausas cuando lo necesites</li>
      <li>La constancia es clave</li>
    </ul>
  </div>

  <!-- Botones de feedback -->
  <div style="background: #4CAF50; padding: 30px; border-radius: 12px; text-align: center; margin: 30px 0;">
    <div style="font-size: 48px; margin-bottom: 15px;">🎉</div>
    <h3 style="color: white; margin: 0 0 10px 0; font-size: 24px;">¡Genial! ¿Completaste la sesión?</h3>
    <p style="color: white; margin: 0 0 25px 0; font-size: 16px;">Cuéntanos cómo te sentiste y recibirás la siguiente de inmediato</p>
    <div style="display: flex; flex-direction: column; gap: 12px; max-width: 400px; margin: 0 auto;">
      <a href="{{webhook_url}}/sesion-completada?user_id={{user_id}}&sesion={{sesion_numero}}&dificultad=facil"
         style="background: white; color: #4CAF50; padding: 18px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; display: block; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
        <div style="font-size: 18px; margin-bottom: 5px;">😊 Fue fácil</div>
        <div style="font-size: 14px; color: #2e7d32;">→ Recibir siguiente sesión</div>
      </a>
      <a href="{{webhook_url}}/sesion-completada?user_id={{user_id}}&sesion={{sesion_numero}}&dificultad=adecuado"
         style="background: white; color: #4CAF50; padding: 18px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; display: block; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
        <div style="font-size: 18px; margin-bottom: 5px;">✅ Estuvo adecuado</div>
        <div style="font-size: 14px; color: #2e7d32;">→ Recibir siguiente sesión</div>
      </a>
      <a href="{{webhook_url}}/sesion-completada?user_id={{user_id}}&sesion={{sesion_numero}}&dificultad=dificil"
         style="background: white; color: #4CAF50; padding: 18px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; display: block; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
        <div style="font-size: 18px; margin-bottom: 5px;">😓 Fue difícil</div>
        <div style="font-size: 14px; color: #2e7d32;">→ Recibir siguiente sesión</div>
      </a>
    </div>
    <p style="color: white; margin: 25px 0 0 0; font-size: 13px; opacity: 0.9;">💡 Tu feedback nos ayuda a personalizar tu programa</p>
  </div>

  <!-- Footer de contacto -->
  <div style="text-align: center; padding: 20px; background: #f5f5f5; border-radius: 8px;">
    <p style="margin: 0; color: #666;">¿Dudas o necesitas ayuda?</p>
    <p style="margin: 10px 0 0 0;"><a href="mailto:hola@habitos-vitales.com" style="color: #4CAF50;">Escríbenos →</a></p>
  </div>

  <!-- Footer final -->
  <p style="text-align: center; color: #999; font-size: 12px; margin-top: 40px; border-top: 1px solid #ddd; padding-top: 20px;">
    Camino Vital | Hábitos Vitales<br>
    Sesión {{sesion_numero}} de {{sesiones_total}} - Semana {{semana_numero}}
  </p>
</body>
</html>',
  '["titulo", "descripcion", "duracion", "enfoque", "ejercicios_html", "sesion_numero", "sesiones_total", "semana_numero", "user_id", "webhook_url"]'::jsonb,
  1
) ON CONFLICT (nombre, version) DO UPDATE SET
  html_template = EXCLUDED.html_template,
  variables_requeridas = EXCLUDED.variables_requeridas,
  descripcion = EXCLUDED.descripcion,
  updated_at = NOW();

-- ============================================
-- Verificación
-- ============================================
SELECT
  nombre,
  tipo,
  version,
  LENGTH(html_template) as tamano_html,
  jsonb_array_length(variables_requeridas) as num_variables,
  activo
FROM email_templates
WHERE nombre = 'sesion_ejercicios';

RAISE NOTICE '✅ Template "sesion_ejercicios" insertado correctamente';
RAISE NOTICE 'Variables requeridas: %', (
  SELECT jsonb_pretty(variables_requeridas)
  FROM email_templates
  WHERE nombre = 'sesion_ejercicios'
  LIMIT 1
);
