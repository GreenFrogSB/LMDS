<!DOCTYPE html>

<head>
  <title>LMDS Web Server Test Page</title>
  <!-- Required meta tags -->
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

  <!-- Bootstrap CSS-->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBo$

</head>

  <body class=" bg-dark">


  <div class="container">
    <div class="text-center pt-3">
      <div class="bg-dark text-white">
        <h1> LMDS WebServer is <font color=#3cfc44>UP </font>(<?php print $_SERVER['SERVER_SOFTWARE']; ?>)</h1>
        <h3 class="mb-3">
          <font color=#009900>NGINX</font> +
          <font color=#cccccc>MariaDB</font> +
          <font color=#576490>PHP</font> +
          <font color=#6C78AF>php</font>
          <font color=#F89C0E>MyAdmin</font>
        </h3>


        <p>This <font color=#55b5e2>index.php</font> file is locard in: <br>
          <font color=#edd207>~/LMDS/volumes/WebServ/ngnix01/www/html/index.php</font><br>
          Replace it with your own project.
        </p>

        <div class=" bg-dark text-white m-2">
          <a target="_blank" href="http://<?php print $_SERVER{
                                            'HTTP_HOST'}; ?>:8888">
            <font color=#6C78AF>php</font>
            <font color=#F89C0E>MyAdmin</font>
          </a>:
          <?php print $_SERVER{
            'HTTP_HOST'}; ?>:8888<br>

          <font color=#edd207>Trouble login into phpMyAdmin - use Chrome Incognito mode.</font>

          <br>
          SERVER: mariadb<br>
          USER: lmds <br>
          PASSWORD: passw0rd <br>
        </div>

        <?php
        $dbname = 'lmdsdb';
        $dbuser = 'lmds';
        $dbpass = 'passw0rd';
        $dbhost = 'mariadb';

        $connect = mysqli_connect($dbhost, $dbuser, $dbpass) or die("Unable to Connect to '$dbhost'");
        mysqli_select_db($connect, $dbname) or die("Could not open the db '$dbname'");
        ?>

        Database: <?php print  $_SERVER{
                    'HTTP_HOST'}; ?>:3306<br>
        MariaDB: <?php echo  $connect->server_info; ?>
        <?php

        $test_query = "SHOW TABLES FROM $dbname";
        $result = mysqli_query($connect, $test_query);

        $tblCnt = 0;
        while ($tbl = mysqli_fetch_array($result)) {
          $tblCnt++;
          #echo $tbl[0]."<br />\n";
        }

        if (!$tblCnt) {
          echo "<br>There are no tables in the Database";
        } else {
          echo "<br>There are $tblCnt tables<br>";
        }

        /* close connection */
        $connect->close();
        ?>
      </div>
    </div>
  </div>

  <?php
  // Show all information, defaults to INFO_ALL
  phpinfo();
  ?>

  </body>

  </html>