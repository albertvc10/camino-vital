-- ============================================
-- TEMPLATES EMAILS UNIFICADOS - Dark Mode
-- ============================================
-- Fecha: 2026-02-12
-- Propósito: Unificar estética de todos los emails de sesión
-- Cambios:
--   - email_primera_sesion: morado → verde
--   - email_sesion_siguiente: morado → verde
--   - email_bienvenida: corrección de tildes
-- ============================================

-- ============================================
-- TEMPLATE: email_bienvenida (corregido tildes)
-- ============================================
UPDATE email_templates
SET html_template = '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Bienvenido a Camino Vital</title>
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background: #232323; color: #E8E8E8;">
  <div style="background: #1C1C1C; border-radius: 18px; overflow: hidden; box-shadow: 0 10px 40px rgba(0,0,0,0.4); border: 1px solid rgba(255,255,255,0.08);">

    <!-- Logo -->
    <div style="text-align: center; padding: 30px 20px 20px;">
      <img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Hábitos Vitales" style="max-width: 150px; height: auto;">
    </div>

    <!-- Header -->
    <div style="background: linear-gradient(180deg, #2A2A2A 0%, #1C1C1C 100%); padding: 40px; text-align: center;">
      <h1 style="margin: 0; font-size: 28px; color: #DFCA61;">¡Bienvenido a Camino Vital!</h1>
      <p style="margin: 10px 0 0; color: #B5B5B5;">Tu camino hacia una vida más activa comienza hoy</p>
    </div>

    <!-- Contenido -->
    <div style="padding: 40px;">
      <p style="font-size: 18px; line-height: 1.6; color: #E8E8E8;">Hola <strong style="color: #DFCA61;">{{nombre}}</strong>,</p>

      <p style="font-size: 16px; line-height: 1.6; color: #B5B5B5;">¡Ha llegado el día! Tu programa <strong style="color: #62B882;">Camino Vital</strong> está listo para empezar.</p>

      <p style="font-size: 16px; line-height: 1.6; color: #B5B5B5;">Has dado el primer paso para cuidar tu autonomía y tu longevidad. Y eso ya es mucho.</p>

      <!-- Programa personalizado -->
      <div style="background: rgba(98, 184, 130, 0.1); border-left: 4px solid #62B882; padding: 20px; margin: 30px 0; border-radius: 4px;">
        <h3 style="color: #62B882; margin: 0 0 15px 0;">Tu programa personalizado:</h3>
        <ul style="margin: 0; padding-left: 20px; line-height: 1.8; color: #B5B5B5;">
          <li><strong style="color: #E8E8E8;">Etapa:</strong> Base Vital</li>
          <li><strong style="color: #E8E8E8;">Nivel:</strong> {{nivel}}</li>
        </ul>
      </div>

      <!-- Selección de sesiones -->
      <div style="background: rgba(223, 202, 97, 0.1); border: 1px solid rgba(223, 202, 97, 0.3); padding: 30px; border-radius: 12px; text-align: center; margin: 30px 0;">
        <h3 style="color: #DFCA61; margin: 0 0 15px 0; font-size: 22px;">Empecemos: ¿Cuántas sesiones puedes hacer esta semana?</h3>
        <p style="color: #B5B5B5; margin: 0 0 25px 0; font-size: 15px;">Sé realista, siempre puedes ajustar cada semana</p>
        <div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">
          <a href="{{base_url}}/webhook/seleccionar-sesiones?user_id={{user_id}}&sesiones=2" style="background: #DFCA61; color: #1C1C1C; padding: 15px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block; margin: 5px; min-width: 90px; text-align: center;">2 sesiones</a>
          <a href="{{base_url}}/webhook/seleccionar-sesiones?user_id={{user_id}}&sesiones=3" style="background: #DFCA61; color: #1C1C1C; padding: 15px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block; margin: 5px; min-width: 90px; text-align: center;">3 sesiones<br><span style="font-size: 11px; font-weight: normal;">(Recomendado)</span></a>
          <a href="{{base_url}}/webhook/seleccionar-sesiones?user_id={{user_id}}&sesiones=4" style="background: #DFCA61; color: #1C1C1C; padding: 15px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block; margin: 5px; min-width: 90px; text-align: center;">4 sesiones</a>
          <a href="{{base_url}}/webhook/seleccionar-sesiones?user_id={{user_id}}&sesiones=5" style="background: #DFCA61; color: #1C1C1C; padding: 15px 25px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block; margin: 5px; min-width: 90px; text-align: center;">5 sesiones</a>
        </div>
      </div>

      <!-- Qué esperar -->
      <h3 style="color: #DFCA61; margin: 30px 0 15px;">¿Qué puedes esperar?</h3>
      <ul style="line-height: 1.8; color: #B5B5B5;">
        <li>Cuando termines una sesión, recibirás la siguiente inmediatamente</li>
        <li>Vídeos demostrativos para cada movimiento</li>
        <li>El programa se adapta a tu ritmo y feedback</li>
        <li>Soporte personalizado si tienes dudas</li>
      </ul>

      <!-- Consejo -->
      <div style="background: rgba(223, 202, 97, 0.1); border-left: 4px solid #DFCA61; padding: 20px; margin: 30px 0; border-radius: 4px;">
        <p style="margin: 0; font-weight: 600; color: #DFCA61;">Consejo importante:</p>
        <p style="margin: 10px 0 0; color: #B5B5B5;">Empieza con 2-3 sesiones si tienes dudas. Es mejor hacer menos y ser constante que planificar mucho y abandonar.</p>
      </div>

      <!-- Contacto -->
      <div style="text-align: center; margin: 40px 0;">
        <p style="font-size: 16px; color: #888;">¿Tienes dudas o necesitas ayuda?</p>
        <p style="margin: 10px 0;"><a href="mailto:hola@habitos-vitales.com" style="color: #DFCA61; text-decoration: none; font-weight: bold;">Escríbenos</a></p>
      </div>

      <p style="font-size: 16px; line-height: 1.6; color: #B5B5B5;">¡Haz click arriba para empezar!</p>
      <p style="font-size: 16px; line-height: 1.6; color: #B5B5B5;">Un saludo,<br><strong style="color: #E8E8E8;">El equipo de Camino Vital</strong></p>
    </div>
  </div>

  <!-- Footer -->
  <div style="text-align: center; margin-top: 30px; padding: 20px; color: #666; font-size: 12px;">
    <strong style="color: #DFCA61;">Camino Vital</strong> | Hábitos Vitales<br>
    Este email es parte de tu programa de ejercicio personalizado
  </div>
