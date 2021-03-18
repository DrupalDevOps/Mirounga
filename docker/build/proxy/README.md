VSD PROXY
=========

Image mostly from https://github.com/traefik/traefik-library-image/tree/master/alpine

Changes/additions:

- Built from the alexanderallen/nobody image:
  - Provides non-root user `nobody` and `su-exec`.
  - Executes process as user `nobody`.
  - Uses latest version of Alpine available.
