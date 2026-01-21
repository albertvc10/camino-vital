# Guía de Testing - Flujo Completo de Generación Personalizada

## 📋 Preparación

### 1. Importar Workflow 09 a n8n

1. Abre n8n: http://localhost:5678
2. Click en **"+"** (New workflow)
3. Click en **"..."** menú → **"Import from File"**
4. Selecciona: `workflows/09-mostrar-sesion.json`
5. **Guarda** el workflow
6. **Activa** el workflow (toggle en la parte superior)

### 2. Verificar Workflow 01-bis está actualizado

1. Abre el workflow **"01-bis Seleccionar Sesiones"**
2. Verifica que el nodo **"Preparar Prompt Claude"** tiene la matriz de distribución
3. **Guarda y activa** el workflow si no lo está

---

## 🧪 Test 1: Generar Primera Sesión

### Paso 1: Simular selección de sesiones

Abre en el navegador (sustituye `USER_ID` por un ID real de tu DB):
```
http://localhost:5678/webhook/seleccionar-sesiones?user_id=1&sesiones=3
```

### Qué debe pasar:

1. ✅ **Página de confirmación** se muestra
   - Dice: "Has elegido hacer 3 sesiones esta semana"
   - Indica que el email está en camino

2. ✅ **Email recibido** (revisa bandeja del usuario)
   - Asunto: "Tu Sesión 1 de 3: [Título generado]"
   - Contiene introducción personalizada
   - Muestra resumen de la sesión
   - Tiene botón grande: "VER MI SESIÓN COMPLETA"

3. ✅ **Base de datos actualizada**
   ```sql
   -- Verifica en Adminer (http://localhost:8080)
   SELECT * FROM camino_vital.programa_sesiones
   WHERE user_id = 1
   ORDER BY created_at DESC
   LIMIT 1;
   ```

   Debe mostrar:
   - `titulo`: Título generado por Claude
   - `enfoque`: "movilidad", "fuerza", "cardio" o "equilibrio" (según matriz)
   - `calentamiento`: JSON con 2 ejercicios
   - `trabajo_principal`: JSON con 4-6 ejercicios
   - `numero_sesion`: 1

### Logs a revisar en n8n:

1. Abre workflow 01-bis → Click en **"Executions"**
2. Busca la última ejecución
3. Revisa el nodo **"Preparar Prompt Claude"**:
   - Debe mostrar en consola: `🎯 Objetivo: X → Tipo de sesión: Y`
   - Debe mostrar: `📅 Sesión 1 de 3`
   - Debe mostrar: `📋 Patrón completo: [tipo1, tipo2, tipo3]`

---

## 🧪 Test 2: Ver Sesión en el Navegador

### Paso 2: Click en el link del email

1. Abre el email recibido
2. Click en el botón **"VER MI SESIÓN COMPLETA"**
3. Se abre una página en el navegador

### Qué debe pasar:

1. ✅ **Página HTML carga correctamente**
   - Header morado con título de la sesión
   - Icono según enfoque (💪 fuerza, 🧘 movilidad, ❤️ cardio, ⚖️ equilibrio)
   - Metadatos: duración, nivel, enfoque, sesión X de Y

2. ✅ **Introducción personalizada visible**
   - Fondo azul claro
   - Texto explicando por qué se eligieron estos ejercicios

3. ✅ **Sección Calentamiento**
   - 2 ejercicios con videos
   - Videos de Firebase Storage se cargan
   - Controles de video funcionan
   - Muestra repeticiones y duración

4. ✅ **Sección Trabajo Principal**
   - 4-6 ejercicios con videos
   - Cada ejercicio muestra consejos (si los hay)
   - Videos reproducibles

5. ✅ **Botón "He completado esta sesión"**
   - Visible al final
   - Por ahora muestra alert (funcionalidad pendiente)

### Debugging si algo falla:

