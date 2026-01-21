# 📚 Camino Vital - Sistema de Programa de Ejercicio Automatizado

**Última actualización:** Enero 2026
**Versión:** 2.0.0

## 🎯 Visión General

**Camino Vital** es un programa de ejercicio completamente automatizado que se entrega por email usando n8n + Brevo + OpenAI. El sistema personaliza automáticamente el contenido basándose en el feedback del usuario, permitiendo:

- Progresión adaptativa (matriz adherencia + feedback)
- Sesiones generadas por IA personalizadas
- Usuario elige cuántas sesiones hacer por semana
- Interacción mediante clicks en emails (sin necesidad de login)
- Totalmente automatizado con mínima intervención manual

> 📋 Ver documentación detallada del sistema adaptativo en [SISTEMA-CHECKPOINT-ADAPTATIVO.md](./SISTEMA-CHECKPOINT-ADAPTATIVO.md)

---

## 🏗️ Arquitectura del Sistema

```
┌──────────────────────────────────────────────────────────────────┐
│                       FLUJO DEL USUARIO                          │
└──────────────────────────────────────────────────────────────────┘

1. CAPTACIÓN
   Landing Page → Cuestionario → Resultados → Stripe Pago (39€)

2. ONBOARDING (Workflow 01)
   Stripe Webhook → Activar usuario → Mover Brevo → Email bienvenida

3. CICLO SEMANAL (bajo demanda, no programado)
   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
   │ Usuario     │───▶│ Sistema     │───▶│ ¿Quedan     │
   │ da feedback │    │ registra +  │    │ sesiones?   │
   │ de sesión   │    │ incrementa  │    │             │
   └─────────────┘    └─────────────┘    └─────────────┘
                                                │
                           ┌────────────────────┴────────────────────┐
                           ▼                                         ▼
                    ┌─────────────┐                           ┌─────────────┐
                    │ SÍ: Envía   │                           │ NO: Muestra │
                    │ siguiente   │                           │ "Semana     │
                    │ sesión      │                           │ completada" │
                    └─────────────┘                           └─────────────┘
                                                                     │
                                                                     ▼
4. CHECKPOINT DOMINICAL (Workflow 06 + 07)
   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
   │ Domingo     │───▶│ Usuario     │───▶│ Procesa +   │
   │ 18:00       │    │ elige       │    │ genera      │
   │ Email       │    │ sesiones    │    │ sesión IA   │
   │ resumen     │    │ próx. sem.  │    │             │
   └─────────────┘    └─────────────┘    └─────────────┘
```

---

## 📦 Componentes

### 1. Base de Datos (PostgreSQL)

**Tablas principales:**

- `programa_users` - Usuarios del programa (con campos adaptativos)
- `programa_sesiones` - Sesiones generadas por IA
- `programa_feedback` - Historial de feedback por sesión
- `programa_contenido` - Biblioteca de ejercicios (legacy)
- `programa_envios` - Log de emails enviados

**Funciones SQL:**

- `analizar_semana_para_checkpoint(user_id)` - Analiza adherencia + feedback
- `procesar_checkpoint_interactivo(...)` - Aplica ajustes y elección del usuario

### 2. Workflows n8n

#### **Workflow 01: Onboarding**
- Trigger: Webhook de Stripe cuando usuario paga
- Acciones: Activar usuario → Mover lista Brevo → Email bienvenida

#### **Workflow 04: Guardar Lead**
- Trigger: Webhook cuestionario
- Acciones: INSERT usuario como lead → Añadir a Brevo

#### **Workflow 06: Checkpoint Dominical**
- Trigger: Cron domingo 18:00
- Acciones:
  1. Obtener usuarios con `ajustado_esta_semana = FALSE`
  2. Llamar `analizar_semana_para_checkpoint()`
  3. Enviar email interactivo con resumen + botones elección

#### **Workflow 07: Procesar Checkpoint**
- Trigger: Webhook cuando usuario elige sesiones
- Acciones:
  1. Llamar `procesar_checkpoint_interactivo()`
  2. Detectar si ya procesado (idempotencia)
  3. Llamar workflow 09 para generar sesión IA
  4. Enviar email con primera sesión de la semana

#### **Workflow 09: Generador Sesión IA**
- Trigger: Llamada interna desde otros workflows
- Acciones:
  1. Recibir parámetros (user_id, semana, nivel, intensidad, perfil)
  2. Generar contenido con OpenAI
  3. Guardar en `programa_sesiones`
  4. Devolver contenido formateado

