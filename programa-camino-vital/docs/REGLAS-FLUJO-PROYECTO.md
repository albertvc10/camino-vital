# 📋 Reglas del Flujo del Proyecto - Camino Vital

**Última actualización:** 15 Enero 2026
**Versión:** 2.0.0

> **NOTA:** Para detalles del sistema de checkpoint adaptativo, ver [SISTEMA-CHECKPOINT-ADAPTATIVO.md](./SISTEMA-CHECKPOINT-ADAPTATIVO.md)

---

## 🎯 Visión General del Sistema

**Camino Vital** es un programa de ejercicio personalizado entregado por email, que se adapta automáticamente al progreso de cada usuario mediante feedback continuo.

---

## 👤 FLUJO DEL USUARIO

### 1. Captación (Landing → Cuestionario)

**URL:** `camino-vital.habitos-vitales.com`

**Paso 1: Landing Page**
- Usuario llega a `index.html`
- Click en "Descubre tu programa personalizado"
- → Redirige a `cuestionario.html`

**Paso 2: Cuestionario (5 pasos)**

Campos capturados:
- **Nombre** (text)
- **Email** (email)
- **Tiempo sin ejercicio** (select):
  - `menos_3meses` = "Menos de 3 meses"
  - `3-6meses` = "Entre 3 y 6 meses"
  - `6-12meses` = "Entre 6 meses y 1 año"
  - `1-2anos` = "Entre 1 y 2 años"
  - `mas_2anos` = "Más de 2 años"

- **Nivel de movilidad** (select):
  - `limitada` = "Limitada (me cuesta agacharme, levantarme)"
  - `normal` = "Normal (puedo moverme pero con cuidado)"
  - `buena` = "Buena (me muevo sin problemas)"

- **Limitaciones físicas** (select):
  - `ninguna` = "Ninguna"
  - `rodilla` = "Rodilla"
  - `espalda` = "Espalda"
  - `hombro` = "Hombro"
  - `cadera` = "Cadera"
  - `otra` = "Otra"

- **Objetivo principal** (select):
  - `movilidad` = "Recuperar movilidad"
  - `fuerza` = "Ganar fuerza"
  - `confianza` = "Sentirme más seguro/a"
  - `autonomia` = "Ser más autónomo/a"

**Acción al completar cuestionario:**
```javascript
// ANTES de redirigir a resultados
POST https://n8n.habitos-vitales.com/webhook/guardar-lead
Body: {
  nombre, email, tiempo_sin_ejercicio, nivel_movilidad,
  limitaciones, objetivo_principal,
  nivel_asignado, duracion_programa
}

// Workflow 04 ejecuta:
INSERT INTO programa_users (
  email, nombre, etapa, nivel_actual, semana_actual,
  estado, perfil_inicial
) VALUES (
  email, nombre, 'base_vital', nivel_asignado, 1,
  'lead', JSON con todos los campos del cuestionario
)

// Añade a lista Brevo #14 (Leads)
```

**Regla de asignación de nivel:**
```javascript
if ((tiempo === 'menos_3meses' || tiempo === '3-6meses') &&
    (movilidad === 'normal' || movilidad === 'buena')) {
  nivel_asignado = 'intermedio';
  duracion_programa = '10 semanas';
} else {
  nivel_asignado = 'iniciacion';
  duracion_programa = '12 semanas';
}
```

**Paso 3: Resultados Personalizados**
- Muestra nivel asignado
- Muestra duración estimada
- Muestra ejemplos de ejercicios
- Precio: **39€**
- Botón: "Empezar mi programa"

**Acción al hacer click:**
```javascript
// Redirige directamente a Stripe Checkout
window.location.href = 'https://buy.stripe.com/test_xxx?prefilled_email={email}';
```

---

### 2. Pago (Stripe)

**Producto:**
- Nombre: "Camino Vital - Base Vital"
- Precio: 39€
- Tipo: One-time payment

**Después del pago exitoso:**
1. Stripe envía webhook a: `https://n8n.habitos-vitales.com/webhook/camino-vital-pago`
2. Evento: `checkout.session.completed`
3. Redirige usuario a: `https://camino-vital.habitos-vitales.com/gracias.html`

