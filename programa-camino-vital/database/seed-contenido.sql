-- ============================================
-- CAMINO VITAL - Contenido de Ejemplo (Seed Data)
-- ============================================

-- BASE VITAL - INICIACIÓN - Semanas 1-4

INSERT INTO programa_contenido (etapa, nivel, semana, titulo, descripcion, contenido_ejercicios, duracion_estimada, enfoque) VALUES
(
    'base_vital',
    'iniciacion',
    1,
    'Empezamos con confianza: Movilidad suave',
    'Tu primera semana se centra en despertar el cuerpo con movimientos suaves y seguros',
    '{
        "ejercicios": [
            {
                "nombre": "Movilidad de cuello",
                "descripcion": "Rotaciones suaves de la cabeza",
                "repeticiones": "8 cada lado",
                "video_url": "https://example.com/video1",
                "notas": "Sin forzar, movimientos lentos"
            },
            {
                "nombre": "Círculos de hombros",
                "descripcion": "Rotaciones hacia adelante y atrás",
                "repeticiones": "10 cada dirección",
                "video_url": "https://example.com/video2",
                "notas": "Mantén la respiración tranquila"
            },
            {
                "nombre": "Sentadillas asistidas",
                "descripcion": "Con apoyo de silla",
                "repeticiones": "5-8 repeticiones",
                "video_url": "https://example.com/video3",
                "notas": "Usa la silla solo como apoyo"
            }
        ],
        "feedback_questions": [
            {
                "tipo": "dificultad",
                "pregunta": "¿Cómo te has sentido con estos ejercicios?",
                "opciones": ["muy_facil", "adecuado", "dificil"]
            }
        ]
    }'::jsonb,
    15,
    'movilidad'
),
(
    'base_vital',
    'iniciacion',
    2,
    'Ganando confianza: Equilibrio básico',
    'Esta semana añadimos ejercicios para mejorar tu estabilidad',
    '{
        "ejercicios": [
            {
                "nombre": "Equilibrio sobre un pie",
                "descripcion": "Con apoyo opcional de pared",
                "repeticiones": "15 segundos cada pie",
                "video_url": "https://example.com/video4",
                "notas": "No te preocupes si necesitas apoyarte"
            },
            {
                "nombre": "Marcha en el sitio",
                "descripcion": "Elevando rodillas suavemente",
                "repeticiones": "30 segundos",
                "video_url": "https://example.com/video5",
                "notas": "A tu ritmo, sin prisa"
            },
            {
                "nombre": "Flexiones de pared",
                "descripcion": "Empujar contra la pared",
                "repeticiones": "8-10 repeticiones",
                "video_url": "https://example.com/video6",
                "notas": "Mantén el cuerpo recto"
            }
        ],
        "feedback_questions": [
            {
                "tipo": "dificultad",
                "pregunta": "¿Cómo te has sentido esta semana?",
                "opciones": ["muy_facil", "adecuado", "dificil"]
            },
            {
                "tipo": "progreso",
                "pregunta": "¿Notas alguna mejora desde la semana 1?",
                "opciones": ["si", "un_poco", "aun_no"]
            }
        ]
    }'::jsonb,
    20,
    'equilibrio'
);

-- BASE VITAL - INTERMEDIO - Semanas 1-4

INSERT INTO programa_contenido (etapa, nivel, semana, titulo, descripcion, contenido_ejercicios, duracion_estimada, enfoque) VALUES
(
    'base_vital',
    'intermedio',
    1,
    'Subimos la intensidad: Fuerza funcional',
    'Ejercicios diseñados para actividades del día a día',
    '{
        "ejercicios": [
            {
                "nombre": "Sentadillas completas",
                "descripcion": "Sin apoyo de silla",
                "repeticiones": "10-12 repeticiones",
                "video_url": "https://example.com/video7",
                "notas": "Espalda recta, rodillas alineadas"
            },
            {
                "nombre": "Zancadas estáticas",
                "descripcion": "Manteniendo posición",
                "repeticiones": "8 cada pierna",
                "video_url": "https://example.com/video8",
                "notas": "Rodilla no sobrepasa el pie"
            },
            {
                "nombre": "Plancha de rodillas",
                "descripcion": "Manteniendo posición",
                "repeticiones": "20-30 segundos",
                "video_url": "https://example.com/video9",
                "notas": "Core activado"
            }
        ],
        "feedback_questions": [
            {
                "tipo": "dificultad",
                "pregunta": "¿Este nivel es adecuado para ti?",
                "opciones": ["muy_facil", "adecuado", "dificil"]
            }
        ]
    }'::jsonb,
    25,
    'fuerza'
);

-- BASE VITAL - AVANZADO - Semana 1

INSERT INTO programa_contenido (etapa, nivel, semana, titulo, descripcion, contenido_ejercicios, duracion_estimada, enfoque) VALUES
(
    'base_vital',
    'avanzado',
    1,
    'Desafío completo: Fuerza y resistencia',
    'Para quienes buscan un entrenamiento más completo',
    '{
        "ejercicios": [
            {
                "nombre": "Sentadillas con salto suave",
                "descripcion": "Añadiendo componente explosivo",
                "repeticiones": "8-10 repeticiones",
                "video_url": "https://example.com/video10",
                "notas": "Aterrizaje suave"
            },
            {
                "nombre": "Zancadas caminando",
                "descripcion": "Avanzando con cada repetición",
                "repeticiones": "10 cada pierna",
                "video_url": "https://example.com/video11",
                "notas": "Control en todo momento"
            },
            {
                "nombre": "Plancha completa",
                "descripcion": "Posición extendida",
                "repeticiones": "30-45 segundos",
                "video_url": "https://example.com/video12",
                "notas": "Cuerpo alineado"
            }
        ],
        "feedback_questions": [
            {
                "tipo": "dificultad",
                "pregunta": "¿El nivel avanzado es apropiado?",
                "opciones": ["muy_facil", "adecuado", "dificil"]
            },
            {
                "tipo": "satisfaccion",
                "pregunta": "¿Te sientes retado de forma positiva?",
                "opciones": ["si", "necesito_mas", "es_demasiado"]
            }
        ]
    }'::jsonb,
    30,
    'fuerza_resistencia'
);
