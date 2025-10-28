#!/usr/bin/env bash

# Actualizar paquetes
sudo apt-get update -y

# Instalar PostgreSQL
sudo apt-get install -y postgresql postgresql-contrib

# Iniciar servicio
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Determinar la versión de PostgreSQL para las rutas de configuración
PG_CONF_DIR="/etc/postgresql/12/main"
echo "Usando directorio de configuración: $PG_CONF_DIR"

# Archivo de configuración
PG_CONF_FILE="$PG_CONF_DIR/postgresql.conf"
# Archivo de autenticación de clientes
PG_HBA_FILE="$PG_CONF_DIR/pg_hba.conf"


# ------------------------------------------------------------------
# 2. CONFIGURACIÓN DE ACCESO EXTERNO
# ------------------------------------------------------------------
echo "Configurando PostgreSQL para aceptar conexiones externas..."


# 2.1. Modificar postgresql.conf para escuchar en todas las IPs ('*')
# Busca y reemplaza la línea de listen_addresses

# Esta línea fuerza el valor correcto, sin importar la sintaxis original
sudo sed -i -r "s/^(#)?listen_addresses\s*=\s*'.*'/listen_addresses = '*'/" $PG_CONF_FILE

# 2.2. Modificar pg_hba.conf para permitir la conexión desde la red Vagrant (192.168.56.x)
# Añade una regla al final del archivo para permitir la conexión al usuario 'daniel'
sudo sed -i '/192.168.56.0\/24/d' $PG_HBA_FILE
echo "host    taller_sistemas_operativos    daniel    192.168.56.0/24    md5" | sudo tee -a $PG_HBA_FILE


# 2.3. Reiniciar el servicio para aplicar los cambios de configuración
sudo systemctl restart postgresql
echo "¡PostgreSQL configurado para escuchar en la red!"



# Crear base de datos, usuario y tabla de ejemplo
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
SET ROLE daniel;

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