</body>
</html>',
updated_at = NOW()
WHERE nombre = 'email_bienvenida' AND activo = true;


-- ============================================
-- TEMPLATE: email_primera_sesion (verde unificado)
-- ============================================
UPDATE email_templates
SET html_template = '<!DOCTYPE html>
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
    <div style="font-size: 48px; margin-bottom: 10px;">🎯</div>
    <h1 style="margin: 0; font-size: 28px;">¡Tu Primera Sesión!</h1>
    <p style="margin: 10px 0 0 0; opacity: 0.9; font-size: 16px;">Sesión 1 de {{sesiones_objetivo}} esta semana</p>
  </div>

  <div style="background: #1C1C1C; padding: 40px 30px; border-radius: 0 0 18px 18px; border: 1px solid rgba(255,255,255,0.08); border-top: none;">

    <p style="font-size: 18px; line-height: 1.6; margin: 0 0 20px 0; color: #E8E8E8;">
      Hola <strong style="color: #DFCA61;">{{nombre}}</strong>,
    </p>

    <p style="font-size: 16px; line-height: 1.6; margin: 0 0 25px 0; color: #B5B5B5;">
      ¡Genial! Has elegido hacer {{sesiones_objetivo}} sesiones esta semana. Aquí tienes la primera, diseñada especialmente para ti.
    </p>

    <div style="background: rgba(98,184,130,0.1); border-left: 4px solid #62B882; padding: 20px; margin: 0 0 30px 0; border-radius: 12px;">
      <p style="margin: 0; font-size: 15px; line-height: 1.6; color: #B5B5B5;">
        {{introduccion}}
      </p>
    </div>

    <div style="background: rgba(255,255,255,0.04); padding: 25px; border-radius: 12px; margin: 0 0 30px 0; border: 1px solid rgba(255,255,255,0.08);">
      <h3 style="margin: 0 0 15px 0; color: #E8E8E8; font-size: 18px;">📋 Tu sesión de hoy:</h3>
      <ul style="margin: 0; padding-left: 20px; line-height: 2; color: #B5B5B5;">
        <li><strong style="color: #E8E8E8;">Duración:</strong> {{duracion}}</li>
        <li><strong style="color: #E8E8E8;">Enfoque:</strong> {{enfoque}}</li>
        <li><strong style="color: #E8E8E8;">Contenido:</strong> {{contenido}}</li>
        <li><strong style="color: #E8E8E8;">Nivel:</strong> {{nivel}}</li>
      </ul>
    </div>

    <div style="text-align: center; margin: 40px 0;">
      <a href="{{sesion_url}}" style="display: inline-block; background: linear-gradient(135deg, #62B882 0%, #4CAF50 100%); color: white; padding: 18px 40px; text-decoration: none; border-radius: 12px; font-weight: bold; font-size: 18px; box-shadow: 0 4px 15px rgba(98, 184, 130, 0.4);">
        🎬 VER MI SESIÓN
      </a>
    </div>

    <div style="background: rgba(223,202,97,0.1); border-left: 4px solid #DFCA61; padding: 20px; margin: 30px 0; border-radius: 12px;">
      <p style="margin: 0; font-weight: 600; color: #DFCA61;">💡 Recuerda:</p>
      <ul style="margin: 10px 0 0; padding-left: 20px; color: #B5B5B5; line-height: 1.8;">
        <li>Ve a tu ritmo, no hay prisa</li>
        <li>Si algo duele, para y descansa</li>
        <li>Al terminar, pulsa FINALIZAR para recibir la siguiente</li>
      </ul>
    </div>

    <p style="font-size: 16px; line-height: 1.6; margin: 30px 0 10px; color: #B5B5B5;">
      ¡Estás dando un gran paso! 💪<br>
      <strong style="color: #DFCA61;">El equipo de Camino Vital</strong>
    </p>
  </div>

  <div style="text-align: center; margin-top: 30px; padding: 20px; color: #666; font-size: 12px;">
    <p style="margin: 0;">Camino Vital | Hábitos Vitales</p>
  </div>

