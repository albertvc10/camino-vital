# 📋 Instrucciones: Importar Workflows con Sistema de Límite

## ✅ Lo que se ha modificado

### Workflow 01 (Onboarding) - MODIFICADO
**Archivo**: `workflows/[TEST-CV] 01 Onboarding.json`

**Cambios implementados**:
1. ✅ Nodo "Execute Workflow 07" añadido después de "Extraer Datos del Pago"
2. ✅ Nodo IF "¿Permitir Activación?" para verificar el límite
3. ✅ Rama TRUE: Flujo normal de activación (sin cambios)
4. ✅ Rama FALSE: Nuevo flujo de lista de espera:
   - Reembolso automático vía Stripe API
   - Email lista de espera con template completo
5. ✅ Respuesta webhook adaptada a ambos casos

---

## 🚀 Pasos para Importar

### 1. Importar Workflow 07 (Verificar Límite)

```bash
1. Abre n8n: http://localhost:5678
2. Click "+" (nuevo workflow)
3. Click "..." → "Import from File"
4. Selecciona: workflows/07-verificar-limite-usuarios.json
5. Guarda el workflow
6. ✅ IMPORTANTE: Activa el workflow (toggle en la esquina superior derecha)
```

### 2. Reimportar Workflow 01 (Onboarding) - MODIFICADO

```bash
1. OPCIÓN A - Reimportar (Recomendado):
   - Abre el workflow 01 actual en n8n
   - Click "..." → "Delete"
   - Confirma eliminación
   - Click "+" → "Import from File"
   - Selecciona: workflows/[TEST-CV] 01 Onboarding.json
   - Guarda y activa

2. OPCIÓN B - Crear nuevo:
   - Deja el workflow 01 actual como backup
   - Importa el nuevo workflow con otro nombre
   - Prueba el nuevo workflow
   - Cuando funcione, elimina el antiguo
```

### 3. Configurar Stripe Secret Key

**⚠️ CRÍTICO**: El nodo "Reembolsar Stripe" necesita tu clave secreta de Stripe.

```bash
1. Abre el workflow 01 en n8n
2. Click en el nodo "Reembolsar Stripe"
3. En "Header Parameters" → "Authorization"
4. Reemplaza: "Bearer sk_test_YOUR_STRIPE_SECRET_KEY_HERE"
5. Con: "Bearer sk_test_TU_CLAVE_SECRETA_REAL"

   O si estás en producción:
   "Bearer sk_live_TU_CLAVE_SECRETA_REAL"

6. Guarda el workflow
```

**Dónde encontrar tu Stripe Secret Key**:
```
1. Abre: https://dashboard.stripe.com/test/apikeys
2. Copia "Secret key" (empieza con sk_test_...)
3. Para producción: https://dashboard.stripe.com/apikeys
```

---

## 🧪 Probar el Sistema

### Test 1: Usuario dentro del límite (actualmente hay espacio)

**Estado actual**: 3 usuarios activos, límite = 75

```bash
1. Simula un pago de prueba en Stripe
2. Verifica en logs de n8n:
   - ✅ Workflow 07 se ejecuta
   - ✅ Devuelve: permitir_activacion = true
   - ✅ Usuario se activa normalmente
   - ✅ Email de bienvenida enviado
3. Verifica en DB:
   SELECT * FROM camino_vital.programa_users
   WHERE email = 'tu_email_test@test.com';
```

### Test 2: Simular límite alcanzado

**Temporalmente reduce el límite para probar el flujo de lista de espera**:

```sql
-- En Adminer, ejecuta:
SET search_path TO camino_vital;

-- 1. Reducir límite a 3 (para forzar lista de espera)
UPDATE configuracion
SET value = jsonb_set(value, '{limite}', '3')
WHERE key = 'usuarios_activos_max';

-- 2. Verificar
SELECT value FROM configuracion WHERE key = 'usuarios_activos_max';
-- Debe mostrar: {"limite": 3, "activo": true}
```

**Ahora prueba un pago**:
```bash
1. Simula un nuevo pago (será el usuario #4)
2. Verifica en logs de n8n:
   - ✅ Workflow 07 se ejecuta
   - ✅ Devuelve: permitir_activacion = false
   - ✅ Usuario NO se activa
   - ✅ Usuario añadido a lista_espera
   - ✅ Stripe reembolsa automáticamente
   - ✅ Email lista espera enviado
3. Verifica en DB:
   SELECT * FROM camino_vital.lista_espera;
4. Verifica en Stripe que el reembolso se procesó
```

