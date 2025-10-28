<!DOCTYPE html>
<html>
<head>
  <title>Conexión PHP a PostgreSQL</title>
  <meta charset="UTF-8">
</head>
<body>
  <h1>Hola desde PHP, soy Daniel David Garcia Restrepo</h1>
  <p>Este sitio web está corriendo con PHP en Vagrant y Apache.</p>
  <p>Universidad Autónoma de Occidente - Octubre 2025</p>

  <hr>

  <h2>Conexión a la base de datos PostgreSQL</h2>

  <?php
  // Datos de conexión (provision-db.sh)
  $host = "192.168.56.11";    // IP privada de la máquina
  $dbname = "taller_sistemas_operativos";
  $user = "daniel";
  $password = "12345";

  // Intentar conexión
  $conn = pg_connect("host=$host dbname=$dbname user=$user password=$password");

  if (!$conn) {
      echo "<p style='color:red;'>❌ Error: No se pudo conectar a la base de datos PostgreSQL.</p>";
  } else {
      echo "<p style='color:green;'>✅ Conexión exitosa a la base de datos.</p>";

      // Ejecutar consulta
      $result = pg_query($conn, "SELECT * FROM estudiantes");

      if ($result) {
          echo "<h3>Listado de estudiantes:</h3>";
          echo "<table border='1' cellpadding='5'>
                  <tr><th>ID</th><th>Nombre</th><th>Carrera</th></tr>";
          while ($row = pg_fetch_assoc($result)) {
              echo "<tr>
                      <td>{$row['id']}</td>
                      <td>{$row['nombre']}</td>
                      <td>{$row['carrera']}</td>
                    </tr>";
          }
          echo "</table>";
      } else {
          echo "<p>No se pudo ejecutar la consulta.</p>";
      }

      // Cerrar conexión
      pg_close($conn);
  }
  ?>
</body>
</html>