# Sistema de Checkpoint Semanal Adaptativo

> Documentación del sistema de checkpoint interactivo que analiza el rendimiento semanal del usuario y permite elegir la configuración de la siguiente semana.

## Resumen

El sistema de checkpoint se ejecuta cada domingo y:
1. Analiza la adherencia y feedback del usuario durante la semana
2. Calcula una recomendación personalizada (subir/mantener/bajar intensidad)
3. Envía un email interactivo donde el usuario elige cuántas sesiones quiere hacer
4. Procesa la elección, aplica ajustes y genera la primera sesión de la nueva semana

---

## Flujo General

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DOMINGO 18:00 (Cron)                                │
│                                                                             │
│  Workflow 06: Checkpoint Dominical                                          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │ Resetear    │───▶│ Obtener     │───▶│ Obtener     │───▶│ Preparar    │  │
│  │ flags       │    │ usuarios    │    │ templates   │    │ email       │  │
│  │ semanales   │    │ activos     │    │             │    │ (checkpoint │  │
│  └─────────────┘    └─────────────┘    └─────────────┘    │ o fin)      │  │
│                                                           └──────┬──────┘  │
│                                                                  │          │
│  ┌─────────────┐    ┌─────────────┐                              │          │
│  │ Marcar      │◀───│ IF semana   │◀─────────────────────────────┘          │
│  │ completado  │    │ 12?         │                                         │
│  │ (si aplica) │    │             │                                         │
│  └─────────────┘    └─────────────┘                                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     USUARIO HACE CLIC EN EMAIL                              │
│                                                                             │
│  URL: /webhook/checkpoint-semanal?user_id=X&sesiones=N&token=XXX           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     Workflow 07: Procesar Checkpoint                        │
│                                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │
│  │ Procesar    │───▶│ IF: ¿Ya     │───▶│ Responder   │  (INMEDIATO)       │
│  │ checkpoint  │    │ procesado?  │    │ HTML        │────────────────┐    │
│  │ interactivo │    │             │    │ confirmación│                │    │
│  └─────────────┘    └─────────────┘    └─────────────┘                │    │
│                           │ (Sí)                                      │    │
│                           ▼                                           ▼    │
│                     ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│                     │ Responder   │    │ Generar     │───▶│ Enviar      │  │
│                     │ HTML "Ya    │    │ sesión IA   │    │ email con   │  │
│                     │ procesado"  │    │ (background)│    │ sesión      │  │
│                     └─────────────┘    └─────────────┘    └─────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Matriz de Decisión Adaptativa

El sistema usa una matriz que combina **adherencia** (sesiones completadas) y **feedback** (dificultad percibida):

### Niveles de Adherencia
| Nivel | Porcentaje | Descripción |
|-------|------------|-------------|
| Alta | 100% | Completó todas las sesiones objetivo |
| Media | 66-99% | Completó la mayoría |
| Baja | ≤33% | Completó pocas o ninguna |

### Matriz Completa

| Adherencia | Feedback | Acción Nivel | Δ Intensidad | Sesiones Recomendadas |
|------------|----------|--------------|--------------|----------------------|
| **Alta** | Fácil | subir_mucho | +10% | +1 sesión |
| **Alta** | Apropiado | subir | +5% | mantener |
| **Alta** | Difícil | mantener | 0% | mantener |
| **Media** | Fácil | subir | +5% | mantener |
| **Media** | Apropiado | mantener | 0% | mantener |
| **Media** | Difícil | bajar | -5% | mantener |
| **Baja** | Fácil | mantener | 0% | -1 sesión |
| **Baja** | Apropiado | bajar | -5% | -1 sesión |
| **Baja** | Difícil | bajar_mucho | -10% | -1 sesión |

### Progresión de Niveles
```
iniciacion ──subir──▶ intermedio ──subir──▶ avanzado
     ◀──bajar──           ◀──bajar──
```

### Límites de Intensidad
- **Mínimo:** 50%
- **Máximo:** 100%

---

## Funciones SQL

### 1. `analizar_semana_para_checkpoint(user_id)`

Analiza el rendimiento de la semana y devuelve recomendaciones.

**Entrada:**
- `p_user_id INTEGER` - ID del usuario

**Salida:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| out_user_id | INTEGER | ID del usuario |
| out_email | VARCHAR | Email del usuario |
| out_nombre | VARCHAR | Nombre del usuario |
| out_nivel_actual | VARCHAR | Nivel actual (iniciacion/intermedio/avanzado) |
| out_semana_actual | INTEGER | Semana actual |
| out_sesiones_objetivo | INTEGER | Sesiones objetivo de la semana |
| out_sesiones_completadas | INTEGER | Sesiones completadas |
| out_intensidad_actual | INTEGER | Intensidad actual (%) |
| adherencia_porcentaje | INTEGER | % de adherencia (0-100) |
| adherencia_nivel | VARCHAR | Clasificación (alta/media/baja) |
| feedback_mayoritario | VARCHAR | Feedback más común (facil/apropiado/dificil/mixto/sin_datos) |
| accion_nivel | VARCHAR | Acción recomendada (subir_mucho/subir/mantener/bajar/bajar_mucho) |
| accion_intensidad | INTEGER | Delta de intensidad (-10 a +10) |
| sesiones_recomendadas | INTEGER | Sesiones recomendadas para siguiente semana |
| mensaje_usuario | TEXT | Mensaje personalizado para el email |
| explicacion_corta | TEXT | Explicación breve del ajuste |

