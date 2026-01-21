# Plan de Actualización de Estilos - Camino Vital

**Fecha de creación:** 2026-01-17
**Referencia de diseño:** https://habitos-vitales.com/index.php/movegate/
**Estado:** EN PROGRESO

---

## Objetivo

Actualizar todas las páginas HTML de Camino Vital para:
1. Alinear el estilo visual con Movegate (Hábitos Vitales)
2. Mejorar la experiencia de usuario (UX)
3. Mejorar el copywriting y los mensajes para aumentar conversión
4. **Dejar claro que es un producto de Hábitos Vitales** - branding consistente

---

## Branding de Hábitos Vitales

**Logo:** https://habitos-vitales.com/wp-content/uploads/2023/10/Diseno-sin-titulo-9.png

**Elementos de branding a incluir:**
- Logo de HV en navbar (header)
- Texto "Camino Vital" junto al logo con separador
- Footer con logo, texto "Un programa de Hábitos Vitales" y copyright
- Link a habitos-vitales.com desde el logo
- Email de contacto: hola@habitos-vitales.com

---

## Archivos a Modificar

| # | Archivo | Prioridad | Estado |
|---|---------|-----------|--------|
| 1 | `landing/index.html` | ALTA | ✅ Completado |
| 2 | `landing/cuestionario.html` | ALTA | ✅ Completado |
| 3 | `landing/resultados.html` | ALTA | ✅ Completado |
| 4 | `landing/gracias.html` | MEDIA | ✅ Completado |
| 5 | `landing/feedback-problemas.html` | MEDIA | ✅ Completado |
| 6 | `templates/email-lista-espera.html` | BAJA | ✅ Completado |
| 7 | `database/ejercicios_biblioteca.html` | BAJA | ✅ Completado |

---

## Cambios Globales (Aplicar a TODOS los archivos)

### 1. Estilos de Botones (Estilo Movegate)
```css
/* Botón Primario - ANTES */
.btn-primary {
    background: #DFCA61;
    border-radius: 12px;
    padding: 18px 40px;
}

/* Botón Primario - DESPUÉS (Movegate) */
.btn-primary {
    background: #DFCA61;
    color: #1C1C1C;
    border: none;
    border-radius: 999px; /* Completamente redondeado */
    padding: 14px 26px;
    font-size: 15px;
    font-weight: 600;
    box-shadow: 0 0 35px rgba(223, 202, 97, 0.3);
    cursor: pointer;
    transition: all 0.12s ease;
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 0 45px rgba(223, 202, 97, 0.4);
}

/* Botón Ghost/Secundario */
.btn-secondary {
    background: transparent;
    color: #DFCA61;
    border: 2px solid #DFCA61;
    border-radius: 999px;
    padding: 14px 26px;
    font-size: 15px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.12s ease;
}

.btn-secondary:hover {
    background: rgba(223, 202, 97, 0.1);
}
```

### 2. Layout Full-Width
```css
/* Secciones full-width con padding agresivo */
.section {
    width: 100%;
    padding: 80px 20px;
}

@media (max-width: 768px) {
    .section {
        padding: 40px 16px;
    }
}

.section-container {
    max-width: 1120px;
    margin: 0 auto;
}
```

### 3. Tipografía Consistente
```css
body {
    font-family: system-ui, -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
    line-height: 1.7;
    color: #B5B5B5;
}

h1 { font-size: 44px; font-weight: 700; color: #DFCA61; }
h2 { font-size: 32px; font-weight: 600; color: #E8E8E8; }
h3 { font-size: 22px; font-weight: 600; color: #E8E8E8; }

.tagline {
    font-size: 14px;
    text-transform: uppercase;
    letter-spacing: 0.16em;
    color: #62B882;
}

@media (max-width: 768px) {
    h1 { font-size: 32px; }
    h2 { font-size: 26px; }
    h3 { font-size: 20px; }
}
```

### 4. Cards Mejoradas
```css
.card {
    background: #1C1C1C;
    border: 1px solid rgba(255,255,255,0.08);
    border-radius: 18px;
    padding: 32px;
    transition: all 0.12s ease;
}

.card:hover {
    border-color: rgba(223, 202, 97, 0.3);
    transform: translateY(-4px);
}

/* Cards con borde de acento */
.card-accent {
    border-left: 4px solid #62B882;
}
```

