    <!DOCTYPE html>

    <head>
      <title>LMDS Web Server Test Page</title>
      <!-- Required meta tags -->
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

      <!-- Bootstrap CSS -->
      <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">

    </head>

    <body>
      <div class="container">

        <div class="row">
          <div class="col-12 mt-4 m-2">
            <h1>LMDS WebServer:</h1>
          </div>
        </div>

        <div class="row">
          <div class="col m-2">
            <?php
            $dbname = 'lmdsdb';
            $dbuser = 'lmds';
            $dbpass = 'passw0rd';
            $dbhost = 'mariadb';

            $connect = mysqli_connect($dbhost, $dbuser, $dbpass) or die("Unable to Connect to '$dbhost'");
            mysqli_select_db($connect, $dbname) or die("Could not open the db '$dbname'");

            /* print server version */
            echo "Database: \n", $connect->server_info;

            $test_query = "SHOW TABLES FROM $dbname";
            $result = mysqli_query($connect, $test_query);

            $tblCnt = 0;
            while ($tbl = mysqli_fetch_array($result)) {
              $tblCnt++;
              #echo $tbl[0]."<br />\n";
            }

            if (!$tblCnt) {
              echo "<p>There are no tables in the Database</p>\n";
            } else {
              echo "<p>There are $tblCnt tables</p>\n";
            }

            /* close connection */
            $connect->close();

            ?>

          </div>
          <div class="col-8">
            SERVER: mariadb<br>
            MYSQL_USER=lmds <br>
            MYSQL_ROOT_PASSWORD=passw0rd <br>
            MYSQL_PASSWORD=passw0rd <br>
            MYSQL_DATABASE=lmdsdb

            <h2><a href="http://<?php print $_SERVER{
                                'HTTP_HOST'}; ?>:8888"> PHP MyAdmin </a> (port 8888)</h2>
          </div>
        </div>

      </div>

      <?php
      // Show all information, defaults to INFO_ALL
      phpinfo();
      ?>


    </body>

    </html>