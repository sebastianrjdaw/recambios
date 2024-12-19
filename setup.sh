#!/bin/bash

# --- setup.sh ---
# Este script limpia el entorno, configura WordPress usando Docker y realiza una instalación limpia.

# Función para limpiar archivos y carpetas innecesarias
clean_project() {
  echo "Limpiando archivos innecesarios del proyecto..."

  # Eliminar caché y archivos temporales
  rm -rf wordpress/wp-content/cache/*
  rm -rf wordpress/wp-content/uploads/sessions/*
  find wordpress/wp-content/ -type f -name "*.log" -delete
  find wordpress/wp-content/ -type f -name "*.tmp" -delete

  # Eliminar datos de la base de datos si existen
  if [ -d "db_data" ]; then
    echo "Eliminando datos antiguos de la base de datos..."
    rm -rf db_data/*
  fi

  # Eliminar archivos SQL antiguos en el proyecto
  find . -type f -name "*.sql" -delete

  # Eliminar configuraciones sensibles antiguas
  if [ -f "wordpress/wp-config.php" ]; then
    echo "Eliminando archivo wp-config.php..."
    rm -f wordpress/wp-config.php
  fi

  echo "Limpieza completada."
}

# Cargar variables del archivo .env
if [ -f .env ]; then
  echo "Cargando configuración desde .env..."
  source .env
else
  echo "No se encontró el archivo .env. Abortando."
  exit 1
fi

# Ejecutar la limpieza del proyecto
clean_project

# Inicia los contenedores Docker
echo "Iniciando los contenedores..."
docker-compose down
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
if [ -f plugins.txt ]; then
  echo "Instalando y activando plugins..."
  while IFS= read -r plugin; do
    docker exec wordpress_app wp plugin install "$plugin" --activate --allow-root
  done < plugins.txt
else
  echo "No se encontró el archivo plugins.txt. Continuando sin instalar plugins."
fi

# Importa la base de datos si existe un backup
if [ -f db_data/backup_wp.sql ]; then
  echo "Importando base de datos..."
  docker exec -i wordpress_db mysql -u root -proot_password wp_database < db_data/backup_wp.sql
  echo "Base de datos importada con éxito."
else
  echo "No se encontró el archivo backup_wp.sql. Continuando sin importar la base de datos."
fi

echo "Configuración inicial completada. Accede a $WORDPRESS_URL para empezar."
