# 🚀 Guía de Despliegue en Digital Ocean

## 📋 Pre-requisitos

- ✅ Droplet creado en Digital Ocean (Ubuntu)
- ✅ IP del droplet: **167.71.51.148**
- ✅ Dominio: **habitos-vitales.com**
- ✅ Subdominio para n8n: **n8n.habitos-vitales.com**

---

## 🌐 Paso 1: Configurar DNS en Hostinger

1. Ve a tu panel de Hostinger
2. Ve a **Dominios** → **habitos-vitales.com** → **DNS/Nameservers**
3. Añade un registro **A**:
   - **Tipo**: A
   - **Nombre**: n8n
   - **Apunta a**: 167.71.51.148
   - **TTL**: 3600 (o automático)

⏱️ **Nota**: Los cambios de DNS pueden tardar entre 5 minutos y 24 horas en propagarse (normalmente 5-10 minutos)

---

## 🔐 Paso 2: Conectar al Droplet

### Primera conexión (con contraseña temporal)

```bash
ssh root@167.71.51.148
```

**Contraseña temporal**: `bffa318b9fec3528413a975836`

Te pedirá cambiar la contraseña. Elige una segura.

### Configurar SSH Key (recomendado)

En tu Mac, genera una SSH key si no tienes una:

```bash
# Verifica si ya tienes una
ls -la ~/.ssh/id_*.pub

# Si no tienes, genera una nueva
ssh-keygen -t ed25519 -C "tu_email@ejemplo.com"
```

Copia la key al servidor:

```bash
ssh-copy-id root@167.71.51.148
```

Ahora podrás conectar sin contraseña:

```bash
ssh root@167.71.51.148
```

---

## 🐳 Paso 3: Instalar Docker en el Droplet

Una vez conectado al servidor, ejecuta:

```bash
# Actualizar el sistema
apt update && apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Instalar Docker Compose
apt install docker-compose-plugin -y

# Verificar instalación
docker --version
docker compose version
```

---

## 📦 Paso 4: Preparar el Proyecto

### En tu Mac, genera las passwords seguras:

```bash
# Genera encryption key
openssl rand -base64 32

# Genera passwords seguras
openssl rand -base64 24
openssl rand -base64 24
openssl rand -base64 24
```

### Edita el archivo .env.production

Abre `.env.production` y CAMBIA todos los valores que dicen `CAMBIA_ESTA_PASSWORD`:

```bash
# Usa las passwords que acabas de generar
N8N_BASIC_AUTH_PASSWORD=tu_password_generada_1
POSTGRES_PASSWORD=tu_password_generada_2
POSTGRES_NON_ROOT_PASSWORD=tu_password_generada_3
DB_POSTGRESDB_PASSWORD=tu_password_generada_3  # ← Misma que POSTGRES_NON_ROOT_PASSWORD
N8N_ENCRYPTION_KEY=tu_encryption_key_generada

# Añade tus API keys
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
```

---

## 🚀 Paso 5: Subir Archivos al Servidor

### Opción A: Usando rsync (recomendado)

En tu Mac, desde la carpeta del proyecto:

```bash
# Subir archivos necesarios
rsync -avz --exclude 'data' --exclude '.git' \
  -e ssh \
  ./ root@167.71.51.148:/root/n8n/
```

### Opción B: Usando scp

```bash
# Crear carpeta en el servidor
ssh root@167.71.51.148 'mkdir -p /root/n8n'

# Subir archivos uno por uno
scp docker-compose.production.yml root@167.71.51.148:/root/n8n/docker-compose.yml
scp Caddyfile root@167.71.51.148:/root/n8n/
scp .env.production root@167.71.51.148:/root/n8n/.env
scp init-data.sh root@167.71.51.148:/root/n8n/
```

---

## 🎬 Paso 6: Levantar n8n en Producción

Conéctate al servidor:

```bash
ssh root@167.71.51.148
cd /root/n8n
```

Verifica que los archivos estén ahí:

```bash
ls -la
```

Crea las carpetas de datos:

```bash
mkdir -p data/postgres data/n8n data/caddy
chmod +x init-data.sh
```

Levanta los contenedores:

```bash
docker compose up -d
```

Verifica que estén corriendo:

```bash
docker compose ps
docker compose logs -f
```

---

## ✅ Paso 7: Verificar el Despliegue

### Verifica que los contenedores estén corriendo:

```bash
docker compose ps
```

Deberías ver 3 contenedores:
- ✅ n8n_postgres
- ✅ n8n
- ✅ caddy

### Verifica los logs:

```bash
# Ver todos los logs
docker compose logs

# Ver solo logs de n8n
docker compose logs n8n

# Ver solo logs de Caddy
docker compose logs caddy
```

### Accede a n8n:

Abre tu navegador y ve a: **https://n8n.habitos-vitales.com**

- Usuario: `admin` (o el que pusiste en .env.production)
- Contraseña: la que configuraste en `N8N_BASIC_AUTH_PASSWORD`

---

## 🔧 Comandos Útiles

### Ver logs en tiempo real:

```bash
docker compose logs -f
```

### Reiniciar n8n:

```bash
docker compose restart n8n
```

### Parar todo:

```bash
docker compose down
```

### Reiniciar todo:

```bash
docker compose down && docker compose up -d
```

### Ver uso de recursos:

```bash
docker stats
```

---

## 🔥 Firewall (Opcional pero Recomendado)

```bash
# Configurar firewall
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
ufw status
```

---

## 📊 Importar Workflows

Una vez n8n esté corriendo, puedes importar tus workflows:

1. Ve a https://n8n.habitos-vitales.com
2. Click en el menú **Workflows** → **Import from File**
3. Sube tus archivos .json de la carpeta `workflows/`

O súbelos al servidor y móntelos:

```bash
# En tu Mac
scp workflows/*.json root@167.71.51.148:/root/n8n/workflows/
```

---

## 🆘 Troubleshooting

### El dominio no resuelve:

```bash
# Verifica DNS
nslookup n8n.habitos-vitales.com
# o
dig n8n.habitos-vitales.com
```

### Caddy no obtiene certificado SSL:

```bash
# Ver logs de Caddy
docker compose logs caddy

# Verificar que el puerto 80 y 443 estén abiertos
ufw status
```

### n8n no arranca:

```bash
# Ver logs
docker compose logs n8n

# Verificar PostgreSQL
docker compose logs postgres
```

---

## 🎉 ¡Listo!

Ahora tienes n8n corriendo en producción con:
- ✅ SSL automático (HTTPS)
- ✅ Base de datos PostgreSQL
- ✅ Persistencia de datos
- ✅ Reverse proxy con Caddy
- ✅ Reinicio automático si se cae
