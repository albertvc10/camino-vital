# 💳 Configuración de Stripe para Camino Vital

## 🎯 Objetivo

Configurar Stripe para aceptar pagos de 39€ por el programa Base Vital, con metadata personalizada del cuestionario.

---

## 📋 Paso 1: Crear Producto en Stripe

1. Ve a tu dashboard de Stripe: https://dashboard.stripe.com
2. Navega a **Products** → **Add product**
3. Configura el producto:

```
Nombre: Camino Vital - Base Vital
Descripción: Programa personalizado de ejercicio por email (8-12 semanas)
Precio: 39 EUR
Tipo de pago: One-time (pago único)
```

4. **Guarda el producto** y copia el **Price ID** (empieza con `price_xxx`)

---

## 📋 Paso 2: Crear Payment Link

1. En Stripe, ve a **Payment Links** → **Create payment link**
2. Selecciona el producto que acabas de crear
3. Configuración:

```
Collect customer information:
  ✅ Email address
  ✅ Name

After payment:
  → Redirect to: https://habitos-vitales.com/gracias

Tax collection:
  ⬜ No collect tax (o configura según tu país)
```

4. **Campos personalizados** (metadata):

```
Campo 1:
  Label: "Nivel asignado"
  Key: nivel_asignado
  Type: Text
  Optional: No

Campo 2:
  Label: "Email del cuestionario"
  Key: email_cuestionario
  Type: Text
  Optional: No
```

5. Guarda y copia el **Payment Link URL** (algo como `https://buy.stripe.com/test_xxxxx`)

---

## 📋 Paso 3: Configurar Webhook

1. En Stripe, ve a **Developers** → **Webhooks** → **Add endpoint**

2. Configuración:

```
Endpoint URL: https://n8n.habitos-vitales.com/webhook/camino-vital-pago

Description: Camino Vital - Activar usuario después del pago

Events to send:
  ✅ checkout.session.completed
  ✅ payment_intent.succeeded (opcional, backup)

API version: Latest
```

3. **Guarda** y copia el **Webhook signing secret** (empieza con `whsec_xxx`)

4. Añade el secret a tu `.env`:

```bash
STRIPE_WEBHOOK_SECRET=whsec_tu_secret_aqui
```

---

## 📋 Paso 4: Actualizar resultados.html

Edita el archivo `resultados.html` y actualiza la función `redirectToCheckout()`:

```javascript
async function redirectToCheckout() {
    // Guardar datos en n8n primero
    try {
        const response = await fetch('https://n8n.habitos-vitales.com/webhook/guardar-lead', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                ...quizData,
                nivel_asignado: programData.nivel,
                duracion_programa: programData.duration,
                timestamp: new Date().toISOString()
            })
        });

        // Construir URL de Stripe con prefill
        const stripeUrl = new URL('TU_PAYMENT_LINK_DE_STRIPE_AQUI');
        stripeUrl.searchParams.append('prefilled_email', quizData.email);
        stripeUrl.searchParams.append('client_reference_id', quizData.email);

        // Añadir metadata personalizada
        stripeUrl.searchParams.append('__field_nivel_asignado', programData.nivel);
        stripeUrl.searchParams.append('__field_email_cuestionario', quizData.email);

        // Redirigir a Stripe
        window.location.href = stripeUrl.toString();

    } catch (error) {
        console.error('Error:', error);
        alert('Hubo un error. Por favor, inténtalo de nuevo o contacta con hola@habitos-vitales.com');
    }
}
```

**Reemplaza:** `TU_PAYMENT_LINK_DE_STRIPE_AQUI` con tu Payment Link real

---

## 📋 Paso 5: Añadir Código de Descuento (Opcional)

Para el email de remarketing del día 7, crea un cupón de descuento:

1. En Stripe, ve a **Products** → **Coupons** → **Create coupon**

2. Configuración:

```
Name: ULTIMAOPORTUNIDAD
Type: Fixed amount
Amount off: 8 EUR
Duration: Once
Redeem by: (opcional, puedes dejarlo vacío)
```

