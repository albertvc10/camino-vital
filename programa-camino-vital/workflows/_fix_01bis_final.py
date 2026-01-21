#!/usr/bin/env python3
import json

# Leer workflow
with open('/Users/albertvillanueva/Documents/HV_n8n/programa-camino-vital/workflows/Camino Vital - 01-bis Seleccionar Sesiones y Enviar Primera-CENTRALIZADO.json', 'r') as f:
    workflow = json.load(f)

# 1. Encontrar y actualizar nodo "Preparar Email Sesión"
for nodo in workflow['nodes']:
    if nodo['name'] == 'Preparar Email Sesión':
        nodo['parameters']['jsCode'] = """// Preparar email con link a página de sesión personalizada

const usuario = $node["Guardar Sesiones Objetivo"].json;
const sesion = $node["Obtener Sesión Completa"].json;

console.log('📧 Preparando email con sesión personalizada');
console.log('🎯 Sesión ID:', sesion.sesion_id);
console.log('🎯 Enfoque:', sesion.enfoque);

// Variables para el template
const webhookUrl = process.env.WEBHOOK_URL || 'http://localhost:5678';
const sesionUrl = `${webhookUrl}/webhook/view-session/sesion/${sesion.sesion_id}?token=${usuario.auth_token}`;

// Calcular total de ejercicios según tipo
let totalEjercicios = 'N/A';
let enfoqueTexto = sesion.enfoque || 'Mixto';

if (sesion.enfoque === 'fuerza' && sesion.calentamiento && sesion.trabajo_principal) {
  const calentamiento = typeof sesion.calentamiento === 'string' ? JSON.parse(sesion.calentamiento) : sesion.calentamiento;
  const trabajoPrincipal = typeof sesion.trabajo_principal === 'string' ? JSON.parse(sesion.trabajo_principal) : sesion.trabajo_principal;
  totalEjercicios = `${(calentamiento?.length || 0) + (trabajoPrincipal?.length || 0)} ejercicios personalizados`;
  enfoqueTexto = 'Fuerza Funcional';
} else if (sesion.enfoque === 'cardio') {
  totalEjercicios = 'Actividad cardiovascular guiada';
  enfoqueTexto = 'Cardio y Resistencia';
}

// HTML del email (versión resumida con botón CTA)
const emailHTML = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; color: #333; background: #f5f5f5;">

  <!-- Header -->
  <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px 30px; text-align: center; border-radius: 12px 12px 0 0;">
    <h1 style="margin: 0; font-size: 28px;">🎯 Tu Sesión 1 de ${usuario.sesiones_objetivo_semana}</h1>
    <p style="margin: 10px 0 0 0; opacity: 0.9; font-size: 16px;">Diseñada específicamente para ti</p>
  </div>

  <!-- Contenido -->
  <div style="background: white; padding: 40px 30px; border-radius: 0 0 12px 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">

    <p style="font-size: 18px; line-height: 1.6; margin: 0 0 20px 0;">
      Hola <strong>${usuario.nombre}</strong>,
    </p>

    <p style="font-size: 16px; line-height: 1.6; margin: 0 0 25px 0;">
      He preparado una sesión personalizada para ti basándome en tu nivel, objetivos y limitaciones.
    </p>

    <!-- Introducción personalizada -->
    <div style="background: #f0f7ff; border-left: 4px solid #667eea; padding: 20px; margin: 0 0 30px 0; border-radius: 4px;">
      <p style="margin: 0; font-size: 15px; line-height: 1.6; color: #333;">
        ${sesion.introduccion_personalizada || 'Sesión diseñada para tu nivel y objetivos.'}
      </p>
    </div>

    <!-- Resumen de la sesión -->
    <div style="background: #f9f9f9; padding: 25px; border-radius: 8px; margin: 0 0 30px 0;">
      <h3 style="margin: 0 0 15px 0; color: #333; font-size: 18px;">📋 Resumen de tu sesión:</h3>
      <ul style="margin: 0; padding-left: 20px; line-height: 2; color: #666;">
        <li><strong>Duración:</strong> ${sesion.duracion_estimada || '25-30 minutos'}</li>
        <li><strong>Enfoque:</strong> ${enfoqueTexto}</li>
        <li><strong>Contenido:</strong> ${totalEjercicios}</li>
        <li><strong>Nivel:</strong> ${usuario.nivel_actual}</li>
      </ul>
    </div>

    <!-- CTA Button -->
    <div style="text-align: center; margin: 40px 0;">
      <a href="${sesionUrl}" style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 18px 40px; text-decoration: none; border-radius: 8px; font-weight: bold; font-size: 18px; box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);">
        🎬 VER MI SESIÓN COMPLETA
      </a>
      <p style="margin: 15px 0 0 0; font-size: 14px; color: #999;">
        Click para ver tu sesión completa
      </p>
    </div>

    <!-- Instrucciones -->
    <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 20px; margin: 30px 0; border-radius: 4px;">
      <p style="margin: 0; font-weight: 600; color: #856404;">💡 <strong>Recuerda:</strong></p>
      <ul style="margin: 10px 0 0; padding-left: 20px; color: #856404; line-height: 1.8;">
        <li>Ve a tu ritmo, no hay prisa</li>
        <li>Si algo duele, para y descansa</li>
        <li>Puedes pausar cuando necesites</li>
      </ul>
    </div>

    <!-- Cierre -->
    <p style="font-size: 16px; line-height: 1.6; margin: 30px 0 10px;">
      Cuando termines la sesión, haz click en "Completar Sesión" y recibirás la siguiente inmediatamente.
    </p>

    <p style="font-size: 16px; line-height: 1.6; margin: 10px 0;">
      ¡A por ello! 💪<br>
      <strong>El equipo de Camino Vital</strong>
    </p>
  </div>

  <!-- Footer -->
  <div style="text-align: center; margin-top: 30px; padding: 20px; color: #999; font-size: 12px;">
    <p style="margin: 0;">Camino Vital | Hábitos Vitales</p>
    <p style="margin: 5px 0 0;">Este email es parte de tu programa de ejercicio personalizado</p>
  </div>

</body>
</html>
`;

return {
  json: {
    user_id: usuario.id,
    user_email: usuario.email,
    user_nombre: usuario.nombre,
    sesion_id: sesion.sesion_id,
    sesiones_objetivo: usuario.sesiones_objetivo_semana,
    semana: usuario.semana_actual,
    sesion_numero: 1,
    email_html: emailHTML,
    asunto: `🎯 Tu Sesión 1 de ${usuario.sesiones_objetivo_semana}: ${sesion.titulo}`
  }
};"""

