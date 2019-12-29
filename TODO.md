# TODO:

  - Parametrize project assets using .env files under ./run folder with examples per OS.
  - CONFIRM file perms for Drupal 8 install, and whether service user param is needed, or more mount tweaks.
  - Setup XHProf containers, test on php-fpm+nginx, and on cli (drush).
  - Explore dynamic nginx vhost solutions (might require openresty or lua), potentially using env vars.
  - Acquia API integration: regular ACE api, ACSF, automatic authentication and WORKING drush alias retrieval.
  - Currently ACSF aliases + uris are poorly or not documented, current ACE aliases useless for ACSF without --uri params.
  - Add back ability to customize MySQL startup options on entrypoint via compose services' command options.
  - Optimize ship size on php-fpm images by breaking composer install into runtime (like mariadb image does ATM)
  - Test portability of containers into Kubernetes!
