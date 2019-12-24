#
# Rust Ion shell https://github.com/redox-os/ion.
#
FROM alexanderallen/php-cli:d8

ENV BUILD_DEPS \
      autoconf \
      file \
      g++ \
      gcc \
      libc-dev \
      make \
      pkgconf \
      re2c \
      git \
      # https://www.rust-lang.org
      rust

RUN \
    cd /tmp \
    && apk add --no-cache --virtual .build-deps $BUILD_DEPS \
    && apk add --no-cache \
      cargo \
    && git clone https://gitlab.redox-os.org/redox-os/ion/ \
    && ( \
      cd ion \
      # By default RUSTUP equals 1, which is for developmental purposes
      && RUSTUP=0 make \
      && make install prefix=/usr \
      && make update-shells prefix=/usr \
    ) \
    && rm -rf ion \
    && apk del .build-deps
