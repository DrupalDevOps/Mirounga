#!/usr/bin/env bash

# Display Composer version.
echo "[Composer]"
composer --ansi --version
echo ""

# Show available Coding Standards and versions for Manny's tools.
echo "[PHPCS, PDepend, PHPMD]"
pdepend --version
phpmd --version
echo ""
phpcs --version
phpcs -i
echo "Type phpcs --help for more help with PHP Code Sniffer."
echo ""

# Display some help with debugging.
echo "[XDebug]"
echo "To debug any PHP CLI script, use: "
echo "export PHP_IDE_CONFIG='serverName=docker' \\"
echo "export XDEBUG_CONFIG='idekey=${XDEBUG_IDE_KEY}'"

# Provide the user with a Z Shell as the entrypoint.
/bin/zsh --interactive
