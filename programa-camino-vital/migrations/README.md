# Migraciones de Base de Datos

Este directorio contiene las migraciones SQL para mantener sincronizados los esquemas de local y producción.

## Convención de nombres

```
NNN_descripcion_breve.sql
```

- `NNN`: Número secuencial de 3 dígitos (001, 002, 003...)
- `descripcion_breve`: Descripción en snake_case

## Cómo crear una nueva migración

1. Crear archivo con el siguiente número secuencial
2. Usar `IF NOT EXISTS` / `IF EXISTS` para hacer las migraciones idempotentes
3. Incluir comentarios con fecha y descripción

## Cómo aplicar migraciones en producción

```bash
# Copiar migración al servidor
scp migrations/NNN_descripcion.sql root@164.90.222.166:/tmp/

# Ejecutar migración
ssh root@164.90.222.166 "docker exec -i n8n_postgres psql -U n8n_admin -d n8n < /tmp/NNN_descripcion.sql"
```

## Migraciones aplicadas

| # | Archivo | Fecha | Descripción |
|---|---------|-------|-------------|
| 001 | 001_initial_schema_sync.sql | 2026-02-04 | Sincronización inicial local → producción |

## Notas importantes

- **Siempre** usar `IF NOT EXISTS` para CREATE TABLE/INDEX
- **Siempre** usar `ADD COLUMN IF NOT EXISTS` para ALTER TABLE
- **Nunca** hacer DROP sin confirmación explícita del usuario
- Las migraciones deben ser **idempotentes** (ejecutar 2 veces = mismo resultado)
