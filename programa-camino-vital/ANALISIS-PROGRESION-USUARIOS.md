# 📊 Análisis: Sistema de Progresión de Usuarios

**Fecha**: 8 Enero 2026
**Estado**: Sistema funciona PERO no hay progresión automática

---

## 🔍 Estado Actual del Sistema

### Estructura de Datos (Base de Datos)

```sql
-- Campos relevantes en programa_users:
etapa: 'base_vital' (default)
nivel_actual: 'iniciacion' o 'intermedio' (default: 'iniciacion')
semana_actual: integer (default: 1)
sesiones_objetivo_semana: 3, 4 o 5 (default: 3)
sesiones_completadas_semana: integer (default: 0)
sesion_actual_dentro_semana: integer (default: 1)
semanas_consecutivas_completas: integer (default: 0)
```

### Usuarios Actuales (Ejemplo)

```
email                               | etapa      | nivel      | semana | sesiones_obj | completadas
------------------------------------+------------+------------+--------+--------------+-------------
test-activo@camino-vital.local      | base_vital | iniciacion | 2      | 3            | 0
test-intermedio@camino-vital.local  | base_vital | intermedio | 1      | 3            | 0
albertvc10@gmail.com                | base_vital | intermedio | 1      | 4            | 0
```

---

## ⚙️ Flujo Actual (Lo que SÍ funciona)

### 1. Usuario completa cuestionario
```
Cuestionario → Determina nivel basado en respuestas:
- Tiempo < 6 meses + Movilidad normal/buena → Intermedio (10 semanas)
- Resto de casos → Iniciación (12 semanas)

Se crea usuario con:
- nivel_actual: 'iniciacion' o 'intermedio'
- semana_actual: 1
- etapa: 'base_vital'
- estado: 'lead'
```

### 2. Usuario selecciona sesiones/semana
```
Email bienvenida → Click "3 sesiones" →
- estado: 'lead' → 'activo'
- sesiones_objetivo_semana: 3
- Envía primera sesión (Semana 1, Sesión 1)
```

### 3. Usuario completa sesión
```
Workflow: 03-bis Feedback y Siguiente Sesión

1. Usuario hace click "Sesión completada" (con feedback: fácil/bien/difícil)
2. Registrar feedback en programa_feedback
3. Actualizar usuario:
   - sesiones_completadas_semana += 1
   - sesion_actual_dentro_semana += 1
4. IF sesion_actual_dentro_semana <= sesiones_objetivo_semana:
   → Envía siguiente sesión de la MISMA semana
5. ELSE:
   → Mensaje: "¡Semana completada! Descansa hasta el domingo"
```

### 4. Checkpoint Dominical
```
Workflow: 06 Checkpoint Dominical
Cron: Cada domingo a las 18:00

1. Obtiene usuarios activos
2. Calcula porcentaje: sesiones_completadas / sesiones_objetivo
3. Envía email resumen:
   - "Has completado X de Y sesiones esta semana"
   - "Porcentaje: 67%" (con color según progreso)
   - Si racha ≥ 2 semanas: "🔥 ¡X semanas consecutivas!"
```

---

## ❌ Lo que NO funciona (El Problema)

### 🚨 NO HAY PROGRESIÓN AUTOMÁTICA

**Problemas identificados**:

1. ❌ **`semana_actual` NUNCA se incrementa**
   - Usuario se queda en semana 1 para siempre
   - Siempre recibe contenido de la misma semana

2. ❌ **`sesiones_completadas_semana` NUNCA se resetea**
   - Debería volver a 0 cada nueva semana
   - Actualmente se acumula indefinidamente

3. ❌ **`nivel_actual` NUNCA cambia**
   - Usuario en iniciación nunca pasa a intermedio
   - Usuario en intermedio nunca pasa a avanzado (si existe)

4. ❌ **`etapa` NUNCA cambia**
   - Todos se quedan en 'base_vital' para siempre
   - No hay progresión a siguientes etapas

5. ❌ **`semanas_consecutivas_completas` NUNCA se actualiza**
   - Se usa en checkpoint pero nunca se incrementa
   - Debería incrementarse si completó la semana (100%)