**Workflow 01 ejecuta:**
```sql
-- 1. Extraer email del webhook
email = body.data.object.customer_details.email

-- 2. Activar usuario
UPDATE programa_users
SET
  estado = 'activo',
  fecha_pago = NOW(),
  monto_pagado = 39,
  stripe_customer_id = customer_id,
  fecha_inicio = NOW()
WHERE email = email

-- 3. Mover en Brevo
// De lista #14 (Leads) → lista #13 (Clientes Activos)

-- 4. Enviar email de bienvenida
Asunto: "✨ ¡Bienvenido a Camino Vital! Tu recorrido empieza aquí"
```

**Estados posibles del usuario:**
- `lead` = Completó cuestionario pero NO pagó
- `activo` = Pagó y recibe ejercicios
- `pausado` = Pausó temporalmente (vacaciones, lesión)
- `completado` = Terminó las 12 semanas
- `cancelado` = Se dio de baja
- `pendiente_contenido` = No hay contenido para su semana/nivel

---

### 3. Envío de Sesiones (Bajo Demanda)

**NO hay envíos programados L/M/V.** Las sesiones se envían cuando el usuario da feedback.

**Flujo:**
1. Usuario recibe primera sesión (tras pago o tras checkpoint dominical)
2. Usuario hace ejercicios y da feedback
3. Sistema envía siguiente sesión inmediatamente (si quedan)
4. Cuando completa todas las sesiones de la semana, espera al domingo

**Ventajas de este modelo:**
- Usuario controla su propio ritmo
- No hay emails "perdidos" si el usuario no está disponible
- Cada sesión llega justo cuando el usuario está listo

---

### 4. Feedback del Usuario y Sistema Adaptativo

**Botones en cada email de sesión:**

```html
<a href="https://n8n.habitos-vitales.com/webhook/feedback-sesion?user_id={id}&tipo=facil&token={token}">
  Fácil 😊
</a>

<a href="https://n8n.habitos-vitales.com/webhook/feedback-sesion?user_id={id}&tipo=apropiado&token={token}">
  Bien ✅
</a>

<a href="https://n8n.habitos-vitales.com/webhook/feedback-sesion?user_id={id}&tipo=dificil&token={token}">
  Difícil 😓
</a>
```

**Workflow 03-bis: Procesar Feedback Sesión**

1. Recibe click del usuario
2. Guarda feedback en `programa_feedback` (tipo: `sesion_completada`)
3. Incrementa `sesiones_completadas_semana` del usuario
4. Muestra página de confirmación

**Sistema de Checkpoint Semanal (IMPLEMENTADO)**

El sistema usa un checkpoint dominical que combina **adherencia** y **feedback** para adaptar el programa.

> 📋 Ver documentación completa en [SISTEMA-CHECKPOINT-ADAPTATIVO.md](./SISTEMA-CHECKPOINT-ADAPTATIVO.md)

**Matriz de Decisión:**

| Adherencia | Feedback | Acción Nivel | Δ Intensidad | Sesiones |
|------------|----------|--------------|--------------|----------|
| **Alta** (100%) | Fácil | subir_mucho | +10% | +1 |
| **Alta** | Apropiado | subir | +5% | mantener |
| **Alta** | Difícil | mantener | 0% | mantener |
| **Media** (66-99%) | Fácil | subir | +5% | mantener |
| **Media** | Apropiado | mantener | 0% | mantener |
| **Media** | Difícil | bajar | -5% | mantener |
| **Baja** (≤33%) | Fácil | mantener | 0% | -1 |
| **Baja** | Apropiado | bajar | -5% | -1 |
| **Baja** | Difícil | bajar_mucho | -10% | -1 |

**Flujo del Checkpoint:**

1. **Domingo 18:00** - Workflow 06 envía email interactivo con resumen de la semana
2. **Usuario elige** cuántas sesiones quiere hacer la próxima semana (2, 3 o 4)
3. **Workflow 07** procesa la elección y genera la primera sesión con IA
4. **Lunes 9:00** - Reset de `ajustado_esta_semana = FALSE`

**El usuario tiene la decisión final** sobre cuántas sesiones hacer, aunque el sistema recomienda basándose en su rendimiento.

---

### 5. Remarketing (No compradores)

**Workflow 05: Remarketing Leads**

