FROM alexanderallen/php-cli

ARG DRUSH_VERSION='7.x-dev'
ARG DRUSH_ALIAS=drush
ARG INSTALL_PATH=/usr/local/drush
ARG COMPOSER_GLOBAL=0

ENV \
    DRUSH_VERSION=${DRUSH_VERSION} \
    DRUSH_ALIAS=${DRUSH_ALIAS} \
    INSTALL_PATH=${INSTALL_PATH}

RUN if [ "$COMPOSER_GLOBAL" = 1 ]; then \
        composer global require drush/drush:${DRUSH_VERSION}; \
    else \
        mkdir -pv "${INSTALL_PATH}/${DRUSH_ALIAS}" \
        && cd ${INSTALL_PATH}/${DRUSH_ALIAS} \
        && composer require drush/drush:${DRUSH_VERSION}; \
    fi

# Add non-global drush to path.
ENV PATH ${INSTALL_PATH}/${DRUSH_ALIAS}/vendor/bin:$PATH

# Intend for the container to be used interactively instead of for one-off commands.
# ENTRYPOINT ["/bin/zsh", "--interactive"]
