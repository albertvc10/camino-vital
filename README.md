# n8n con Docker + PostgreSQL + IA

Proyecto de n8n completamente dockerizado con PostgreSQL y flujos de ejemplo usando APIs de IA (OpenAI y Anthropic).

## ¿Qué es esto?

Este proyecto te permite ejecutar **n8n** (plataforma de automatización de workflows) en tu Mac usando Docker, con:
- Base de datos PostgreSQL para persistencia profesional
- Flujos de ejemplo listos para usar con OpenAI y Claude
- Configuración completa y documentada
- Todo listo para producción

## Requisitos Previos

1. **Docker Desktop** instalado en tu Mac
   - Descarga: https://www.docker.com/products/docker-desktop
   - Verifica la instalación: `docker --version`

2. **API Keys** (opcional para empezar, necesario para los flujos de IA):
   - OpenAI: https://platform.openai.com/api-keys
   - Anthropic: https://console.anthropic.com/

## Estructura del Proyecto

```
HV_n8n/
├── .env                          # Tus configuraciones y secretos
├── docker-compose.yml            # Orquestación de contenedores
├── init-data.sh                  # Script de inicialización de PostgreSQL
├── workflows/                    # Flujos de ejemplo
│   ├── 01-openai-content-generator.json
│   └── 02-anthropic-text-analyzer.json
├── data/                         # Carpeta para persistencia (se crea automáticamente)
│   ├── postgres/                 # Datos de PostgreSQL
│   └── n8n/                      # Workflows y configuración de n8n
└── README.md                     # Esta documentación
```

## Instalación y Primer Uso

### 1. Configurar las credenciales

El archivo `.env` ya está configurado con valores seguros. Lo único que necesitas hacer:

**Para empezar a probar (sin IA):**
- ¡Ya está todo listo! Puedes arrancar directamente.

**Para usar los workflows de IA:**
- Edita el archivo `.env` y reemplaza:
  ```env
  OPENAI_API_KEY=sk-your-openai-key-here
  ANTHROPIC_API_KEY=sk-ant-your-anthropic-key-here
  ```

### 2. Arrancar el proyecto

```bash
# Desde la carpeta del proyecto (HV_n8n)
docker-compose up -d
```

**¿Qué hace este comando?**
- `docker-compose`: Usa el archivo docker-compose.yml para orquestar los contenedores
- `up`: Arranca los servicios (PostgreSQL + n8n)
- `-d`: Modo "detached" (corre en segundo plano)

**Primera vez:** Docker descargará las imágenes (PostgreSQL y n8n). Tarda 2-3 minutos.

### 3. Acceder a n8n

Abre tu navegador en: **http://localhost:5678**

**Credenciales de acceso:**
- Usuario: `admin`
- Contraseña: `5+05GaaaRQPbTjRbRNj3N3pl17K1zhyv`

## Comandos Útiles

### Ver los logs (útil para debugging)
```bash
# Ver logs de ambos contenedores
docker-compose logs -f

# Ver solo logs de n8n
docker-compose logs -f n8n

# Ver solo logs de PostgreSQL
docker-compose logs -f postgres
```

### Detener el proyecto
```bash
# Detener sin borrar nada
docker-compose stop

# Detener y eliminar contenedores (los datos se mantienen)
docker-compose down
```

### Reiniciar desde cero (CUIDADO: Borra todos los datos)
```bash
# Detener y eliminar todo (incluidos datos)
docker-compose down -v

# Borrar la carpeta de datos
rm -rf data/

# Volver a arrancar
docker-compose up -d
```

### Ver el estado de los contenedores
```bash
docker-compose ps
```

## Usar los Workflows de Ejemplo

### Importar workflows en n8n

1. Accede a n8n: http://localhost:5678
2. Haz clic en tu nombre (esquina superior derecha) → **Settings** → **Import from File**
3. Selecciona uno de los archivos en la carpeta `workflows/`
4. El workflow se importará automáticamente

### Configurar credenciales de IA

**Para OpenAI:**
1. En n8n, ve a **Credentials** (menú lateral izquierdo)
2. Click en **Add Credential**
3. Busca "OpenAI"
4. Nombre: `OpenAI API`
5. API Key: Tu clave de OpenAI (la del archivo .env)
6. Guarda

