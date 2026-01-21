# Queries de Monitoreo - Sistema de Límite de Usuarios

## 📊 Dashboard Principal

### Ver estado actual completo
```sql
SET search_path TO camino_vital;

SELECT
  '📊 Estado del sistema' as seccion,
  (SELECT value->>'limite' FROM configuracion WHERE key = 'usuarios_activos_max')::int as limite_configurado,
  (SELECT value->>'activo' FROM configuracion WHERE key = 'usuarios_activos_max')::boolean as limite_activo,
  (SELECT COUNT(*) FROM programa_users WHERE estado = 'activo') as usuarios_activos,
  (SELECT COUNT(*) FROM lista_espera WHERE notificado = false) as en_espera_pendiente,
  (SELECT COUNT(*) FROM lista_espera WHERE notificado = true) as en_espera_notificados,
  ROUND(
    (SELECT COUNT(*)::numeric FROM programa_users WHERE estado = 'activo') /
    (SELECT value->>'limite' FROM configuracion WHERE key = 'usuarios_activos_max')::numeric * 100,
    1
  ) as porcentaje_uso;
```

### Ver usuarios activos
```sql
SET search_path TO camino_vital;

SELECT
  id,
  nombre,
  email,
  nivel_actual,
  sesiones_objetivo_semana,
  fecha_inicio,
  created_at
FROM programa_users
WHERE estado = 'activo'
ORDER BY created_at DESC;
```

### Ver lista de espera
```sql
SET search_path TO camino_vital;

SELECT
  id,
  nombre,
  email,
  monto_pagado,
  created_at as fecha_registro,
  notificado,
  fecha_notificacion,
  notas
FROM lista_espera
ORDER BY created_at ASC;
```

---

## 🎛️ Gestión del Límite

### Activar límite
```sql
SET search_path TO camino_vital;

UPDATE configuracion
SET value = jsonb_set(value, '{activo}', 'true', false),
    updated_at = NOW()
WHERE key = 'usuarios_activos_max';

SELECT '✅ Límite ACTIVADO' as resultado;
```

### Desactivar límite
```sql
SET search_path TO camino_vital;

UPDATE configuracion
SET value = jsonb_set(value, '{activo}', 'false', false),
    updated_at = NOW()
WHERE key = 'usuarios_activos_max';

SELECT '🔓 Límite DESACTIVADO - Todos los usuarios pueden activarse' as resultado;
```

### Cambiar el límite (ej: de 75 a 100)
```sql
SET search_path TO camino_vital;

UPDATE configuracion
SET value = jsonb_set(value, '{limite}', '100', false),
    updated_at = NOW()
WHERE key = 'usuarios_activos_max';

SELECT '✅ Límite cambiado a 100 usuarios' as resultado;
```

---

## 📧 Gestionar Lista de Espera

### Ver próximos a notificar
```sql
SET search_path TO camino_vital;

SELECT
  id,
  nombre,
  email,
  monto_pagado,
  EXTRACT(DAY FROM NOW() - created_at) as dias_esperando
FROM lista_espera
WHERE notificado = false
ORDER BY created_at ASC
LIMIT 20;
```

### Marcar usuarios como notificados (cuando les envías email de plazas abiertas)
```sql
SET search_path TO camino_vital;

-- Marcar los primeros 20 como notificados
UPDATE lista_espera
SET
  notificado = true,
  fecha_notificacion = NOW()
WHERE id IN (
  SELECT id
  FROM lista_espera
  WHERE notificado = false
  ORDER BY created_at ASC
  LIMIT 20
)
RETURNING id, email, nombre;
```

### Remover usuario de lista de espera (si ya se activó)
```sql
SET search_path TO camino_vital;

DELETE FROM lista_espera
WHERE email = 'ejemplo@email.com';
```

---

## 📈 Estadísticas

