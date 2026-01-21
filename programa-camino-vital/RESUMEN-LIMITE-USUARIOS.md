# ✅ Resumen: Sistema de Límite de Usuarios

## 🎯 Objetivo

Limitar el programa a **75 usuarios activos** mientras estamos en n8n, y gestionar automáticamente una lista de espera cuando se alcance el límite.

---

## ✅ Lo que se ha implementado

### 1. Base de Datos ✅

**Tablas creadas**:

```sql
-- Tabla de configuración del sistema
camino_vital.configuracion
├── key: 'usuarios_activos_max'
├── value: {"limite": 75, "activo": true}
└── descripcion

-- Tabla de lista de espera
camino_vital.lista_espera
├── email (único)
├── nombre
├── stripe_payment_intent_id
├── monto_pagado
├── perfil_inicial (JSONB)
├── notificado (boolean)
└── fecha_notificacion
```

**Estado actual**:
- ✅ Límite configurado: 75 usuarios
- ✅ Límite activo: true
- ✅ Usuarios activos actuales: 3
- ✅ Margen disponible: 72 espacios

### 2. Workflow 07: Verificar Límite ✅

**Archivo**: `workflows/07-verificar-limite-usuarios.json`

**Flujo**:
```
1. Obtener configuración (límite + activo)
2. Contar usuarios activos actuales
3. Verificar si hay espacio
4. IF hay espacio:
   → Devolver: permitir_activacion = true
5. IF NO hay espacio:
   → Añadir a lista_espera
   → Devolver: permitir_activacion = false
```

**Output**:
```json
{
  "permitir_activacion": true/false,
  "motivo": "espacio_disponible" | "limite_alcanzado",
  "email": "...",
  "nombre": "...",
  "limite_info": {
    "limite": 75,
    "usuarios_activos": 3,
    "hay_espacio": true,
    "porcentaje_uso": 4
  }
}
```

### 3. Template Email Lista de Espera ✅

**Archivo**: `templates/email-lista-espera.html`

**Contenido**:
- ✅ Explica que se alcanzó el límite de 75 usuarios
- ✅ Informa que está en lista de espera
- ✅ Confirma reembolso automático
- ✅ Promete 20% descuento cuando abran plazas
- ✅ Estima 3-4 semanas de espera
- ✅ Explica el por qué del límite (calidad)

### 4. Queries de Monitoreo ✅

**Archivo**: `QUERIES-MONITOREO-LIMITE.md`

**Incluye**:
- ✅ Dashboard completo del sistema
- ✅ Ver usuarios activos
- ✅ Ver lista de espera
- ✅ Activar/desactivar límite
- ✅ Cambiar el límite (75 → 100, etc.)
- ✅ Gestionar lista de espera
- ✅ Estadísticas y reportes
- ✅ Alertas automáticas
- ✅ Queries para abrir nuevas plazas

---

## ⏳ Lo que FALTA hacer (manual)

### 1. Importar Workflow 07 en n8n

**Pasos**:
1. Abre n8n: http://localhost:5678
2. Click **"+"** → **"..."** → **"Import from File"**
3. Selecciona: `workflows/07-verificar-limite-usuarios.json`
4. Guarda y activa el workflow

### 2. Modificar Workflow 01 (Onboarding)

**Cambios necesarios**:

```
FLUJO ACTUAL:
Stripe Webhook → Extraer Datos → Activar Usuario → Brevo → Email

FLUJO NUEVO:
Stripe Webhook → Extraer Datos → [Execute Workflow 07] → IF ¿Permitir?
                                                            ↓         ↓
                                                          TRUE     FALSE
                                                            ↓         ↓
                                                    Activar Usuario  Lista Espera
                                                            ↓         ↓
                                                         Brevo    Reembolso
                                                            ↓         ↓
                                                      Email Bienvenida  Email Lista Espera
```

**Nodos a añadir**:

1. **Execute Workflow** (después de "Extraer Datos del Pago"):
   ```
   Source: Database
   Workflow: [TEST-CV] 07 Verificar Límite y Lista Espera
   Fields to Send: All fields
   ```

2. **IF** (después de Execute Workflow):
   ```
   Condition: Boolean
   Value 1: {{ $json.permitir_activacion }}
   Operation: Is Equal To
   Value 2: true
   ```

