-- ============================================
-- CONTENIDO TEMPORAL PARA TESTING
-- ============================================
-- Ejercicios de ejemplo para probar el flujo de sesiones

-- Semana 1 - Nivel Iniciación
INSERT INTO programa_contenido (
  etapa,
  nivel,
  semana,
  titulo,
  descripcion,
  contenido_ejercicios,
  duracion_estimada,
  enfoque
) VALUES (
  'base_vital',
  'iniciacion',
  1,
  'Semana 1: Despertando el cuerpo',
  'Ejercicios suaves para reconectar con tu cuerpo y mejorar la movilidad básica',
  '{
    "ejercicios": [
      {
        "nombre": "Respiración diafragmática",
        "descripcion": "Siéntate cómodamente en una silla con la espalda recta. Coloca una mano en tu pecho y otra en tu abdomen. Inhala profundamente por la nariz permitiendo que tu abdomen se expanda (la mano del abdomen debe moverse más que la del pecho). Exhala lentamente por la boca.",
        "repeticiones": "10 respiraciones profundas",
        "video_url": "https://www.youtube.com/watch?v=example1",
        "notas": "Este ejercicio te ayuda a relajarte y conectar con tu cuerpo. Perfecto para empezar cualquier sesión."
      },
      {
        "nombre": "Rotación de hombros",
        "descripcion": "De pie o sentado, lleva tus hombros hacia arriba (como si quisieras tocar tus orejas), luego hacia atrás, abajo y adelante, haciendo círculos completos.",
        "repeticiones": "10 círculos hacia atrás, 10 hacia adelante",
        "video_url": "https://www.youtube.com/watch?v=example2",
        "notas": "Mantén el movimiento suave y controlado. Si sientes alguna molestia, reduce el rango de movimiento."
      },
      {
        "nombre": "Extensión de brazos sentado",
        "descripcion": "Sentado en una silla, entrelaza los dedos y estira los brazos al frente a la altura del pecho, con las palmas mirando hacia afuera. Mantén la posición sintiendo el estiramiento en la espalda y hombros.",
        "repeticiones": "3 repeticiones de 15-20 segundos",
        "video_url": "https://www.youtube.com/watch?v=example3",
        "notas": "Respira normalmente durante el estiramiento. No fuerces, debe sentirse cómodo."
      },
      {
        "nombre": "Elevación de rodillas sentado",
        "descripcion": "Sentado en el borde de una silla, con la espalda recta, eleva una rodilla hacia el pecho manteniendo el abdomen activo. Baja controladamente y repite con la otra pierna.",
        "repeticiones": "10 repeticiones con cada pierna",
        "video_url": "https://www.youtube.com/watch?v=example4",
        "notas": "Si te resulta muy fácil, puedes hacerlo más lento o mantener la rodilla arriba 2-3 segundos."
      },
      {
        "nombre": "Círculos de tobillos",
        "descripcion": "Sentado, levanta un pie del suelo y realiza círculos con el tobillo, primero en una dirección y luego en la otra. Mantén el movimiento fluido.",
        "repeticiones": "10 círculos en cada dirección, con cada pie",
        "video_url": "https://www.youtube.com/watch?v=example5",
        "notas": "Este ejercicio mejora la movilidad del tobillo, importante para caminar con seguridad."
      }
    ],
    "feedback_questions": [
      {
        "tipo": "dificultad",
        "pregunta": "¿Cómo te has sentido con esta sesión?",
        "opciones": ["facil", "adecuado", "dificil"]
      }
    ]
  }'::jsonb,
  18,
  'movilidad'
) ON CONFLICT (etapa, nivel, semana) DO UPDATE SET
  titulo = EXCLUDED.titulo,
  descripcion = EXCLUDED.descripcion,
  contenido_ejercicios = EXCLUDED.contenido_ejercicios,
  duracion_estimada = EXCLUDED.duracion_estimada,
  enfoque = EXCLUDED.enfoque;

