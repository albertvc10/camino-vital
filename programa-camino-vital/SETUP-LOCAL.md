# 🧪 Setup de Entorno Local para Camino Vital

## 🎯 Objetivo

Configurar un entorno de pruebas local para Camino Vital **sin afectar** los workflows de Instagram que ya tienes funcionando en el mismo n8n.

---

## 📋 Prerequisitos

✅ Ya tienes n8n local corriendo en `~/Documents/HV_n8n/`
✅ Ya tienes PostgreSQL local funcionando (contenedor `n8n_postgres`)
✅ Ya tienes workflows de Instagram que NO deben ser afectados

---

## 🚀 Instalación (5 minutos)

### Paso 1: Ejecutar script de setup

```bash
cd ~/Documents/HV_n8n/programa-camino-vital
./setup-local.sh
```

Este script automáticamente:
1. ✅ Verifica que n8n local está corriendo
2. ✅ Crea schema `camino_vital` en PostgreSQL
3. ✅ Crea tablas: `programa_users`, `programa_contenido`, `programa_feedback`, `programa_envios`
4. ✅ Inserta 3 usuarios de prueba
5. ✅ Inserta contenido de ejemplo (semanas 1-2)

**Resultado esperado:**
```
✅ Setup completado exitosamente!
```

---

## 🗄️ Estructura de Base de Datos Local

Tu PostgreSQL ahora tiene:

```
Database: n8n
├── Schema: public
│   └── [Tablas de Instagram - NO TOCAR]
│
└── Schema: camino_vital  ← NUEVO
    ├── programa_users
    ├── programa_contenido
    ├── programa_feedback
    └── programa_envios
```

**Separación total:** Schemas diferentes = No hay riesgo de conflicto.

---

## 👥 Usuarios de Prueba Creados

El script crea automáticamente:

| Email | Estado | Nivel | Semana | Uso |
|-------|--------|-------|--------|-----|
| `test-lead@camino-vital.local` | lead | iniciacion | 1 | Probar onboarding |
| `test-activo@camino-vital.local` | activo | iniciacion | 2 | Probar envío programado |
| `test-intermedio@camino-vital.local` | activo | intermedio | 1 | Probar nivel intermedio |

---

## 🔧 Configurar Workflows en n8n Local

### Paso 1: Abrir n8n local

```bash
open http://localhost:5678
```

**Credenciales:** Ver archivo `~/Documents/HV_n8n/.env`
- Usuario: `admin`
- Password: (la que está en `.env`)

### Paso 2: Importar workflows

1. En n8n → **Workflows** → **Import from File**
2. Navega a: `~/Documents/HV_n8n/programa-camino-vital/workflows/`
3. Selecciona workflow (ej: `01-onboarding-v2.json`)
4. **IMPORTANTE:** Renombrar con prefijo `[TEST-CV]`

**Ejemplo:**
- ❌ Original: `01-onboarding-v2`
- ✅ Renombrado: `[TEST-CV] 01-onboarding-v2`

**¿Por qué renombrar?**
- Distinguir workflows de prueba vs Instagram
- Evitar confusión
- Poder tener ambos activos sin conflicto

### Paso 3: Crear credencial PostgreSQL

En n8n:
1. **Credentials** (menú lateral) → **Add Credential**
2. Buscar: `Postgres`
3. **Nombre:** `PostgreSQL Camino Vital Local`
4. Configuración:
   ```
   Host: postgres
   Port: 5432
   Database: n8n
   User: n8n
   Password: [ver ~/Documents/HV_n8n/.env]
   SSL: Disabled
   ```
5. **Guardar**

### Paso 4: Modificar queries en workflows

**En CADA nodo PostgreSQL del workflow:**

❌ **Antes (producción):**
```sql
SELECT * FROM programa_users WHERE estado = 'activo'
```

✅ **Después (local con schema):**
```sql
SELECT * FROM camino_vital.programa_users WHERE estado = 'activo'
```

**Alternativa (cambiar search_path):**
```sql
SET search_path TO camino_vital;
SELECT * FROM programa_users WHERE estado = 'activo';
```

### Paso 5: Deshabilitar envíos reales de email

**En nodos de Brevo/HTTP Request (envío de emails):**

Opción A - Reemplazar por nodo Code:
```javascript
// Mock de envío de email
const emailData = {
  to: $json.email,
  subject: $json.subject,
  html: $json.html
};

console.log('📧 [MOCK EMAIL - NO ENVIADO]');
console.log(emailData);

return {
  json: {
    messageId: 'mock-' + Date.now(),
    status: 'sent'
  }
};
```