</body>
</html>',
updated_at = NOW()
WHERE nombre = 'email_primera_sesion' AND activo = true;


-- ============================================
-- TEMPLATE: email_sesion_siguiente (verde unificado)
-- ============================================
UPDATE email_templates
SET html_template = '<!DOCTYPE html>
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
    <div style="font-size: 48px; margin-bottom: 10px;">💪</div>
    <h1 style="margin: 0; font-size: 28px;">¡Siguiente Sesión Lista!</h1>
    <p style="margin: 10px 0 0 0; opacity: 0.9; font-size: 16px;">Sesión {{sesion_numero}} de {{sesiones_objetivo}} esta semana</p>
  </div>

  <div style="background: #1C1C1C; padding: 40px 30px; border-radius: 0 0 18px 18px; border: 1px solid rgba(255,255,255,0.08); border-top: none;">

    <p style="font-size: 18px; line-height: 1.6; margin: 0 0 20px 0; color: #E8E8E8;">
      Hola <strong style="color: #DFCA61;">{{nombre}}</strong>,
    </p>

    <p style="font-size: 16px; line-height: 1.6; margin: 0 0 25px 0; color: #B5B5B5;">
      ¡Muy bien! Ya has completado una sesión. Aquí tienes la siguiente para continuar con tu progreso.
    </p>

    <div style="background: rgba(98,184,130,0.1); border-left: 4px solid #62B882; padding: 20px; margin: 0 0 30px 0; border-radius: 12px;">
      <p style="margin: 0; font-size: 15px; line-height: 1.6; color: #B5B5B5;">
        {{introduccion}}
      </p>
    </div>

    <div style="background: rgba(255,255,255,0.04); padding: 25px; border-radius: 12px; margin: 0 0 30px 0; border: 1px solid rgba(255,255,255,0.08);">
      <h3 style="margin: 0 0 15px 0; color: #E8E8E8; font-size: 18px;">📋 Tu sesión de hoy:</h3>
      <ul style="margin: 0; padding-left: 20px; line-height: 2; color: #B5B5B5;">
        <li><strong style="color: #E8E8E8;">Duración:</strong> {{duracion}}</li>
        <li><strong style="color: #E8E8E8;">Enfoque:</strong> {{enfoque}}</li>
        <li><strong style="color: #E8E8E8;">Contenido:</strong> {{contenido}}</li>
        <li><strong style="color: #E8E8E8;">Nivel:</strong> {{nivel}}</li>
      </ul>
    </div>

    <div style="text-align: center; margin: 40px 0;">
      <a href="{{sesion_url}}" style="display: inline-block; background: linear-gradient(135deg, #62B882 0%, #4CAF50 100%); color: white; padding: 18px 40px; text-decoration: none; border-radius: 12px; font-weight: bold; font-size: 18px; box-shadow: 0 4px 15px rgba(98, 184, 130, 0.4);">
        🎬 VER MI SESIÓN
      </a>
    </div>

    <div style="background: rgba(223,202,97,0.1); border-left: 4px solid #DFCA61; padding: 20px; margin: 30px 0; border-radius: 12px;">
      <p style="margin: 0; font-weight: 600; color: #DFCA61;">💡 Recuerda:</p>
      <ul style="margin: 10px 0 0; padding-left: 20px; color: #B5B5B5; line-height: 1.8;">
        <li>Ve a tu ritmo, no hay prisa</li>
        <li>Si algo duele, para y descansa</li>
        <li>Al terminar, pulsa FINALIZAR para recibir la siguiente</li>
      </ul>
    </div>

    <p style="font-size: 16px; line-height: 1.6; margin: 30px 0 10px; color: #B5B5B5;">
      ¡Sigue así, vas muy bien! 🔥<br>
      <strong style="color: #DFCA61;">El equipo de Camino Vital</strong>
    </p>
  </div>

  <div style="text-align: center; margin-top: 30px; padding: 20px; color: #666; font-size: 12px;">
    <p style="margin: 0;">Camino Vital | Hábitos Vitales</p>
  </div>

</body>
</html>',
updated_at = NOW()
WHERE nombre = 'email_sesion_siguiente' AND activo = true;


-- ============================================
-- Verificación
-- ============================================
SELECT
  nombre,
  updated_at,
  CASE
    WHEN html_template LIKE '%#62B882%' THEN 'Verde OK'
    WHEN html_template LIKE '%#667eea%' THEN 'Morado (antiguo)'
    ELSE 'Otro'
  END as color_header
FROM email_templates
WHERE nombre IN ('email_bienvenida', 'email_primera_sesion', 'email_sesion_siguiente')
  AND activo = true;
