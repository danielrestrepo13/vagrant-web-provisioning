# 🧾 Taller Vagrant + Provisionamiento con Shell
**Estudiante:** Daniel David García Restrepo  
**Universidad Autónoma de Occidente – Octubre 2025**

Este repositorio contiene la configuración completa de un entorno de dos máquinas virtuales (**web** y **db**) utilizando **Vagrant** y **Shell Provisioning**, logrando el despliegue de una aplicación PHP que se conecta a una base de datos PostgreSQL.

---

## 🎯 Objetivo
Implementar un entorno virtualizado con **Vagrant** que incluya:
- Una máquina **web** con **Apache y PHP**.
- Una máquina **db** con **PostgreSQL**.
- Conexión entre ambas máquinas para desplegar un sitio dinámico en PHP que muestre datos desde la base de datos.

---

## ⚙️ Clonación del repositorio
Primero se realizó un fork del repositorio base y se clonó en el equipo local:

git clone https://github.com/<tu_usuario>/vagrant-web-provisioning.git
cd vagrant-web-provisioning

---

## Pasos Generales
Clonar este repositorio.
- Ejecutar vagrant up para levantar las máquinas.
- Acceder a la máquina web en: http://192.168.56.10
- Verificar los archivos index.html y info.php desde el navegador.

## 💡 Reto
- Completar provision-db.sh para instalar PostgreSQL.
- Crear una base de datos y tabla de ejemplo.
- Conectar la página PHP a la base de datos y mostrar los datos.

## 1. Proceso
Se definieron dos máquinas virtuales en el Vagrantfile con sus respectivas IPs privadas para comunicación interna:

### Máquina / Rol / Dirección IP Privada / Propósito
**web** / Servidor Web/App / 192.168.56.10 / Apache, PHP y la aplicación web
**db** / Base de Datos / 192.168.56.11 / Servidor PostgreSQL

## 2. Pasos de Instalación y Provisionamiento
- Para levantar y configurar el entorno, se deben seguir estos pasos desde la carpeta raíz del proyecto:

Levantar y Provisionar Ambas Máquinas:
Este comando inicializa las VMs y ejecuta los scripts de provisionamiento (provision-web.sh y provision-db.sh).
vagrant up

- Reprovisionamiento (si ya están encendidas):
vagrant provision web
vagrant provision db

- Acceso a la Aplicación:
Sitio web principal: http://192.168.56.10

Página PHP conectada a PostgreSQL: http://192.168.56.10/info.php

## 3. Scripts de Provisionamiento
## A. provision-web.sh (Máquina Web)
Instala y configura Apache, PHP y el módulo PHP–PostgreSQL:

#!/usr/bin/env bash

### Actualizar paquetes
sudo apt-get update -y

### Instalar Apache, PHP y el módulo de PostgreSQL
sudo apt-get install -y apache2 php libapache2-mod-php php-pgsql

### Habilitar e iniciar Apache
sudo systemctl enable apache2
sudo systemctl start apache2

### Reiniciar Apache para cargar el módulo php-pgsql
sudo systemctl restart apache2

### Copiar archivos del proyecto (carpeta compartida Vagrant)
sudo cp -r /vagrant/www/* /var/www/html/

### Dar permisos al servidor web
sudo chown -R www-data:www-data /var/www/html

## B. provision-db.sh (Máquina DB)
Instala PostgreSQL, configura la red para aceptar conexiones externas y crea la base de datos con datos de ejemplo.
#!/usr/bin/env bash

### Actualizar paquetes e instalar PostgreSQL
sudo apt-get update -y
sudo apt-get install -y postgresql postgresql-contrib

### Iniciar servicio
sudo systemctl enable postgresql
sudo systemctl start postgresql

### Configuración de rutas fijas (versión 12)
PG_CONF_DIR="/etc/postgresql/12/main"
PG_CONF_FILE="$PG_CONF_DIR/postgresql.conf"
PG_HBA_FILE="$PG_CONF_DIR/pg_hba.conf"

echo "Configurando PostgreSQL para aceptar conexiones externas..."

### Habilitar escucha en todas las IPs
sudo sed -i -r "s/^(#)?listen_addresses\s*=\s*'.*'/listen_addresses = '*'/" $PG_CONF_FILE

### Permitir conexión desde la red privada de Vagrant
sudo sed -i '/192.168.56.0\/24/d' $PG_HBA_FILE
echo "host    taller_sistemas_operativos    daniel    192.168.56.0/24    md5" | sudo tee -a $PG_HBA_FILE

### Reiniciar PostgreSQL
sudo systemctl restart postgresql

### Crear base de datos, usuario y tabla
sudo -u postgres psql <<EOF
DROP DATABASE IF EXISTS taller_sistemas_operativos;
DROP USER IF EXISTS daniel;

CREATE USER daniel WITH PASSWORD '12345';
CREATE DATABASE taller_sistemas_operativos OWNER daniel;

\c taller_sistemas_operativos
SET ROLE daniel;

CREATE TABLE estudiantes (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(50),
  carrera VARCHAR(50)
);
INSERT INTO estudiantes (nombre, carrera) VALUES
('Daniel García', 'Ingeniería de Datos e IA'),
('David Restrepo', 'Administración de Empresas'),
('Pepito Pérez', 'Ingeniería Informática');
EOF

echo "Provisionamiento de la base de datos completado."

## 4. Archivo info.php
Archivo PHP conectado a PostgreSQL que muestra los datos de la tabla estudiantes.

<!DOCTYPE html>
<html>
<head>
  <title>Conexión PHP a PostgreSQL</title>
  <meta charset="UTF-8">
</head>
<body>
  <h1>Hola desde PHP, soy Daniel David García Restrepo</h1>
  <p>Este sitio web está corriendo con PHP en Vagrant y Apache.</p>
  <p>Universidad Autónoma de Occidente - Octubre 2025</p>

  <hr>

  <h2>Conexión a la base de datos PostgreSQL</h2>

  <?php
  $host = "192.168.56.11";
  $dbname = "taller_sistemas_operativos";
  $user = "daniel";
  $password = "12345";

  $conn = pg_connect("host=$host dbname=$dbname user=$user password=$password");

  if (!$conn) {
      echo "<p style='color:red;'>❌ Error: No se pudo conectar a la base de datos.</p>";
  } else {
      echo "<p style='color:green;'>✅ Conexión exitosa a la base de datos.</p>";
      $result = pg_query($conn, "SELECT * FROM estudiantes");
      if ($result) {
          echo "<table border='1' cellpadding='5'>
                  <tr><th>ID</th><th>Nombre</th><th>Carrera</th></tr>";
          while ($row = pg_fetch_assoc($result)) {
              echo "<tr><td>{$row['id']}</td><td>{$row['nombre']}</td><td>{$row['carrera']}</td></tr>";
          }
          echo "</table>";
      } else {
          echo "<p>No se pudo ejecutar la consulta.</p>";
      }
      pg_close($conn);
  }
  ?>
</body>
</html>

- **Acceso desde el navegador:**
http://192.168.56.10/info.php


## 5. 📸 Evidencia de Ejecución y Resultado Final

![Sitio Web Apache](capturas/Sitio_Web_Apache.png)
![Conexión PHP PostgreSQL](capturas/Conexión_PHP_PostgreSQL.png)








  
  
  
  




