# ✅ Sistema de Feedback Mejorado - Actualización Completada

**Fecha**: 2026-01-09
**Estado**: Listo para importar y probar

---

## Resumen de Cambios

Se ha implementado el nuevo sistema de feedback mejorado que reemplaza el sistema simple de "fácil/bien/difícil" por uno que captura:
1. **Completitud**: Si completaron la sesión o no
2. **Dificultad**: Si fue fácil, apropiado o difícil (solo para sesiones completadas)
3. **Razón**: Por qué no completaron (tiempo, dificultad, dolor)

---

## Archivos Actualizados

### 1. Workflow 09 - Mostrar Sesión ✅
**Archivo**: `Camino Vital - 09 Mostrar Sesión.json`

**Cambios**:
- ✅ SQL actualizado en "Obtener Sesión" para incluir `user_id`
- ✅ HTML de sesión reemplazado con 4 botones de feedback:
  - 😊 Fácil - Podría haber hecho más (`completa_facil`)
  - 💪 Apropiado - Nivel perfecto (`completa_bien`)
  - 😰 Difícil - Me costó pero lo logré (`completa_dificil`)
  - ⚠️ No pude completarla (enlace a landing page)
- ✅ Usa variable de entorno `WEBHOOK_URL` o localhost:5678 por defecto
- ✅ CSS mejorado con botones estilizados y responsive

**URLs de feedback**:
```
Casos felices (3 botones):
http://localhost:5678/webhook/sesion-completada?user_id=X&sesion=Y&feedback=completa_facil
http://localhost:5678/webhook/sesion-completada?user_id=X&sesion=Y&feedback=completa_bien
http://localhost:5678/webhook/sesion-completada?user_id=X&sesion=Y&feedback=completa_dificil

Problemas (landing page):
http://localhost:8080/feedback-problemas.html?user_id=X&sesion=Y
```

---

### 2. Workflow 03-bis - Feedback y Siguiente Sesión ✅
**Archivo**: `Camino Vital - 03-bis Feedback y Siguiente Sesión.json`

**Cambios**:
- ✅ Nodo "Registrar Feedback" actualizado con SQL que parsea el nuevo formato
- ✅ Usa CTE (Common Table Expression) para parsear el parámetro `feedback` en:
  - `completitud`: 'completa' | 'incompleta'
  - `respuesta`: 'facil' | 'apropiado' | 'dificil' | NULL
  - `razon_no_completar`: 'tiempo' | 'muy_dificil' | 'dolor' | NULL
- ✅ Inserta en las nuevas columnas de la tabla `programa_feedback`
- ✅ Página de respuesta actualizada (sin mostrar feedback específico)

**Mapeo de valores**:
```sql
'completa_facil' → completitud='completa', respuesta='facil'
'completa_bien' → completitud='completa', respuesta='apropiado'
'completa_dificil' → completitud='completa', respuesta='dificil'
'incompleta_tiempo' → completitud='incompleta', razon_no_completar='tiempo'
'incompleta_dificil' → completitud='incompleta', razon_no_completar='muy_dificil'
'dolor' → completitud='incompleta', razon_no_completar='dolor'
```

---

### 3. Landing Page - Feedback Problemas ✅
**Archivo**: `landing/feedback-problemas.html`

**Cambios**:
- ✅ Webhook URL actualizada de `/webhook/feedback` a `/webhook/sesion-completada`
- ✅ Añadido parámetro `sesion` en la llamada al webhook
- ✅ 3 botones para casos problemáticos:
  - ⏰ No tuve tiempo (`incompleta_tiempo`)
  - 😓 Fue muy difícil (`incompleta_dificil`)
  - 🤕 Sentí molestia física (`dolor`)

---

## Base de Datos

Las columnas ya fueron añadidas previamente:
```sql
ALTER TABLE programa_feedback
ADD COLUMN IF NOT EXISTS completitud VARCHAR(50),
ADD COLUMN IF NOT EXISTS razon_no_completar VARCHAR(50);
```

Verificado con:
```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'camino_vital'
AND table_name = 'programa_feedback';
```

---

## Instrucciones de Implementación

### Paso 1: Importar Workflows en n8n

1. **Abrir n8n** en `http://localhost:5678`

2. **Importar Workflow 09**:
   - Ir a Workflows → Import from File
   - Seleccionar: `workflows/Camino Vital - 09 Mostrar Sesión.json`
   - Si existe workflow anterior, sobrescribirlo o borrarlo primero
   - Activar el workflow

