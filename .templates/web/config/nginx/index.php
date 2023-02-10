<!DOCTYPE html>

<head>
  <title>LMDS Web Server Test Page</title>
  <!-- Required meta tags -->
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

  <!-- Bootstrap CSS-->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBo$

</head>

  <body class="bg-dark">

  <div class="bg-dark">

    <div class="container">
    <div class="text-center pt-3">
      <div class="bg-dark text-white">
        <h1> LMDS <font color=#3cfc44> <?php print $_SERVER['SERVER_NAME']; ?> </font> Web Server is <font color=#3cfc44> UP </font></h1>
        <h3 class="mb-3">
          <font color=#009900>NGINX</font> +
          <font color=#cccccc>MariaDB</font> +
          <font color=#576490>PHP</font> +
          <font color=#6C78AF>php</font>
          <font color=#F89C0E>MyAdmin</font>
        </h3>


        <p>This <font color=#55b5e2>index.php</font> file location: <br>
          <font color=#edd207>~/LMDS/volumes/WebServ/<?php print $_SERVER['SERVER_NAME']; ?>/www/html/index.php</font><br>
          Replace it with your own project.
        </p>

        <div class=" bg-dark text-white m-2">
          <a target="_blank" href="http://<?php print strtok($_SERVER['HTTP_HOST'], ':'); ?>:8888">
            <font color=#6C78AF>php</font>
            <font color=#F89C0E>MyAdmin</font>
          </a>:
          <?php print strtok($_SERVER['HTTP_HOST'], ':'); ?>:8888<br>

          <font color=#edd207>Trouble login into phpMyAdmin - use Chrome Incognito mode.</font>

          <br>
          MariaDB: <?php print strtok($_SERVER['HTTP_HOST'], ':'); ?>:3306<br>
          USER: lmds or root <br>
          PASSWORD: passw0rd <br>
        </div>

      </div>
    </div>
  </div>

  <?php
  // Show all information, defaults to INFO_ALL
  phpinfo();
  ?>
</div>
  </body>

  </html>