#!/usr/bin/env python3
import json

# Leer workflow 03-bis
with open('/Users/albertvillanueva/Documents/HV_n8n/programa-camino-vital/workflows/Camino Vital - 03-bis Feedback y Siguiente Sesión.json', 'r') as f:
    workflow = json.load(f)

# 1. Eliminar nodo "Obtener Contenido Siguiente Sesión"
nodos_a_eliminar = ['d6c5d6d1-426a-4c43-9449-e8e0d8cf420d']  # ID del nodo a eliminar
workflow['nodes'] = [n for n in workflow['nodes'] if n['id'] not in nodos_a_eliminar]

# 2. Crear nodo HTTP Request para llamar al generador IA
nuevo_nodo_generar_ia = {
    "parameters": {
        "method": "POST",
        "url": "=http://localhost:5678/webhook/generar-sesion-ia",
        "sendQuery": True,
        "queryParameters": {
            "parameters": [
                {
                    "name": "user_id",
                    "value": "={{ $node['Actualizar Progreso Usuario'].json.id }}"
                }
            ]
        },
        "options": {
            "response": {
                "response": {
                    "responseFormat": "json"
                }
            },
            "timeout": 120000
        }
    },
    "id": "generar-sesion-ia-03",
    "name": "Generar Sesión con IA",
    "type": "n8n-nodes-base.httpRequest",
    "typeVersion": 4.2,
    "position": [896, -112]
}

# 3. Crear nodo para obtener sesión completa
nuevo_nodo_obtener_sesion = {
    "parameters": {
        "operation": "executeQuery",
        "query": "=SET search_path TO camino_vital;\n\nSELECT \n  id as sesion_id,\n  titulo,\n  introduccion_personalizada,\n  enfoque,\n  duracion_estimada,\n  calentamiento,\n  trabajo_principal,\n  tipo_actividad,\n  calentamiento_texto,\n  actividad_principal,\n  numero_sesion\nFROM programa_sesiones\nWHERE id = {{ $json.sesion_id }};",
        "options": {}
    },
    "id": "obtener-sesion-completa-03",
    "name": "Obtener Sesión Completa",
    "type": "n8n-nodes-base.postgres",
    "typeVersion": 2.4,
    "position": [1056, -112],
    "credentials": {
        "postgres": {
            "id": "nLcUOvLreXurFbBs",
            "name": "PostgreSQL Camino Vital Local"
        }
    }
}

# Añadir nuevos nodos
workflow['nodes'].append(nuevo_nodo_generar_ia)
workflow['nodes'].append(nuevo_nodo_obtener_sesion)

