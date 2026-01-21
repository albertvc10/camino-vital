-- ============================================
-- INSERTAR PROMPT DE CLASIFICACIÓN
-- ============================================
-- Nota: Usar schema public (donde n8n trabaja por defecto)

-- Eliminar si existe
DELETE FROM email_templates WHERE nombre = 'clasificacion_ejercicios';

INSERT INTO email_templates (
  nombre,
  tipo,
  descripcion,
  html_template,
  variables_requeridas,
  activo
)
VALUES (
  'clasificacion_ejercicios',
  'prompt',
  'Prompt para clasificar ejercicios con IA basándose en el nombre del archivo',
  '# Prompt de Clasificación de Ejercicios

## Contexto
Eres un experto en clasificación de ejercicios físicos para personas mayores y con movilidad limitada. Tu tarea es analizar nombres de videos de ejercicios y asignar atributos detallados.

## Instrucciones
Analiza el siguiente nombre de video y devuelve un objeto JSON con la clasificación completa del ejercicio.

**Nombre del video:** `{{nombre_archivo}}`

## Clasificación Requerida

Devuelve ÚNICAMENTE un objeto JSON válido con esta estructura:

```json
{
  "nombre_espanol": "Nombre del ejercicio en español",
  "nivel": "iniciacion|intermedio|avanzado",
  "areas_cuerpo": ["piernas", "core", "brazos", "espalda", "hombros", "gluteos", "pecho"],
  "tipo_ejercicio": ["movilidad", "fuerza", "equilibrio", "estiramiento", "cardio", "estabilidad"],
  "posicion": "de_pie|sentado|suelo|tumbado|cuadrupedia",
  "requiere_equipo": true|false,
  "equipo_necesario": ["silla", "banda_elastica", "mancuernas", "esterilla", "pared"],
  "evitar_si_limitacion": ["espalda", "rodillas", "hombros", "munecas", "cuello", "cadera"],
  "objetivos": ["movilidad", "fuerza", "equilibrio", "confianza", "flexibilidad", "postura"],
  "descripcion_corta": "Descripción breve de 1-2 líneas del ejercicio",
  "descripcion_completa": "Descripción detallada del ejercicio, cómo se realiza y qué trabaja",
  "instrucciones_clave": [
    "Paso 1 del ejercicio",
    "Paso 2 del ejercicio",
    "Paso 3 del ejercicio"
  ],
  "beneficios": [
    "Beneficio 1",
    "Beneficio 2"
  ],
  "precauciones": [
    "Precaución 1 si aplica",
    "Precaución 2 si aplica"
  ]
}
```

## Criterios de Clasificación

### Nivel de Dificultad
- **iniciacion**: Ejercicios suaves, bajo impacto, adecuados para principiantes o movilidad muy limitada
- **intermedio**: Requieren cierta fuerza/equilibrio, pero son accesibles con práctica
- **avanzado**: Requieren fuerza significativa, equilibrio avanzado o coordinación compleja

### Áreas del Cuerpo
Indica todas las áreas que trabaja el ejercicio (puede ser múltiple):
- piernas, core, brazos, espalda, hombros, gluteos, pecho

### Tipo de Ejercicio
Indica todos los tipos que aplican:
- movilidad, fuerza, equilibrio, estiramiento, cardio, estabilidad

### Posición
La posición principal del ejercicio:
- de_pie, sentado, suelo, tumbado, cuadrupedia

### Equipo
- Si requiere algo más allá del propio cuerpo: requiere_equipo = true
- Especifica qué equipo: silla, banda_elastica, mancuernas, esterilla, pared

### Limitaciones
Indica limitaciones físicas con las que NO es recomendable este ejercicio:
- espalda: problemas lumbares, hernias, dolor crónico
- rodillas: artrosis, dolor, operaciones recientes
- hombros: lesiones de manguito rotador, limitación de movimiento
- munecas: problemas de túnel carpiano, artritis
- cuello: dolor cervical, limitación de rotación
- cadera: artrosis, prótesis, limitación de movilidad

### Objetivos
Indica qué objetivos cumple el ejercicio:
- movilidad: mejora rango de movimiento
- fuerza: desarrolla fuerza muscular
- equilibrio: mejora estabilidad y coordinación
- confianza: ejercicios que dan seguridad y autoestima
- flexibilidad: estiramientos, mejora de flexibilidad
- postura: corrección postural, fortalecimiento postural

## Ejemplos

### Ejemplo 1: Arm_Circles_Backward.mov

```json
{
  "nombre_espanol": "Círculos de Brazos Hacia Atrás",
  "nivel": "iniciacion",
  "areas_cuerpo": ["hombros", "brazos", "espalda"],
  "tipo_ejercicio": ["movilidad", "estiramiento"],
  "posicion": "de_pie",
  "requiere_equipo": false,
  "equipo_necesario": [],
  "evitar_si_limitacion": [],
  "objetivos": ["movilidad", "postura", "confianza"],
  "descripcion_corta": "Movimiento circular de los brazos hacia atrás para mejorar movilidad de hombros.",
  "descripcion_completa": "Ejercicio suave de movilidad donde se realizan círculos con los brazos hacia atrás. Ideal para calentar los hombros, mejorar el rango de movimiento y prevenir rigidez. Se realiza de pie con los pies separados al ancho de las caderas.",
  "instrucciones_clave": [
    "Colócate de pie con los pies al ancho de las caderas",
    "Extiende los brazos a los lados a la altura de los hombros",
    "Realiza círculos hacia atrás de forma controlada y suave",
    "Mantén los hombros relajados y la espalda recta",
    "Respira de forma natural durante el movimiento"
  ],
  "beneficios": [
    "Mejora la movilidad de hombros y parte superior de la espalda",
    "Previene rigidez y tensión en los hombros",
    "Mejora la postura al abrir el pecho"
  ],
  "precauciones": [
    "Si sientes dolor en los hombros, reduce el rango de movimiento",
    "No fuerces el movimiento, debe ser suave y controlado"
  ]
}
```

### Ejemplo 2: Alligator_Push-ups.mov

```json
{
  "nombre_espanol": "Flexiones Alligator",
  "nivel": "avanzado",
  "areas_cuerpo": ["brazos", "pecho", "core", "hombros"],
  "tipo_ejercicio": ["fuerza", "estabilidad"],
  "posicion": "suelo",
  "requiere_equipo": false,
  "equipo_necesario": [],
  "evitar_si_limitacion": ["hombros", "munecas", "espalda"],
  "objetivos": ["fuerza", "estabilidad"],
  "descripcion_corta": "Variación avanzada de flexiones que requiere fuerza significativa de brazos y core.",
  "descripcion_completa": "Ejercicio avanzado de fuerza que combina flexiones con movimiento de arrastre. Requiere fuerza significativa en brazos, pecho y core, además de buena estabilidad. Solo recomendado para personas con experiencia en ejercicio.",
  "instrucciones_clave": [
    "Colócate en posición de plancha con brazos extendidos",
    "Mantén el core activado y el cuerpo en línea recta",
    "Realiza una flexión bajando el pecho hacia el suelo",
    "Al subir, avanza arrastrándote hacia adelante",
    "Mantén el control durante todo el movimiento"
  ],
  "beneficios": [
    "Desarrolla fuerza significativa en brazos y pecho",
    "Mejora la estabilidad del core",
    "Aumenta la resistencia muscular"
  ],
  "precauciones": [
    "No apto para personas con problemas de hombros o muñecas",
    "Requiere buena forma física previa",
    "Puede causar tensión lumbar si no se mantiene el core activado"
  ]
}
```

### Ejemplo 3: Bent_Knee_Leg_Raises.mov

```json
{
  "nombre_espanol": "Elevaciones de Pierna con Rodilla Flexionada",
  "nivel": "intermedio",
  "areas_cuerpo": ["core", "piernas"],
  "tipo_ejercicio": ["fuerza", "estabilidad"],
  "posicion": "tumbado",
  "requiere_equipo": false,
  "equipo_necesario": [],
  "evitar_si_limitacion": ["espalda"],
  "objetivos": ["fuerza", "estabilidad", "postura"],
  "descripcion_corta": "Ejercicio de fortalecimiento abdominal realizado tumbado con rodillas flexionadas.",
  "descripcion_completa": "Ejercicio de nivel intermedio que fortalece el core mediante elevaciones de piernas con rodillas flexionadas. Más accesible que las elevaciones con piernas rectas, pero aún requiere control abdominal. Se realiza tumbado boca arriba.",
  "instrucciones_clave": [
    "Túmbate boca arriba con la espalda pegada al suelo",
    "Flexiona las rodillas en ángulo de 90 grados",
    "Eleva las piernas manteniendo las rodillas flexionadas",
    "Baja de forma controlada sin arquear la espalda",
    "Mantén el core activado durante todo el ejercicio"
  ],
  "beneficios": [
    "Fortalece el core y abdominales inferiores",
    "Mejora la estabilidad lumbar",
    "Ayuda a prevenir dolor de espalda baja"
  ],
  "precauciones": [
    "Si tienes dolor lumbar, coloca las manos bajo la espalda baja",
    "No arquees la espalda durante el movimiento",
    "Detente si sientes tensión en el cuello"
  ]
}
```

## Importante
- Devuelve SOLO el objeto JSON, sin texto adicional
- Asegúrate de que el JSON sea válido
- Todos los campos son obligatorios
- Los arrays pueden estar vacíos [] si no aplica
- Sé preciso y realista con la clasificación',
  '["nombre_archivo"]'::jsonb,
  true
);

SELECT 'Prompt de clasificación insertado' as resultado;