Opción B - Cambiar destinatario:
```javascript
// En vez de enviar a usuario real, enviar siempre a ti
to: 'albertvc10@gmail.com'  // Tu email de pruebas
```

### Paso 6: Desactivar webhooks de Stripe

**En nodos Webhook:**
- Cambiar a **Manual Trigger** para testing
- O usar webhook de test en Stripe

---

## 🧪 Probar un Workflow

### Ejemplo: Probar Workflow 02 (Envío Programado)

1. Abrir workflow `[TEST-CV] 02-envio-programado`
2. Verificar que todos los nodos usan:
   - Credencial: `PostgreSQL Camino Vital Local`
   - Queries con schema: `camino_vital.tabla`
   - Emails en modo mock
3. Click en **Execute Workflow** (arriba a la derecha)
4. Ver resultados en cada nodo
5. Verificar en DB:

```bash
docker exec -it n8n_postgres psql -U n8n -d n8n
```

```sql
SET search_path TO camino_vital;

-- Ver usuarios
SELECT * FROM programa_users;

-- Ver envíos registrados
SELECT * FROM programa_envios;

-- Ver último envío
SELECT
  u.email,
  u.nombre,
  e.created_at
FROM programa_envios e
JOIN programa_users u ON e.user_id = u.id
ORDER BY e.created_at DESC
LIMIT 5;
```

---

## 📊 Verificar Instalación

### Conectar a PostgreSQL

```bash
docker exec -it n8n_postgres psql -U n8n -d n8n
```

### Verificar schema y tablas

```sql
-- Listar schemas
\dn

-- Cambiar a schema camino_vital
SET search_path TO camino_vital;

-- Listar tablas
\dt

-- Ver usuarios de prueba
SELECT id, email, nombre, estado, nivel_actual, semana_actual
FROM programa_users;

-- Ver contenido disponible
SELECT id, etapa, nivel, semana, titulo
FROM programa_contenido;

-- Salir
\q
```

**Resultado esperado:**
```
Schema   | Name
---------+------------
public   | (tablas de Instagram)
camino_vital | (tablas de Camino Vital)

     id | email                          | nombre               | estado | nivel_actual | semana_actual
   -----+--------------------------------+----------------------+--------+--------------+--------------
      1 | test-lead@camino-vital.local   | Lead de Prueba       | lead   | iniciacion   | 1
      2 | test-activo@camino-vital.local | Usuario Activo Test  | activo | iniciacion   | 2
      3 | test-intermedio@...            | Usuario Intermedio.. | activo | intermedio   | 1
```

---

## 🔄 Workflow de Desarrollo Diario

### 1. Iniciar n8n local (si está apagado)

```bash
cd ~/Documents/HV_n8n
docker-compose up -d
```

### 2. Hacer cambios en workflow

```bash
open http://localhost:5678
```

- Editar workflow `[TEST-CV] XXX`
- Modificar nodos, queries, lógica
- **Guardar** (Ctrl+S / Cmd+S)

### 3. Probar manualmente

- Click en **Execute Workflow**
- Revisar output de cada nodo
- Verificar que funciona como esperas

### 4. Verificar en DB

```bash
docker exec -it n8n_postgres psql -U n8n -d n8n -c "SET search_path TO camino_vital; SELECT * FROM programa_users;"
```

### 5. Si funciona → Exportar

- Workflow → **...** (tres puntos) → **Download**
- Guardar en: `~/Documents/HV_n8n/programa-camino-vital/workflows/`
- Nombrar: `[nombre]-v2-YYYY-MM-DD.json`

### 6. Importar a producción

**Solo cuando estés 100% seguro:**

1. Conectar a producción: https://n8n.habitos-vitales.com
2. Desactivar workflow actual
3. Exportar workflow actual como backup
4. Importar nueva versión
5. Probar ejecución manual
6. Activar workflow

---

## 🚨 Reglas Importantes

### ✅ HACER

- ✅ Usar prefijo `[TEST-CV]` en workflows locales
- ✅ Usar schema `camino_vital` en todas las queries
- ✅ Probar 3+ veces antes de deploy a producción
- ✅ Verificar datos en DB después de cada prueba
- ✅ Exportar workflow antes de modificaciones grandes
- ✅ Usar emails de prueba (@camino-vital.local)