**Para Anthropic:**
1. En n8n, ve a **Credentials**
2. Click en **Add Credential**
3. Busca "Anthropic"
4. Nombre: `Anthropic API`
5. API Key: Tu clave de Anthropic (la del archivo .env)
6. Guarda

### Ejecutar un workflow

1. Abre cualquier workflow importado
2. Haz clic en **Execute Workflow** (botón arriba a la derecha)
3. Observa los resultados en cada nodo

## Entendiendo la Arquitectura

### ¿Qué hace cada componente?

**PostgreSQL (contenedor `postgres`)**
- Base de datos profesional que almacena:
  - Tus workflows (las "recetas" de automatización)
  - Historial de ejecuciones
  - Credenciales (encriptadas)
- Se ejecuta en puerto 5432 (interno, no expuesto)
- Los datos se guardan en `./data/postgres/` (persisten aunque reinicies)

**n8n (contenedor `n8n`)**
- La aplicación principal donde creas workflows
- Se ejecuta en puerto 5678 (accesible en tu navegador)
- Se conecta automáticamente a PostgreSQL
- Los datos se guardan en `./data/n8n/`

**Red Docker (`n8n-network`)**
- Red privada donde PostgreSQL y n8n se comunican
- n8n puede acceder a PostgreSQL usando el nombre `postgres` (en vez de IP)

### Flujo de datos

```
Tu navegador (http://localhost:5678)
        ↓
    n8n (contenedor)
        ↓
PostgreSQL (contenedor)
        ↓
    ./data/postgres/ (tu Mac)
```

## Troubleshooting

### Error: "port 5678 already in use"
Otro servicio está usando el puerto 5678. Cambia el puerto en `.env`:
```env
N8N_PORT=5679
```
Luego reinicia: `docker-compose down && docker-compose up -d`

### Error: "Cannot connect to database"
PostgreSQL aún se está iniciando. Espera 30 segundos y vuelve a intentar.

### n8n no carga en el navegador
1. Verifica que los contenedores estén corriendo: `docker-compose ps`
2. Revisa los logs: `docker-compose logs n8n`
3. Reinicia: `docker-compose restart n8n`

### He perdido mi contraseña
Está en el archivo `.env` en la variable `N8N_BASIC_AUTH_PASSWORD`

## Backup de tus Workflows

### Método 1: Exportar desde n8n (recomendado)
1. En n8n, abre el workflow
2. Click en los 3 puntos (...) → **Download**
3. Guarda el archivo JSON en un lugar seguro

### Método 2: Backup de la base de datos completa
```bash
# Backup
docker exec n8n_postgres pg_dump -U n8n n8n > backup_$(date +%Y%m%d).sql

# Restaurar (CUIDADO: sobrescribe todo)
cat backup_20241201.sql | docker exec -i n8n_postgres psql -U n8n -d n8n
```

## Recursos Útiles

- Documentación oficial de n8n: https://docs.n8n.io/
- Comunidad n8n: https://community.n8n.io/
- Workflows de la comunidad: https://n8n.io/workflows/
- API de OpenAI: https://platform.openai.com/docs/
- API de Anthropic: https://docs.anthropic.com/

## Próximos Pasos

1. Explora la interfaz de n8n
2. Prueba los workflows de ejemplo
3. Crea tu primer workflow personalizado
4. Conéctalo con tus servicios favoritos (Gmail, Slack, Notion, etc.)
5. Automatiza tareas repetitivas

## Notas de Seguridad

- **NUNCA** subas el archivo `.env` a GitHub (ya está en .gitignore)
- Cambia la contraseña por defecto si vas a exponer n8n a internet
- Las API keys están protegidas, pero mantén backups seguros
- Para producción, considera usar HTTPS y autenticación OAuth

## Soporte

Si encuentras problemas:
1. Revisa los logs: `docker-compose logs`
2. Consulta la documentación oficial de n8n
3. Busca en la comunidad de n8n
4. Revisa este README nuevamente

---

Creado con para automatizar el mundo.
