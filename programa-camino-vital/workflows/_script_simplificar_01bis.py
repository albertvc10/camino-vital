#!/usr/bin/env python3
"""
Script para simplificar el workflow 01-bis reemplazando la generación de IA
por una llamada al workflow centralizado
"""
import json

# Leer workflow actual
with open('/Users/albertvillanueva/Documents/HV_n8n/programa-camino-vital/workflows/Camino Vital - 01-bis Seleccionar Sesiones y Enviar Primera-OPTIMIZADO.json', 'r') as f:
    workflow = json.load(f)

# IDs de nodos a eliminar (los de generación IA)
nodos_a_eliminar = [
    '5eab9019-0f52-46b2-a459-83062facad97',  # Obtener Ejercicios Disponibles
    '9e821f3a-7b52-47d0-a8e0-be881151ca6c',  # Preparar Prompt Claude
    'af06cbb7-1cdb-4c3f-91f2-6fa6ae1d3bef',  # Llamar Claude API
    '117eff0d-0f12-4008-af2c-1c46314b0344',  # Parsear Respuesta Claude
    'c0124c40-1675-49c9-83f1-8c4a9bd669d2',  # Guardar Sesión en DB
]

# Filtrar nodos
workflow['nodes'] = [n for n in workflow['nodes'] if n['id'] not in nodos_a_eliminar]

# Crear nuevo nodo HTTP Request para llamar al workflow centralizado
nuevo_nodo_llamada_ia = {
    "parameters": {
        "method": "POST",
        "url": "=http://localhost:5678/webhook/generar-sesion-ia",
        "sendQuery": True,
        "queryParameters": {
            "parameters": [
                {
                    "name": "user_id",
                    "value": "={{ $json.id }}"
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
    "id": "llamada-generador-ia",
    "name": "Generar Sesión con IA",
    "type": "n8n-nodes-base.httpRequest",
    "typeVersion": 4.2,
    "position": [400, -480]
}

# Insertar nuevo nodo después de "Guardar Sesiones Objetivo"
workflow['nodes'].append(nuevo_nodo_llamada_ia)

# Actualizar conexiones
# "Guardar Sesiones Objetivo" → "Generar Sesión con IA"
workflow['connections']['Guardar Sesiones Objetivo']['main'][0] = [
    {
        "node": "Generar Sesión con IA",
        "type": "main",
        "index": 0
    }
]

# "Generar Sesión con IA" → "Obtener Template Email"
workflow['connections']['Generar Sesión con IA'] = {
    "main": [[
        {
            "node": "Obtener Template Email",
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

# Limpiar conexiones de nodos eliminados
for nodo_id in nodos_a_eliminar:
    # Buscar el nombre del nodo
    for nodo in workflow['nodes']:
        if nodo['id'] == nodo_id:
            nombre_nodo = nodo['name']
            if nombre_nodo in workflow['connections']:
                del workflow['connections'][nombre_nodo]
            break

# Guardar workflow modificado
with open('/Users/albertvillanueva/Documents/HV_n8n/programa-camino-vital/workflows/Camino Vital - 01-bis Seleccionar Sesiones y Enviar Primera-CENTRALIZADO.json', 'w') as f:
    json.dump(workflow, f, indent=2, ensure_ascii=False)

print("✅ Workflow 01-bis simplificado y guardado")
print(f"📊 Nodos eliminados: {len(nodos_a_eliminar)}")
print(f"📊 Nodos totales: {len(workflow['nodes'])}")