### ❌ NUNCA HACER

- ❌ Modificar workflows de Instagram
- ❌ Usar schema `public` para Camino Vital
- ❌ Enviar emails reales desde local
- ❌ Ejecutar `docker-compose down -v` (borra todo)
- ❌ Hacer queries DELETE sin WHERE en producción
- ❌ Copiar credenciales de producción a local

---

## 🔧 Comandos Útiles

### Docker

```bash
# Ver estado
docker-compose ps

# Ver logs
docker-compose logs -f n8n

# Reiniciar n8n (sin tocar DB)
docker-compose restart n8n

# Detener todo
docker-compose stop

# Iniciar todo
docker-compose up -d
```

### PostgreSQL

```bash
# Conectar a DB
docker exec -it n8n_postgres psql -U n8n -d n8n

# Ejecutar query directa
docker exec -it n8n_postgres psql -U n8n -d n8n -c "SET search_path TO camino_vital; SELECT * FROM programa_users;"

# Ver tablas de Camino Vital
docker exec -it n8n_postgres psql -U n8n -d n8n -c "\dt camino_vital.*"

# Backup de schema camino_vital
docker exec n8n_postgres pg_dump -U n8n -d n8n --schema=camino_vital > backup-local-camino-vital.sql

# Restaurar backup
cat backup-local-camino-vital.sql | docker exec -i n8n_postgres psql -U n8n -d n8n
```

### Añadir más datos de prueba

```bash
docker exec -it n8n_postgres psql -U n8n -d n8n
```

```sql
SET search_path TO camino_vital;

-- Añadir usuario
INSERT INTO programa_users (email, nombre, estado, nivel_actual, semana_actual)
VALUES ('nuevo@test.com', 'Nuevo Test', 'activo', 'iniciacion', 1);

-- Añadir contenido
INSERT INTO programa_contenido (etapa, nivel, semana, titulo, descripcion, contenido_ejercicios, duracion_estimada, enfoque)
VALUES (
  'base_vital',
  'iniciacion',
  3,
  'Semana 3: Test',
  'Ejercicios de prueba',
  '{"ejercicios": []}'::jsonb,
  20,
  'movilidad'
);
```

---

## 🐛 Troubleshooting

### Problema: "schema camino_vital does not exist"

**Solución:** Re-ejecutar setup
```bash
cd ~/Documents/HV_n8n/programa-camino-vital
./setup-local.sh
```

### Problema: n8n no se conecta a PostgreSQL

**Solución:** Verificar que PostgreSQL está corriendo
```bash
docker-compose ps
# Si postgres no está UP:
docker-compose restart postgres
```

### Problema: Workflow falla con "permission denied"

**Solución:** Verificar credencial PostgreSQL
- En n8n → Credentials
- Editar `PostgreSQL Camino Vital Local`
- Verificar usuario/password

### Problema: Queries no encuentran tablas

**Solución:** Añadir schema explícitamente
```sql
-- ❌ Mal
SELECT * FROM programa_users

-- ✅ Bien
SELECT * FROM camino_vital.programa_users
```

### Problema: Modifico workflow pero no se guarda

**Solución:**
1. Ctrl+S / Cmd+S para guardar
2. Verificar que no hay errores en nodos
3. Click en botón "Save" arriba

---

## 📚 Recursos

- **Documentación n8n:** https://docs.n8n.io/
- **PostgreSQL schemas:** https://www.postgresql.org/docs/current/ddl-schemas.html
- **Docker Compose:** https://docs.docker.com/compose/

---

## 🎯 Checklist de Setup Completado

- [ ] Script `setup-local.sh` ejecutado sin errores
- [ ] Schema `camino_vital` creado en PostgreSQL
- [ ] 4 tablas creadas (users, contenido, feedback, envios)
- [ ] 3 usuarios de prueba visibles en DB
- [ ] Workflow importado en n8n con prefijo `[TEST-CV]`
- [ ] Credencial PostgreSQL configurada
- [ ] Queries modificadas para usar schema `camino_vital`
- [ ] Envíos de email en modo mock
- [ ] Ejecución manual exitosa de workflow
- [ ] Datos visibles en DB después de ejecución

---

**¿Todo listo? ¡Estás preparado para desarrollar sin miedo! 🚀**

Si tienes problemas, revisa los logs:
```bash
docker-compose logs -f
```
