# ✅ Workflows Actualizados para Sistema de Feedback Mejorado

## Archivos Modificados

### ✅ PRODUCCIÓN (para servidor remoto):
1. `workflows/02-envio-programado.json` ✅ Actualizado
2. `workflows/03-feedback.json` ✅ Actualizado

### ✅ LOCAL/TEST (para testing en localhost):
3. `workflows/02-envio-programado-LOCAL.json` ✅ Actualizado  
4. `workflows/03-feedback-LOCAL.json` ✅ Actualizado (copia de producción)

---

## Cambios Realizados

### Workflow 02: Envío de Sesiones

**Antes**:
```html
<a href=".../feedback?tipo=dificultad&respuesta=facil">Fácil 😊</a>
<a href=".../feedback?tipo=dificultad&respuesta=adecuado">Adecuado ✅</a>
<a href=".../feedback?tipo=dificultad&respuesta=dificil">Difícil 😓</a>
```

**Ahora**:
```html
<!-- 3 botones casos felices -->
<a href=".../feedback?feedback=completa_facil">😊 Fácil - Podría haber hecho más</a>
<a href=".../feedback?feedback=completa_bien">💪 Apropiado - Nivel perfecto</a>
<a href=".../feedback?feedback=completa_dificil">😰 Difícil - Me costó pero lo logré</a>

<!-- 1 botón problemas -->
<a href="http://localhost:8080/feedback-problemas.html?user_id=X">⚠️ No pude completarla</a>
```

### Workflow 03: Procesamiento de Feedback

**Antes**:
- Procesaba: `tipo` y `respuesta`
- No distinguía si completó sesión

**Ahora**:
- Procesa: `feedback` (valor combinado)
- Extrae: `completitud`, `respuesta`, `razon_no_completar`
- Lógica mejorada con 6 tipos de feedback

---

## URLs de Webhooks

### Producción:
- Feedback: `https://n8n.habitos-vitales.com/webhook/feedback`
- Landing problemas: `https://camino-vital.habitos-vitales.com/feedback-problemas.html`

### Local/Test:
- Feedback: `http://localhost:5678/webhook/feedback`
- Landing problemas: `http://localhost:8080/feedback-problemas.html`

---

## 🎯 Próximos Pasos

1. **Importar workflows en n8n**:
   - Borrar workflows antiguos
   - Importar versiones actualizadas
   - Activar ambos workflows

2. **Servir landing page**:
   ```bash
   cd landing
   python3 -m http.server 8080
   ```

3. **Probar flujo completo**:
   - Ejecutar workflow 02 (envío de sesión)
   - Hacer click en los 4 botones de feedback
   - Verificar datos en base de datos

---

## Diferencias LOCAL vs PRODUCCIÓN

| Aspecto | LOCAL | PRODUCCIÓN |
|---------|-------|------------|
| Nombre workflow | `[TEST-CV] 02 Envío...` | `Camino Vital - 02 Envío...` |
| Trigger | Manual Trigger | Cron Schedule (L/M/V 9 AM) |
| Email subject | `[TEST] Título...` | `Título...` |
| Banner en email | ✅ "MODO TEST" | ❌ No |
| Webhook feedback | `/webhook/feedback` | `/webhook/feedback` |
| Landing problemas | `localhost:8080` | `camino-vital.habitos-vitales.com` |
| Credentials | PostgreSQL Camino Vital Local | PostgreSQL local |

---

## Backups Creados

- `02-envio-programado-LOCAL-BACKUP.json`
- `02-envio-programado-LOCAL-OLD.json`
- `03-feedback-LOCAL-OLD.json`

Si algo falla, puedes restaurar estos archivos.

---

**Estado**: ✅ Todos los workflows actualizados y listos para importar
**Fecha**: 2026-01-09
