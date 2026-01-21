-- ================================================================
-- TABLA DE TEMPLATES PREDEFINIDOS PARA SESIONES DE CARDIO
-- ================================================================
--
-- PROPÓSITO: Garantizar consistencia en sesiones de cardio
-- En lugar de que la IA genere estructuras desde cero, selecciona
-- y personaliza templates predefinidos.
--
-- AHORRO ADICIONAL: Reduce prompt de ~800 tokens a ~500 tokens
-- ================================================================

SET search_path TO camino_vital;

-- Crear tabla de templates
CREATE TABLE IF NOT EXISTS actividades_cardio_templates (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  tipo_actividad VARCHAR(50) NOT NULL,
  nivel_requerido VARCHAR(50) NOT NULL, -- iniciacion, basico, intermedio
  duracion_min INTEGER NOT NULL,
  duracion_max INTEGER NOT NULL,
  descripcion_corta TEXT NOT NULL,
  calentamiento_texto TEXT NOT NULL,
  actividad_principal JSONB NOT NULL,
  senales_de_alerta TEXT[] NOT NULL,
  consejos_seguridad TEXT[] NOT NULL,
  progresion_sugerida TEXT NOT NULL,
  activo BOOLEAN DEFAULT true,
  fecha_creacion TIMESTAMP DEFAULT NOW()
);

-- Índices para búsqueda rápida
CREATE INDEX IF NOT EXISTS idx_cardio_templates_nivel ON actividades_cardio_templates(nivel_requerido);
CREATE INDEX IF NOT EXISTS idx_cardio_templates_activo ON actividades_cardio_templates(activo);

-- ================================================================
-- TEMPLATES PREDEFINIDOS
-- ================================================================

-- 1. CAMINATA SUAVE (Iniciación)
INSERT INTO actividades_cardio_templates (
  nombre,
  tipo_actividad,
  nivel_requerido,
  duracion_min,
  duracion_max,
  descripcion_corta,
  calentamiento_texto,
  actividad_principal,
  senales_de_alerta,
  consejos_seguridad,
  progresion_sugerida
) VALUES (
  'Caminata Suave',
  'caminata',
  'iniciacion',
  15,
  20,
  'Caminata relajada a ritmo cómodo, ideal para comenzar con actividad cardiovascular',
  'Comienza con 3-5 minutos de movimientos suaves: rotaciones de tobillos, movimientos circulares de brazos, balanceo suave de piernas. Esto prepara tus articulaciones para la caminata.',
  '{
    "descripcion": "Caminata a ritmo suave y cómodo",
    "duracion": "15 minutos",
    "intensidad_objetivo": "Baja-Moderada (4-5/10)",
    "como_debe_sentirse": "Debes poder mantener una conversación sin problemas. Tu respiración será un poco más profunda que en reposo, pero sin sentir falta de aire. Es como dar un paseo relajado.",
    "fases": [
      {
        "fase": "Inicio suave",
        "duracion": "3-4 minutos",
        "intensidad": "Baja (3/10)",
        "descripcion": "Comienza caminando muy despacio, permitiendo que tu cuerpo se active gradualmente. Siente cómo tus músculos se calientan suavemente."
      },
      {
        "fase": "Ritmo cómodo",
        "duracion": "8-10 minutos",
        "intensidad": "Baja-Moderada (4-5/10)",
        "descripcion": "Aumenta ligeramente el ritmo hasta encontrar un paso cómodo. Debes sentir que te mueves pero sin esfuerzo excesivo. Tu respiración es tranquila."
      },
      {
        "fase": "Enfriamiento",
        "duracion": "3 minutos",
        "intensidad": "Baja (3/10)",
        "descripcion": "Reduce gradualmente el ritmo, volviendo a una caminata muy lenta. Respira profundamente y siente cómo tu cuerpo se relaja."
      }
    ]
  }'::jsonb,
  ARRAY[
    'Dolor en el pecho o dificultad significativa para respirar',
    'Mareo, náuseas o sensación de desmayo',
    'Dolor articular agudo (no confundir con molestia muscular leve)',
    'Palpitaciones irregulares o muy rápidas'
  ],
  ARRAY[
    'Lleva una botella de agua y bebe pequeños sorbos cuando lo necesites',
    'Elige un terreno plano y seguro (parque, acera amplia)',
    'Usa calzado cómodo con buen soporte',
    'Si sientes que necesitas parar, hazlo sin culpa - siempre puedes continuar después'
  ],
  'En las próximas sesiones puedes: (1) Aumentar 2-3 minutos la fase de ritmo cómodo, o (2) Incrementar ligeramente el ritmo durante 1-2 minutos en la fase principal'
);

