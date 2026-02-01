# Mapa de Dependencias de Workflows - Camino Vital

Este documento describe las dependencias entre workflows, tablas de base de datos, APIs externas y recursos compartidos. **Consultar antes de modificar cualquier workflow.**

---

## Resumen Visual de Dependencias

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FLUJO PRINCIPAL DEL USUARIO                          │
└─────────────────────────────────────────────────────────────────────────────┘

Landing Page (Cuestionario)
        │
        ▼
┌───────────────────┐
│ 04-guardar-lead   │──────────► programa_users (estado: 'lead')
│ Webhook: POST     │            Brevo Lista: LEADS
│ /guardar-lead     │
└───────────────────┘
        │
        │ (usuario paga)
        ▼
┌───────────────────┐
│ 01-bis-onboarding │──────────► programa_users (estado: 'activo')
│ Webhook Stripe    │            Brevo Lista: USUARIOS_ACTIVOS
│ payment_intent    │
└───────────────────┘
        │
        ▼
┌───────────────────┐         ┌─────────────────────────┐
│ 01-bis-seleccionar│────────►│ Generador Sesion IA     │
│ Webhook: POST     │         │ Webhook: POST           │
│ /seleccionar-ses  │         │ /generar-sesion-ia      │
└───────────────────┘         └────────────┬────────────┘
        │                                  │
        │                                  ▼
        │                     ┌─────────────────────────┐
        │                     │ UTIL-enviar-email-brevo │
        │                     │ Webhook: POST           │
        │                     │ /util/enviar-email      │
        │                     └─────────────────────────┘
        │                                  ▲
        ▼                                  │
┌───────────────────┐                      │
│ 09 Mostrar Sesion │                      │
│ Webhook: GET      │                      │
│ /sesion/:id       │                      │
└───────────────────┘                      │
        │                                  │
        │ (usuario da feedback)            │
        ▼                                  │
┌───────────────────┐                      │
│ 03-bis-feedback   │──────────────────────┤
│ Webhook: POST     │                      │
│ /feedback-sesion  │                      │
└───────────────────┘                      │
        │                                  │
        │ (cada domingo)                   │
        ▼                                  │
┌───────────────────┐                      │
│ 06-checkpoint     │──────────────────────┤
│ Cron: Dom 18:00   │                      │
│ DOMINICAL         │                      │
└───────────────────┘                      │
        │                                  │
        │ (usuario elige sesiones)         │
        ▼                                  │
