# 📧 Cómo Usar el Sistema de Templates de Email

**Fecha:** 2 Enero 2025
**Versión:** 1.0

---

## 🎯 Ventajas del Sistema

✅ **Cambiar diseño sin reimportar workflows** - Editas HTML en DB, todos los workflows usan la nueva versión
✅ **Componentes reutilizables** - Header, footer, botones compartidos
✅ **Versionado** - Puedes tener v1, v2 y hacer A/B testing
✅ **Mantenimiento centralizado** - Un solo lugar para todos los diseños

---

## 📋 Estructura del Sistema

### Tablas:

```
camino_vital.email_templates     → Templates completos de emails
camino_vital.email_components    → Componentes reutilizables (header, footer, etc.)
```

### Funciones útiles:

```sql
-- Obtener template activo más reciente
SELECT * FROM get_email_template('sesion_ejercicios');

-- Crear nueva versión
SELECT create_template_version('sesion_ejercicios', '<html>...nuevo diseño...</html>');
```

---

## 🔧 Cómo Modificar un Workflow para Usar Templates

### ANTES (hardcoded):

```
Workflow: 01-bis Seleccionar Sesiones

Nodo: Preparar Email Sesión (Code)
├─ HTML hardcoded dentro del código JavaScript
├─ Difícil de mantener
└─ Hay que reimportar workflow para cambiar diseño
```

### DESPUÉS (con templates DB):

```
Workflow: 01-bis Seleccionar Sesiones

Nodo 1: Obtener Template (PostgreSQL)
├─ Query: SELECT * FROM get_email_template('sesion_ejercicios')
└─ Output: { html_template, variables_requeridas }

Nodo 2: Preparar Email Sesión (Code)
├─ Obtiene template del nodo anterior
├─ Reemplaza variables con datos
└─ Output: { email_html }

Nodo 3: Preparar Body Brevo (Code)
└─ Mismo que antes

Nodo 4: Enviar Email
└─ Mismo que antes
```

---

## 📝 Ejemplo Paso a Paso: Modificar Workflow 01-bis

### Paso 1: Añadir nodo para obtener template

**Nodo:** PostgreSQL
**Nombre:** "Obtener Template Email"
**Posición:** Después de "Obtener Contenido Sesión 1"
**Query:**

```sql
SET search_path TO camino_vital;
SELECT * FROM get_email_template('sesion_ejercicios');
```

**Output:**
```json
{
  "id": 1,
  "html_template": "<!DOCTYPE html>...",
  "variables_requeridas": ["titulo", "descripcion", ...]
}
```

---

### Paso 2: Modificar nodo "Preparar Email Sesión"

**Tipo:** Code
**Código:**

```javascript
// ========================================
// FUNCIONES HELPER (copiar al inicio)
// ========================================
function replaceVariables(template, variables) {
  let result = template;
  for (const [key, value] of Object.entries(variables)) {
    const safeValue = String(value);
    const regex = new RegExp(`\\{\\{${key}\\}\\}`, 'g');
    result = result.replace(regex, safeValue);
  }
  return result;
}

// ========================================
// DATOS DE ENTRADA
// ========================================
const usuario = $node["Guardar Sesiones Objetivo"].json;
const contenido = $node["Obtener Contenido Sesión 1"].json;
const template = $node["Obtener Template Email"].json.html_template;

// ========================================
// GENERAR HTML DE EJERCICIOS
// ========================================
const ejercicios = typeof contenido.contenido_ejercicios === 'string'
  ? JSON.parse(contenido.contenido_ejercicios)
  : contenido.contenido_ejercicios;

const ejerciciosHTML = ejercicios.ejercicios.map((ej, index) => `
  <div style="background: #f9f9f9; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #4CAF50;">
    <h3 style="margin: 0 0 10px 0; color: #333;">${index + 1}. ${ej.nombre}</h3>
    <p style="margin: 5px 0; color: #666;">${ej.descripcion}</p>
    <p style="margin: 5px 0;"><strong>Repeticiones:</strong> ${ej.repeticiones}</p>
    ${ej.video_url && ej.video_url !== '[PENDIENTE]' && ej.video_url !== '[TEST-LOCAL]'
      ? `<p><a href="${ej.video_url}" style="color: #4CAF50; text-decoration: none;">📹 Ver video demostrativo</a></p>`
      : ''}
    ${ej.notas ? `<p style="font-size: 14px; color: #888; font-style: italic;">💡 ${ej.notas}</p>` : ''}
  </div>
`).join('');

// ========================================
// PREPARAR VARIABLES PARA EL TEMPLATE
// ========================================
const variables = {
  titulo: contenido.titulo,
  descripcion: contenido.descripcion,
  duracion: contenido.duracion_estimada,
  enfoque: contenido.enfoque,
  ejercicios_html: ejerciciosHTML,
  sesion_numero: 1,
  sesiones_total: usuario.sesiones_objetivo_semana,
  semana_numero: usuario.semana_actual,
  user_id: usuario.id,
  webhook_url: 'https://n8n.habitos-vitales.com/webhook'
};

// ========================================
// PROCESAR TEMPLATE
// ========================================
console.log('📧 Procesando template de email desde DB...');
const emailHTML = replaceVariables(template, variables);

// ========================================
// RETURN
// ========================================
return {
  json: {
    user_id: usuario.id,
    user_email: usuario.email,
    user_nombre: usuario.nombre,
    contenido_id: contenido.id,
    sesiones_objetivo: usuario.sesiones_objetivo_semana,
    semana: usuario.semana_actual,
    sesion_numero: 1,
    email_html: emailHTML,
    asunto: `🎯 Sesión 1 de ${usuario.sesiones_objetivo_semana}: ${contenido.titulo}`
  }
};
```

