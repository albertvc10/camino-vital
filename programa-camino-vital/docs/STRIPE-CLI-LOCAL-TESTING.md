# 🔧 Stripe CLI - Testing Local de Webhooks

**Última actualización:** 30 Diciembre 2024

---

## 📋 ¿Para qué sirve?

Stripe CLI permite **recibir webhooks de Stripe en localhost** durante el desarrollo, sin necesidad de ngrok u otros túneles.

Cuando haces un pago de prueba en Stripe (modo test), el webhook se envía automáticamente a tu servidor local.

---

## 🚀 INSTALACIÓN

### MacOS (Homebrew)

```bash
brew install stripe/stripe-cli/stripe
```

### Linux

```bash
wget -O stripe.tar.gz https://github.com/stripe/stripe-cli/releases/download/v1.19.0/stripe_1.19.0_linux_x86_64.tar.gz
tar -xvf stripe.tar.gz
sudo mv stripe /usr/local/bin/
```

### Windows

Descarga desde: https://github.com/stripe/stripe-cli/releases

---

## 🔑 CONFIGURACIÓN INICIAL (Solo primera vez)

### 1. Login en Stripe

```bash
stripe login
```

Esto abrirá el navegador para autenticarte. Acepta los permisos.

**Output esperado:**
```
Your pairing code is: word-word-word
Press Enter to open the browser (^C to quit)
> Done! The Stripe CLI is configured for [tu_cuenta] with account id acct_xxxxx
```

### 2. Verificar instalación

```bash
stripe --version
```

Deberías ver algo como: `stripe version 1.19.0`

---

## 🎯 USO PARA TESTING LOCAL

### Paso 1: Arrancar n8n local

Asegúrate de que n8n esté corriendo:

```bash
docker ps | grep n8n
```

Si no está corriendo:

```bash
cd ~/Documents/HV_n8n
docker-compose up -d
```

### Paso 2: Iniciar Stripe webhook forwarding

```bash
stripe listen --forward-to localhost:5678/webhook/camino-vital-pago-test --events checkout.session.completed
```

**Parámetros:**
- `--forward-to`: URL de tu webhook local (n8n)
- `--events`: Eventos que quieres capturar (opcional, si no se especifica captura todos)

**Output esperado:**
```
Ready! You are using Stripe API Version [2025-12-15.clover]
Your webhook signing secret is whsec_xxxxx (^C to quit)
```

⚠️ **Importante:** Deja este comando corriendo en una terminal. No lo cierres.

### Paso 3: Hacer pago de prueba

1. Abre tu landing: http://localhost:8000/cuestionario.html
2. Completa el cuestionario
3. Haz un pago de prueba con tarjeta test: `4242 4242 4242 4242`

### Paso 4: Ver eventos en tiempo real

En la terminal donde corre `stripe listen` verás algo como:

```
2024-12-30 12:34:56   --> checkout.session.completed [evt_1Abc123]
2024-12-30 12:34:56   <-- [200] POST http://localhost:5678/webhook/camino-vital-pago-test [evt_1Abc123]
```

✅ `[200]` = Webhook entregado correctamente

❌ `[400]` o `[500]` = Error en n8n, revisa el workflow

---

## 🔄 EVENTOS DISPONIBLES

### Para Camino Vital necesitas:

**Pago único (actual):**
```bash
stripe listen --forward-to localhost:5678/webhook/camino-vital-pago-test --events checkout.session.completed
```

**Suscripciones (futuro):**
```bash
stripe listen --forward-to localhost:5678/webhook/camino-vital-pago-test --events \
  customer.subscription.created,\
  customer.subscription.updated,\
  customer.subscription.deleted,\
  invoice.payment_succeeded,\
  invoice.payment_failed
```

**Todos los eventos (debugging):**
```bash
stripe listen --forward-to localhost:5678/webhook/camino-vital-pago-test
```

---

## 🧪 TESTING DE WEBHOOKS SIN HACER PAGOS

Puedes **simular eventos** sin hacer pagos reales:

### Simular checkout completado

```bash
stripe trigger checkout.session.completed
```

Esto envía un evento fake a tu webhook local.