**Trigger:** Diario a las 10:00 AM

**Email Día 3:**
```sql
SELECT * FROM programa_users
WHERE estado = 'lead'
  AND created_at::date = (CURRENT_DATE - INTERVAL '3 days')::date
  AND NOT EXISTS (
    SELECT 1 FROM programa_users pu2
    WHERE pu2.email = programa_users.email
    AND pu2.estado = 'activo'
  )
```

**Contenido:**
- Asunto: "{{ nombre }}, tu programa personalizado te está esperando"
- Recordatorio suave
- CTA: Link al checkout

**Email Día 7:**
```sql
SELECT * FROM programa_users
WHERE estado = 'lead'
  AND created_at::date = (CURRENT_DATE - INTERVAL '7 days')::date
  AND NOT EXISTS (...)
```

**Contenido:**
- Asunto: "[Última oportunidad] 20% descuento en tu programa"
- Precio: ~~39€~~ **31€**
- Cupón: `ULTIMAOPORTUNIDAD` (-8€)
- CTA: Link con cupón aplicado

---

## 📊 ESTRUCTURA DE BASE DE DATOS

### Tabla: `programa_users`

```sql
id                      SERIAL PRIMARY KEY
email                   VARCHAR(255) UNIQUE NOT NULL
nombre                  VARCHAR(255)

-- Programa
etapa                   VARCHAR(50) DEFAULT 'base_vital'
nivel_actual            VARCHAR(50) DEFAULT 'iniciacion'
semana_actual           INTEGER DEFAULT 1
intensidad_nivel        INTEGER DEFAULT 60  -- 50-100%

-- Sistema adaptativo (NUEVO)
sesiones_objetivo_semana     INTEGER DEFAULT 3   -- Sesiones a hacer esta semana
sesiones_completadas_semana  INTEGER DEFAULT 0   -- Sesiones hechas
ajustado_esta_semana         BOOLEAN DEFAULT FALSE  -- TRUE si ya pasó checkpoint

-- Estado
estado                  VARCHAR(50) DEFAULT 'activo'
                        -- 'lead', 'activo', 'pausado', 'completado', 'cancelado'
activo                  BOOLEAN DEFAULT TRUE
fecha_inicio            TIMESTAMP
fecha_ultimo_envio      TIMESTAMP
fecha_ultima_respuesta  TIMESTAMP

-- Perfil del cuestionario
perfil_inicial          JSONB
                        -- Estructura:
                        {
                          "tiempo_sin_ejercicio": "1-2anos",
                          "nivel_movilidad": "limitada",
                          "limitaciones": "espalda",
                          "limitaciones_detalle": "",
                          "objetivo_principal": "confianza",
                          "cuestionario_completado": "ISO timestamp"
                        }

-- Tracking
envios_totales          INTEGER DEFAULT 0
respuestas_totales      INTEGER DEFAULT 0
tasa_respuesta          DECIMAL(5,2)

-- Pago
stripe_customer_id      VARCHAR(255)
fecha_pago              TIMESTAMP
monto_pagado            DECIMAL(10,2)

-- Sistema
created_at              TIMESTAMP DEFAULT NOW()
updated_at              TIMESTAMP DEFAULT NOW()
```

### Tabla: `programa_contenido`

```sql
id                      SERIAL PRIMARY KEY
etapa                   VARCHAR(50) NOT NULL  -- 'base_vital'
nivel                   VARCHAR(50) NOT NULL  -- 'iniciacion', 'intermedio'
semana                  INTEGER NOT NULL

titulo                  VARCHAR(255)
descripcion             TEXT
contenido_ejercicios    JSONB
                        -- Estructura:
                        {
                          "ejercicios": [
                            {
                              "nombre": "Respiración diafragmática",
                              "descripcion": "...",
                              "repeticiones": "10 respiraciones",
                              "video_url": "[PENDIENTE]" | "https://...",
                              "notas": "..."
                            }
                          ]
                        }

duracion_estimada       INTEGER  -- minutos
enfoque                 VARCHAR(100)  -- 'movilidad', 'fuerza', 'equilibrio'

created_at              TIMESTAMP
updated_at              TIMESTAMP

UNIQUE(etapa, nivel, semana)
```

