# Guía Rápida de n8n

## Inicio Rápido (3 pasos)

### 1. Arranca el proyecto
```bash
./start.sh
```
O si prefieres hacerlo manualmente:
```bash
docker-compose up -d
```

### 2. Accede a n8n
Abre tu navegador: **http://localhost:5678**

Credenciales:
- Usuario: `admin`
- Contraseña: revisa el archivo `.env`

### 3. Importa un workflow de ejemplo
1. En n8n: Click en tu nombre (arriba derecha) → **Settings** → **Import from File**
2. Selecciona `workflows/01-openai-content-generator.json`
3. Configura las credenciales (ve abajo)
4. Click en **Execute Workflow**

---

## Comandos Esenciales

### Ver qué está corriendo
```bash
docker-compose ps
```

### Ver los logs en tiempo real
```bash
docker-compose logs -f
```

### Detener todo
```bash
docker-compose down
```

### Reiniciar n8n (si algo va mal)
```bash
docker-compose restart n8n
```

### Empezar desde cero (BORRA TODO)
```bash
docker-compose down -v
rm -rf data/
docker-compose up -d
```

---

## Configurar API Keys de IA

### OpenAI

1. Ve a https://platform.openai.com/api-keys
2. Crea una API key
3. Cópiala y pégala en el archivo `.env`:
   ```env
   OPENAI_API_KEY=sk-tu-key-aquí
   ```
4. Reinicia n8n: `docker-compose restart n8n`

### Anthropic (Claude)

1. Ve a https://console.anthropic.com/
2. Sección **API Keys** → Create Key
3. Cópiala y pégala en el archivo `.env`:
   ```env
   ANTHROPIC_API_KEY=sk-ant-tu-key-aquí
   ```
4. Reinicia n8n: `docker-compose restart n8n`

### Configurar credenciales EN n8n

Después de configurar las keys en `.env`:

1. Abre n8n: http://localhost:5678
2. Click en **Credentials** (menú izquierdo)
3. **Add Credential** → Busca "OpenAI" o "Anthropic"
4. Nombre: `OpenAI API` o `Anthropic API`
5. API Key: Introduce la misma que pusiste en `.env`
6. **Save**

---

## Solución de Problemas Comunes

### "Puerto 5678 ya en uso"
**Solución**: Cambia el puerto en `.env` a otro (ej: 5679)
```env
N8N_PORT=5679
```
Luego reinicia: `docker-compose down && docker-compose up -d`

### "Cannot connect to database"
**Solución**: PostgreSQL está iniciándose. Espera 30 segundos.

### "Authentication failed"
**Solución**: Verifica las credenciales en el archivo `.env`:
- Variable: `N8N_BASIC_AUTH_PASSWORD`

### n8n no carga
**Solución**:
1. `docker-compose ps` - Verifica que esté "Up"
2. `docker-compose logs n8n` - Mira los errores
3. `docker-compose restart n8n` - Reinicia

---

## Estructura de Carpetas

```
HV_n8n/
├── .env                # TUS SECRETOS (nunca subir a git)
├── docker-compose.yml  # Configuración de contenedores
├── start.sh           # Script de inicio rápido
├── workflows/         # Flujos de ejemplo
└── data/              # Datos persistentes
    ├── postgres/      # Base de datos
    └── n8n/           # Workflows guardados
```

---

## ¿Qué Hace Cada Contenedor?

### PostgreSQL (`postgres`)
- **Función**: Almacena todos tus workflows, ejecuciones y credenciales
- **Puerto interno**: 5432
- **Datos**: Se guardan en `./data/postgres/`

### n8n (`n8n`)
- **Función**: La aplicación web donde creas workflows
- **Puerto**: 5678 → http://localhost:5678
- **Datos**: Se guardan en `./data/n8n/`

---

## Tips Útiles

### Backup de workflows
```bash
# Exporta toda la base de datos
docker exec n8n_postgres pg_dump -U n8n n8n > backup.sql
```

### Ver uso de recursos
```bash
docker stats
```

### Acceder a la consola de PostgreSQL
```bash
docker exec -it n8n_postgres psql -U n8n -d n8n
```

### Ver workflows guardados
```bash
ls -la data/n8n/
```

---

## Próximos Pasos

1. ✅ Arranca el proyecto: `./start.sh`
2. ✅ Accede a n8n: http://localhost:5678
3. ✅ Importa un workflow de ejemplo
4. ✅ Configura tus API keys
5. ✅ Ejecuta tu primer workflow
6. 🚀 Crea tu propio workflow

---

## Enlaces Útiles

- [Documentación completa](README.md)
- [Documentación oficial n8n](https://docs.n8n.io/)
- [Workflows de la comunidad](https://n8n.io/workflows/)
- [OpenAI API Docs](https://platform.openai.com/docs/)
- [Anthropic API Docs](https://docs.anthropic.com/)

---

**¿Problemas?** Revisa el archivo [README.md](README.md) completo o los logs: `docker-compose logs -f`
