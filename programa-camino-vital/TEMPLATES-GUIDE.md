# Guía de Templates HTML - Camino Vital

## Regla Principal

**NUNCA generar HTML directamente en los workflows de n8n.** Todo el HTML debe estar almacenado en la tabla `email_templates` de la base de datos.

## ¿Por qué?

1. **Mantenibilidad**: Cambiar estilos o contenido sin tocar workflows
2. **Consistencia**: Un solo lugar para el tema visual (Dark Theme Hábitos Vitales)
3. **Versionado**: Los templates pueden tener versiones
4. **Reutilización**: El mismo template puede usarse en múltiples workflows

## Estructura de la Tabla `email_templates`

```sql
CREATE TABLE email_templates (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50),           -- 'email', 'pagina', 'componente', 'checkpoint'
    descripcion TEXT,
    html_template TEXT NOT NULL,
    version INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(nombre, version)
);
```

## Tipos de Templates

| Tipo | Uso | Ejemplo |
|------|-----|---------|
| `email` | Emails enviados al usuario | `email_primera_sesion`, `email_sesion_siguiente` |
| `pagina` | Páginas de respuesta webhook | `pagina_procesando_primera`, `pagina_semana_completada` |
| `componente` | Partes reutilizables de HTML | `componente_banner_ajuste_subir`, `ejercicio_item` |
| `checkpoint` | Templates del checkpoint semanal | `checkpoint_semanal`, `programa_completado` |
| `global` | CSS y estilos globales | `css_base_habitos_vitales` |

## Variables en Templates

Usar sintaxis `{{variable}}` para variables dinámicas:

```html
<h1>Hola {{nombre}}</h1>
<p>Tu sesión {{sesion_numero}} de {{sesiones_objetivo}}</p>
<a href="{{sesion_url}}">Ver sesión</a>
```

### Variables Comunes

| Variable | Descripción |
|----------|-------------|
| `{{nombre}}` | Nombre del usuario |
| `{{sesion_numero}}` | Número de sesión actual |
| `{{sesiones_objetivo}}` | Sesiones objetivo por semana |
| `{{semana_actual}}` | Semana actual del programa |
| `{{sesion_url}}` | URL para ver la sesión |
| `{{enfoque}}` | Tipo de enfoque (Fuerza/Cardio) |
| `{{duracion}}` | Duración estimada |
| `{{contenido}}` | Descripción del contenido |
| `{{nivel}}` | Nivel del usuario |
| `{{introduccion}}` | Texto de introducción personalizada |

## Patrón en Workflows

### 1. Obtener Template de BD

```sql
SELECT html_template
FROM email_templates
WHERE nombre = 'nombre_template' AND version = 1;
```

### 2. Nodo de Renderizado (Code Node)

```javascript
// Renderizar template con variables
const template = $json.html_template;
const usuario = $node['Nodo Usuario'].json;

const html = template
  .replace(/\{\{nombre\}\}/g, usuario.nombre || '')
  .replace(/\{\{sesion_numero\}\}/g, usuario.sesion_actual || '')
  .replace(/\{\{sesiones_objetivo\}\}/g, usuario.sesiones_objetivo_semana || '');

return { json: { html } };
```

### 3. Responder con HTML

```javascript
// En Respond to Webhook node
responseBody: "={{ $json.html }}"
```

## Templates Actuales

### Emails
- `email_primera_sesion` - Primera sesión después de configurar
- `email_sesion_siguiente` - Siguientes sesiones de la semana
- `email_checkpoint_nueva_semana` - Email tras checkpoint con nueva sesión
- `sesion_ejercicios` - Email con ejercicios detallados

### Páginas
- `pagina_procesando_primera` - "Preparando tu primera sesión..."
- `pagina_procesando_siguiente` - "Preparando siguiente sesión..."
- `pagina_semana_completada` - "¡Semana completada!"
- `pagina_ya_configurado` - "Ya tienes sesiones configuradas"
- `pagina_programa_completado` - "¡Has completado el programa!"

### Componentes
- `componente_banner_ajuste_subir` - Banner cuando mejora nivel
- `componente_banner_ajuste_bajar` - Banner cuando baja nivel
- `ejercicio_item` - HTML para un ejercicio individual
- `css_base_habitos_vitales` - CSS base con colores del tema

## Crear Nuevo Template

```sql
INSERT INTO email_templates (nombre, tipo, descripcion, html_template) VALUES
('nuevo_template', 'pagina', 'Descripción del template', '<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Título</title>
  <style>
    /* Usar colores Hábitos Vitales */
    :root {
      --color-primary: #DFCA61;
      --color-success: #62B882;
      --color-bg-dark: #232323;
      --color-bg-card: #1C1C1C;
      --color-text-primary: #E8E8E8;
      --color-text-secondary: #B5B5B5;
    }
  </style>
</head>
<body>
  <h1>{{titulo}}</h1>
</body>
</html>');
```

## Colores del Tema Dark - Hábitos Vitales

```css
--hv-bg-primary: #232323;      /* Fondo principal */
--hv-bg-secondary: #1C1C1C;    /* Fondo tarjetas */
--hv-bg-dark: #181818;         /* Fondo más oscuro */
--hv-accent-gold: #DFCA61;     /* Dorado - Acento principal */
--hv-accent-green: #62B882;    /* Verde - Éxito/Progreso */
--hv-text-primary: #FFFFFF;    /* Texto principal */
--hv-text-muted: #B5B5B5;      /* Texto secundario */
--hv-border-glass: rgba(255,255,255,0.08);  /* Bordes sutiles */
```

## Checklist para Nuevos Workflows

- [ ] ¿El HTML está en `email_templates`?
- [ ] ¿Se usa el nodo PostgreSQL para obtener el template?
- [ ] ¿Se usa un Code Node para reemplazar variables?
- [ ] ¿Los colores siguen el tema Dark de Hábitos Vitales?
- [ ] ¿Las variables usan sintaxis `{{variable}}`?
