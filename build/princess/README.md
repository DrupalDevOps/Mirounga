PRINCESS
========

Princess is a barebones ingress controller for Docker based on Nginx.

It arose from the desire to route a collection of docker projects through
a single http port (80), while avoiding manually managing hostnames on
local `/etc/hosts` files.

It uses:

- Nginx to proxy traffic from port 80 (or any desired port) to Docker containers.
- Virtual host naming to identify and route traffic to applications.
- Node.js to automatically detect changes within the Docker Engine and update the traffic rules.
- Supervisor to manage the nginx and nodejs process lifecycles.