### Ver crecimiento por día (últimos 30 días)
```sql
SET search_path TO camino_vital;

SELECT
  DATE(created_at) as fecha,
  COUNT(*) as usuarios_nuevos,
  SUM(COUNT(*)) OVER (ORDER BY DATE(created_at)) as total_acumulado
FROM programa_users
WHERE estado = 'activo'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY fecha DESC;
```

### Ver ingresos potenciales de lista de espera
```sql
SET search_path TO camino_vital;

SELECT
  COUNT(*) as usuarios_en_espera,
  SUM(monto_pagado) as ingresos_cuando_activen,
  ROUND(AVG(monto_pagado), 2) as ticket_promedio
FROM lista_espera
WHERE notificado = false;
```

### Alertas - Usuarios cerca del límite
```sql
SET search_path TO camino_vital;

WITH stats AS (
  SELECT
    (SELECT value->>'limite' FROM configuracion WHERE key = 'usuarios_activos_max')::int as limite,
    (SELECT COUNT(*) FROM programa_users WHERE estado = 'activo') as activos
)
SELECT
  CASE
    WHEN activos >= limite THEN '🚨 LÍMITE ALCANZADO'
    WHEN activos >= limite * 0.9 THEN '⚠️ 90% DE CAPACIDAD'
    WHEN activos >= limite * 0.75 THEN '⚠️ 75% DE CAPACIDAD'
    ELSE '✅ Capacidad normal'
  END as alerta,
  activos as usuarios_activos,
  limite as limite_maximo,
  ROUND((activos::numeric / limite::numeric) * 100, 1) as porcentaje_uso,
  limite - activos as espacios_disponibles
FROM stats;
```

---

## 🔧 Troubleshooting

### Ver usuarios que pagaron pero están en lista de espera
```sql
SET search_path TO camino_vital;

SELECT
  le.id,
  le.email,
  le.nombre,
  le.monto_pagado,
  le.stripe_payment_intent_id,
  le.created_at,
  le.notificado,
  pu.estado as estado_en_users
FROM lista_espera le
LEFT JOIN programa_users pu ON le.email = pu.email
ORDER BY le.created_at DESC;
```

### Verificar si un email específico está en lista de espera
```sql
SET search_path TO camino_vital;

SELECT
  CASE
    WHEN EXISTS (SELECT 1 FROM lista_espera WHERE email = 'ejemplo@email.com')
    THEN '📋 Usuario en lista de espera'
    ELSE '❌ Usuario NO está en lista de espera'
  END as status,
  le.*
FROM lista_espera le
WHERE le.email = 'ejemplo@email.com';
```

### Ver historial de cambios de configuración (si añades auditoría)
```sql
SET search_path TO camino_vital;

SELECT
  key,
  value,
  updated_at,
  descripcion
FROM configuracion
WHERE key = 'usuarios_activos_max'
ORDER BY updated_at DESC;
```

---

## 🎯 Preparar para abrir nuevas plazas

### Query completa para cuando vayas a abrir plazas
```sql
SET search_path TO camino_vital;

-- 1. Ver estado actual
SELECT
  '1️⃣ ESTADO ACTUAL' as paso,
  (SELECT COUNT(*) FROM programa_users WHERE estado = 'activo') as usuarios_activos,
  (SELECT value->>'limite' FROM configuracion WHERE key = 'usuarios_activos_max')::int as limite_actual,
  (SELECT COUNT(*) FROM lista_espera WHERE notificado = false) as en_espera
UNION ALL
-- 2. Aumentar límite (ejemplo: de 75 a 150)
SELECT
  '2️⃣ AUMENTAR LÍMITE A 150' as paso,
  NULL, NULL, NULL
UNION ALL
-- 3. Ver cuántos de lista de espera puedes aceptar
SELECT
  '3️⃣ ESPACIOS DISPONIBLES' as paso,
  150 - (SELECT COUNT(*) FROM programa_users WHERE estado = 'activo') as nuevos_espacios,
  (SELECT COUNT(*) FROM lista_espera WHERE notificado = false) as usuarios_esperando,
  LEAST(
    150 - (SELECT COUNT(*) FROM programa_users WHERE estado = 'activo'),
    (SELECT COUNT(*) FROM lista_espera WHERE notificado = false)
  ) as usuarios_a_notificar;

-- 4. Ejecutar el aumento de límite
UPDATE configuracion
SET value = jsonb_set(value, '{limite}', '150', false)
WHERE key = 'usuarios_activos_max';

-- 5. Ver primeros 75 usuarios a notificar
SELECT
  id,
  nombre,
  email,
  monto_pagado
FROM lista_espera
WHERE notificado = false
ORDER BY created_at ASC
LIMIT 75;
```

