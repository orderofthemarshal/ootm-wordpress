# Order of the Marshal Website

This repository contains the WordPress codebase for the Order of the Marshal website.

The Order of the Marshal is a group of enthusiasts focused on European medieval history and living by a modern code of chivalry. The organization emphasizes historical learning, kit development, martial demonstrations, Renaissance fair participation, and camaraderie. The name honors Sir William Marshal (c. 1145-1219).

Primary reference site (legacy/current content):

- https://orderofthemarshal.org/
- https://orderofthemarshal.org/about/about

## Tech Stack

This project is based on Bedrock (WordPress with Composer-driven dependency management) and keeps WordPress core, plugins, and themes in source-controlled, repeatable structure.

Key points:

- WordPress is installed via Composer (`roots/wordpress`) into `web/wp`.
- Custom app content lives under `web/app`.
- Environment-driven config is in `config/application.php` plus `config/environments/*.php`.
- Local web serving is provided via Composer script:
  - `composer serve` -> `php -S 0.0.0.0:8080 -t web/wp`

## Repository Layout

- `web/wp`: WordPress core (Composer-managed)
- `web/app`: Themes, plugins, mu-plugins, uploads
- `config/`: Bedrock/WordPress configuration
- `.devcontainer/`: Reproducible development environment (container + DB)
- `composer.json`: Dependencies and project scripts

## Devcontainer Setup (VS Code)

Use this path for the fastest, most consistent onboarding.

### What the devcontainer provides

Defined in `.devcontainer/devcontainer.json`, `.devcontainer/compose.yml`, and `.devcontainer/Containerfile`:

- Two services:
  - `devcontainer`: Fedora-based PHP/Composer workspace container
  - `mariadb`: MariaDB 11 with a preconfigured `wordpress` database/user
- Database wiring in container environment:
  - `WP_DB_NAME=wordpress`
  - `WP_DB_USER=wordpress`
  - `WP_DB_PASSWORD=wordpress`
  - `WP_DB_HOST=mariadb`
- Local HTTP port mapping:
  - Host `localhost:8080` -> container `8080`
- Workspace bind mount:
  - Repo mounted at `/workspaces/ootm-wordpress`
- Preinstalled tooling inside the devcontainer:
  - `php`, `php-mysqlnd`, `composer`, `npm`, `git`, `vim`, `curl`, `ImageMagick`, and more
- VS Code extension recommendations for this repo (from `devcontainer.json`), including PHP tools, Docker tooling, formatter, GitLens, and OpenAI extension.

### Run locally with the devcontainer

1. Install Docker or Podman plus the VS Code Dev Containers extension.
2. Open this repo in VS Code.
3. Run: `Dev Containers: Reopen in Container`.
4. Wait for services to start (`devcontainer` + `mariadb`).
5. In the devcontainer terminal, install dependencies:
   - `composer install`
6. Create local env files if needed:
   - `cp .env.example .env`
   - Optionally override local values in `.env.local`
7. Start WordPress:
   - `composer serve`
8. Open:
   - `http://localhost:8080/`
   - Installer/admin path: `http://localhost:8080/wp-admin/install.php`

## Non-Container Setup (Host Machine)

Use this if you prefer running directly on your own machine.

### Prerequisites

- PHP 8.1+
- Composer 2+
- MySQL or MariaDB running locally or reachable remotely
- A created database/user with privileges for WordPress

### Steps

1. Clone the repo.
2. Install dependencies:
   - `composer install`
3. Create env files:
   - `cp .env.example .env`
   - Optional overrides in `.env.local`
4. Set required environment values (in `.env`, `.env.local`, or shell environment):
   - `WP_DB_NAME`
   - `WP_DB_USER`
   - `WP_DB_PASSWORD`
   - `WP_DB_HOST`
   - `WP_HOME` (example: `http://localhost:8080`)
   - `WP_SITEURL` (typically `${WP_HOME}/wp`)
   - `WP_ENV` (recommended: `development` for local work)
5. Start the local server:
   - `composer serve`
6. Open in browser:
   - `http://localhost:8080/`
   - Installer/admin path: `http://localhost:8080/wp-admin/install.php`

## Useful Commands

- Start local server: `composer serve`
- PHP style check: `composer lint`
- Auto-fix style: `composer lint:fix`

## Troubleshooting

- Blank page:
  - Confirm you are using `composer serve` from this repo (docroot is set to `web/wp` in `composer.json`).
  - Ensure `WP_ENV=development` for local debugging.
- DB connection errors:
  - Verify `WP_DB_*` values and host reachability.
- Wrong site URL/redirect behavior:
  - Verify `WP_HOME` and `WP_SITEURL` match your local URL.
