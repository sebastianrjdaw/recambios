### **Guía de Instalación del Entorno WordPress con Docker**

Esta guía te ayudará a configurar y trabajar con un entorno de desarrollo WordPress utilizando Docker. A continuación, se detallan los pasos para la instalación y el uso del entorno.

---

### **1. Requisitos Previos**

Antes de comenzar, asegúrate de tener instalado en tu máquina:

- **Docker**: [Descargar Docker](https://www.docker.com/products/docker-desktop/)
- **Docker Compose**: Viene incluido con Docker Desktop o puede instalarse por separado.

---

### **2. Preparar el Proyecto**

1. Clona el repositorio o crea la carpeta donde alojarás tu entorno:
   ```bash
   git clone <URL_DEL_REPOSITORIO>
   cd wordpress-docker
   ```

2. Copia el archivo de ejemplo `.env-example` y renómbralo como `.env`:
   ```bash
   cp .env-example .env
   ```

3. **Edita el archivo `.env`**:
   Configura las credenciales de base de datos y el sitio WordPress. Por ejemplo:
   ```env
   MYSQL_ROOT_PASSWORD=root_password
   MYSQL_DATABASE=wp_database
   MYSQL_USER=wp_user
   MYSQL_PASSWORD=wp_password

   WORDPRESS_URL=http://localhost:8000
   WORDPRESS_TITLE=Mi Sitio WordPress
   WORDPRESS_ADMIN_USER=admin
   WORDPRESS_ADMIN_PASSWORD=admin_password
   WORDPRESS_ADMIN_EMAIL=admin@example.com
   ```

---

### **3. Instalación de Plugins**

1. **Plugins a instalar**:
   Crea un archivo de texto `plugins.txt` dentro del directorio raíz del proyecto. Este archivo debe contener los nombres de los plugins a instalar. Por ejemplo:
   ```txt
   woocommerce
   woocommerce-gateway-stripe
   redsys-gateway-for-woocommerce
   seo-by-rank-math
   wp-mail-smtp
   litespeed-cache
   updraftplus
   ```

2. Los plugins se instalarán automáticamente al ejecutar el script `setup.sh`.

---

### **4. Levantar los Contenedores**

1. Levanta los contenedores con el siguiente comando:
   ```bash
   docker-compose up -d
   ```

2. Verifica que los contenedores estén corriendo:
   ```bash
   docker ps
   ```

Deberías ver tres servicios: `wordpress_app`, `wordpress_db`, y `phpmyadmin`.

---

### **5. Configuración Inicial con `setup.sh`**

Una vez que los contenedores estén levantados, ejecuta el script de configuración:

```bash
./setup.sh
```

Este script realizará las siguientes acciones:

- Instalará WordPress si no está instalado.
- Configurará el sitio con las credenciales definidas en `.env`.
- Instalará y activará los plugins definidos en `plugins.txt`.
- Importará una base de datos si el archivo `db.sql` está presente en el directorio `db_data`.

---

### **6. Acceder al Sitio y phpMyAdmin**

- **Sitio WordPress**: [http://localhost:8000](http://localhost:8000)
- **phpMyAdmin**: [http://localhost:8080](http://localhost:8080)

Para phpMyAdmin, usa las siguientes credenciales:
- **Servidor MySQL (Host):** `db`
- **Usuario:** `root` o el configurado en `.env` (`wp_user`).
- **Contraseña:** Configurada en `.env` (`root_password` o `wp_password`).

---

### **Estructura del Proyecto**

- `docker-compose.yml`: Define los servicios de Docker (WordPress, MySQL, phpMyAdmin).
- `.env`: Archivo de configuración para credenciales y variables del entorno.
- `plugins.txt`: Lista de plugins de WordPress que se instalarán automáticamente.
- `wordpress/`: Carpeta persistente que almacena los archivos de WordPress.
- `db_data/`: Carpeta persistente que almacena los datos de MySQL.
- `setup.sh`: Script para la configuración inicial del entorno.

---

### **7. Limpieza del Entorno**

Si necesitas reiniciar o limpiar el entorno:

1. Detén los contenedores y elimina volúmenes:
   ```bash
   docker-compose down --volumes
   ```

2. Elimina datos persistentes si es necesario:
   ```bash
   sudo rm -rf ./db_data ./wordpress
   ```

3. Levanta los contenedores nuevamente:
   ```bash
   docker-compose up -d
   ./setup.sh
   ```

---
