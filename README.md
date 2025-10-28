# Taller Vagrant + Provisionamiento con Shell
## Estudiante: Daniel David Garcia Restrepo
Universidad Autónoma de Occidente - Octubre 2025

Este repositorio contiene la configuración completa de un entorno de dos máquinas virtuales (web y db) utilizando Vagrant y Shell Provisioning, logrando el despliegue de una aplicación PHP que se conecta a una base de datos PostgreSQL.

## Objetivo
Implementar un entorno virtualizado con **Vagrant** que incluya:
- Una máquina **web** con **Apache y PHP**.
- Una máquina **db** con **PostgreSQL**.
- Conexión entre ambas máquinas para desplegar un sitio dinámico en PHP que muestre datos desde la base de datos.

### Clonación del repositorio
Primero se realizó un fork del repositorio base y se clonó en el equipo local:
```bash
git clone https://github.com/<tu_usuario>/vagrant-web-provisioning.git
cd vagrant-web-provisioning

## Pasos
1. Clonar este repositorio.
2. Ejecutar `vagrant up` para levantar las máquinas.
3. Acceder a la máquina web en: http://192.168.56.10
4. Verificar `index.html` y `info.php`.

## Reto
- Completar `provision-db.sh` para instalar PostgreSQL.
- Crear una base de datos y tabla.
- Conectar la página PHP a la base de datos y mostrar datos.

# Proceso 
## 1. ⚙️ Configuración del Entorno Vagrant

Se definieron dos máquinas virtuales en el `Vagrantfile` con sus respectivas IPs privadas para comunicación interna:

| Máquina | Rol | Dirección IP Privada | Propósito |
| :--- | :--- | :--- | :--- |
| **web** | Servidor Web/App | 192.168.56.10 | Apache, PHP y la aplicación web. |
| **db** | Base de Datos | 192.168.56.11 | Servidor PostgreSQL. |

---

## 2. 🛠️ Pasos de Instalación y Provisionamiento

Para levantar y configurar el entorno, se deben seguir estos pasos desde la carpeta raíz del proyecto:

1.  **Levantar y Provisionar Ambas Máquinas:** Este comando inicializa las VMs y ejecuta los scripts de provisionamiento (`provision-web.sh` y `provision-db.sh`).
    ```bash
    vagrant up
    ```
2.  **Reprovisionamiento (Si las máquinas ya están encendidas):** Si se realizan cambios en los scripts, se debe forzar el provisionamiento en cada máquina.
    ```bash
    vagrant provision web
    vagrant provision db
    ```
3.  **Acceso a la Aplicación:** Una vez que la provisión finalice sin errores, acceda al sitio web en el navegador:
    ```
    [http://192.168.56.10/info.php](http://192.168.56.10/info.php)
    ```

---

## 3. 📄 Scripts de Provisionamiento

### **A. provision-web.sh** (Máquina Web)
Este script instala y configura el servidor web, el intérprete de PHP y el módulo de conexión a PostgreSQL.

```bash
#!/usr/bin/env bash

# Actualizar paquetes
sudo apt-get update -y

# Instalar Apache, PHP y añadir el módulo de PostgreSQL para PHP (php-pgsql)
sudo apt-get install -y apache2 php libapache2-mod-php php-pgsql


# Habilitar e iniciar Apache
sudo systemctl enable apache2
sudo systemctl start apache2

# Reiniciar Apache para cargar el módulo php-pgsql
sudo systemctl restart apache2 

# Copiar archivos del proyecto (carpeta compartida Vagrant)
sudo cp -r /vagrant/www/* /var/www/html/

# Dar permisos al servidor web
sudo chown -R www-data:www-data /var/www/html

### **B. provision-db.sh** (Máquina DB)
Este script instala PostgreSQL, configura la red para aceptar conexiones externas y crea la base de datos, el usuario y la tabla.

#!/usr/bin/env bash

# Actualizar paquetes e instalar PostgreSQL
sudo apt-get update -y
sudo apt-get install -y postgresql postgresql-contrib

# Iniciar servicio
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Configuración de Rutas Fijas (Versión 12)
PG_CONF_DIR="/etc/postgresql/12/main"
PG_CONF_FILE="$PG_CONF_DIR/postgresql.conf"
PG_HBA_FILE="$PG_CONF_DIR/pg_hba.conf"


# ------------------------------------------------------------------
# CONFIGURACIÓN DE ACCESO EXTERNO
# ------------------------------------------------------------------
echo "Configurando PostgreSQL para aceptar conexiones externas..."

# 2.1. Modificar postgresql.conf: Habilita la escucha en todas las IPs ('*')
sudo sed -i -r "s/^(#)?listen_addresses\s*=\s*'.*'/listen_addresses = '*'/" $PG_CONF_FILE

# 2.2. Modificar pg_hba.conf: Permite conexión desde la red Vagrant (192.168.56.x)
sudo sed -i '/192.168.56.0\/24/d' $PG_HBA_FILE
echo "host    taller_sistemas_operativos    daniel    192.168.56.0/24    md5" | sudo tee -a $PG_HBA_FILE

# 2.3. Reiniciar el servicio
sudo systemctl restart postgresql
echo "¡PostgreSQL configurado para escuchar en la red!"


# ------------------------------------------------------------------
# CREACIÓN DE BASE DE DATOS Y DATOS DE EJEMPLO
# ------------------------------------------------------------------
echo "Creando base de datos, usuario y tabla..."
sudo -u postgres psql <<EOF
-- Eliminar si existen para un provisionamiento limpio
DROP DATABASE IF EXISTS taller_sistemas_operativos;
DROP USER IF EXISTS daniel;

-- Crear usuario y base de datos
CREATE USER daniel WITH PASSWORD '12345';
CREATE DATABASE taller_sistemas_operativos OWNER daniel;

-- Conectarse a la nueva base de datos y crear la tabla
\c taller_sistemas_operativos
SET ROLE daniel; -- Asegura que daniel sea el propietario de los objetos, evitando errores de permisos (No se pudo ejecutar la consulta)

CREATE TABLE estudiantes (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(50),
  carrera VARCHAR(50)
);
INSERT INTO estudiantes (nombre, carrera) VALUES
('Daniel García', 'Ingeniería de Datos e IA'),
('David Restrepo', 'Administración de Empresas'),
('Pepito Perez', 'Ingeniería Informática');
EOF

echo "Provisionamiento de la base de datos completado."

## 4. 📸 Evidencia de Ejecución y Resultado Final

