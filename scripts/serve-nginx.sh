#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NGINX_CONF="${ROOT_DIR}/.nginx/nginx.conf"
PHP_FPM_CONF="${ROOT_DIR}/.nginx/php-fpm.conf"
PHP_FPM_SOCK="/tmp/ootm-php-fpm.sock"

if ! command -v nginx >/dev/null 2>&1; then
  echo "nginx is not installed. Rebuild the dev container after updating .devcontainer/Containerfile."
  exit 1
fi

if ! command -v php-fpm >/dev/null 2>&1; then
  echo "php-fpm is not installed. Rebuild the dev container after updating .devcontainer/Containerfile."
  exit 1
fi

mkdir -p "${ROOT_DIR}/static"
mkdir -p /tmp/ootm-nginx/client_body /tmp/ootm-nginx/proxy /tmp/ootm-nginx/fastcgi /tmp/ootm-nginx/uwsgi /tmp/ootm-nginx/scgi

cleanup() {
  if [[ -n "${NGINX_PID:-}" ]] && kill -0 "${NGINX_PID}" 2>/dev/null; then
    kill "${NGINX_PID}" 2>/dev/null || true
    wait "${NGINX_PID}" 2>/dev/null || true
  fi

  if [[ -n "${PHP_FPM_PID:-}" ]] && kill -0 "${PHP_FPM_PID}" 2>/dev/null; then
    kill "${PHP_FPM_PID}" 2>/dev/null || true
    wait "${PHP_FPM_PID}" 2>/dev/null || true
  fi

  rm -f "${PHP_FPM_SOCK}"
}

trap cleanup EXIT INT TERM

php-fpm --fpm-config "${PHP_FPM_CONF}" &
PHP_FPM_PID=$!

for _ in $(seq 1 50); do
  if [[ -S "${PHP_FPM_SOCK}" ]]; then
    break
  fi
  sleep 0.1
done

if [[ ! -S "${PHP_FPM_SOCK}" ]]; then
  echo "php-fpm did not start correctly (missing ${PHP_FPM_SOCK})."
  exit 1
fi

nginx -e /tmp/ootm-nginx-error.log -c "${NGINX_CONF}" -g 'daemon off;' &
NGINX_PID=$!

wait "${NGINX_PID}"