---

### Paso 3: Actualizar conexiones

```
Obtener Contenido Sesión 1
    ↓
Obtener Template Email (NUEVO)
    ↓
Preparar Email Sesión (MODIFICADO - usa template de DB)
    ↓
Preparar Body Brevo
    ↓
...
```

---

## 🎨 Cómo Editar un Template

### Opción A: SQL directo

```sql
-- Ver template actual
SELECT html_template FROM camino_vital.email_templates
WHERE nombre = 'sesion_ejercicios' AND activo = true
ORDER BY version DESC LIMIT 1;

-- Crear nueva versión (recomendado)
SELECT create_template_version(
  'sesion_ejercicios',
  '<html>...nuevo diseño...</html>'
);

-- O actualizar versión existente (solo en desarrollo)
UPDATE camino_vital.email_templates
SET html_template = '<html>...nuevo diseño...</html>',
    updated_at = NOW()
WHERE nombre = 'sesion_ejercicios' AND version = 1;
```

### Opción B: Adminer (UI visual)

1. Abre Adminer: http://localhost:8080
2. Login: servidor=postgres, usuario=n8n, password=(del .env), database=n8n
3. Schema: camino_vital
4. Tabla: email_templates
5. Edit record → Modificar html_template

---

## 📊 Variables Disponibles por Template

### Template: `sesion_ejercicios`

| Variable | Tipo | Ejemplo | Descripción |
|----------|------|---------|-------------|
| `titulo` | string | "Semana 1: Despertando el cuerpo" | Título de la sesión |
| `descripcion` | string | "Ejercicios suaves..." | Descripción breve |
| `duracion` | number | 15 | Duración en minutos |
| `enfoque` | string | "movilidad" | Tipo de enfoque |
| `ejercicios_html` | HTML | `<div>...</div>` | HTML de ejercicios generado |
| `sesion_numero` | number | 1 | Número de sesión actual |
| `sesiones_total` | number | 3 | Total de sesiones de la semana |
| `semana_numero` | number | 1 | Número de semana del programa |
| `user_id` | number | 4 | ID del usuario |
| `webhook_url` | string | "https://n8n..." | URL base para webhooks |

---

## 🔄 Versionado de Templates

### Crear nueva versión (A/B testing):

```sql
-- Crear v2 con nuevo diseño
SELECT create_template_version(
  'sesion_ejercicios',
  '<html>...diseño v2...</html>'
);

-- Ahora existen v1 y v2, ambas activas

-- Workflow puede elegir versión aleatoria:
SELECT html_template FROM email_templates
WHERE nombre = 'sesion_ejercicios'
  AND activo = true
  AND version = (CASE WHEN random() < 0.5 THEN 1 ELSE 2 END);
```

### Deprecar versión antigua:

```sql
UPDATE email_templates
SET activo = false
WHERE nombre = 'sesion_ejercicios' AND version = 1;
```

---

## 🧩 Componentes Reutilizables

Los componentes se pueden usar para construir templates más modulares:

```sql
-- Obtener componente
SELECT html_snippet FROM camino_vital.email_components
WHERE nombre = 'botones_feedback';

-- Usar en template personalizado
const header = await SELECT html_snippet FROM email_components WHERE nombre = 'header_sesion';
const footer = await SELECT html_snippet FROM email_components WHERE nombre = 'footer_final';

const emailHTML = header + contenidoHTML + footer;
```

---

## 📚 Próximos Pasos

1. ✅ Migrar workflow 01-bis a usar templates (EJEMPLO ARRIBA)
2. ⏳ Crear template para email de bienvenida
3. ⏳ Crear template para checkpoint dominical
4. ⏳ Crear template para felicitación de semana completada

---

## 🆘 Troubleshooting

### Variables no se reemplazan

**Problema:** El email muestra `{{nombre}}` en vez del valor
**Causa:** Variable no está en el objeto `variables`
**Solución:** Añadir la variable al objeto antes de `replaceVariables()`

### Template no se encuentra

**Problema:** Error "template not found"
**Causa:** Nombre incorrecto o template inactivo
**Solución:**
```sql
-- Verificar templates disponibles
SELECT nombre, version, activo FROM email_templates;
```

### HTML se muestra como texto plano

**Problema:** El email muestra HTML crudo
**Causa:** Campo incorrecto en Brevo API
**Solución:** Asegúrate de usar `htmlContent` (no `textContent`)

---

**Documentación creada por:** Hábitos Vitales
**Última actualización:** 2 Enero 2025
