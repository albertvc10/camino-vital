# Camino Vital - Instrucciones del Proyecto

## Flujo de Deployment (OBLIGATORIO)

Todos los cambios siguen este flujo:

```
LOCAL (editar) → GitHub (push) → Servidor (git pull)
```

### Paso a paso:
1. **Editar en LOCAL** - Esta máquina, en este directorio
2. **Commit + push** - `git add . && git commit -m "..." && git push`
3. **SSH al servidor** - `ssh root@164.90.222.166`
4. **Pull en servidor** - `cd /root/camino-vital/programa-camino-vital && git pull`
5. **Verificar** - Las landing pages se actualizan al instante tras `git pull`

### Reglas
- NUNCA editar archivos directamente en producción
- NUNCA hacer push sin antes verificar que los cambios son correctos en local
- NUNCA subir a servidor sin haber probado primero que los cambios funcionan bien en local (probar workflows en n8n local, verificar landing pages en localhost, etc.)
- Siempre seguir el flujo: local → probar en local → git → servidor
- Si un cambio afecta workflows: probar ejecución en n8n local antes de desplegar
- Si un cambio afecta landing pages: verificar en http://localhost visualmente antes de desplegar

## Servidor de Producción

| Recurso | Valor |
|---------|-------|
| IP | 164.90.222.166 |
| SSH | `ssh root@164.90.222.166` |
| Landing pages | https://camino-vital.habitos-vitales.com |
| n8n UI | https://n8n.habitos-vitales.com |
| Ruta landing en servidor | `/root/camino-vital/programa-camino-vital/landing/` |
| Ruta repo en servidor | `/root/camino-vital/programa-camino-vital/` |
| Docker n8n | Container `n8n` |
| Docker PostgreSQL | Container `n8n_postgres` |
| DB User | `n8n_admin` |
| DB Name | `n8n` |

## Tipos de Cambio y Cómo Desplegarlos

| Tipo de cambio | Flujo |
|---|---|
| HTML/CSS/JS (landings) | local → git push → servidor git pull (se ve al instante) |
| Workflows n8n | Editar en JSON local → reimportar en n8n del servidor |
| Templates email (BD) | SQL directo en BD del servidor |
| Variables de entorno | Editar `.env` en servidor → `docker compose restart n8n` |

## Estructura del Proyecto

```
landing/           → Páginas web (servidas por Caddy)
  index.html       → Landing principal (programa a 89€)
  preventa.html    → Landing preventa (39€, sube a 89€ el 1 marzo)
  cuestionario.html → Cuestionario de evaluación
  resultados.html  → Resultados + pago programa normal
  resultados-preventa.html → Resultados + pago preventa
workflows/         → Workflows n8n (JSON exportados)
templates/         → Templates de email
database/          → Scripts SQL
docs/              → Documentación interna
```

## Precios Actuales

| Concepto | Precio |
|----------|--------|
| Programa normal (a partir del 1 marzo) | 89€ |
| Preventa (hasta 1 marzo) | 39€ |
| Stripe link preventa (PROD) | https://buy.stripe.com/9B6bJ0foEgv670Z6WZ2Ry00 |
| Stripe link normal (PROD) | https://buy.stripe.com/8x2eVc90gfr2clj3KN2Ry01 |
| Stripe link preventa (TEST) | https://buy.stripe.com/test_3cIcN471xdCzcjx4IreZ203 |
| Stripe link normal (TEST) | https://buy.stripe.com/test_fZubJ00D941Zabpej1eZ204 |

## Detección de Entorno

Las landing pages detectan automáticamente si están en local o producción:
```javascript
const isLocal = window.location.hostname === 'localhost' || ...
```
- Local → usa webhooks y Stripe en modo test
- Producción → usa webhooks y Stripe reales
