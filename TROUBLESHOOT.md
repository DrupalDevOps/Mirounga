Restart WSL instance

https://superuser.com/a/1347725/80143


    wsl -l
    wsl.exe -t <DistroName>
    wsl.exe -t Alpine

If you need to update `/etc/hosts` on Windows:

    # Open elevated priviledge cmd.exe shell and type:
    notepad C:\Windows\System32\Drivers\etc\hosts

Connect to database from PHP-FPM, on running stack

     ../../Sites/localenv/scripts/vsd-connect.sh php-fpm
     apk add mariadb-client
     mariadb -hmysql

Connect to database from drush container

     ../../Sites/localenv/scripts/vsd-drush.sh
     mysql -uroot -hmysql

Import a database

     ../../Sites/localenv/scripts/vsd-drush.sh
     cd /vsdroot
     mysql -uroot -hmysql drupal_database_name < database_dump.sql

Associate .module files with php interpreter

- https://code.visualstudio.com/docs/languages/identifiers