#### **Workflow 03-bis: Feedback y Siguiente Sesión**
- Trigger: Webhook cuando usuario hace click en feedback
- Acciones:
  1. Registrar feedback en `programa_feedback`
  2. Incrementar `sesiones_completadas_semana`
  3. Si quedan sesiones → Enviar siguiente sesión por email
  4. Si no quedan → Mostrar "Semana completada, domingo checkpoint"

**NOTA:** No hay envíos programados L/M/V. Las sesiones se envían bajo demanda cuando el usuario da feedback.

### 3. Integraciones

- **Brevo** - Emails transaccionales y listas
- **Stripe** - Pagos
- **OpenAI** - Generación de contenido personalizado

---

## 🔄 Flujo de Usuario Completo

### Semana 1

```
ANTES DEL PAGO:
└─ Usuario completa cuestionario → Lead guardado en DB
└─ Ve resultados personalizados
└─ Click "Empezar programa" → Stripe checkout

DESPUÉS DEL PAGO:
└─ Stripe webhook → Workflow 01
└─ Usuario activado
└─ Email de bienvenida + primera sesión recibido

DURANTE LA SEMANA (bajo demanda):
└─ Usuario hace ejercicios de la sesión
└─ Usuario hace click en feedback: Fácil/Bien/Difícil
└─ Workflow 03-bis procesa:
   ├─ Registra feedback
   ├─ Incrementa sesiones_completadas
   └─ Si quedan sesiones → Envía siguiente inmediatamente
       Si no quedan → "Semana completada, espera checkpoint"

DOMINGO 18:00:
└─ Workflow 06: Email checkpoint con resumen
└─ Usuario ve: adherencia, feedback, recomendación
└─ Usuario elige: 2, 3 o 4 sesiones para próxima semana
└─ Workflow 07 procesa elección
└─ Se aplican ajustes de nivel/intensidad
└─ Primera sesión de nueva semana generada
└─ Email con sesión enviado
└─ Ciclo se repite...
```

**IMPORTANTE:** No hay envíos programados L/M/V. El usuario controla su ritmo - cada vez que da feedback, recibe la siguiente sesión (si le quedan).

### Ejemplo de Adaptación

```
CASO 1: Usuario comprometido, ejercicios fáciles
├─ Adherencia: 100% (3/3 sesiones)
├─ Feedback: Mayoría "fácil"
├─ Resultado: Sube nivel + intensidad +10%
└─ Recomendación: 4 sesiones/semana

CASO 2: Usuario con dificultades
├─ Adherencia: 33% (1/3 sesiones)
├─ Feedback: "difícil"
├─ Resultado: Baja nivel + intensidad -10%
└─ Recomendación: 2 sesiones/semana

CASO 3: Usuario equilibrado
├─ Adherencia: 66% (2/3 sesiones)
├─ Feedback: "apropiado"
├─ Resultado: Mantiene nivel e intensidad
└─ Recomendación: 3 sesiones/semana
```

---

## 🛠️ Instalación y Configuración

### 1. Crear Base de Datos

```bash
# Conectar a PostgreSQL
psql -U n8n_user -d n8n

# Ejecutar schema
\i ~/Documents/HV_n8n/programa-camino-vital/database/schema.sql

# Cargar contenido de ejemplo
\i ~/Documents/HV_n8n/programa-camino-vital/database/seed-contenido.sql
```

### 2. Configurar Variables de Entorno

Añadir a `.env`:

```bash
# Brevo API
BREVO_API_KEY=xkeysib-tu_api_key_aqui

# Stripe Webhook Secret (opcional)
STRIPE_WEBHOOK_SECRET=whsec_tu_secret_aqui
```

### 3. Importar Workflows en n8n

```bash
# Importar workflows
1. Abrir n8n → Workflows → Import from File
2. Seleccionar: 01-onboarding.json
3. Repetir para 02-envio-programado.json
4. Repetir para 03-feedback.json
```

### 4. Configurar Webhooks

**URL Base:** `https://n8n.habitos-vitales.com/webhook/`

- Pago: `/camino-vital-pago` (POST desde Stripe)
- Cuestionario: `/cuestionario-inicial` (GET y POST)
- Feedback: `/feedback?user_id=X&tipo=Y&respuesta=Z` (GET)

### 5. Configurar Stripe

En el dashboard de Stripe:
1. Webhooks → Add endpoint
2. URL: `https://n8n.habitos-vitales.com/webhook/camino-vital-pago`
3. Events: `checkout.session.completed`

---

## 📊 Sistema Adaptativo

### Matriz de Decisión

El sistema usa una matriz que combina **adherencia** (sesiones completadas) y **feedback** (dificultad percibida):