3. Guarda y actualiza el link en el email de remarketing:

```html
https://buy.stripe.com/test_xxxxx?coupon=ULTIMAOPORTUNIDAD
```

---

## 🧪 Paso 6: Probar en Modo Test

1. Asegúrate de estar en **Test mode** (toggle arriba a la derecha en Stripe)

2. Usa tarjetas de prueba:

```
Tarjeta de éxito: 4242 4242 4242 4242
Fecha: Cualquier fecha futura
CVC: Cualquier 3 dígitos
ZIP: Cualquier 5 dígitos
```

3. Completa un pago de prueba y verifica:
   - ✅ Webhook se ejecuta en n8n
   - ✅ Usuario se activa en la DB
   - ✅ Email de bienvenida se envía
   - ✅ Metadata se guarda correctamente

---

## 🚀 Paso 7: Activar Modo Producción

Una vez probado todo:

1. En Stripe, cambia a **Live mode**
2. Repite los pasos 1-3 en modo producción
3. Actualiza las URLs en `resultados.html` con las de producción
4. Actualiza el webhook endpoint en n8n (debe estar en producción también)

---

## 📊 Monitorización

### Ver pagos en Stripe

```
Stripe Dashboard → Payments
```

Aquí verás todos los pagos con su metadata asociada

### Ver webhooks ejecutados

```
Stripe Dashboard → Developers → Webhooks → [tu endpoint] → Attempts
```

Aquí puedes ver si los webhooks se enviaron correctamente y re-enviarlos manualmente si falla

### Queries útiles en n8n/PostgreSQL

```sql
-- Usuarios que completaron cuestionario pero no pagaron
SELECT email, nombre, created_at
FROM programa_users
WHERE estado = 'lead'
AND created_at > NOW() - INTERVAL '7 days'
ORDER BY created_at DESC;

-- Conversión: % de leads que pagaron
SELECT
  COUNT(CASE WHEN estado = 'lead' THEN 1 END) as leads,
  COUNT(CASE WHEN estado = 'activo' THEN 1 END) as clientes,
  ROUND(
    COUNT(CASE WHEN estado = 'activo' THEN 1 END)::decimal /
    COUNT(*)::decimal * 100,
    2
  ) as tasa_conversion
FROM programa_users
WHERE created_at > NOW() - INTERVAL '30 days';
```

---

## 🔧 Troubleshooting

### Problema: Webhook no se ejecuta

1. Verifica que el endpoint URL sea correcto y accesible desde internet
2. Comprueba que el workflow de n8n esté activo
3. Ve a Stripe → Webhooks → [tu endpoint] → Test webhook
4. Revisa los logs de n8n

### Problema: Metadata no llega

1. Verifica que los campos personalizados estén bien configurados en Payment Link
2. Comprueba que los nombres de los campos coincidan exactamente
3. En el webhook, examina el JSON que llega: `$json.body.data.object.metadata`

### Problema: Usuario no se activa

1. Verifica que el email en Stripe coincida con el del cuestionario
2. Comprueba que el usuario existe en la DB con estado 'lead'
3. Revisa los logs del workflow 01-onboarding-v2

---

## 💡 Tips

1. **Siempre prueba en modo test primero**
2. **Guarda los IDs importantes**: Price ID, Product ID, Webhook secret
3. **Monitoriza los primeros pagos** manualmente para asegurar que todo funciona
4. **Ten un plan B**: Si Stripe falla, ten preparado un email manual de bienvenida

---

## 🔗 Links Útiles

- Dashboard de Stripe: https://dashboard.stripe.com
- Documentación de Payment Links: https://stripe.com/docs/payment-links
- Documentación de Webhooks: https://stripe.com/docs/webhooks
- Tarjetas de prueba: https://stripe.com/docs/testing

---

**Creado por:** Hábitos Vitales
**Última actualización:** Diciembre 2024