-- 2. CAMINATA RÁPIDA (Básico/Intermedio)
INSERT INTO actividades_cardio_templates (
  nombre,
  tipo_actividad,
  nivel_requerido,
  duracion_min,
  duracion_max,
  descripcion_corta,
  calentamiento_texto,
  actividad_principal,
  senales_de_alerta,
  consejos_seguridad,
  progresion_sugerida
) VALUES (
  'Caminata Rápida',
  'caminata',
  'basico',
  20,
  25,
  'Caminata a ritmo activo que eleva el pulso y trabaja la resistencia cardiovascular',
  'Comienza con 3-5 minutos de calentamiento: caminata muy lenta, movimientos circulares de brazos, elevaciones suaves de rodillas. Prepara tu cuerpo para el esfuerzo.',
  '{
    "descripcion": "Caminata a ritmo activo y constante",
    "duracion": "20 minutos",
    "intensidad_objetivo": "Moderada (5-6/10)",
    "como_debe_sentirse": "Debes poder hablar pero con algo de esfuerzo - frases cortas sí, conversación larga difícil. Tu respiración será más profunda y notarás que tu corazón late más rápido. Sentirás calor corporal.",
    "fases": [
      {
        "fase": "Calentamiento activo",
        "duracion": "4-5 minutos",
        "intensidad": "Baja-Moderada (4/10)",
        "descripcion": "Comienza con paso lento y aumenta gradualmente hasta un ritmo moderado. Siente cómo tu cuerpo se activa y tu respiración se profundiza."
      },
      {
        "fase": "Ritmo activo sostenido",
        "duracion": "12-14 minutos",
        "intensidad": "Moderada (5-6/10)",
        "descripcion": "Mantén un ritmo constante y activo. Debes sentir que trabajas - respiración profunda, corazón bombeando. Si puedes cantar, ve más rápido; si no puedes hablar, reduce el ritmo."
      },
      {
        "fase": "Enfriamiento progresivo",
        "duracion": "4 minutos",
        "intensidad": "Baja (3-4/10)",
        "descripcion": "Reduce gradualmente el ritmo durante los últimos minutos. Siente cómo tu respiración vuelve a la normalidad y tu pulso se calma."
      }
    ]
  }'::jsonb,
  ARRAY[
    'Dolor en el pecho, brazo izquierdo o mandíbula',
    'Dificultad extrema para respirar (si no puedes hablar en absoluto, reduce intensidad)',
    'Mareo intenso o visión borrosa',
    'Dolor articular agudo en rodillas, caderas o tobillos'
  ],
  ARRAY[
    'Mantén agua cerca y bebe cada 5-7 minutos',
    'Usa calzado adecuado para caminar - evita suelas gastadas',
    'Si sientes que el ritmo es muy intenso, reduce la velocidad - es mejor completar la sesión más lento que parar',
    'Elige rutas conocidas y seguras'
  ],
  'Para progresar: (1) Aumenta 3-5 minutos la duración total, o (2) Añade 2-3 intervalos de 1 minuto a ritmo más rápido durante la fase principal'
);

