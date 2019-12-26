#
# Rust Ion shell https://github.com/redox-os/ion.
#
FROM alpine:3.11 AS core

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
      rust \
      cargo

ENV PATH=$HOME/.cargo/bin:$PATH

RUN \
    cd /tmp \
    && apk add --no-cache --virtual .build-deps $BUILD_DEPS \
    # && apk add --no-cache \
    && echo "" \
    && echo "Installing mdbook" \
    && echo "" \
    && cargo install mdbook \
    && echo "" \
    && echo "Installing Ion Shell" \
    && echo "" \
    && git clone https://gitlab.redox-os.org/redox-os/ion/ \
    && ( \
      cd ion \
      # By default RUSTUP equals 1, which is for developmental purposes
      && RUSTUP=0 make \
      && make install prefix=/usr \
      && make update-shells prefix=/usr \
      && echo "" \
      && echo "Building Ion Manual" \
      && echo "" \
      && make manual \
      && $HOME/.cargo/bin/mdbook build -d ../public manual \
    ) \
    && rm -rf ion \
    && apk del .build-deps

# RUN \
#     cargo install mdbook
# export PATH="$HOME/.cargo/bin:$PATH"

# Rust Ion Shell.
ENTRYPOINT ["ion"]
