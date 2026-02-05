-- ============================================
-- Templates para el sistema de Checkpoint Semanal
-- ============================================
-- Fecha creación: 2026-01-XX (documentado 2026-02-05)
-- Usados por: workflow 06-Checkpoint Dominical, 07-Procesar Checkpoint

-- ============================================
-- TEMPLATE: checkpoint_semanal
-- ============================================
-- Email enviado cada domingo con el resumen semanal y selección de sesiones

INSERT INTO email_templates (nombre, tipo, descripcion, html_template, variables_requeridas, version)
VALUES (
  'checkpoint_semanal',
  'email',
  'Email de checkpoint semanal con resumen y selección de sesiones para la próxima semana',
  '<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Checkpoint Semanal</title>
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, ''Segoe UI'', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; color: #E8E8E8; background: #232323;">

  <div style="text-align: center; padding: 25px 0 15px 0;">
    <img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width: 150px; height: auto;">
  </div>

  <div style="background: linear-gradient(135deg, #DFCA61 0%, #62B882 100%); color: #1C1C1C; padding: 40px 30px; text-align: center; border-radius: 18px 18px 0 0;">
    <div style="font-size: 48px; margin-bottom: 15px;">📊</div>
    <h1 style="margin: 0; font-size: 28px; font-weight: 700;">Checkpoint Semana {{semana_actual}}</h1>
    <p style="margin: 10px 0 0 0; opacity: 0.9; font-size: 16px;">Tu resumen semanal</p>
  </div>

  <div style="background: #1C1C1C; padding: 40px 30px; border-radius: 0 0 18px 18px; border: 1px solid rgba(255,255,255,0.08); border-top: none;">

    <p style="font-size: 18px; line-height: 1.6; margin: 0 0 20px 0; color: #E8E8E8;">
      Hola <strong style="color: #DFCA61;">{{nombre}}</strong>,
    </p>

    <div style="background: rgba(98,184,130,0.1); border-left: 4px solid #62B882; padding: 20px; margin: 25px 0; border-radius: 12px;">
      <p style="margin: 0 0 10px 0; font-size: 16px; font-weight: 600; color: #62B882;">📈 Tu progreso esta semana:</p>
      <ul style="margin: 0; padding-left: 20px; color: #B5B5B5; line-height: 1.8;">
        <li>Sesiones completadas: <strong style="color: #E8E8E8;">{{sesiones_completadas}}/{{sesiones_objetivo}}</strong></li>
        <li>Adherencia: <strong style="color: #E8E8E8;">{{adherencia_porcentaje}}%</strong></li>
        <li>Nivel actual: <strong style="color: #E8E8E8;">{{nivel_actual}}</strong></li>
        <li>Intensidad: <strong style="color: #E8E8E8;">{{intensidad}}%</strong></li>
      </ul>
    </div>

    <div style="background: rgba(223,202,97,0.15); border-radius: 12px; padding: 20px; margin: 25px 0; text-align: center;">
      <p style="margin: 0; font-size: 17px; line-height: 1.6; color: #E8E8E8;">
        💬 {{mensaje_usuario}}
      </p>
    </div>

    <div style="background: rgba(223,202,97,0.1); border: 2px solid #DFCA61; padding: 25px; margin: 25px 0; border-radius: 12px;">
      <p style="margin: 0 0 10px 0; font-size: 16px; font-weight: 600; color: #DFCA61;">📅 Siguiente paso: elige cuántas sesiones quieres esta semana</p>
      <p style="margin: 0 0 20px 0; font-size: 14px; color: #B5B5B5;">Esto activa tu semana {{semana_siguiente}}. Te enviaremos la primera sesión para que la hagas cuando te venga bien esta semana.</p>

      <div style="text-align: center;">
        <a href="{{webhook_url}}/webhook/checkpoint-semanal?user_id={{user_id}}&sesiones=2"
           style="display: inline-block; background: rgba(98,184,130,0.2); border: 2px solid #62B882; color: #62B882; padding: 14px 24px; text-decoration: none; border-radius: 10px; font-weight: 600; font-size: 15px; margin: 6px;">
          2 sesiones
        </a>
        <a href="{{webhook_url}}/webhook/checkpoint-semanal?user_id={{user_id}}&sesiones=3"
           style="display: inline-block; background: rgba(223,202,97,0.3); border: 2px solid #DFCA61; color: #DFCA61; padding: 14px 24px; text-decoration: none; border-radius: 10px; font-weight: 600; font-size: 15px; margin: 6px;">
          3 sesiones ⭐
        </a>
        <a href="{{webhook_url}}/webhook/checkpoint-semanal?user_id={{user_id}}&sesiones=4"
           style="display: inline-block; background: rgba(98,184,130,0.2); border: 2px solid #62B882; color: #62B882; padding: 14px 24px; text-decoration: none; border-radius: 10px; font-weight: 600; font-size: 15px; margin: 6px;">
          4 sesiones
        </a>
        <a href="{{webhook_url}}/webhook/checkpoint-semanal?user_id={{user_id}}&sesiones=5"
           style="display: inline-block; background: rgba(102,126,234,0.2); border: 2px solid #667eea; color: #667eea; padding: 14px 24px; text-decoration: none; border-radius: 10px; font-weight: 600; font-size: 15px; margin: 6px;">
          5 sesiones 💪
        </a>
      </div>

      <p style="font-size: 12px; color: #666; text-align: center; margin: 15px 0 0 0;">
        ⭐ = Recomendado para mantener progreso constante
      </p>
    </div>

    <p style="font-size: 16px; line-height: 1.6; margin-top: 30px; color: #B5B5B5;">
      ¡A por la semana {{semana_siguiente}}! 🚀<br>
      <strong style="color: #DFCA61;">El equipo de Camino Vital</strong>
    </p>
  </div>

  <div style="text-align: center; margin-top: 30px; padding: 20px; color: #666; font-size: 12px;">
    <p style="margin: 0;">Camino Vital | Hábitos Vitales</p>
  </div>
</body>
</html>',
  '["nombre", "semana_actual", "semana_siguiente", "sesiones_completadas", "sesiones_objetivo", "adherencia_porcentaje", "nivel_actual", "intensidad", "mensaje_usuario", "user_id", "webhook_url"]',
  1
)
ON CONFLICT (nombre, version) DO UPDATE SET
  html_template = EXCLUDED.html_template,
  descripcion = EXCLUDED.descripcion,
  variables_requeridas = EXCLUDED.variables_requeridas;


