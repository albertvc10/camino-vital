#!/bin/bash

echo "🚀 Iniciando n8n con Docker..."
echo ""

# Verificar si Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker no está corriendo"
    echo "   Por favor, inicia Docker Desktop y vuelve a intentar"
    exit 1
fi

# Verificar si existe el archivo .env
if [ ! -f .env ]; then
    echo "⚠️  Advertencia: No existe el archivo .env"
    echo "   Creando .env desde .env.example..."

    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ Archivo .env creado"
        echo "   IMPORTANTE: Edita el archivo .env y configura tus contraseñas y API keys"
        echo ""
        read -p "Presiona Enter para continuar o Ctrl+C para cancelar..."
    else
        echo "❌ Error: No se encuentra .env.example"
        exit 1
    fi
fi

# Iniciar los contenedores
echo "📦 Iniciando contenedores..."
docker-compose up -d

# Esperar a que los servicios estén listos
echo ""
echo "⏳ Esperando a que los servicios estén listos..."
sleep 5

# Verificar el estado
if docker-compose ps | grep -q "Up"; then
    echo ""
    echo "✅ ¡n8n está corriendo!"
    echo ""
    echo "📍 Accede a n8n en: http://localhost:5678"
    echo ""
    echo "🔑 Credenciales:"
    echo "   Usuario: admin"
    echo "   Contraseña: (revisa el archivo .env)"
    echo ""
    echo "📊 Ver logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "🛑 Detener n8n:"
    echo "   docker-compose down"
    echo ""
else
    echo ""
    echo "❌ Error al iniciar los servicios"
    echo "   Ejecuta 'docker-compose logs' para ver los errores"
    exit 1
fi