### Tabla: `programa_feedback`

```sql
id                      SERIAL PRIMARY KEY
user_id                 INTEGER REFERENCES programa_users(id)

semana                  INTEGER NOT NULL
etapa                   VARCHAR(50) NOT NULL
nivel                   VARCHAR(50) NOT NULL

tipo_feedback           VARCHAR(50)  -- 'dificultad', 'progreso'
respuesta               VARCHAR(50)  -- 'facil', 'adecuado', 'dificil'
respuesta_extendida     TEXT

accion_tomada           VARCHAR(50)  -- 'mantener', 'avanzar', 'retroceder'

created_at              TIMESTAMP DEFAULT NOW()
```

### Tabla: `programa_sesiones` (NUEVA - Generadas por IA)

```sql
id                      SERIAL PRIMARY KEY
user_id                 INTEGER REFERENCES programa_users(id)
semana                  INTEGER NOT NULL
numero_sesion           INTEGER NOT NULL  -- 1, 2, 3...

-- Contenido generado por IA
titulo                  VARCHAR(255)
descripcion             TEXT
contenido_ejercicios    JSONB  -- Array de ejercicios con nombre, descripcion, etc.
duracion_estimada       INTEGER  -- minutos
enfoque                 VARCHAR(100)

-- Parámetros de generación
nivel_generado          VARCHAR(50)
intensidad_generada     INTEGER

-- Estado
enviada                 BOOLEAN DEFAULT FALSE
fecha_envio             TIMESTAMP

created_at              TIMESTAMP DEFAULT NOW()

UNIQUE(user_id, semana, numero_sesion)
```

### Tabla: `programa_envios`

```sql
id                      SERIAL PRIMARY KEY
user_id                 INTEGER REFERENCES programa_users(id)
contenido_id            INTEGER REFERENCES programa_contenido(id)

brevo_message_id        VARCHAR(255)
estado                  VARCHAR(50) DEFAULT 'enviado'
                        -- 'enviado', 'abierto', 'clickeado', 'respondido'

fecha_envio             TIMESTAMP DEFAULT NOW()
fecha_apertura          TIMESTAMP
fecha_click             TIMESTAMP

created_at              TIMESTAMP DEFAULT NOW()
```

---

## 🔄 REGLAS DE NEGOCIO

### Progresión de Semanas (Sistema Adaptativo)

**Flujo semanal:**
1. Usuario recibe 2-5 sesiones por semana (L/M/V + opcionales)
2. Cada sesión tiene botones de feedback (fácil/apropiado/difícil)
3. **Domingo 18:00** - Checkpoint semanal analiza adherencia + feedback
4. Usuario elige sesiones para próxima semana
5. → `semana_actual` incrementa, ajustes de nivel/intensidad aplicados

**Campos clave del usuario:**
- `sesiones_objetivo_semana` - Cuántas debe hacer (2-5)
- `sesiones_completadas_semana` - Cuántas ha hecho
- `ajustado_esta_semana` - TRUE si ya pasó por checkpoint

### Niveles e Intensidad

**Niveles:**
- `iniciacion` = Nivel base para principiantes
- `intermedio` = Nivel medio
- `avanzado` = Nivel avanzado

**Intensidad:**
- Rango: 50% - 100%
- Ajuste automático: ±5% o ±10% según checkpoint
- Afecta la dificultad de las sesiones generadas por IA

**¿Puede cambiar de nivel durante el programa?**
- ✅ **SÍ** - El sistema puede subir o bajar nivel automáticamente
- `subir`: iniciacion → intermedio → avanzado
- `bajar`: avanzado → intermedio → iniciacion

### Limitaciones Físicas

**Estado actual:**
- Se capturan en `perfil_inicial.limitaciones`
- NO se usan para filtrar ejercicios (todavía)

**🔮 Futuro (Fase 2):**
- Filtrar ejercicios según limitación
- Ofrecer modificaciones/alternativas
- Check-in cada 4 semanas: "¿Cómo está tu {limitación}?"

### Pausas

**Actual:** NO IMPLEMENTADO

**🔮 Futuro:**
- Usuario puede pausar respondiendo al email
- Estado = `pausado`
- Campo nuevo: `fecha_reactivacion` (calculada)
- Workflow diario reactiva usuarios cuando `fecha_reactivacion <= HOY`