**Ejemplo de uso:**
```sql
SELECT * FROM analizar_semana_para_checkpoint(1);
```

---

### 2. `procesar_checkpoint_interactivo(...)`

Procesa el checkpoint aplicando los ajustes y la elección del usuario.

**Entrada:**
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| p_user_id | INTEGER | ID del usuario |
| p_sesiones_elegidas | INTEGER | Sesiones elegidas por el usuario (2-5) |
| p_accion_nivel | VARCHAR | Acción de nivel del análisis |
| p_delta_intensidad | INTEGER | Cambio de intensidad del análisis |
| p_adherencia_nivel | VARCHAR | Nivel de adherencia |
| p_feedback_mayoritario | VARCHAR | Feedback mayoritario |
| p_explicacion | VARCHAR | Explicación del ajuste |

**Comportamiento:**
1. Verifica si `ajustado_esta_semana = TRUE` (idempotencia)
2. Si NO está procesado:
   - Aplica cambio de nivel si corresponde
   - Aplica delta de intensidad (respetando límites 50-100)
   - Incrementa semana_actual
   - Actualiza sesiones_objetivo_semana con elección del usuario
   - Resetea sesiones_completadas_semana a 0
   - Marca ajustado_esta_semana = TRUE
3. Devuelve estado actual del usuario con `estado_checkpoint` ('nuevo' o 'ya_procesado')

**Ejemplo de uso:**
```sql
SELECT * FROM procesar_checkpoint_interactivo(
  1,           -- user_id
  4,           -- sesiones elegidas
  'subir',     -- accion_nivel
  5,           -- delta_intensidad
  'alta',      -- adherencia_nivel
  'apropiado', -- feedback_mayoritario
  'Progresión gradual'  -- explicacion
);
```

---

## Workflows n8n

### Workflow 06: Checkpoint Dominical

**Trigger:** Cron cada domingo a las 18:00

**Nodos principales:**
1. **Cron** - Dispara el workflow
2. **Resetear Flag Semanal** - Resetea `ajustado_esta_semana = FALSE` para todos los usuarios activos
3. **Obtener Usuarios Activos** - Consulta usuarios activos (semanas 1-12)
4. **Obtener Template Email** - Obtiene template `checkpoint_semanal`
5. **Obtener Template Fin Programa** - Obtiene template `programa_completado`
6. **Preparar Email Checkpoint** - Genera HTML según semana:
   - **Semanas 1-11:** Resumen + botones para elegir sesiones
   - **Semana 12:** Email de fin de programa (sin botones)
7. **Enviar vía UTIL Email** - Envía el email
8. **IF es_fin_programa** - Detecta si el usuario está en semana 12
9. **Marcar Usuario Completado** - Actualiza `estado = 'completado'`

**Nota importante:** Los nodos de obtención de templates deben ejecutarse en **serie** (no paralelo) para evitar errores de "Node hasn't been executed".

**Estructura del Email:**
```
┌────────────────────────────────────────────┐
│  📊 Tu resumen de la semana               │
│  ────────────────────────────────────────  │
│  Sesiones completadas: 3/3                │
│  Adherencia: 100% ✅                       │
│  Tu feedback: La mayoría "apropiado"      │
├────────────────────────────────────────────┤
│  💪 ¡Perfecta semana!                     │
│  [Mensaje personalizado según análisis]   │
├────────────────────────────────────────────┤
│  ¿Cuántas sesiones quieres hacer?         │
│                                            │
│  [2 sesiones] [3 sesiones ✓] [4 sesiones] │
│               (Recomendado)                │
└────────────────────────────────────────────┘
```

---

### Workflow 07: Procesar Checkpoint Semanal

**Trigger:** Webhook GET `/webhook/checkpoint-semanal`

**Parámetros URL:**
- `user_id` - ID del usuario
- `sesiones` - Número de sesiones elegidas (2, 3 o 4)
- `token` - Token de autenticación

**Nodos principales:**
1. **Webhook Checkpoint Semanal** - Recibe la petición
2. **Procesar Checkpoint Interactivo** - Aplica ajustes y elección del usuario
3. **IF: ¿Checkpoint ya procesado?** - Verifica `estado_checkpoint`
   - **TRUE →** Responde HTML "Ya procesamos tu checkpoint"
   - **FALSE →** Responde HTML "¡Elección confirmada!" **inmediatamente**
4. **Llamar Generador Sesión IA** - Genera primera sesión de nueva semana (después de responder)
5. **Enviar Email vía UTIL** - Envía email con la sesión

**Patrón de respuesta inmediata:**
El workflow responde al usuario **antes** de generar la sesión con IA, evitando que el usuario espere. La generación y envío del email ocurren en background.

**Cabeceras de respuesta:**
```
Content-Type: text/html; charset=utf-8
```

