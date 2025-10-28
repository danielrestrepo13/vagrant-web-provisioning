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

```bash
git clone https://github.com/<tu_usuario>/vagrant-web-provisioning.git
cd vagrant-web-provisioning

## 🚀 Pasos Generales
Clonar este repositorio.
- Ejecutar vagrant up para levantar las máquinas.
- Acceder a la máquina web en: http://192.168.56.10
- Verificar los archivos index.html y info.php desde el navegador.

## 💡 Reto
- Completar provision-db.sh para instalar PostgreSQL.

- Crear una base de datos y tabla de ejemplo.

- Conectar la página PHP a la base de datos y mostrar los datos.