---

## 🎯 Cómo DEBERÍA Funcionar (Propuesta)

### Escenario: Usuario en Iniciación (12 semanas)

```
Semana 1:
- semana_actual: 1
- Completa 3/3 sesiones → Domingo checkpoint → "¡Semana 1 completada!"
- Lunes siguiente: semana_actual = 2, sesiones_completadas_semana = 0

Semana 2:
- semana_actual: 2
- Recibe sesiones de semana 2 (contenido diferente)
- Completa 3/3 sesiones → Domingo checkpoint → "¡Semana 2 completada!"
- semanas_consecutivas_completas: 2

...

Semana 12:
- semana_actual: 12
- Completa 3/3 sesiones → "¡Has completado Base Vital - Iniciación!"
- Siguiente paso: ¿cambiar a intermedio? ¿nueva etapa?
```

---

## 🤔 Decisiones de Diseño Necesarias

### 1. ¿Cuándo se cambia de semana?

**Opción A: Lunes automático (Recomendado)**
```
Checkpoint Dominical ejecuta:
1. Envía resumen semanal
2. Si completó todas las sesiones:
   - semanas_consecutivas_completas += 1
   - semana_actual += 1
   - sesiones_completadas_semana = 0
   - sesion_actual_dentro_semana = 1
3. Si NO completó:
   - semanas_consecutivas_completas = 0
   - Mantiene misma semana (repetir)
```

**Opción B: Solo si completó todas las sesiones**
```
- Si completa 3/3 → avanza inmediatamente a semana 2
- Si completa 2/3 → repite semana 1
- Más flexible pero más complejo
```

### 2. ¿Cuándo se cambia de nivel?

**Escenario**: Usuario en Iniciación (12 semanas)

```
OPCIÓN A - Automático al completar 12 semanas:
Semana 12 completada →
  nivel_actual: 'iniciacion' → 'intermedio'
  semana_actual: 1 (reset)
  Contenido: ahora recibe de "base_vital + intermedio + semana 1"

OPCIÓN B - Evaluación manual:
- Admin revisa progreso
- Decide si está listo para intermedio
- Cambio manual

OPCIÓN C - No cambia nunca:
- Iniciación: 12 semanas → Fin del programa
- Intermedio: 10 semanas → Fin del programa
- Cada nivel es un "producto" separado
```

### 3. ¿Qué pasa después de completar Iniciación?

```
OPCIÓN A - Pasa a Intermedio automáticamente:
Iniciación (12 semanas) → Intermedio (10 semanas) → Total 22 semanas

OPCIÓN B - Fin del programa:
Iniciación (12 semanas) → Fin
Usuario puede recomprar "Nivel Intermedio" como producto separado

OPCIÓN C - Nueva etapa:
Base Vital Iniciación (12 semanas) →
Fuerza Funcional Iniciación (8 semanas) →
Movilidad Avanzada (10 semanas) →
...
```

### 4. ¿Qué pasa si NO completa todas las sesiones?

```
OPCIÓN A - Repite la semana:
- Si completa 2/3 sesiones → Mantiene semana_actual = X
- Siguiente semana recibe las mismas sesiones
- semanas_consecutivas_completas = 0

OPCIÓN B - Avanza de todas formas:
- Aunque complete solo 1/3 → semana_actual += 1
- Más "indulgente"

OPCIÓN C - Pausa automática:
- Si 2 semanas consecutivas <50% → estado: 'pausado'
- Envía email: "¿Quieres continuar?"
```

---

## 📋 Contenido en Base de Datos

Necesito verificar: **¿Tienes contenido para múltiples semanas?**

```sql
SELECT etapa, nivel, semana, COUNT(*) as ejercicios_disponibles
FROM programa_contenido
GROUP BY etapa, nivel, semana
ORDER BY etapa, nivel, semana;
```

**Si SÍ tienes**:
```
base_vital | iniciacion | 1 | 5 ejercicios
base_vital | iniciacion | 2 | 5 ejercicios
base_vital | iniciacion | 3 | 5 ejercicios
...
base_vital | intermedio | 1 | 6 ejercicios
base_vital | intermedio | 2 | 6 ejercicios
```