**Página de Confirmación:**
```
┌────────────────────────────────────────────┐
│  🎉 ¡Perfecto, [Nombre]!                  │
│                                            │
│  Tu configuración para la Semana X        │
│  ────────────────────────────────────────  │
│  📊 Nivel: INTERMEDIO                     │
│  ⚡ Intensidad: 65%                        │
│  📅 Sesiones/semana: 4                    │
│                                            │
│  📬 Revisa tu email                       │
│  Ya te hemos enviado la primera sesión    │
└────────────────────────────────────────────┘
```

---

## Base de Datos

### Campos relevantes en `programa_users`

| Campo | Tipo | Descripción |
|-------|------|-------------|
| nivel_actual | VARCHAR | 'iniciacion', 'intermedio', 'avanzado' |
| intensidad_nivel | INTEGER | 50-100 (%) |
| semana_actual | INTEGER | Número de semana en el programa |
| sesiones_objetivo_semana | INTEGER | Sesiones objetivo (2-5) |
| sesiones_completadas_semana | INTEGER | Sesiones completadas esta semana |
| ajustado_esta_semana | BOOLEAN | TRUE si ya se procesó checkpoint |

### Tabla `programa_feedback`

El análisis usa feedback de tipo `'sesion_completada'` con respuestas:
- `'facil'` - La sesión fue fácil
- `'apropiado'` - La sesión fue adecuada
- `'dificil'` - La sesión fue difícil

---

## Reset Semanal

El campo `ajustado_esta_semana` debe resetearse a `FALSE` cada semana para permitir un nuevo checkpoint.

**Implementación actual:** El reset se hace al **inicio del Workflow 06** (domingo 18:00), justo antes de obtener usuarios. Esto garantiza que todos los usuarios activos reciban el email de checkpoint cada domingo.

```sql
-- Nodo "Resetear Flag Semanal" en Workflow 06
UPDATE programa_users
SET ajustado_esta_semana = FALSE
WHERE estado = 'activo'
  AND ajustado_esta_semana = TRUE
RETURNING id, email, 'flag reseteado' as accion;
```

**Nota técnica:** Este nodo usa `alwaysOutputData: true` para continuar el flujo aunque no haya usuarios que resetear.

---

## Fin del Programa (Semana 12)

Cuando un usuario llega a la semana 12, el sistema detecta que ha completado el programa:

### Workflow 06 - Detección y Email Especial
```javascript
// En nodo "Preparar Email Checkpoint"
if (usuario.semana_actual === 12) {
  // Usa template 'programa_completado' (sin botones)
  // Marca es_fin_programa: true en output
}
```

### Email de Fin de Programa
- **Template:** `programa_completado` (en tabla `email_templates`)
- **Sin botones ni enlaces** - Solo mensaje de felicitación
- **Branding correcto:** "Camino Vital" (no "Base Vital")
- **Mensaje:** Agradecimiento + aviso de futuro programa avanzado

### Marcado de Usuario Completado
```sql
-- Nodo "Marcar Usuario Completado" (si es_fin_programa = true)
UPDATE programa_users
SET estado = 'completado'
WHERE id = :user_id;
```

---

## Pruebas

### Test 1: Usuario ya procesado
```bash
# Usuario con ajustado_esta_semana = TRUE
curl "http://localhost:5678/webhook/checkpoint-semanal?user_id=1&sesiones=3&token=test"
# Resultado: Página "Ya procesamos tu checkpoint"
```

### Test 2: Checkpoint nuevo
```bash
# Resetear usuario
psql -c "UPDATE programa_users SET ajustado_esta_semana = FALSE WHERE id = 1;"

# Procesar checkpoint con elección de 4 sesiones
curl "http://localhost:5678/webhook/checkpoint-semanal?user_id=1&sesiones=4&token=test"
# Resultado: Página "¡Elección confirmada!" + email con sesión
```

### Verificar resultado
```sql
SELECT nivel_actual, intensidad_nivel, semana_actual, sesiones_objetivo_semana
FROM programa_users WHERE id = 1;
```

---

## Consideraciones de Diseño

### ¿Por qué el usuario elige las sesiones?

> "No sabemos los compromisos personales que puede tener el usuario y al final es mejor que pueda elegir"

El sistema **recomienda** un número de sesiones basado en el análisis, pero la **decisión final es del usuario**. Esto:
- Respeta la autonomía del usuario
- Evita frustraciones por objetivos inalcanzables
- Aumenta el compromiso al ser una elección consciente

### ¿Por qué considerar adherencia además de feedback?

> "Por muy fácil que lo encuentre un usuario, si hace una sesión solo a la semana, ¿cómo va a progresar?"

La adherencia es fundamental porque:
- Un usuario que dice "fácil" pero solo hace 1/3 sesiones no debería progresar
- La consistencia es más importante que la intensidad percibida
- Reduce ajustes sobre usuarios poco comprometidos

### Idempotencia

El sistema es **idempotente**: si el usuario hace clic múltiples veces en el email:
- Solo se procesa la primera vez
- Las siguientes muestran "Ya procesamos tu checkpoint"
- No se generan sesiones duplicadas