**Restaurar límite original**:
```sql
SET search_path TO camino_vital;

UPDATE configuracion
SET value = jsonb_set(value, '{limite}', '75')
WHERE key = 'usuarios_activos_max';
```

---

## 📊 Monitoreo Rápido

### Dashboard en una query
```sql
SET search_path TO camino_vital;

SELECT
  '🎯 LÍMITE' as " ",
  (SELECT value->>'limite' FROM configuracion WHERE key = 'usuarios_activos_max') as configurado,
  (SELECT COUNT(*) FROM programa_users WHERE estado = 'activo') as activos,
  ROUND(
    (SELECT COUNT(*)::numeric FROM programa_users WHERE estado = 'activo') /
    (SELECT value->>'limite' FROM configuracion WHERE key = 'usuarios_activos_max')::numeric * 100,
    1
  ) || '%' as porcentaje_uso,
  (SELECT COUNT(*) FROM lista_espera WHERE notificado = false) as en_espera;
```

**Output esperado**:
```
   | configurado | activos | porcentaje_uso | en_espera |
---|-------------|---------|----------------|-----------|
🎯 | 75          | 3       | 4.0%           | 0         |
```

---

## 🎯 Flujo Visual del Workflow 01 Modificado

```
Stripe Webhook
    ↓
Extraer Datos del Pago
    ↓
Execute Workflow 07 (Verificar Límite)
    ↓
¿Permitir Activación? (IF node)
    ↓
    ├─ TRUE (hay espacio) ───────────────┐
    │   ↓                                 │
    │   Activar Usuario (lead → activo)  │
    │   ↓                                 │
    │   Formatear Datos Usuario          │
    │   ↓                                 │
    │   Actualizar Brevo [TEST]          │
    │   ↓                                 │
    │   Recuperar Datos Usuario          │
    │   ↓                                 │
    │   Enviar Email Bienvenida          │
    │   ↓                                 │
    └───┼─────────────────────────────────┘
        │
    ├─ FALSE (límite alcanzado) ─────────┐
    │   ↓                                 │
    │   Reembolsar Stripe                │
    │   ↓                                 │
    │   Enviar Email Lista Espera        │
    │   ↓                                 │
    └───┼─────────────────────────────────┘
        │
        ↓
    Responder Webhook
```

---

## ⚠️ Checklist Final

Antes de considerar el sistema completo:

- [ ] Workflow 07 importado y activado
- [ ] Workflow 01 reimportado con cambios
- [ ] Stripe Secret Key configurada en nodo "Reembolsar Stripe"
- [ ] Test 1 completado: Usuario activado correctamente
- [ ] Test 2 completado: Usuario va a lista de espera y se reembolsa
- [ ] Límite restaurado a 75
- [ ] Dashboard SQL probado y funcionando

---

## 📁 Archivos Relevantes

```
programa-camino-vital/
├── workflows/
│   ├── [TEST-CV] 01 Onboarding.json ✅ MODIFICADO - Reimportar
│   └── 07-verificar-limite-usuarios.json ✅ NUEVO - Importar
├── templates/
│   └── email-lista-espera.html ✅ (ya integrado en workflow)
├── QUERIES-MONITOREO-LIMITE.md ✅ Para gestión diaria
├── RESUMEN-LIMITE-USUARIOS.md ✅ Documentación completa
└── INSTRUCCIONES-IMPORTAR-WORKFLOWS.md ✅ Este archivo
```

---

## 🚨 Problemas Comunes

### Error: "Workflow 07 not found"
```
Solución:
1. Verifica que workflow 07 esté importado
2. Verifica que el nombre sea exactamente: "[TEST-CV] 07 Verificar Límite y Lista Espera"
3. Verifica que workflow 07 esté activado
```

### Error: "Stripe refund failed"
```
Solución:
1. Verifica que la Stripe Secret Key esté configurada
2. Verifica que el payment_intent_id sea correcto
3. Verifica que el pago no esté ya reembolsado
```

### Error: "Email no se envía"
```
Solución:
1. Verifica que la API key de Brevo sea válida
2. Verifica que el email del destinatario exista
3. Revisa logs de n8n para más detalles
```

---

**Estado**: ✅ Workflows modificados y listos para importar

**Próxima acción**: Importar workflows y configurar Stripe Secret Key