**Si NO tienes**:
```
base_vital | iniciacion | 1 | 5 ejercicios
base_vital | intermedio | 1 | 6 ejercicios
```

Entonces primero necesitas generar contenido para las 12/10 semanas antes de implementar progresión.

---

## 🛠️ Implementación Propuesta (Opción A - Automática)

### Cambio 1: Modificar Checkpoint Dominical

```sql
-- Al final del checkpoint, añadir:
SET search_path TO camino_vital;

UPDATE programa_users
SET
  -- Si completó todas las sesiones → avanza
  semana_actual = CASE
    WHEN sesiones_completadas_semana >= sesiones_objetivo_semana
    THEN semana_actual + 1
    ELSE semana_actual  -- Repite la semana
  END,

  -- Actualizar racha
  semanas_consecutivas_completas = CASE
    WHEN sesiones_completadas_semana >= sesiones_objetivo_semana
    THEN semanas_consecutivas_completas + 1
    ELSE 0  -- Se rompe la racha
  END,

  -- Resetear contadores semanales
  sesiones_completadas_semana = 0,
  sesion_actual_dentro_semana = 1,

  -- Cambiar nivel si completó todas las semanas de iniciación
  nivel_actual = CASE
    WHEN nivel_actual = 'iniciacion' AND semana_actual >= 12 AND sesiones_completadas_semana >= sesiones_objetivo_semana
    THEN 'intermedio'
    WHEN nivel_actual = 'intermedio' AND semana_actual >= 10 AND sesiones_completadas_semana >= sesiones_objetivo_semana
    THEN 'avanzado'  -- O marcar como completado
    ELSE nivel_actual
  END,

  -- Resetear semana si cambió de nivel
  semana_actual = CASE
    WHEN (nivel_actual = 'iniciacion' AND semana_actual >= 12)
      OR (nivel_actual = 'intermedio' AND semana_actual >= 10)
    THEN 1
    ELSE semana_actual
  END

WHERE estado = 'activo';
```

### Cambio 2: Email cuando cambia de nivel

```
Si nivel_actual cambió de 'iniciacion' → 'intermedio':
  Enviar email especial:
  "🎉 ¡Felicidades! Has completado Iniciación
   La próxima semana comenzarás nivel Intermedio"
```

---

## ❓ Preguntas para Decidir Implementación

1. **¿Tienes contenido para múltiples semanas?**
   - Sí → ¿Cuántas semanas de cada nivel?
   - No → Hay que generarlo primero

2. **¿Cuándo debe avanzar de semana?**
   - Cada lunes automáticamente (haya completado o no)
   - Solo si completó todas las sesiones
   - Otra lógica

3. **Si NO completa todas las sesiones, ¿qué pasa?**
   - Repite la semana
   - Avanza de todas formas
   - Se pausa automáticamente

4. **Después de completar Iniciación (12 semanas), ¿qué pasa?**
   - Pasa automáticamente a Intermedio
   - Fin del programa (puede recomprar Intermedio)
   - Pasa a otra etapa diferente

5. **¿Quieres que sea automático o con revisión manual?**
   - Todo automático (usuario progresa solo)
   - Admin revisa y aprueba cambios de nivel

---

## 🎯 Recomendación Inmediata

**Mi sugerencia**:

1. **Primero**: Genera contenido para las 12 semanas de iniciación y 10 de intermedio
2. **Segundo**: Implementa progresión automática simple:
   - Cada lunes → semana += 1 (si completó sesiones)
   - Semana 13 de iniciación → cambia a intermedio
   - Semana 11 de intermedio → marca como "completado"
3. **Tercero**: Añade email especial cuando completa un nivel

**¿Por qué?**
- Simple de implementar (1 modificación en checkpoint dominical)
- Predecible para el usuario
- Escalable (fácil de ajustar después)
- No requiere intervención manual

---

**Estado**: Esperando tus respuestas para implementar la progresión