3. **Reembolsar Stripe** (rama FALSE del IF):
   ```
   Node: HTTP Request
   Method: POST
   URL: https://api.stripe.com/v1/refunds
   Headers:
     Authorization: Bearer {{tu_stripe_secret_key}}
     Content-Type: application/x-www-form-urlencoded
   Body (Form):
     payment_intent: {{ $json.stripe_payment_intent_id }}
     reason: requested_by_customer
   ```

4. **Enviar Email Lista Espera** (después de Reembolsar):
   ```
   Node: HTTP Request (Brevo)
   Method: POST
   URL: https://api.brevo.com/v3/smtp/email
   Body: Copiar de templates/email-lista-espera.html
   ```

5. **Notificar Admin** (opcional, paralelo):
   ```
   Node: HTTP Request o Email
   Mensaje: "🚨 Límite alcanzado - Usuario {{email}} en lista de espera"
   ```

### 3. Probar Flujo Completo

**Escenario 1: Usuario dentro del límite (actualmente)**
```
1. Hacer pago de prueba
2. Verificar que usuario se activa normalmente
3. Verificar email de bienvenida recibido
```

**Escenario 2: Usuario alcanza el límite (simular)**
```
1. Cambiar límite temporalmente:
   UPDATE configuracion
   SET value = jsonb_set(value, '{limite}', '3')
   WHERE key = 'usuarios_activos_max';

2. Hacer pago de prueba (usuario #4)
3. Verificar:
   - Usuario NO se activa
   - Aparece en lista_espera
   - Recibe email de lista de espera
   - Stripe reembolsa automáticamente

4. Restaurar límite:
   UPDATE configuracion
   SET value = jsonb_set(value, '{limite}', '75')
   WHERE key = 'usuarios_activos_max';
```

---

## 📊 Monitoreo Diario

**Query rápida** (ejecutar en Adminer):

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
  ) as porcentaje_uso,
  (SELECT COUNT(*) FROM lista_espera WHERE notificado = false) as en_espera;
```

**Alertas**:
- ⚠️ **75% capacidad** (56 usuarios): Preparar migración
- ⚠️ **90% capacidad** (68 usuarios): Urgente, empieza migración YA
- 🚨 **100% capacidad** (75 usuarios): LÍMITE ALCANZADO, lista de espera activa

---

## 🚀 Cuando llegues a 75 usuarios

### Día 1: Límite alcanzado
```
✅ Automático:
- Nuevos usuarios → Lista de espera
- Pagos → Reembolso automático
- Email lista espera enviado
- Notificación admin

📢 Tú haces:
- Post redes: "¡Sold out! 75 plazas agotadas"
- Email lista de espera: "Nuevas plazas en 3-4 semanas"
```

### Semana 1-3: Migración a Vapor
```
✅ Desarrollo backend Vapor
✅ Endpoints críticos migrados
✅ Tests + deploy
```

### Semana 4: Abrir nuevas plazas
```
1. Aumentar límite:
   UPDATE configuracion
   SET value = jsonb_set(value, '{limite}', '150')
   WHERE key = 'usuarios_activos_max';

2. Email a lista de espera (primeros 75):
   - Código descuento 20%
   - Early access 24h

3. Monitorear activaciones
```

---

## 📁 Archivos Creados

```
programa-camino-vital/
├── workflows/
│   └── 07-verificar-limite-usuarios.json ✅
├── templates/
│   └── email-lista-espera.html ✅
├── QUERIES-MONITOREO-LIMITE.md ✅
└── RESUMEN-LIMITE-USUARIOS.md ✅ (este archivo)
```

---

## 🎯 Próximos Pasos

### Ahora mismo:
- [ ] Importar workflow 07 en n8n
- [ ] Modificar workflow 01 con los cambios indicados
- [ ] Probar flujo completo

### Cuando tengas 50+ usuarios:
- [ ] Revisar QUERIES-MONITOREO-LIMITE.md diariamente
- [ ] Preparar estrategia de comunicación para lista de espera
- [ ] Planificar migración a Vapor

### Cuando llegues a 75 usuarios:
- [ ] Activar lista de espera (automático)
- [ ] Comunicar en redes sociales
- [ ] Empezar migración a Vapor
- [ ] Abrir nuevas plazas en 3-4 semanas

---

**Estado**: ✅ Sistema implementado, listo para importar workflows y probar

**Tiempo invertido**: ~2 horas

**Próxima acción**: Importar workflow 07 en n8n y modificar workflow 01