-- ============================================
-- TEMPLATE: programa_completado
-- ============================================
-- Email enviado cuando el usuario completa las 12 semanas del programa

INSERT INTO email_templates (nombre, tipo, descripcion, html_template, variables_requeridas, version)
VALUES (
  'programa_completado',
  'email',
  'Email de felicitación cuando el usuario completa las 12 semanas de Base Vital',
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

  <div style="background: linear-gradient(135deg, #DFCA61 0%, #62B882 100%); color: #1C1C1C; padding: 50px 30px; text-align: center; border-radius: 18px 18px 0 0;">
    <div style="font-size: 80px; margin-bottom: 15px;">🏆</div>
    <h1 style="margin: 0; font-size: 32px; font-weight: 700;">¡Felicidades, {{nombre}}!</h1>
    <p style="margin: 15px 0 0 0; font-size: 18px; opacity: 0.9;">Has completado Base Vital</p>
  </div>

  <div style="background: #1C1C1C; padding: 40px 30px; border-radius: 0 0 18px 18px; border: 1px solid rgba(255,255,255,0.08); border-top: none;">

    <div style="text-align: center; margin-bottom: 30px;">
      <div style="background: rgba(223,202,97,0.15); padding: 25px 35px; border-radius: 12px; display: inline-block; border: 1px solid rgba(223,202,97,0.3);">
        <div style="font-size: 42px; font-weight: 700; color: #DFCA61;">12</div>
        <div style="font-size: 14px; color: #B5B5B5;">Semanas completadas</div>
      </div>
    </div>

    <p style="font-size: 18px; line-height: 1.7; margin: 0 0 25px 0; text-align: center; color: #E8E8E8;">
      Has demostrado <strong style="color: #62B882;">constancia y compromiso</strong> con tu salud durante 12 semanas.
    </p>

    <div style="background: rgba(98,184,130,0.1); border-left: 4px solid #62B882; padding: 25px; border-radius: 12px; margin: 30px 0;">
      <h3 style="margin: 0 0 15px 0; color: #62B882; font-size: 18px;">💡 ¿Qué hacer ahora?</h3>
      <ul style="margin: 0; padding-left: 20px; line-height: 2; color: #B5B5B5;">
        <li>Mantén el hábito: sigue moviéndote 3x por semana</li>
        <li>Repite tus ejercicios favoritos del programa</li>
      </ul>
    </div>

    <p style="font-size: 16px; line-height: 1.7; margin: 30px 0 10px; text-align: center; color: #B5B5B5;">
      Gracias por confiar en nosotros. 💛<br>
      <strong style="color: #DFCA61;">El equipo de Camino Vital</strong>
    </p>
  </div>

  <div style="text-align: center; margin-top: 30px; padding: 20px; color: #666; font-size: 12px;">
    <p style="margin: 0;">Camino Vital | Hábitos Vitales</p>
  </div>

</body>
</html>',
  '["nombre"]',
  1
)
ON CONFLICT (nombre, version) DO UPDATE SET
  html_template = EXCLUDED.html_template,
  descripcion = EXCLUDED.descripcion,
  variables_requeridas = EXCLUDED.variables_requeridas;