#### Videos no cargan:
- Abre DevTools (F12) → Console
- Busca errores de CORS o 404
- Verifica que los `nombre_archivo` en DB coinciden con Firebase Storage

#### Sesión no encontrada (404):
- Verifica que el `sesion_id` en la URL existe en DB
- Revisa logs de workflow 09 en n8n

---

## 🧪 Test 3: Verificar Distribución de Tipos

### Paso 3: Generar múltiples sesiones

Para verificar que la matriz funciona, crea un usuario de prueba y genera varias sesiones:

```sql
-- En Adminer, crear usuario de prueba
SET search_path TO camino_vital;

INSERT INTO programa_users (
  nombre, email, nivel_actual, semana_actual,
  perfil_inicial, sesiones_objetivo_semana, sesion_actual_dentro_semana
) VALUES (
  'Test User',
  'test@example.com',
  'principiante',
  1,
  '{"objetivo_principal": "fuerza", "limitaciones": "", "nivel_movilidad": "buena"}',
  3,
  1
) RETURNING id;
```

Luego, para cada sesión (1, 2, 3):

1. Llama al webhook con ese user_id
2. Verifica el `enfoque` en la tabla `programa_sesiones`
3. Según la matriz, para objetivo "fuerza" + 3 sesiones debe ser:
   - Sesión 1: `fuerza`
   - Sesión 2: `cardio`
   - Sesión 3: `fuerza`

---

## 🧪 Test 4: Probar Diferentes Combinaciones

### Combinaciones a probar:

| Objetivo | Sesiones | Sesión 1 | Sesión 2 | Sesión 3 | Sesión 4 | Sesión 5 |
|----------|----------|----------|----------|----------|----------|----------|
| movilidad | 3 | movilidad | fuerza | movilidad | - | - |
| fuerza | 4 | fuerza | cardio | fuerza | movilidad | - |
| cardio | 2 | cardio | fuerza | - | - | - |
| equilibrio | 5 | equilibrio | fuerza | movilidad | cardio | equilibrio |

Para cada combinación:
1. Crea usuario con ese objetivo en `perfil_inicial`
2. Genera sesiones
3. Verifica que el `enfoque` coincide con la tabla

---

## ✅ Checklist Final

- [ ] Workflow 09 importado y activado
- [ ] Workflow 01-bis actualizado con matriz de distribución
- [ ] Email se recibe correctamente con link
- [ ] Página de sesión carga con videos funcionando
- [ ] Claude genera ejercicios apropiados para cada tipo
- [ ] Matriz de distribución asigna tipos correctamente
- [ ] Logs en n8n muestran el tipo de sesión generado
- [ ] HTML responsive en móvil (prueba desde smartphone)

---

## 🐛 Troubleshooting Común

### Error: "No se encontró JSON válido en la respuesta de Claude"
**Causa:** Claude devolvió texto adicional antes/después del JSON
**Solución:** El código ya tiene regex para extraer JSON, pero verifica en logs

### Error: "Sesión no encontrada"
**Causa:** El `sesion_id` no existe o hay error en la query
**Solución:** Verifica en Adminer que la sesión existe

### Videos no reproducen
**Causa:** Nombre de archivo incorrecto o token de Firebase expirado
**Solución:** Verifica en Firebase Console que los videos existen

### Email no llega
**Causa:** Límite de Brevo alcanzado o email mal formado
**Solución:** Revisa logs de Brevo en n8n, verifica cuota API

---

## 📊 Próximos Pasos (Después de Testing)

1. Implementar botón "Completar Sesión" (workflow 10)
2. Generar automáticamente la siguiente sesión al completar
3. Tracking de progreso del usuario
4. Dashboard de sesiones completadas

---

**¿Todo funcionó?** ¡Genial! Ya tienes el sistema completo de generación personalizada con distribución inteligente de tipos de sesión.

**¿Encontraste bugs?** Anótalos y los arreglamos juntos.
