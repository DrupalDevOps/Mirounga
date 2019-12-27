#!/usr/bin/env bash

# Display Composer version.
composer --ansi --version
pdepend --version
phpcs --version
phpcs -i
echo "Type phpcs --help for more help with PHP Code Sniffer."
echo ""
drush --version
which drush
echo "\$COMPOSER_HOME: ${COMPOSER_HOME}"

/bin/zsh --interactive
