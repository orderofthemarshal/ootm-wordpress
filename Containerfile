# ── Build stage: resolve Composer dependencies ────────────────────────────────
FROM registry.fedoraproject.org/fedora:43 AS builder

RUN dnf install -y --setopt=install_weak_deps=False \
    composer \
    php \
    && dnf clean all

WORKDIR /build

# Copy manifests first so the composer-install layer is cached independently
# of application source changes.
COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --prefer-dist

# Overlay committed source files (custom theme, mu-plugin shim, web entry
# points) on top of the Composer-managed tree.
COPY config ./config
COPY web    ./web

# ── Production deployment image ───────────────────────────────────────────────
FROM fedora:43 AS deployment

# ---------------------------------------------------------------------------
# Runtime environment variables.
# All secrets / credentials MUST be supplied at deploy time via the
# Lightsail container service "Environment variables" tab (or a secrets
# manager).  The defaults below are non-functional placeholders.
#
# Required at runtime:
#   WP_HOME, WP_SITEURL       – public URL of the site
#   WP_DB_NAME/USER/PASSWORD  – database credentials
#   WP_DB_HOST                – database hostname
#   AUTH_KEY … NONCE_SALT     – WordPress secret keys (generate via
#                               https://api.wordpress.org/secret-key/1.1/salt/)
#   AWS_ACCESS_KEY_ID/SECRET  – S3 credentials for media offloading
#   AWS_BUCKET                – S3 bucket name for media
#
# Optional:
#   WP_ENV          (default: production)
#   DB_SSL          (default: false)
#   WP_DB_PREFIX    (default: wp_)
#   AWS_REGION      (default: us-east-1)
#   DISABLE_WP_CRON (default: false)
# ---------------------------------------------------------------------------
ENV WP_ENV=production \
    WP_HOME=https://example.com \
    WP_SITEURL=https://example.com/wp \
    WP_DB_NAME=wordpress \
    WP_DB_USER=wordpress \
    WP_DB_PASSWORD="" \
    WP_DB_HOST=localhost \
    WP_DB_PREFIX=wp_ \
    DB_SSL=false \
    AUTH_KEY="" \
    SECURE_AUTH_KEY="" \
    LOGGED_IN_KEY="" \
    NONCE_KEY="" \
    AUTH_SALT="" \
    SECURE_AUTH_SALT="" \
    LOGGED_IN_SALT="" \
    NONCE_SALT="" \
    AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_BUCKET="" \
    AWS_REGION=us-east-1 \
    DISABLE_WP_CRON=false

RUN dnf install -y --setopt=install_weak_deps=False \
    nginx \
    php \
    php-fpm \
    php-mysqlnd \
    php-opcache \
    php-xml \
    php-mbstring \
    php-gd \
    php-curl \
    php-intl \
    && dnf clean all

# Replace the distro's default nginx config with our own, then drop any
# conf.d stubs that ship with the package so only wordpress.conf is active.
COPY container/nginx.conf  /etc/nginx/nginx.conf
RUN  rm -f /etc/nginx/conf.d/*.conf /etc/nginx/default.d/*.conf 2>/dev/null || true
COPY container/wordpress.conf /etc/nginx/conf.d/wordpress.conf

# php-fpm pool override (replaces the distro www.conf)
COPY container/php-fpm-www.conf /etc/php-fpm.d/www.conf

WORKDIR /app
COPY --from=builder /build/vendor ./vendor
COPY --from=builder /build/config ./config
COPY --from=builder /build/web    ./web

# The uploads directory is used by amazon-s3-and-cloudfront as a staging
# area before files are offloaded to S3.  It must be writable by the
# php-fpm worker process (nginx user).
RUN chown -R nginx:nginx /app/web/app/uploads

COPY container/entrypoint.sh /entrypoint.sh
RUN  chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]