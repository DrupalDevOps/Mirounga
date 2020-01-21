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
  - Test XDebug with new containers, document on medium (same for xhprof)/
  - Use ENV variable to determine whether running in production (named volumes, no debugging) or development (volume mounts, debugging)
  - Isolate core PHP/MySQL/Memcache stack from framework containers.

Images

- Need xhprof
- Need MySQL viewer

Environment

- Set in bash/shell env
- Set in docker-compose by default
- We can do a MySQL service with slow logs enabled based on the same image.

Mounts

- Code volume is done for PROD
- Need volume set up for DEV (mounts and or VSC dockerfiles)

Debugging

- PHP FPM DEV has debugger. Runs w/ xdebug. exposes xdebug port. is therefore accessible for debugging.
- PHP CLI, depending on build target, might not be built from the PHPFPM DEV target.
- There is a CLI build target w/o debugging. Adding debugging to it would duplicate xdebug dependencies downstream, that are available
  technically not-quite-upstream but rather on an upstream branch in the the form of the PHP-FPM-DEV build target.
  So adding XDebug to prod PHP CLI would duplicate dependencies available on a sister branch upstream (PHPFPMDEV)
- Can a PHP CLI DEV build target be built from the PHP FPM DEV target.
- And would that also create it's own duplication, where FPM DEV -> CLI DEV (inherits xdebug, but duplicates composer)?
- Can there be a viable merge strategy via --copy-from COPY instruction? Emphasis on viable, repeatable, predictable.

- Before we head to create a new CLI DEV build target, have to make sure that
- existing prod targets work (WORKING)
- existing dev targets are workable, so we have something to start from a new build target
-