3. **Importar Workflow 03-bis**:
   - Ir a Workflows → Import from File
   - Seleccionar: `workflows/Camino Vital - 03-bis Feedback y Siguiente Sesión.json`
   - Si existe workflow anterior, sobrescribirlo o borrarlo primero
   - Activar el workflow

### Paso 2: Servir Landing Page

```bash
cd /Users/albertvillanueva/Documents/HV_n8n/programa-camino-vital/landing
python3 -m http.server 8080
```

Esto servirá la landing page en `http://localhost:8080`

### Paso 3: Probar Flujo Completo

#### Test 1: Feedback "Fácil"
1. Abrir la sesión del usuario en el navegador
2. Hacer scroll hasta abajo
3. Click en "😊 Fácil - Podría haber hecho más"
4. **Verificar**:
   - Redirige a página de confirmación
   - Registro en `programa_feedback` con `completitud='completa'`, `respuesta='facil'`
   - Usuario recibe email con siguiente sesión

#### Test 2: Feedback "Apropiado"
1. Click en "💪 Apropiado - Nivel perfecto"
2. **Verificar**:
   - Página de confirmación
   - Registro con `completitud='completa'`, `respuesta='apropiado'`
   - Email siguiente sesión

#### Test 3: Feedback "Difícil"
1. Click en "😰 Difícil - Me costó pero lo logré"
2. **Verificar**:
   - Página de confirmación
   - Registro con `completitud='completa'`, `respuesta='dificil'`
   - Email siguiente sesión

#### Test 4: No pudo completar
1. Click en "⚠️ No pude completarla"
2. **Verificar**:
   - Redirige a `http://localhost:8080/feedback-problemas.html`
   - Muestra 3 opciones
3. Seleccionar una opción (ej: "😓 Fue muy difícil")
4. **Verificar**:
   - Página de confirmación
   - Registro con `completitud='incompleta'`, `razon_no_completar='muy_dificil'`
   - Email siguiente sesión

### Verificar en Base de Datos

```sql
SET search_path TO camino_vital;

-- Ver últimos feedbacks
SELECT
  id,
  user_id,
  sesion_numero,
  completitud,
  respuesta,
  razon_no_completar,
  accion_tomada,
  fecha_feedback
FROM programa_feedback
ORDER BY fecha_feedback DESC
LIMIT 10;
```

---

## URLs Importantes

### Webhooks
- **Local**: `http://localhost:5678/webhook/sesion-completada`
- **Producción**: `https://n8n.habitos-vitales.com/webhook/sesion-completada`

### Landing Pages
- **Local**: `http://localhost:8080/feedback-problemas.html`
- **Producción**: `https://camino-vital.habitos-vitales.com/feedback-problemas.html`

### Visualizar Sesión
```
http://localhost:5678/webhook/view-session/sesion/[SESION_ID]?token=[AUTH_TOKEN]
```

---

## Diferencias vs Sistema Anterior

### Antes:
- 1 pregunta simple: "¿Cómo te fue?"
- 3 opciones: Fácil / Bien / Difícil
- Ambigüedad: "Difícil" podía significar 4 cosas diferentes
- No sabíamos si completaron la sesión

### Ahora:
- 2 preguntas implícitas en 4 botones
- Sabemos si completó la sesión (80% casos felices)
- Si no completó, sabemos el motivo exacto
- Datos más útiles para ajustar dificultad

---

## Próximos Pasos (Futuro)

Una vez que este sistema esté funcionando y recolectando datos:

1. **Implementar Sistema de Progresión Adaptativa**:
   - Analizar feedback cada 3 sesiones
   - Ajustar parámetros de dificultad (JSONB en `programa_users`)
   - Generar mensajes transparentes al usuario
   - Ver: `SISTEMA-PROGRESION-COMPLETO.md`

2. **Análisis de Datos**:
   - Identificar patrones de abandono
   - Calcular tasa de completitud por nivel
   - Ajustar contenido según feedback

3. **Migrar a Producción**:
   - Actualizar URLs de landing pages
   - Configurar variable `WEBHOOK_URL` en n8n producción
   - Servir landing en dominio de producción

---

## Backups Creados

Por si necesitas revertir cambios:
- `Camino Vital - 09 Mostrar Sesión-BACKUP.json`

---

**Estado Final**: ✅ Todos los archivos actualizados y listos para testing
**Autor**: Claude Code
**Revisión necesaria**: Sí - testing completo del flujo
