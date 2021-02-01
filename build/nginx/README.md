Nginx Image
===========

This image contains a vhost optimized to run Drupal 7 or higher.

Nginx is run on Alpine using the `nobody` user, created in the custom image.

Most logs are sent into the physical supplemental log inside the container,
which is persistent as long as the container lives.

Interesting or higher priority logs such as requests to PHP-FPM locations are
surfaced to Docker's `docker logs` or `docker-compose logs` facilities, making
them more accessible but also completely ephemeral.

There is no SSL as it requires too much boilerplate/effort for the container's
purpose, which is local development.


ETC
===


Drupal preset, somewhat dated but still functional.
https://www.nginx.com/resources/wiki/start/topics/recipes/drupal/

Some modern optimizations.
https://thephp.cc/dates/2019/10/international-php-conference/optimizing-nginx-and-php-fpm-from-beginner-to-expert-to-crazy.

Capturing hostnames, should it be needed:

    # Capture the whole hostname, should match a directory.
    # Directive server_name can only be used in server context.
    # http://nginx.org/en/docs/http/ngx_http_core_module.html#server_name
    # http://nginx.org/en/docs/http/server_names.html

    # server_name ~^(?<domaincapture>.*)$;
    # server_name  localhost "";

If you need to update `/etc/hosts` on Windows:

    # Open elevated priviledge cmd.exe shell and type:
    notepad C:\Windows\System32\Drivers\etc\hosts

Location variations

The old school version works, but it's dated. The named location required using an ending slash in order to work.

    location / {
        # Old school, but works.
        try_files $uri /index.php?$query_string; # For Drupal >= 7

        # Doesn't work.
        # try_files $uri $uri/ @php; # For Drupal >= 7
        # try_files $uri @php; # For Drupal >= 7

        # Named location with slash seems to work.
        try_files $uri @php/; # For Drupal >= 7
    }