### Simular con datos específicos

```bash
stripe trigger checkout.session.completed \
  --override checkout.session:customer_email=test@example.com
```

---

## 🐛 TROUBLESHOOTING

### Problema: "Command not found: stripe"

**Solución:**
```bash
which stripe
# Si no devuelve nada, reinstala:
brew install stripe/stripe-cli/stripe
```

### Problema: "You need to login first"

**Solución:**
```bash
stripe login
```

### Problema: Webhook recibe [400] o [500]

**Causas posibles:**
1. Workflow no está activo en n8n → Actívalo
2. Path del webhook incorrecto → Verifica que coincida
3. Error en el nodo de procesamiento → Revisa logs en n8n

**Verificar:**
```bash
# Ver qué recibe n8n
docker logs n8n --tail 50
```

### Problema: "Connection refused"

**Causa:** n8n no está corriendo

**Solución:**
```bash
docker-compose up -d
```

### Problema: No llegan eventos

**Verifica:**
1. Stripe CLI esté corriendo (no cerrado)
2. URL correcta: `localhost:5678` (no `127.0.0.1`)
3. Workflow activo en n8n

---

## 📊 MODO BACKGROUND (opcional)

Si no quieres ver logs en tiempo real:

```bash
stripe listen --forward-to localhost:5678/webhook/camino-vital-pago-test \
  --events checkout.session.completed \
  > stripe-webhooks.log 2>&1 &
```

Ver logs:
```bash
tail -f stripe-webhooks.log
```

Matar proceso:
```bash
pkill -f "stripe listen"
```

---

## 🔐 WEBHOOK SIGNING SECRET

Cuando corres `stripe listen`, genera un **webhook signing secret temporal**:

```
whsec_a93e108accf5395c7db0a4434bd72efb50e2503afa453f7118288b4d8e42e7a4
```

Este secret es solo para testing local y cambia cada vez que reinicias `stripe listen`.

**Para producción** usa el secret permanente de Stripe Dashboard:
- https://dashboard.stripe.com/test/webhooks
- Click en el webhook
- Copiar "Signing secret"

---

## 📝 FLUJO COMPLETO DE TESTING

### Setup (solo primera vez)

```bash
# 1. Instalar Stripe CLI
brew install stripe/stripe-cli/stripe

# 2. Login
stripe login

# 3. Verificar
stripe --version
```

### Testing (cada vez que desarrolles)

```bash
# Terminal 1: n8n
cd ~/Documents/HV_n8n
docker-compose up

# Terminal 2: Stripe webhooks
stripe listen --forward-to localhost:5678/webhook/camino-vital-pago-test \
  --events checkout.session.completed

# Terminal 3: Landing page
cd ~/Documents/HV_n8n/programa-camino-vital/landing
python3 -m http.server 8000

# Navegador: Hacer test
open http://localhost:8000/cuestionario.html
```

---

## 🌐 ALTERNATIVA: WEBHOOKS EN PRODUCCIÓN

Si prefieres testear directamente en producción (más simple):

1. Workflows activos en: https://n8n.habitos-vitales.com
2. Webhook configurado en Stripe Dashboard apunta a producción
3. Landing en local o producción → funciona igual
4. No necesitas Stripe CLI

**Ventaja:** Más simple, ambiente real
**Desventaja:** No tienes logs locales

---

## 🔗 RECURSOS

- **Stripe CLI Docs:** https://stripe.com/docs/stripe-cli
- **Testing Webhooks:** https://stripe.com/docs/webhooks/test
- **Event Reference:** https://stripe.com/docs/api/events/types

---

## ✅ CHECKLIST DE TESTING

Antes de probar el flujo completo:

- [ ] Stripe CLI instalado (`stripe --version`)
- [ ] Login en Stripe (`stripe login`)
- [ ] n8n corriendo (`docker ps | grep n8n`)
- [ ] Workflow activo en n8n
- [ ] `stripe listen` corriendo (ver "Ready!")
- [ ] Landing servido (`python3 -m http.server 8000`)

---

**Creado por:** Hábitos Vitales
**Versión:** 1.0.0
**Última actualización:** Diciembre 2024
