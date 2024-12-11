#!/bin/bash

# --- setup.sh ---
# Este script configura el entorno inicial de WordPress usando Docker.

# Cargar variables del archivo .env
if [ -f .env ]; then
  echo "Cargando configuración desde .env..."
  source .env
else
  echo "No se encontró el archivo .env. Abortando."
  exit 1
fi

# Inicia los contenedores Docker
echo "Iniciando los contenedores..."
docker-compose up -d

# Espera a que el contenedor de WordPress esté listo
echo "Esperando a que el contenedor de WordPress esté listo..."
sleep 15

# Verifica si WordPress está instalado
echo "Verificando si WordPress está instalado..."
docker exec wordpress_app wp core is-installed --allow-root
if [ $? -ne 0 ]; then
  echo "Instalando WordPress..."
  docker exec wordpress_app wp core install \
      --url="$WORDPRESS_URL" \
      --title="$WORDPRESS_TITLE" \
      --admin_user="$WORDPRESS_ADMIN_USER" \
      --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
      --admin_email="$WORDPRESS_ADMIN_EMAIL" \
      --allow-root
else
  echo "WordPress ya está instalado."
fi

# Instala y activa plugins desde plugins.txt
echo "Instalando y activando plugins..."
while IFS= read -r plugin; do
  docker exec wordpress_app wp plugin install "$plugin" --activate --allow-root
done < plugins.txt

# Importa la base de datos, si existe
if [ -f ./db_data/db.sql ]; then
  echo "Importando base de datos..."
  docker exec wordpress_app wp db import /var/www/html/db_data/db.sql --allow-root
  echo "Base de datos importada con éxito."
else
  echo "No se encontró el archivo db.sql. Continuando sin importar la base de datos."
fi

echo "Configuración inicial completa. Accede a $WORDPRESS_URL para empezar."