---

## 📧 EMAILS DEL SISTEMA

### 1. Email de Bienvenida (Post-pago)

**Trigger:** Inmediato después de pago
**Template:** Workflow 01
**Asunto:** "✨ ¡Bienvenido a Camino Vital! Tu recorrido empieza aquí"

**Contenido:**
- Confirmación de pago
- Explicación del programa
- Qué esperar (frecuencia, formato)
- Próximo email: "Lunes/Miércoles/Viernes a las 9:00 AM"

### 2. Email de Ejercicios (L/M/V)

**Trigger:** Programado (cron)
**Template:** Workflow 02
**Asunto:** "{Semana X: Título}"

**Contenido:**
- Título y descripción de la semana
- 4-5 ejercicios detallados
- Videos (cuando estén disponibles)
- Consejos
- Botones de feedback

### 3. Email Remarketing Día 3

**Trigger:** Diario 10:00 AM, leads de hace 3 días
**Template:** Workflow 05
**Asunto:** "{{ nombre }}, tu programa personalizado te está esperando"

**Contenido:**
- Recordatorio suave
- Beneficios del programa
- Link al checkout

### 4. Email Remarketing Día 7 (con descuento)

**Trigger:** Diario 10:00 AM, leads de hace 7 días
**Template:** Workflow 05
**Asunto:** "[Última oportunidad] 20% descuento en tu programa"

**Contenido:**
- Último intento
- Descuento 20% (31€ en vez de 39€)
- Sentido de urgencia
- Link con cupón aplicado

---

## 🔮 FUNCIONALIDADES FUTURAS (NO MVP)

### Fase 2 (Mes 1-2)

**1. Respuestas Inteligentes con IA**
- Webhook de Brevo captura respuestas de usuarios
- IA analiza: ¿pausar? ¿cambiar nivel? ¿problema?
- Acciones automáticas + confirmación por email
- Dashboard para revisar casos complejos

**2. Personalización de Ejercicios**
- Filtrar ejercicios según `limitaciones`
- 2-3 variantes por semana (sin_hombros, sin_rodillas, etc.)
- Usar IA para selección dinámica

**3. Check-ins periódicos**
- Cada 4 semanas: "¿Cómo va tu {limitación}?"
- Actualizar perfil según respuesta
- Ajustar ejercicios dinámicamente

### Fase 3 (Mes 3-6)

**4. Horarios personalizados**
- Usar `dias_preferidos_envio` y `hora_preferida_envio`
- Workflow ejecuta cada hora, filtra por usuarios de esa hora
- Permitir cambiar preferencias desde email

**5. Contenido avanzado**
- Videos profesionales de todos los ejercicios
- Variaciones (regresión/progresión)
- Etapas 2 y 3: Fuerza Vital, Autonomía Vital

**6. Métricas y Analytics**
- Dashboard de métricas en tiempo real
- Predicción de abandono
- A/B testing de emails

### Fase 4 (Mes 6+)

**7. App complementaria**
- Móvil para tracking
- Notificaciones push
- Gamificación

**8. Comunidad**
- Discord/Telegram privado
- Challenges mensuales
- Certificados de completación

---

## ⚙️ CONFIGURACIÓN TÉCNICA

### Dominios
- Landing: `camino-vital.habitos-vitales.com`
- n8n: `n8n.habitos-vitales.com`

### Stripe
- Modo: Test (cambiar a Live en producción)
- Product ID: `prod_xxx`
- Price ID: `price_1Sg2jvAY3mlcRJjrPNn3yxmg`
- Payment Link: `https://buy.stripe.com/test_aFa00igC741Zcjxfn5eZ200`
- Webhook: `https://n8n.habitos-vitales.com/webhook/camino-vital-pago`
- Webhook Secret: `whsec_sK4y75T4PutHsiXzkJBMiJbwPQZmKq2g`
- Cupón descuento: `ULTIMAOPORTUNIDAD` (-8€)

### Brevo
- API Key: `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`
- Lista #13: Clientes Activos (Base Vital)
- Lista #14: Leads (no compradores)
- Sender: `hola@habitos-vitales.com`