---

## Cambios Específicos por Página

### 1. INDEX.HTML - Landing Principal

#### Cambios de Diseño:
- [ ] Añadir hero visual (mockup de móvil con la app o ilustración)
- [ ] Convertir a layout full-width con secciones edge-to-edge
- [ ] Actualizar todos los botones al estilo Movegate (border-radius: 999px)
- [ ] Añadir más CTAs repetidos a lo largo de la página
- [ ] Añadir sección FAQ expandible
- [ ] Mejorar gradientes de fondo entre secciones

#### Cambios de Copy:
- [ ] Hero: Más directo y con urgencia
  - ANTES: "El programa de movimiento que se adapta a ti, no tu a el"
  - DESPUÉS: "Recupera tu movilidad en 12 semanas. Sin gimnasio. Sin excusas."

- [ ] Pain points: Más específicos y urgentes
  - ANTES: "Llevas tiempo sin hacer ejercicio..."
  - DESPUÉS: "Cada semana que pasa sin moverte, pierdes un 1% de masa muscular. Tu cuerpo no espera."

- [ ] Añadir urgencia/escasez si aplica (plazas limitadas, etc.)

#### Estructura Nueva Propuesta:
1. Hero con visual + CTA principal
2. Tagline: "PROGRAMA PERSONALIZADO"
3. Pain Points (con más urgencia)
4. Solución / Value Prop
5. Cómo Funciona (4 pasos visuales)
6. Características / Features Grid
7. Testimonial destacado
8. FAQ Expandible
9. Pricing con CTA
10. Footer con garantía

---

### 2. CUESTIONARIO.HTML

#### Cambios de Diseño:
- [ ] Progress bar más prominente (sticky en top)
- [ ] Botones de navegación estilo Movegate
- [ ] Radio buttons con mejor feedback visual
- [ ] Animaciones de transición entre pasos
- [ ] Indicador de paso actual más claro

#### Cambios de Copy:
- [ ] Mensajes de encouragement entre pasos
- [ ] Contexto de por qué preguntamos cada cosa
- [ ] "Solo faltan X pasos" en vez de solo la barra

---

### 3. RESULTADOS.HTML

#### Cambios de Diseño:
- [ ] Celebración más visual (confetti o animación)
- [ ] Card del programa más destacada
- [ ] Ejemplos de ejercicios con thumbnails/iconos
- [ ] CTA de pago más prominente y repetido
- [ ] Añadir countdown o urgencia si aplica

#### Cambios de Copy:
- [ ] Personalización más evidente ("Basado en tus respuestas, [nombre]...")
- [ ] Beneficios específicos para SU perfil
- [ ] Social proof relevante a su nivel
- [ ] Reducir fricción pre-pago (garantía más visible)

---

### 4. GRACIAS.HTML

#### Cambios de Diseño:
- [ ] Celebración visual mejorada
- [ ] Timeline de próximos pasos más visual
- [ ] Botón para añadir a calendario (opcional)

#### Cambios de Copy:
- [ ] Mensaje de bienvenida más cálido
- [ ] Expectativas claras de qué esperar
- [ ] Reducir ansiedad post-compra

---

### 5. FEEDBACK-PROBLEMAS.HTML

#### Cambios de Diseño:
- [ ] Botones más grandes y táctiles
- [ ] Iconos más expresivos
- [ ] Feedback visual de selección

#### Cambios de Copy:
- [ ] Tono más empático
- [ ] Asegurar que no hay juicio ("Es normal...")

---

### 6. EMAIL-LISTA-ESPERA.HTML

#### Cambios de Diseño:
- [ ] Alinear colores con el resto
- [ ] Layout más limpio

#### Cambios de Copy:
- [ ] Más valor de estar en lista de espera
- [ ] Crear anticipación

---

### 7. EJERCICIOS_BIBLIOTECA.HTML

#### Cambios de Diseño:
- [ ] Cards de ejercicios estilo Movegate
- [ ] Filtros más visuales
- [ ] Mejor organización visual

---

## Orden de Implementación

### Fase 1: Landing Principal (PRIORIDAD MÁXIMA)
1. ⬜ Actualizar estilos globales en index.html
2. ⬜ Rediseñar hero section con visual
3. ⬜ Mejorar pain points y copy
4. ⬜ Añadir FAQ expandible
5. ⬜ Repetir CTAs
6. ⬜ Testing responsive