# 4. Encontrar y modificar nodo "Preparar Email Sesión"
for nodo in workflow['nodes']:
    if nodo['name'] == 'Preparar Email Sesión':
        # El nodo actual obtiene datos de "Obtener Contenido Siguiente Sesión" que ya no existe
        # Necesitamos que obtenga de "Obtener Sesión Completa"
        nodo['parameters']['jsCode'] = """// Preparar email con sesión generada por IA

const usuario = $node["Actualizar Progreso Usuario"].json;
const sesion = $node["Obtener Sesión Completa"].json;

console.log('📧 Preparando email con sesión personalizada');
console.log('🎯 Sesión ID:', sesion.sesion_id);
console.log('🎯 Enfoque:', sesion.enfoque);

// Variables para el template
const webhookUrl = process.env.WEBHOOK_URL || 'http://localhost:5678';
const sesionUrl = `${webhookUrl}/webhook/view-session/sesion/${sesion.sesion_id}?token=${usuario.auth_token}`;

// Calcular contenido según tipo
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

// HTML del email
const emailHTML = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; color: #333; background: #f5f5f5;">

  <!-- Header -->
  <div style="background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%); color: white; padding: 40px 30px; text-align: center; border-radius: 12px 12px 0 0;">
    <h1 style="margin: 0; font-size: 28px;">🎯 Sesión ${usuario.sesion_actual_dentro_semana} de ${usuario.sesiones_objetivo_semana}</h1>
    <p style="margin: 10px 0 0 0; opacity: 0.9; font-size: 16px;">¡Sigue así!</p>
  </div>

  <!-- Contenido -->
  <div style="background: white; padding: 40px 30px; border-radius: 0 0 12px 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">

    <p style="font-size: 18px; line-height: 1.6; margin: 0 0 20px 0;">
      Hola <strong>${usuario.nombre}</strong>,
    </p>

    <p style="font-size: 16px; line-height: 1.6; margin: 0 0 25px 0;">
      ¡Genial trabajo en tu última sesión! Aquí está tu siguiente sesión personalizada.
    </p>

    <!-- Introducción personalizada -->
    <div style="background: #e8f5e9; border-left: 4px solid #4CAF50; padding: 20px; margin: 0 0 30px 0; border-radius: 4px;">
      <p style="margin: 0; font-size: 15px; line-height: 1.6; color: #333;">
        ${sesion.introduccion_personalizada || 'Sesión diseñada para tu nivel y objetivos.'}
      </p>
    </div>

    <!-- Resumen -->
    <div style="background: #f9f9f9; padding: 25px; border-radius: 8px; margin: 0 0 30px 0;">
      <h3 style="margin: 0 0 15px 0; color: #333; font-size: 18px;">📋 Resumen:</h3>
      <ul style="margin: 0; padding-left: 20px; line-height: 2; color: #666;">
        <li><strong>Duración:</strong> ${sesion.duracion_estimada || '25-30 minutos'}</li>
        <li><strong>Enfoque:</strong> ${enfoqueTexto}</li>
        <li><strong>Contenido:</strong> ${totalEjercicios}</li>
      </ul>
    </div>

    <!-- CTA Button -->
    <div style="text-align: center; margin: 40px 0;">
      <a href="${sesionUrl}" style="display: inline-block; background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%); color: white; padding: 18px 40px; text-decoration: none; border-radius: 8px; font-weight: bold; font-size: 18px; box-shadow: 0 4px 15px rgba(76, 175, 80, 0.4);">
        🎬 VER MI SESIÓN
      </a>
    </div>

    <p style="font-size: 16px; line-height: 1.6; margin: 30px 0 10px;">
      ¡A por ello! 💪<br>
      <strong>El equipo de Camino Vital</strong>
    </p>
  </div>

  <!-- Footer -->
  <div style="text-align: center; margin-top: 30px; padding: 20px; color: #999; font-size: 12px;">
    <p style="margin: 0;">Camino Vital | Hábitos Vitales</p>
  </div>

</body>
</html>
`;

return {
  json: {
    user_id: usuario.id,
    user_email: usuario.email,
    user_nombre: usuario.nombre,
    contenido_id: sesion.sesion_id,
    sesiones_objetivo: usuario.sesiones_objetivo_semana,
    semana: usuario.semana_actual,
    sesion_numero: usuario.sesion_actual_dentro_semana,
    email_html: emailHTML,
    asunto: `🎯 Sesión ${usuario.sesion_actual_dentro_semana} de ${usuario.sesiones_objetivo_semana}: ${sesion.titulo}`
  }
};"""

# 5. Actualizar conexiones
# Limpiar conexión obsoleta
if 'Obtener Contenido Siguiente Sesión' in workflow['connections']:
    del workflow['connections']['Obtener Contenido Siguiente Sesión']

# IF quedan más sesiones → Generar Sesión con IA
workflow['connections']['IF: ¿Quedan más sesiones?']['main'][0] = [
    {
        "node": "Generar Sesión con IA",
        "type": "main",
        "index": 0
    }
]

# Generar Sesión con IA → Obtener Sesión Completa
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

# Obtener Sesión Completa → Obtener Template Email
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
output_path = '/Users/albertvillanueva/Documents/HV_n8n/programa-camino-vital/workflows/Camino Vital - 03-bis Feedback y Siguiente Sesión-CENTRALIZADO.json'
with open(output_path, 'w') as f:
    json.dump(workflow, f, indent=2, ensure_ascii=False)

print("✅ Workflow 03-bis simplificado y guardado")
print(f"📊 Total nodos: {len(workflow['nodes'])}")
print(f"📊 Total conexiones: {len(workflow['connections'])}")
print(f"📄 Guardado en: {output_path}")
