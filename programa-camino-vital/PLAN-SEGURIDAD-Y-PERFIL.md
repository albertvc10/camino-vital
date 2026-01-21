# Plan: Seguridad y Actualización de Perfil

## 🎯 Objetivo
Permitir que usuarios actualicen su perfil (limitaciones, nivel, objetivo) de forma segura.

## 🔒 Sistema de seguridad propuesto

### Fase 1: Magic Links (Implementar primero)

**Cambios en DB:**
```sql
ALTER TABLE camino_vital.programa_users
ADD COLUMN auth_token VARCHAR(255) UNIQUE,
ADD COLUMN token_created_at TIMESTAMP DEFAULT NOW();

-- Generar tokens para usuarios existentes
UPDATE camino_vital.programa_users
SET auth_token = gen_random_uuid()::text
WHERE auth_token IS NULL;
```

**URLs nuevas:**
```
Ver sesión: /sesion/7?token={user_token}
Perfil: /perfil?token={user_token}
```

**Validación en workflows:**
```javascript
// En cada webhook, validar token
const token = $json.query.token;
const userId = await getUserByToken(token);

if (!userId) {
  return { error: 'Token inválido' };
}
```

---

### Fase 2: Formulario de actualización de perfil

**Workflow 11: Mostrar formulario de perfil**
- Endpoint: `GET /webhook/perfil?token={token}`
- Valida token
- Muestra formulario HTML con datos actuales
- Campos editables:
  - Limitaciones físicas (checkboxes)
  - Nivel actual (select)
  - Objetivo principal (select)
  - Sesiones por semana (select)

**Workflow 12: Guardar cambios de perfil**
- Endpoint: `POST /webhook/perfil/guardar?token={token}`
- Valida token
- Actualiza `programa_users`
- Muestra confirmación
- Opcionalmente: regenera sesión actual con nuevos parámetros

---

### Fase 3: Verificación por email (Opcional, más seguro)

**Para acciones sensibles (cambiar email, etc.):**
- Generar código de 6 dígitos
- Enviar por email
- Validar antes de permitir cambio

---

## 📊 Casos de uso cubiertos

### 1. Usuario se lesiona
**Flujo:**
1. Abre email de sesión
2. Click "⚙️ Actualizar mi perfil"
3. Ve formulario con limitaciones actuales
4. Marca nueva limitación: ☑️ Hombro lesionado
5. Guarda cambios
6. **Próximas sesiones** excluyen ejercicios que afecten hombros

**Implementación:**
- La sesión actual NO cambia
- La próxima sesión (cuando complete la actual) ya respeta la nueva limitación

---

### 2. Usuario progresa de nivel
**Flujo automático:**
```javascript
// Después de 12 sesiones completadas en "iniciación"
if (sesionesCompletadas >= 12 && nivel === 'iniciacion') {
  enviarEmail({
    asunto: "🎉 ¡Felicidades! Estás listo para nivel intermedio",
    contenido: `
      Has completado 12 sesiones. ¿Quieres subir de nivel?
      [Sí, subir a intermedio] [No, seguir en iniciación]
    `,
    links: {
      si: `/perfil/subir-nivel?token={token}`,
      no: `/sesion/siguiente?token={token}`
    }
  });
}
```

**Flujo manual:**
- Usuario entra a perfil
- Cambia nivel de "iniciación" a "intermedio"
- Guarda
- Próximas sesiones tienen ejercicios más difíciles

---

### 3. Usuario cambia de objetivo
**Flujo:**
1. Usuario con objetivo "movilidad" → quiere cambiar a "fuerza"
2. Abre perfil
3. Cambia objetivo principal
4. Guarda
5. **Próxima sesión** usa nueva distribución:
   - Antes: [movilidad, fuerza, movilidad]
   - Ahora: [fuerza, cardio, fuerza]

---

## 🔐 Seguridad adicional

### Protección contra enumeración
```javascript
// NO revelar si un token existe o no
if (!validToken) {
  return "Enlace inválido o expirado"; // Mensaje genérico
}
```

### Rate limiting
```javascript
// Máximo 10 requests por minuto por token
const rateLimiter = new Map();
if (rateLimiter.get(token) > 10) {
  return "Demasiados intentos, espera 1 minuto";
}
```

### Tokens con expiración (opcional)
```sql
-- Validar que token no tenga más de 90 días
SELECT * FROM programa_users
WHERE auth_token = $1
AND token_created_at > NOW() - INTERVAL '90 days';
```

---

## 📝 Implementación por fases

### ✅ Fase 1: Magic Links (2-3 horas)
- Añadir columna `auth_token` a DB
- Generar tokens para usuarios existentes
- Modificar workflow 01-bis para incluir token en URLs
- Modificar workflow 09 para validar token
- Mostrar error si token inválido

### ⏳ Fase 2: Formulario de perfil (3-4 horas)
- Crear workflow 11: mostrar formulario
- Crear workflow 12: guardar cambios
- Diseñar HTML del formulario
- Añadir botón "Actualizar perfil" en página de sesión

### ⏳ Fase 3: Sugerencias automáticas (2 horas)
- Detectar cuando usuario debería subir de nivel
- Enviar email con sugerencia
- Implementar endpoints de confirmación

### ⏳ Fase 4: Verificación por email (opcional, 2-3 horas)
- Solo para acciones críticas
- Generar códigos de 6 dígitos
- Validar antes de permitir cambios

---

## 🎯 Resultado final

**Usuario tiene control total:**
- ✅ Puede actualizar limitaciones en cualquier momento
- ✅ Puede cambiar de nivel cuando esté listo
- ✅ Puede modificar objetivo según evolucione
- ✅ Todo de forma segura con tokens únicos
- ✅ Sin necesidad de crear cuenta/password
- ✅ Un solo click desde el email

**Sistema es seguro:**
- ✅ URLs no pueden ser adivinadas (tokens UUID)
- ✅ Cada usuario tiene su propio token único
- ✅ Tokens pueden regenerarse si se comprometen
- ✅ Opcionalmente pueden expirar

**Experiencia fluida:**
- ✅ No hay fricción adicional para ver sesiones
- ✅ Actualizar perfil requiere solo confirmar email
- ✅ Cambios aplican desde la próxima sesión