# 2. Limpiar conexiones obsoletas
conexiones_a_eliminar = [
    'Obtener Ejercicios Disponibles',
    'Preparar Prompt Claude',
    'Llamar Claude API',
    'Parsear Respuesta Claude',
    'Guardar Sesión en DB'
]

for conn_name in conexiones_a_eliminar:
    if conn_name in workflow['connections']:
        del workflow['connections'][conn_name]

# 3. Actualizar conexiones del workflow
# "Generar Sesión con IA" → "Obtener Sesión Completa"
workflow['connections']['Generar Sesión con IA'] = {
    "main": [[
        {
            "node": "Obtener Sesión Completa",
            "type": "main",
            "index": 0
        },
        {
            "node": "Responder Error",
            "type": "main",
            "index": 0
        }
    ]]
}

# "Obtener Sesión Completa" → "Obtener Template Email"
workflow['connections']['Obtener Sesión Completa'] = {
    "main": [[
        {
            "node": "Obtener Template Email",
            "type": "main",
            "index": 0
        }
    ]]
}

# Guardar
with open('/Users/albertvillanueva/Documents/HV_n8n/programa-camino-vital/workflows/Camino Vital - 01-bis Seleccionar Sesiones y Enviar Primera-CENTRALIZADO.json', 'w') as f:
    json.dump(workflow, f, indent=2, ensure_ascii=False)

print("✅ Workflow 01-bis completamente arreglado")
print(f"📊 Total nodos: {len(workflow['nodes'])}")
print(f"📊 Total conexiones: {len(workflow['connections'])}")