-- 3. INTERVALOS CAMINAR-TROTAR (Intermedio)
INSERT INTO actividades_cardio_templates (
  nombre,
  tipo_actividad,
  nivel_requerido,
  duracion_min,
  duracion_max,
  descripcion_corta,
  calentamiento_texto,
  actividad_principal,
  senales_de_alerta,
  consejos_seguridad,
  progresion_sugerida
) VALUES (
  'Intervalos Caminar-Trotar',
  'intervalos',
  'intermedio',
  20,
  25,
  'Alternancia entre caminata y trote suave para mejorar resistencia de forma progresiva',
  'Empieza con 5 minutos de caminata moderada para calentar. Realiza algunos movimientos dinámicos: elevaciones de rodillas, talones a glúteos, balanceo de piernas. Tu cuerpo debe estar preparado para el trote.',
  '{
    "descripcion": "Alternar entre caminata rápida y trote suave",
    "duracion": "20 minutos",
    "intensidad_objetivo": "Moderada-Alta (6-7/10)",
    "como_debe_sentirse": "Durante los intervalos de trote sentirás un esfuerzo notable - respiración profunda y rápida, pulso elevado. Durante la caminata te recuperas pero sin llegar a descansar completamente.",
    "fases": [
      {
        "fase": "Calentamiento",
        "duracion": "5 minutos",
        "intensidad": "Moderada (4-5/10)",
        "descripcion": "Caminata a ritmo moderado-activo para preparar el cuerpo. Los últimos 2 minutos aumenta ligeramente el ritmo."
      },
      {
        "fase": "Intervalos (6 repeticiones)",
        "duracion": "12 minutos",
        "intensidad": "Variable (5-7/10)",
        "descripcion": "Alterna: 1 minuto de trote suave (7/10) + 1 minuto de caminata activa (5/10). Repite 6 veces. Durante el trote tu respiración será rápida pero controlada. Durante la caminata te recuperas."
      },
      {
        "fase": "Enfriamiento",
        "duracion": "3 minutos",
        "intensidad": "Baja (3-4/10)",
        "descripcion": "Caminata lenta y relajada. Respira profundamente, siente cómo tu pulso baja gradualmente. Estira suavemente si lo necesitas."
      }
    ]
  }'::jsonb,
  ARRAY[
    'Si durante el trote no puedes mantener una respiración rítmica, reduce intensidad',
    'Dolor agudo en rodillas, tobillos o caderas',
    'Mareo o náuseas',
    'Dolor en el pecho o dificultad severa para respirar'
  ],
  ARRAY[
    'Fundamental: usa calzado apropiado para correr con buena amortiguación',
    'Elige superficies suaves (tierra, pasto) en lugar de asfalto si es posible',
    'Si un intervalo de trote es muy duro, está bien caminar más tiempo',
    'Mantén los hombros relajados durante el trote'
  ],
  'Progresión: (1) Aumenta los intervalos de trote a 1.5 minutos (manteniendo 1 min de caminata), o (2) Añade 2 repeticiones más al ciclo'
);

-- 4. CAMINATA COMBINADA (Básico)
INSERT INTO actividades_cardio_templates (
  nombre,
  tipo_actividad,
  nivel_requerido,
  duracion_min,
  duracion_max,
  descripcion_corta,
  calentamiento_texto,
  actividad_principal,
  senales_de_alerta,
  consejos_seguridad,
  progresion_sugerida
) VALUES (
  'Caminata con Variaciones',
  'caminata',
  'basico',
  20,
  25,
  'Caminata que combina ritmos y ligeras pendientes para mayor variedad y trabajo cardiovascular',
  'Inicia con 4 minutos de caminata muy suave. Realiza movimientos circulares de brazos mientras caminas, eleva rodillas suavemente. Prepara tu cuerpo para cambios de ritmo.',
  '{
    "descripcion": "Caminata con cambios de ritmo y terreno",
    "duracion": "20 minutos",
    "intensidad_objetivo": "Moderada (5-6/10)",
    "como_debe_sentirse": "Sentirás variaciones en el esfuerzo - momentos más intensos seguidos de recuperación. Tu respiración se adaptará a los cambios de ritmo. Es desafiante pero manejable.",
    "fases": [
      {
        "fase": "Calentamiento en llano",
        "duracion": "4 minutos",
        "intensidad": "Baja-Moderada (4/10)",
        "descripcion": "Caminata en terreno plano a ritmo cómodo. Siente cómo tu cuerpo se activa gradualmente."
      },
      {
        "fase": "Variaciones (3 bloques)",
        "duracion": "13 minutos",
        "intensidad": "Variable (5-7/10)",
        "descripcion": "Realiza 3 bloques de 4 minutos: (1) Caminata rápida en llano (6/10), (2) Busca ligera pendiente o aumenta ritmo aún más (7/10) por 2 minutos, (3) Caminata moderada de recuperación (5/10) por 2 minutos. Repite 3 veces."
      },
      {
        "fase": "Enfriamiento",
        "duracion": "3 minutos",
        "intensidad": "Baja (3-4/10)",
        "descripcion": "Vuelve a ritmo lento en llano. Respira profundamente y siente cómo tu cuerpo se calma."
      }
    ]
  }'::jsonb,
  ARRAY[
    'Si en una pendiente sientes esfuerzo excesivo, camina más lento o busca terreno plano',
    'Dolor en rodillas o tobillos al subir pendientes',
    'Mareo o náuseas',
    'Dificultad significativa para respirar'
  ],
  ARRAY[
    'Si no encuentras pendientes naturales, puedes simular mayor esfuerzo aumentando el ritmo',
    'Al subir pendientes, acorta el paso y mantén postura erguida',
    'Bebe agua entre los bloques de variación',
    'Elige rutas que conozcas para poder planificar las fases'
  ],
  'Progresión: (1) Aumenta duración de fases intensas a 2.5-3 minutos, o (2) Busca pendientes ligeramente más pronunciadas'
);