┌───────────────────┐                      │
│ 07-procesar       │──────────────────────┘
│ Webhook: GET      │
│ /checkpoint-sem   │
└───────────────────┘
```

---

## 1. Tablas de Base de Datos

### `programa_users`
**Tabla central del sistema. CAMBIOS AFECTAN A TODOS LOS WORKFLOWS.**

| Campo | Usado por Workflows | Notas |
|-------|---------------------|-------|
| `id` | TODOS | PK, referencia principal |
| `email` | 01, 04, 05, 06, 07, 09 | Unique, identificador de usuario |
| `nombre` | 01, 04, 05, 06, 07, 09, Generador | Para personalización |
| `estado` | 00, 01, 04, 05, 06, 07 | 'lead', 'activo', 'completado', 'pausado' |
| `nivel_actual` | 01, 03, 06, 07, 09, Generador | 'iniciacion', 'intermedio', 'avanzado' |
| `intensidad_nivel` | 03, 06, 07, Generador | 30-100 (porcentaje) |
| `volumen_extra` | Generador | 0-50 (porcentaje adicional) |
| `semana_actual` | 06, 07, Generador | 1-12 |
| `sesion_actual_dentro_semana` | 03, Generador | 1-5 |
| `sesiones_objetivo_semana` | 03, 06, 07, 09, Generador | 2-5 |
| `ajustado_esta_semana` | 03, 06 | Boolean, se resetea en 06 |
| `perfil_inicial` | 04, 05, Generador | JSONB con limitaciones |
| `auth_token` | 09 | Token de autenticación |
| `stripe_customer_id` | 01 | ID de Stripe |

### `programa_sesiones`
| Campo | Usado por Workflows | Notas |
|-------|---------------------|-------|
| `id` | 03, 07, 09 | PK |
| `user_id` | TODOS | FK a programa_users |
| `semana` | 03, 07, Generador | Número de semana |
| `numero_sesion` | 03, 07, 09, Generador | 1-5 dentro de semana |
| `enfoque` | Generador, 09 | 'fuerza' o 'cardio' |
| `calentamiento` | 09, Generador | JSONB con ejercicios |
| `trabajo_principal` | 09, Generador | JSONB con ejercicios |
| `completada` | 03, 09 | Boolean |

### `programa_feedback`
| Campo | Usado por Workflows | Notas |
|-------|---------------------|-------|
| `user_id` | 03, 06, 07 | FK |
| `sesion_id` | 03 | FK |
| `respuesta` | 03, 06, 07 | 'facil', 'adecuado', 'dificil', 'muy_dificil' |
| `semana` | 06, 07 | Para análisis semanal |

### `ejercicios_biblioteca`
| Campo | Usado por Workflows | Notas |
|-------|---------------------|-------|
| `nombre_archivo` | 08, 09, Generador | Clave única, nombre del video |
| `nombre_espanol` | 08, 09, Generador | Nombre traducido |
| `nivel` | 08, Generador | 'iniciacion', 'intermedio', 'avanzado' |
| `areas_cuerpo` | 08, Generador | Array de strings |
| `evitar_si_limitacion` | 08, Generador | Array de limitaciones |

### `email_templates`
| Campo | Usado por Workflows | Notas |
|-------|---------------------|-------|
| `nombre` | 06, 07, 09 | Identificador único |
| `html_template` | 06, 07, 09 | HTML con {{variables}} |

Templates activos:
- `checkpoint_semanal` - 06, 07
- `programa_completado` - 06, 07
- `email_checkpoint_nueva_semana` - 07
- `componente_banner_ajuste_subir` - 07
- `componente_banner_ajuste_bajar` - 07
- `css_base_habitos_vitales` - 09
- `pagina_sesion` - 09

### `configuracion`
| Key | Usado por Workflows | Notas |
|-----|---------------------|-------|
| `usuarios_activos_max` | 07-verificar-limite | JSON: {limite, activo} |

### `lista_espera`
| Campo | Usado por Workflows | Notas |
|-------|---------------------|-------|
| `email` | 07-verificar-limite | Unique |
| `stripe_payment_intent_id` | 07-verificar-limite | Para reembolsos |

---

## 2. Funciones PostgreSQL

⚠️ **CRÍTICO: Modificar estas funciones afecta múltiples workflows**

| Función | Workflows que la usan | Propósito |
|---------|----------------------|-----------|
| `analizar_semana_para_checkpoint(user_id)` | 06, 07 | Calcula adherencia, feedback mayoritario, acción recomendada |
| `procesar_checkpoint_interactivo(...)` | 07 | Aplica ajustes de nivel/intensidad |
| `registrar_envio(user_id, sesion_id)` | UTIL-enviar-email | Registra emails enviados |
| `procesar_feedback_y_proxima_sesion(...)` | 03-bis-feedback | Ajusta intensidad según feedback |

---

## 3. Webhooks (Endpoints)

| Endpoint | Workflow | Método | Llamado por |
|----------|----------|--------|-------------|
| `/guardar-lead` | 04-guardar-lead | POST | Landing page (cuestionario) |
| `/seleccionar-sesiones` | 01-bis-seleccionar | POST | Landing (post-pago) |
| `/feedback-sesion` | 03-bis-feedback | POST | Página de sesión |
| `/generar-sesion-ia` | Generador Sesion IA | POST | 01-bis, 03-bis, 07 |
| `/view-session/sesion/:id` | 09 Mostrar Sesión | GET | Emails de sesión |
| `/checkpoint-semanal` | 07-procesar-checkpoint | GET | Email checkpoint |
| `/util/enviar-email` | UTIL-enviar-email | POST | 03, 06, 07 |

---

## 4. Dependencias entre Workflows

### Workflows que LLAMAN a otros:

```
01-bis-seleccionar-sesiones
    └──► Generador Sesion IA (via HTTP POST /generar-sesion-ia)
    └──► UTIL-enviar-email (via HTTP POST /util/enviar-email)

03-bis-feedback-siguiente-sesion
    └──► Generador Sesion IA (via HTTP POST /generar-sesion-ia)
    └──► UTIL-enviar-email (via HTTP POST /util/enviar-email)

06-checkpoint-dominical
    └──► UTIL-enviar-email (via HTTP POST /util/enviar-email)

07-procesar-checkpoint-semanal
    └──► Generador Sesion IA (via HTTP POST /generar-sesion-ia)
    └──► UTIL-enviar-email (via HTTP POST /util/enviar-email)
