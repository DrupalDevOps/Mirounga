FROM alexanderallen/nobody:latest

ARG TRAEFIK_MAJOR
ARG TRAEFIK_MINOR
ARG TRAEFIK_PATCH

RUN apk --no-cache add ca-certificates tzdata
RUN set -ex; \
  apkArch="$(apk --print-arch)"; \
  case "$apkArch" in \
  armhf) arch='arm' ;; \
  aarch64) arch='arm64' ;; \
  x86_64) arch='amd64' ;; \
  *) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
  esac; \
  wget --quiet -O /usr/local/bin/traefik \
  "https://github.com/traefik/traefik/releases/download/v${TRAEFIK_MAJOR}.${TRAEFIK_MINOR}.${TRAEFIK_PATCH}/traefik_linux-$arch"; \
  chmod +x /usr/local/bin/traefik
COPY entrypoint.sh /
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["traefik"]

# Metadata
LABEL org.opencontainers.image.vendor="alexanderallen" \
  org.opencontainers.image.url="https://alexanderallen.medium.com" \
  org.opencontainers.image.title="VSD-Proxy-9000" \
  org.opencontainers.image.description="Proxy image for VSD platform." \
  org.opencontainers.image.version="v${TRAEFIK_MAJOR}.${TRAEFIK_MINOR}.${TRAEFIK_PATCH}" \
  org.opencontainers.image.documentation="https://docs.traefik.io"