### Fase 2: Funnel de Conversión
7. ⬜ Actualizar cuestionario.html
8. ⬜ Actualizar resultados.html
9. ⬜ Actualizar gracias.html

### Fase 3: Páginas Secundarias
10. ⬜ Actualizar feedback-problemas.html
11. ⬜ Actualizar email-lista-espera.html
12. ⬜ Actualizar ejercicios_biblioteca.html

### Fase 4: Testing Final
13. ⬜ Test completo del flujo usuario
14. ⬜ Test responsive en móvil
15. ⬜ Verificar integraciones (Stripe, n8n)

---

## Notas de Implementación

### CSS Compartido
Considerar extraer los estilos comunes a un archivo `styles.css` externo para:
- Consistencia entre páginas
- Facilidad de mantenimiento
- Mejor rendimiento (caching)

### Variables CSS Recomendadas
```css
:root {
    --color-primary: #DFCA61;
    --color-success: #62B882;
    --color-error: #E74C3C;
    --color-bg-dark: #232323;
    --color-bg-card: #1C1C1C;
    --color-text-primary: #E8E8E8;
    --color-text-secondary: #B5B5B5;
    --border-radius-full: 999px;
    --border-radius-card: 18px;
    --shadow-button: 0 0 35px rgba(223, 202, 97, 0.3);
    --transition-fast: 0.12s ease;
}
```

---

## Historial de Cambios

| Fecha | Cambio | Archivos |
|-------|--------|----------|
| 2026-01-17 | Plan creado | Este archivo |
| 2026-01-17 | Implementacion completa del estilo Movegate | Todos los 7 archivos HTML |
| 2026-01-17 | Mejoras de conversion para aumentar ventas | landing/index.html |

### Cambios implementados (2026-01-17):

**index.html:**
- Variables CSS globales
- Botones estilo Movegate (border-radius: 999px, sombras doradas)
- Hero visual con icono animado
- Pain points con copy mas urgente
- FAQ expandible con JavaScript
- Multiples CTAs a lo largo de la pagina
- Layout full-width con secciones
- Responsive design mejorado

**index.html (Mejoras de Conversion):**
- Seccion "Que recibes exactamente" con mockup de email real mostrando una sesion
- Tabla comparativa: Camino Vital vs YouTube vs Gimnasio
- 3 testimonios con contexto (edad, situacion) y resultados (semana alcanzada)
- Seccion de autoridad: "Creado por Habitos Vitales" con stats
- Timeline de resultados: Semanas 2, 4, 8, 12 - que esperar
- Banner de urgencia antes del pricing (motivacion real, no falsa escasez)
- Estilos responsive para todas las nuevas secciones

**cuestionario.html:**
- Progress bar sticky en top
- Mensajes de encouragement entre pasos
- Radio buttons con mejor feedback visual
- Animaciones de transicion entre pasos
- Botones estilo Movegate

**resultados.html:**
- Celebracion visual mejorada (icono animado)
- Card del programa mas destacada
- Testimonial con avatar
- CTA mas prominente
- Badge de programa recomendado

**gracias.html:**
- Header con gradiente y icono celebratorio
- Timeline de proximos pasos visual
- Info box con recordatorios importantes
- Boton CTA para revisar email

**feedback-problemas.html:**
- Nota de empatia antes de opciones
- Botones mas grandes y tactiles
- Iconos mas expresivos
- Mensaje de exito mejorado

**email-lista-espera.html:**
- Adaptado a dark mode (fondo #232323)
- Colores alineados con el resto
- Stats box con estilo consistente
- Info boxes verdes y dorados

**ejercicios_biblioteca.html:**
- Convertido de purpura a dark mode
- Variables CSS consistentes
- Cards con hover effects
- Badges de nivel con colores del sistema
- Filtros con estilo Movegate

---

## Referencias

- **Diseño de referencia:** https://habitos-vitales.com/index.php/movegate/
- **Colores principales:** #DFCA61 (oro), #62B882 (verde), #1C1C1C (fondo)
- **Tipografía:** system-ui, -apple-system, BlinkMacSystemFont

---

*Este plan se actualiza conforme se completan las tareas. Marca cada item con ✅ cuando esté completado.*
