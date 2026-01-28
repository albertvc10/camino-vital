-- ============================================
-- TEMPLATES PREVENTA - EMAIL PLAZA RESERVADA
-- ============================================
-- Template para confirmar plaza reservada en preventa
-- Ejecutar para anadir template a la base de datos

-- ============================================
-- 1. Anadir columna fecha_inicio_programa si no existe
-- ============================================
ALTER TABLE programa_users
ADD COLUMN IF NOT EXISTS fecha_inicio_programa TIMESTAMP;

COMMENT ON COLUMN programa_users.fecha_inicio_programa IS 'Fecha programada de inicio del programa (para usuarios de preventa)';

-- ============================================
-- 2. TEMPLATE: Plaza Reservada (Preventa)
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
  'email_plaza_reservada',
  'email',
  'Email de confirmacion de plaza reservada en preventa (inicio diferido)',
  '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Tu plaza esta reservada</title>
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background: #232323; color: #E8E8E8;">
  <div style="background: #1C1C1C; border-radius: 18px; overflow: hidden; box-shadow: 0 10px 40px rgba(0,0,0,0.4); border: 1px solid rgba(255,255,255,0.08);">

    <!-- Logo -->
    <div style="text-align: center; padding: 30px 20px 20px;">
      <img src="https://habitos-vitales.com/wp-content/uploads/2023/09/1-e1769547181637.png" alt="Habitos Vitales" style="max-width: 150px; height: auto;">
    </div>

    <!-- Header -->
    <div style="background: linear-gradient(180deg, #2A2A2A 0%, #1C1C1C 100%); padding: 40px; text-align: center;">
      <div style="font-size: 60px; margin-bottom: 20px;">🎉</div>
      <h1 style="margin: 0; font-size: 28px; color: #DFCA61;">Tu plaza esta reservada!</h1>
      <p style="margin: 10px 0 0; color: #B5B5B5;">Gracias por confiar en Camino Vital</p>
    </div>

    <!-- Contenido -->
    <div style="padding: 40px;">
      <p style="font-size: 18px; line-height: 1.6; color: #E8E8E8;">Hola <strong style="color: #DFCA61;">{{nombre}}</strong>,</p>

      <p style="font-size: 16px; line-height: 1.6; color: #B5B5B5;">Tu plaza para el programa <strong style="color: #62B882;">Camino Vital</strong> esta confirmada.</p>

      <!-- Fecha de inicio -->
      <div style="background: rgba(98, 184, 130, 0.1); border: 2px solid rgba(98, 184, 130, 0.3); padding: 25px; margin: 30px 0; border-radius: 12px; text-align: center;">
        <p style="color: #B5B5B5; margin: 0 0 10px 0; font-size: 14px;">INICIO DEL PROGRAMA</p>
        <p style="color: #62B882; margin: 0; font-size: 28px; font-weight: bold;">📅 {{fecha_inicio_programa}}</p>
      </div>

      <!-- Incluye -->
      <div style="background: rgba(223, 202, 97, 0.1); border-left: 4px solid #DFCA61; padding: 20px; margin: 30px 0; border-radius: 4px;">
        <h3 style="color: #DFCA61; margin: 0 0 15px 0;">Tu reserva incluye:</h3>
        <ul style="margin: 0; padding-left: 20px; line-height: 1.8; color: #B5B5B5;">
          <li>Acceso completo al programa Camino Vital</li>
          <li>Ciclo guiado de 12 semanas</li>
          <li>Adaptacion a tu estado y objetivo</li>
          <li>Entrega por email</li>
          <li>Acompanamiento cercano</li>
          <li>Garantia de devolucion</li>
        </ul>
      </div>

      <!-- Precio pagado -->
      <div style="background: rgba(223, 202, 97, 0.08); border: 1px solid rgba(223, 202, 97, 0.2); padding: 20px; border-radius: 12px; text-align: center; margin: 30px 0;">
        <p style="color: #DFCA61; margin: 0; font-size: 15px;">💰 <strong>Precio pagado:</strong> 39€ (precio de reserva)</p>
      </div>

      <p style="font-size: 16px; line-height: 1.6; color: #B5B5B5;">El dia del inicio recibiras un email para configurar tu programa y elegir cuantas sesiones quieres hacer por semana.</p>

      <p style="font-size: 16px; line-height: 1.6; color: #B5B5B5;">Mientras tanto, si tienes cualquier duda puedes escribirnos a <a href="mailto:hola@habitos-vitales.com" style="color: #DFCA61; text-decoration: none;">hola@habitos-vitales.com</a></p>

      <!-- Mensaje final -->
      <div style="text-align: center; margin: 40px 0;">
        <p style="font-size: 18px; color: #62B882; font-weight: bold;">Nos vemos pronto!</p>
      </div>

      <p style="font-size: 16px; line-height: 1.6; color: #B5B5B5;">Un saludo,<br><strong style="color: #E8E8E8;">El equipo de Camino Vital</strong></p>
    </div>
  </div>

  <!-- Footer -->
  <div style="text-align: center; margin-top: 30px; padding: 20px; color: #666; font-size: 12px;">
    <strong style="color: #DFCA61;">Camino Vital</strong> | Habitos Vitales<br>
    Este email confirma tu reserva en el programa
  </div>
</body>
</html>',
  '["nombre", "fecha_inicio_programa"]'::jsonb,
  1
) ON CONFLICT (nombre, version) DO UPDATE SET
  html_template = EXCLUDED.html_template,
  variables_requeridas = EXCLUDED.variables_requeridas,
  descripcion = EXCLUDED.descripcion,
  updated_at = NOW();

-- ============================================
-- 3. Verificacion
-- ============================================
SELECT
  nombre,
  tipo,
  version,
  LENGTH(html_template) as tamano_html,
  jsonb_array_length(variables_requeridas) as num_variables,
  activo,
  created_at
FROM email_templates
WHERE nombre = 'email_plaza_reservada';

-- ============================================
-- Notas de uso:
-- ============================================
-- Estados de usuario para preventa:
-- - 'lead': Usuario que completo cuestionario
-- - 'early_bird_lead': Lead de preventa (opcional, se puede usar 'lead' + source='preventa')
-- - 'pagado_esperando_inicio': Usuario que pago pero espera fecha de inicio
-- - 'activo': Usuario con programa activo
--
-- El workflow 00-activar-usuarios-programados.json se encarga de:
-- 1. Buscar usuarios con estado='pagado_esperando_inicio' y fecha_inicio_programa <= NOW()
-- 2. Activarlos (estado='activo')
-- 3. Enviar email de bienvenida con seleccion de sesiones
