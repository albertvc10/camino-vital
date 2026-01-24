# Administración Manual de Usuarios

Guía para modificar usuarios cuando reportan problemas por email.

**Herramienta recomendada**: DBeaver o pgAdmin

---

## Conexión a la Base de Datos

```
Host: localhost
Puerto: 5432
Base de datos: n8n
Usuario: n8n
Password: (ver archivo .env en directorio padre)
```

---

## Queries Útiles

### 1. Buscar Usuario por Email

```sql
SELECT
    id,
    email,
    nombre,
    nivel_actual,
    intensidad_nivel,
    perfil_inicial->>'limitaciones' as limitaciones,
    semana_actual,
    sesion_actual_dentro_semana,
    sesiones_objetivo_semana,
    estado
FROM programa_users
WHERE email ILIKE '%buscar%';
```

### 2. Ver Estado Completo del Usuario

```sql
SELECT
    id,
    nombre,
    email,
    estado,
    nivel_actual,
    intensidad_nivel,
    semana_actual,
    sesion_actual_dentro_semana,
    sesiones_objetivo_semana,
    sesiones_completadas_semana,
    perfil_inicial->>'limitaciones' as limitaciones,
    perfil_inicial->>'objetivo' as objetivo,
    fecha_inicio,
    fecha_ultimo_envio
FROM programa_users
WHERE email = 'usuario@ejemplo.com';
```

### 3. Ver Feedback Reciente del Usuario

```sql
SELECT
    semana,
    sesion_numero,
    completitud,
    respuesta,
    razon_no_completar,
    created_at
FROM programa_feedback
WHERE user_id = (SELECT id FROM programa_users WHERE email = 'usuario@ejemplo.com')
ORDER BY created_at DESC
LIMIT 10;
```

---

## Modificar Usuario

### Cambiar Nivel

```sql
UPDATE programa_users
SET
    nivel_actual = 'iniciacion',
    updated_at = NOW()
WHERE email = 'usuario@ejemplo.com';
```

**Valores válidos para `nivel_actual`:**
- `iniciacion` - Ejercicios suaves, baja intensidad
- `intermedio` - Ejercicios moderados
- `avanzado` - Ejercicios exigentes

### Cambiar Intensidad

```sql
UPDATE programa_users
SET
    intensidad_nivel = 50,
    updated_at = NOW()
WHERE email = 'usuario@ejemplo.com';
```

**Rango válido**: `40` a `100` (porcentaje)
- `40-50`: Muy suave
- `60-70`: Moderado (por defecto)
- `80-100`: Intenso

### Cambiar Limitaciones

```sql
UPDATE programa_users
SET
    perfil_inicial = jsonb_set(
        COALESCE(perfil_inicial, '{}'),
        '{limitaciones}',
        '"rodillas"'
    ),
    updated_at = NOW()
WHERE email = 'usuario@ejemplo.com';
```

**Valores válidos para limitaciones:**
- `ninguna` - Sin limitaciones
- `rodillas` - Problemas de rodillas
- `espalda` - Problemas de espalda
- `hombros` - Problemas de hombros
- `equilibrio` - Problemas de equilibrio

### Cambiar Múltiples Campos a la Vez

```sql
UPDATE programa_users
SET
    nivel_actual = 'iniciacion',
    intensidad_nivel = 50,
    perfil_inicial = jsonb_set(
        COALESCE(perfil_inicial, '{}'),
        '{limitaciones}',
        '"rodillas"'
    ),
    updated_at = NOW()
WHERE email = 'usuario@ejemplo.com';
```

---

## Después de Modificar: Generar Nueva Sesión

Una vez hechos los cambios en la BD, hay que generar la siguiente sesión para que aplique los nuevos parámetros.

### Opción A: Siguiente Sesión (misma semana)

Usar cuando el usuario está a mitad de semana y quieres que la siguiente sesión ya tenga los cambios.

```bash
curl "http://localhost:5678/webhook/sesion-completada?user_id=ID&sesion=NUMERO&feedback=dolor"
```

Reemplazar:
- `ID`: ID del usuario (número)
- `NUMERO`: Número de sesión actual del usuario

**Ejemplo:**
```bash
curl "http://localhost:5678/webhook/sesion-completada?user_id=33&sesion=1&feedback=dolor"
```

### Opción B: Forzar Checkpoint (nueva semana)

Usar cuando quieres avanzar al usuario a la siguiente semana directamente.

```bash
curl "http://localhost:5678/webhook/checkpoint-semanal?user_id=ID&sesiones=SESIONES"
```

Reemplazar:
- `ID`: ID del usuario
- `SESIONES`: Número de sesiones por semana (1-5)

**Ejemplo:**
```bash
curl "http://localhost:5678/webhook/checkpoint-semanal?user_id=33&sesiones=3"
```

---

## Casos Comunes

### Usuario reporta dolor de rodillas

```sql
-- 1. Actualizar limitaciones y bajar intensidad
UPDATE programa_users
SET
    perfil_inicial = jsonb_set(
        COALESCE(perfil_inicial, '{}'),
        '{limitaciones}',
        '"rodillas"'
    ),
    intensidad_nivel = 50,
    updated_at = NOW()
WHERE email = 'usuario@ejemplo.com';
```

```bash
# 2. Generar siguiente sesión con los cambios
curl "http://localhost:5678/webhook/sesion-completada?user_id=33&sesion=1&feedback=dolor"
```

### Usuario dice que todo es muy difícil

```sql
-- 1. Bajar nivel e intensidad
UPDATE programa_users
SET
    nivel_actual = 'iniciacion',
    intensidad_nivel = 40,
    updated_at = NOW()
WHERE email = 'usuario@ejemplo.com';
```

```bash
# 2. Generar siguiente sesión
curl "http://localhost:5678/webhook/sesion-completada?user_id=33&sesion=1&feedback=completa_dificil"
```

### Usuario dice que todo es muy fácil

```sql
-- 1. Subir nivel e intensidad
UPDATE programa_users
SET
    nivel_actual = 'intermedio',
    intensidad_nivel = 80,
    updated_at = NOW()
WHERE email = 'usuario@ejemplo.com';
```

```bash
# 2. Generar siguiente sesión
curl "http://localhost:5678/webhook/sesion-completada?user_id=33&sesion=2&feedback=completa_facil"
```

---

## Notas

- Siempre verificar el `id` del usuario antes de ejecutar UPDATE
- Los cambios en `perfil_inicial` se leen cuando se genera una nueva sesión
- El feedback `dolor` activa lógica especial de ajuste automático
- Si el usuario no ha dado feedback de la sesión actual, usar su `sesion_actual_dentro_semana` como número de sesión