-- Semana 2 - Nivel Iniciación
INSERT INTO programa_contenido (
  etapa,
  nivel,
  semana,
  titulo,
  descripcion,
  contenido_ejercicios,
  duracion_estimada,
  enfoque
) VALUES (
  'base_vital',
  'iniciacion',
  2,
  'Semana 2: Ganando confianza',
  'Seguimos progresando con ejercicios que refuerzan lo aprendido y añaden nuevos movimientos',
  '{
    "ejercicios": [
      {
        "nombre": "Respiración diafragmática (repaso)",
        "descripcion": "Igual que la semana pasada. Siéntate cómodamente, mano en abdomen, inhala profundo por nariz, exhala por boca.",
        "repeticiones": "10 respiraciones profundas",
        "video_url": "https://www.youtube.com/watch?v=example1",
        "notas": "Ya conoces este ejercicio. Nota si cada vez te resulta más natural."
      },
      {
        "nombre": "Inclinación lateral sentado",
        "descripcion": "Sentado con la espalda recta, lleva un brazo por encima de la cabeza e inclínate hacia el lado opuesto, sintiendo el estiramiento en el costado. Mantén y vuelve al centro. Repite hacia el otro lado.",
        "repeticiones": "6 repeticiones a cada lado",
        "video_url": "https://www.youtube.com/watch?v=example6",
        "notas": "Mantén ambas nalgas apoyadas en la silla. El estiramiento debe ser suave."
      },
      {
        "nombre": "Marcha sentado",
        "descripcion": "Sentado, simula el movimiento de caminar elevando alternativamente las rodillas, como si estuvieras marchando en el sitio.",
        "repeticiones": "20 pasos (10 con cada pierna)",
        "video_url": "https://www.youtube.com/watch?v=example7",
        "notas": "Puedes aumentar la velocidad gradualmente según te sientas cómodo."
      },
      {
        "nombre": "Apertura de pecho sentado",
        "descripcion": "Sentado, lleva los brazos hacia atrás intentando juntar los omóplatos, abriendo el pecho. Mantén 5 segundos y relaja.",
        "repeticiones": "8 repeticiones",
        "video_url": "https://www.youtube.com/watch?v=example8",
        "notas": "Excelente para contrarrestar la postura encorvada del día a día."
      }
    ],
    "feedback_questions": [
      {
        "tipo": "dificultad",
        "pregunta": "¿Cómo te has sentido con esta sesión?",
        "opciones": ["facil", "adecuado", "dificil"]
      }
    ]
  }'::jsonb,
  15,
  'movilidad'
) ON CONFLICT (etapa, nivel, semana) DO UPDATE SET
  titulo = EXCLUDED.titulo,
  descripcion = EXCLUDED.descripcion,
  contenido_ejercicios = EXCLUDED.contenido_ejercicios,
  duracion_estimada = EXCLUDED.duracion_estimada,
  enfoque = EXCLUDED.enfoque;

-- Semana 1 - Nivel Intermedio (para usuarios que empiezan en intermedio)
INSERT INTO programa_contenido (
  etapa,
  nivel,
  semana,
  titulo,
  descripcion,
  contenido_ejercicios,
  duracion_estimada,
  enfoque
) VALUES (
  'base_vital',
  'intermedio',
  1,
  'Semana 1: Activando el cuerpo',
  'Ejercicios de nivel intermedio para mejorar fuerza y movilidad',
  '{
    "ejercicios": [
      {
        "nombre": "Sentadilla con silla de apoyo",
        "descripcion": "De pie frente a una silla, baja como si fueras a sentarte pero detente justo antes de tocar la silla. Mantén 2 segundos y sube. Usa la silla como referencia de profundidad.",
        "repeticiones": "10 repeticiones",
        "video_url": "https://www.youtube.com/watch?v=example9",
        "notas": "Mantén el peso en los talones y la espalda recta. Si necesitas apoyo, toca la silla ligeramente."
      },
      {
        "nombre": "Plancha en pared",
        "descripcion": "De pie frente a una pared, apoya las manos a la altura del pecho y camina los pies hacia atrás hasta formar un ángulo de 45 grados. Mantén el cuerpo recto.",
        "repeticiones": "Mantener 20-30 segundos, 3 repeticiones",
        "video_url": "https://www.youtube.com/watch?v=example10",
        "notas": "Activa el abdomen como si te preparas para recibir un golpe."
      },
      {
        "nombre": "Equilibrio en un pie",
        "descripcion": "De pie junto a una silla (por seguridad), levanta un pie del suelo y mantén el equilibrio. Puedes tocar la silla con un dedo si lo necesitas.",
        "repeticiones": "30 segundos con cada pie",
        "video_url": "https://www.youtube.com/watch?v=example11",
        "notas": "Fija la mirada en un punto fijo. Con práctica podrás hacerlo sin apoyo."
      },
      {
        "nombre": "Rotación de tronco de pie",
        "descripcion": "De pie con pies separados al ancho de caderas, brazos cruzados sobre el pecho, gira el tronco hacia un lado y luego al otro manteniendo la cadera estable.",
        "repeticiones": "10 rotaciones a cada lado",
        "video_url": "https://www.youtube.com/watch?v=example12",
        "notas": "El movimiento debe ser controlado, sin impulso."
      }
    ],
    "feedback_questions": [
      {
        "tipo": "dificultad",
        "pregunta": "¿Cómo te has sentido con esta sesión?",
        "opciones": ["facil", "adecuado", "dificil"]
      }
    ]
  }'::jsonb,
  20,
  'fuerza'
) ON CONFLICT (etapa, nivel, semana) DO UPDATE SET
  titulo = EXCLUDED.titulo,
  descripcion = EXCLUDED.descripcion,
  contenido_ejercicios = EXCLUDED.contenido_ejercicios,
  duracion_estimada = EXCLUDED.duracion_estimada,
  enfoque = EXCLUDED.enfoque;

-- Verificación
SELECT
  etapa,
  nivel,
  semana,
  titulo,
  duracion_estimada || ' min' as duracion
FROM programa_contenido
ORDER BY etapa, nivel, semana;