-- 5. MARCHA ACTIVA EN CASA (Iniciación)
INSERT INTO actividades_cardio_templates (
  nombre,
  tipo_actividad,
  nivel_requerido,
  duracion_min,
  duracion_max,
  descripcion_corta,
  calentamiento_texto,
  actividad_principal,
  senales_de_alerta,
  consejos_seguridad,
  progresion_sugerida
) VALUES (
  'Marcha Activa en Casa',
  'marcha_casa',
  'iniciacion',
  15,
  20,
  'Marcha en el lugar o circuito en casa para días de mal clima, sin necesidad de salir',
  'Comienza con 3 minutos de marcha muy suave en el lugar. Mueve brazos suavemente, rota hombros, prepara tobillos con círculos. Esta actividad es más exigente de lo que parece.',
  '{
    "descripcion": "Marcha activa sin desplazamiento o circuito en casa",
    "duracion": "15 minutos",
    "intensidad_objetivo": "Moderada (5/10)",
    "como_debe_sentirse": "Tu pulso subirá aunque no te desplaces. Respiración más profunda, sentirás calor corporal. Es como caminar rápido pero en tu espacio.",
    "fases": [
      {
        "fase": "Inicio suave",
        "duracion": "3 minutos",
        "intensidad": "Baja (3-4/10)",
        "descripcion": "Marcha en el lugar levantando rodillas a altura cómoda. Mueve brazos naturalmente. Encuentra tu ritmo."
      },
      {
        "fase": "Marcha activa",
        "duracion": "10 minutos",
        "intensidad": "Moderada (5-6/10)",
        "descripcion": "Aumenta el ritmo. Puedes: (1) Marchar en el lugar elevando más las rodillas, (2) Hacer circuito por tu casa, (3) Alternar marcha con pasos laterales. Mantén el movimiento continuo."
      },
      {
        "fase": "Enfriamiento",
        "duracion": "2 minutos",
        "intensidad": "Baja (3/10)",
        "descripcion": "Reduce el ritmo progresivamente. Marcha muy suave, respira profundamente."
      }
    ]
  }'::jsonb,
  ARRAY[
    'Mareo (siéntate inmediatamente si ocurre)',
    'Dolor en rodillas al elevarlas',
    'Dificultad excesiva para respirar',
    'Sensación de inestabilidad'
  ],
  ARRAY[
    'Usa calzado cómodo incluso en casa',
    'Despeja el espacio de obstáculos si harás circuito',
    'Si te mareas, la marcha en el lugar puede causar algo de desorientación - haz pausas si lo necesitas',
    'Ten una silla cerca por si necesitas apoyo o descanso',
    'Ventila la habitación - necesitarás aire fresco'
  ],
  'Progresión: (1) Aumenta 3-5 minutos la duración, o (2) Incorpora variaciones: elevaciones de rodillas más altas, pasos más rápidos, añadir movimientos de brazos más amplios'
);

-- Verificar inserción
SELECT
  id,
  nombre,
  tipo_actividad,
  nivel_requerido,
  duracion_min || '-' || duracion_max || ' min' as duracion,
  descripcion_corta
FROM actividades_cardio_templates
ORDER BY
  CASE nivel_requerido
    WHEN 'iniciacion' THEN 1
    WHEN 'basico' THEN 2
    WHEN 'intermedio' THEN 3
  END,
  duracion_min;