| Adherencia | Feedback | Acción Nivel | Δ Intensidad |
|------------|----------|--------------|--------------|
| Alta (100%) | Fácil | subir_mucho | +10% |
| Alta | Apropiado | subir | +5% |
| Alta | Difícil | mantener | 0% |
| Media (66-99%) | Fácil | subir | +5% |
| Media | Apropiado | mantener | 0% |
| Media | Difícil | bajar | -5% |
| Baja (≤33%) | Fácil | mantener | 0% |
| Baja | Apropiado | bajar | -5% |
| Baja | Difícil | bajar_mucho | -10% |

### Niveles e Intensidad

**Niveles:** iniciacion → intermedio → avanzado

**Intensidad:** 50% - 100% (afecta la dificultad de sesiones generadas por IA)

### Elección del Usuario

El usuario elige cuántas sesiones quiere hacer cada semana (2, 3 o 4) durante el checkpoint dominical. El sistema recomienda basándose en el análisis, pero la decisión final es del usuario.

---

## 🎨 Generación de Contenido con IA

### Sesiones Personalizadas

El sistema genera sesiones usando OpenAI, adaptadas al perfil del usuario:

- **Nivel:** iniciacion / intermedio / avanzado
- **Intensidad:** 50-100%
- **Limitaciones físicas:** del perfil_inicial
- **Objetivo:** movilidad / fuerza / confianza / autonomia

### Prompt de Generación

El workflow 09 envía a OpenAI:
1. Datos del usuario (nivel, intensidad, perfil)
2. Semana y número de sesión
3. Instrucciones para generar ejercicios apropiados

### Almacenamiento

Las sesiones generadas se guardan en `programa_sesiones` con:
- Contenido JSON de ejercicios
- Parámetros de generación
- Estado de envío

---

## 📈 Monitorización

### Métricas Clave

```sql
-- Usuarios activos
SELECT COUNT(*) FROM programa_users WHERE estado = 'activo';

-- Tasa de respuesta promedio
SELECT AVG(tasa_respuesta) FROM programa_users WHERE estado = 'activo';

-- Distribución de niveles
SELECT nivel_actual, COUNT(*)
FROM programa_users
WHERE estado = 'activo'
GROUP BY nivel_actual;

-- Feedback reciente
SELECT tipo_feedback, respuesta, COUNT(*)
FROM programa_feedback
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY tipo_feedback, respuesta;

-- Usuarios sin responder últimos 3 envíos
SELECT email, nombre, envios_totales, respuestas_totales
FROM programa_users
WHERE estado = 'activo'
  AND envios_totales >= 3
  AND (respuestas_totales = 0 OR tasa_respuesta < 20);
```

---

## 🚨 Troubleshooting

### Problema: Usuario no recibe emails

1. Verificar estado del usuario:
```sql
SELECT estado, fecha_ultimo_envio FROM programa_users WHERE email = 'usuario@email.com';
```

2. Verificar que existe contenido:
```sql
SELECT * FROM programa_contenido
WHERE etapa = 'base_vital'
AND nivel = 'iniciacion'
AND semana = 1;
```

3. Ver logs de n8n workflow

### Problema: Feedback no funciona

1. Verificar URL del botón en email
2. Comprobar que webhook está activo en n8n
3. Ver executions del workflow 03

---

## 🔮 Roadmap / Mejoras Futuras

### Fase 1 (MVP) ✅
- [x] Sistema base funcionando
- [x] Onboarding con Stripe
- [x] Guardar leads del cuestionario

### Fase 2 (Sistema Adaptativo) ✅
- [x] Checkpoint semanal con análisis de adherencia + feedback
- [x] Usuario elige sesiones por semana
- [x] Generación de sesiones con IA (OpenAI)
- [x] Matriz de decisión adaptativa
- [x] Idempotencia en procesamiento

### Fase 3 (En progreso)
- [ ] Integrar envío programado L/M/V con sesiones IA
- [ ] Probar feedback de sesión completo
- [ ] Primeros clientes de pago
- [ ] Stripe en modo Live

### Fase 4 (Futuro)
- [ ] Dashboard de métricas
- [ ] Sistema de notificaciones para inactivos
- [ ] Etapas adicionales (Fuerza Vital, Autonomía Vital)
- [ ] App móvil complementaria

---

## 📞 Soporte

- Email: hola@habitos-vitales.com
- Documentación: Este archivo y `docs/` folder
- Workflows: `workflows/`

---

**Creado por:** Hábitos Vitales
**Versión:** 2.0.0
**Última actualización:** Enero 2026