### n8n Webhooks
- Guardar lead: `https://n8n.habitos-vitales.com/webhook/guardar-lead`
- Pago Stripe: `https://n8n.habitos-vitales.com/webhook/camino-vital-pago`
- Feedback: `https://n8n.habitos-vitales.com/webhook/feedback?user_id={id}&semana={semana}&respuesta={respuesta}`

### Cron Schedules (Producción)
- **Workflow 02 (Ejercicios):** `0 9 * * 1,3,5` (L/M/V 9:00 AM UTC)
- **Workflow 05 (Remarketing):** `0 10 * * *` (Diario 10:00 AM UTC)

### Cron Schedules (Testing)
- **Workflow 02:** `*/10 * * * *` (Cada 10 minutos)
- Query modificado: `fecha_ultimo_envio < (NOW() - INTERVAL '10 minutes')`

---

## ✅ DECISIONES TOMADAS

### 1. Progresión de Semanas
**Decisión:** Checkpoint semanal (domingos)
- El usuario avanza de semana cada domingo después del checkpoint
- El sistema analiza adherencia + feedback para ajustar dificultad
- El usuario elige cuántas sesiones quiere hacer la próxima semana

### 2. Usuario Sin Feedback
**Decisión:** Continuar con adherencia baja
- Si no da feedback, su adherencia será 0%
- El checkpoint del domingo reducirá sesiones recomendadas
- No se pausa automáticamente

### 3. Cambio de Nivel
**Decisión:** Automático según matriz adaptativa
- El sistema puede subir/bajar nivel basado en adherencia + feedback
- Alta adherencia + feedback "fácil" → Sube nivel
- Baja adherencia + feedback "difícil" → Baja nivel

### 4. Limitaciones Físicas
**Decisión:** IA personaliza sesiones
- Las limitaciones se pasan al prompt de generación de sesiones
- La IA adapta ejercicios según el perfil del usuario
- No hay variantes estáticas, todo es dinámico

### 5. Horarios Personalizados
**Decisión:** L/M/V 9:00 AM para todos (MVP)
- Simplifica la lógica de envío
- Se puede personalizar en futuras versiones

---

## 📝 NOTAS IMPORTANTES

### Sistema de Generación de Contenido
- ✅ **Sesiones generadas por IA** - OpenAI genera contenido personalizado
- Las sesiones se adaptan al nivel, intensidad y perfil del usuario
- No se requiere contenido estático pre-creado

### Workflows Activos
- ✅ Workflow 01 (Onboarding) - Stripe → Activar usuario → Primera sesión
- ✅ Workflow 04 (Guardar lead) - Cuestionario → DB
- ✅ Workflow 06 (Checkpoint Dominical) - Análisis semanal (domingo 18:00)
- ✅ Workflow 07 (Procesar Checkpoint) - Elección usuario → Nueva sesión
- ✅ Workflow 03-bis (Feedback y Siguiente Sesión) - Feedback → Envía siguiente
- ✅ Workflow 09 (Generador Sesión IA) - Genera contenido personalizado
- ⏸️ Workflow 05 (Remarketing) - Pendiente testing

**NOTA:** No hay workflow de "envíos programados". Las sesiones se envían bajo demanda cuando el usuario da feedback.

### Problemas Conocidos
- SSH solo funciona desde hotspot móvil
- Variables de entorno `{{$env.X}}` no funcionan en workflows (usar valores directos)

---

## 🎯 PRÓXIMOS PASOS

### Inmediatos
1. [ ] Probar flujo completo: Checkpoint → Elección → Sesión IA
2. [ ] Integrar workflow 02 (envío programado L/M/V) con sesiones IA
3. [ ] Probar workflow 03-bis (feedback de sesión)

### Corto Plazo
4. [ ] Pasar Stripe a modo Live
5. [ ] Primera campaña de tráfico
6. [ ] Conseguir primeros 10 clientes de pago

### Medio Plazo
7. [ ] Afinar prompts de generación de sesiones IA
8. [ ] Dashboard de métricas (conversión, retención, adherencia)
9. [ ] Sistema de notificaciones para usuarios inactivos

---

**Creado por:** Hábitos Vitales
**Mantenido por:** Albert Villanueva
**Contacto:** hola@habitos-vitales.com