---

## 📞 Notificaciones Admin

### Query para notificación diaria por email
```sql
SET search_path TO camino_vital;

SELECT
  json_build_object(
    'fecha', CURRENT_DATE,
    'usuarios_activos', (SELECT COUNT(*) FROM programa_users WHERE estado = 'activo'),
    'limite', (SELECT value->>'limite' FROM configuracion WHERE key = 'usuarios_activos_max')::int,
    'porcentaje_uso', ROUND(
      (SELECT COUNT(*)::numeric FROM programa_users WHERE estado = 'activo') /
      (SELECT value->>'limite' FROM configuracion WHERE key = 'usuarios_activos_max')::numeric * 100,
      1
    ),
    'en_lista_espera', (SELECT COUNT(*) FROM lista_espera WHERE notificado = false),
    'nuevos_hoy', (SELECT COUNT(*) FROM programa_users WHERE estado = 'activo' AND DATE(created_at) = CURRENT_DATE)
  ) as reporte_diario;
```

---

## 🎨 Vista consolidada (dashboard SQL)
```sql
SET search_path TO camino_vital;

SELECT
  '📊 CAMINO VITAL - DASHBOARD' as "━━━━━━━━━━━━━━━━━━━━━",
  '' as " "
UNION ALL
SELECT
  '🎯 LÍMITE',
  (SELECT value->>'limite' || ' usuarios (' ||
    CASE WHEN (value->>'activo')::boolean THEN 'ACTIVO ✅' ELSE 'INACTIVO 🔓' END || ')'
   FROM configuracion WHERE key = 'usuarios_activos_max')
UNION ALL
SELECT
  '👥 USUARIOS ACTIVOS',
  (SELECT COUNT(*)::text || ' usuarios' FROM programa_users WHERE estado = 'activo')
UNION ALL
SELECT
  '📈 % CAPACIDAD',
  ROUND(
    (SELECT COUNT(*)::numeric FROM programa_users WHERE estado = 'activo') /
    (SELECT value->>'limite' FROM configuracion WHERE key = 'usuarios_activos_max')::numeric * 100,
    1
  )::text || '%'
UNION ALL
SELECT
  '📋 LISTA ESPERA',
  (SELECT COUNT(*)::text || ' personas' FROM lista_espera WHERE notificado = false)
UNION ALL
SELECT
  '💰 INGRESOS POTENCIALES',
  COALESCE((SELECT SUM(monto_pagado)::text || '€' FROM lista_espera WHERE notificado = false), '0€')
UNION ALL
SELECT
  '📅 NUEVOS HOY',
  (SELECT COUNT(*)::text || ' usuarios' FROM programa_users WHERE estado = 'activo' AND DATE(created_at) = CURRENT_DATE)
UNION ALL
SELECT
  '📅 NUEVOS ESTA SEMANA',
  (SELECT COUNT(*)::text || ' usuarios' FROM programa_users WHERE estado = 'activo' AND created_at >= DATE_TRUNC('week', CURRENT_DATE));
```

---

**Copia y pega cualquiera de estas queries en Adminer** (http://localhost:8080) para monitorear el sistema. 🎯
