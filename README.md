# ootm-wordpress

Composer-based WordPress starter with:

- Core installed in `wordpress/`
- Public docroot in `web-root/`
- Custom content/theme in `web-root/wp-content/`
- Dev stack in `compose.yml` (`devcontainer` + `mariadb`)

## Quick start

1. Reopen the repo in the dev container.

This project uses `compose.yml` to run both:
- `devcontainer`: your development shell/runtime
- `mariadb`: local database for WordPress

2. Install deps:

```bash
composer install
```

3. (Optional) Override DB/app env vars (defaults are already set by `compose.yml`):

```bash
export WP_DB_NAME=wordpress
export WP_DB_USER=wordpress
export WP_DB_PASSWORD=wordpress
export WP_DB_HOST=mariadb
export WP_HOME=http://localhost:8080
export WP_SITEURL=http://localhost:8080
```

4. Run the local server:

```bash
composer serve
```

`composer serve` now runs Nginx + PHP-FPM and serves content with this lookup order:

1. `web-root/<request>`
2. `wordpress/<request>`
3. `web-root/index.php`

`/static/*` is served directly from `static/`.

5. Open `http://localhost:8080` and complete the WordPress installer.

After install, activate the `OOTM Starter` theme if it is not already active.

## Notes

- If you updated from an older setup, rebuild the dev container so `nginx` and `php-fpm` are installed from `.devcontainer/Containerfile`.
