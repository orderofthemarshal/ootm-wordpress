#!/bin/bash
# Container entrypoint: starts php-fpm then hands off to nginx as PID 1.
#
# Execution flow:
#   1. php-fpm daemonizes itself into the background.
#   2. We poll until php-fpm is ready to accept FastCGI connections.
#   3. exec replaces this script with nginx, which becomes the container's
#      main process and receives SIGTERM / SIGQUIT from the runtime on stop.

set -euo pipefail

# Start PHP-FPM.  The default Fedora config has daemonize = yes, so this
# returns immediately after forking the worker processes.
php-fpm

# Wait for PHP-FPM to accept connections on 127.0.0.1:9000 using bash's
# built-in TCP pseudo-device (no netcat required).
echo "Waiting for PHP-FPM to be ready..."
until bash -c 'echo > /dev/tcp/127.0.0.1/9000' 2>/dev/null; do
    sleep 0.1
done
echo "PHP-FPM ready."

# Replace this shell with nginx.  nginx runs in the foreground (-g 'daemon
# off;') and becomes PID 1, so container stop signals are delivered to it
# directly for a graceful shutdown.
exec nginx -g 'daemon off;'