```

### Workflows que son LLAMADOS (utilities):

| Workflow | Llamado por | Input esperado |
|----------|-------------|----------------|
| `Generador Sesion IA` | 01-bis, 03-bis, 07 | `{user_id: number}` |
| `UTIL-enviar-email` | 03-bis, 06, 07 | `{user_email, user_nombre, asunto, email_html, user_id?, sesion_id?}` |

---

## 5. Servicios Externos

### Brevo (Email)
| Lista ID | Nombre | Usado por |
|----------|--------|-----------|
| `BREVO_LIST_LEADS` | Leads sin pagar | 04-guardar-lead |
| `BREVO_LIST_USUARIOS_ACTIVOS` | Usuarios activos | 01-bis-onboarding |

| Endpoint | Usado por |
|----------|-----------|
| `/v3/contacts` | 01-bis, 04 |
| `/v3/smtp/email` | 05, UTIL-enviar-email |

### Stripe
| Evento | Workflow |
|--------|----------|
| `payment_intent.succeeded` | 01-bis-onboarding |

### Cloudflare Turnstile
| Endpoint | Workflow |
|----------|----------|
| `/turnstile/v0/siteverify` | 04-guardar-lead |

### Claude/Anthropic API
| Workflow | Modelo | Propósito |
|----------|--------|-----------|
| Generador Sesion IA | claude-sonnet-4-5 | Generar sesiones personalizadas |
| 08-clasificar-ejercicios | claude-sonnet-4-5 | Clasificar biblioteca ejercicios |

### Firebase Storage
| URL Base | Workflow | Contenido |
|----------|----------|-----------|
| `firebasestorage.googleapis.com/.../playfit-21e92` | 09-Mostrar-Sesion | Videos de ejercicios |

---

## 6. Variables de Entorno

| Variable | Workflows que la usan |
|----------|----------------------|
| `BREVO_API_KEY` | 01, 04, 05, UTIL-enviar-email |
| `BREVO_LIST_LEADS` | 04 |
| `BREVO_LIST_USUARIOS_ACTIVOS` | 01 |
| `WEBHOOK_URL` | 03, 06, 07, 09 |
| `SENDER_NAME` | UTIL-enviar-email |
| `SENDER_EMAIL` | UTIL-enviar-email |

---

## 7. Cronogramas (Triggers Temporales)

| Schedule | Workflow | Propósito |
|----------|----------|-----------|
| `0 10 * * *` (10:00 diario) | 05-remarketing | Emails a leads 3/7 días |
| `0 18 * * 0` (Dom 18:00) | 06-checkpoint | Checkpoint semanal |

---

## 8. Checklist de Impacto

### Si modificas `programa_users`:
- [ ] 04-guardar-lead: campos de INSERT
- [ ] 01-bis-onboarding: campos de UPDATE (estado)
- [ ] 05-remarketing: campos de SELECT
- [ ] 06-checkpoint: campos de SELECT/UPDATE
- [ ] 07-procesar: campos de SELECT/UPDATE
- [ ] 09-mostrar: campos de SELECT
- [ ] Generador IA: campos de SELECT

### Si modificas `programa_sesiones`:
- [ ] 03-bis-feedback: SELECT para validar
- [ ] 07-procesar: SELECT sesión generada
- [ ] 09-mostrar: SELECT completo
- [ ] Generador IA: INSERT nueva sesión

### Si modificas `email_templates`:
- [ ] 06-checkpoint: templates de checkpoint/completado
- [ ] 07-procesar: templates de nueva semana + banners
- [ ] 09-mostrar: templates de página sesión

### Si modificas `ejercicios_biblioteca`:
- [ ] 08-clasificar: INSERT/UPDATE masivo
- [ ] Generador IA: SELECT para prompts
- [ ] 09-mostrar: nombre_archivo para videos

### Si modificas funciones PostgreSQL:
- [ ] `analizar_semana_para_checkpoint`: 06, 07
- [ ] `procesar_checkpoint_interactivo`: 07
- [ ] `registrar_envio`: UTIL-enviar-email

---

## 9. Flujos Críticos

### Flujo de Onboarding (no romper!)
```
1. Usuario completa cuestionario → 04-guardar-lead
2. Usuario paga en Stripe → 01-bis-onboarding
3. Usuario selecciona sesiones → 01-bis-seleccionar
4. Se genera primera sesión → Generador IA
5. Usuario recibe email → UTIL-enviar-email
```

### Flujo Semanal (no romper!)
```
1. Domingo 18:00 → 06-checkpoint-dominical
2. Email con opciones → usuario
3. Usuario click → 07-procesar-checkpoint
4. Se genera nueva sesión → Generador IA
5. Email con sesión → UTIL-enviar-email
```

### Flujo de Feedback (no romper!)
```
1. Usuario completa sesión → 03-bis-feedback
2. Se registra feedback → programa_feedback
3. Si hay más sesiones → Generador IA
4. Email siguiente sesión → UTIL-enviar-email
```

---

## 10. Notas de Mantenimiento

### Campos sensibles (cambiar con cuidado):
- `estado` en programa_users: Usado para filtrar en múltiples queries
- `semana_actual`: Lógica de fin de programa depende de este valor
- `auth_token`: Sistema de autenticación para ver sesiones

### Templates con variables (mantener consistencia):
```
{{nombre}} {{semana_actual}} {{sesiones_completadas}}
{{sesiones_objetivo}} {{adherencia_porcentaje}}
{{nivel_actual}} {{intensidad}} {{mensaje_usuario}}
{{webhook_url}} {{user_id}} {{sesion_url}}
```

---

*Última actualización: 2026-02-01*
