# Laravel Docker

A [Docker](https://www.docker.com/)-based installer and runtime for the [Laravel](https://laravel.com) web framework,
with [FrankenPHP](https://frankenphp.dev) and [Caddy](https://caddyserver.com/) inside!

Coding-agents ready: ships with a [Dev Container](https://containers.dev/) and a [one-page guide](docs/agents.md)
to run [OpenCode](https://opencode.ai), [Claude Code](https://claude.ai/claude-code), or any AI coding assistant,
against a local or a remote model, with an optional network sandbox.

## Getting Started

1. If not already done, [install Docker Compose](https://docs.docker.com/compose/install/) (v2.10+)
2. Run `docker compose build --pull --no-cache` to build fresh images
3. Run `docker compose up --wait` to set up and start a fresh Laravel project
4. Open `https://localhost` in your favorite web browser and [accept the auto-generated TLS certificate](https://stackoverflow.com/a/15076602/1352334)
5. Run `docker compose down --remove-orphans` to stop the Docker containers.

Run Artisan, Composer and npm inside the container:

```console
docker compose exec php php artisan about
docker compose exec php composer require laravel/horizon
docker compose exec php npm run dev
```

A [`Makefile`](Makefile) provides shortcuts for all of this, run `make` to list
them:

```console
make up                        # start the containers
make bash                      # open a shell in the container
make art c="migrate --seed"    # run any Artisan command
```

## Features

- Production, development and CI ready
- PHP and PostgreSQL services, with automatic migrations at startup
- Super-readable configuration
- Automatic HTTPS (in dev and prod)
- HTTP/2, HTTP/3 and compression support
- Vite and Node.js available in the dev image, with hot module replacement
- Optional [worker mode](docs/octane.md) through Laravel Octane
- Native [Xdebug](docs/xdebug.md) integration
- [Dev Container](https://containers.dev/) support
- [AI coding agents](docs/agents.md) with an optional network sandbox
- Rootless, slim production image

**Enjoy!**

## Docs

1. [Options available](docs/options.md)
2. [Using Laravel Docker with an existing project](docs/existing-project.md)
3. [Building assets with Vite](docs/vite.md)
4. [Queues and scheduled tasks](docs/queue-scheduler.md)
5. [Worker mode with Laravel Octane](docs/octane.md)
6. [Support for extra services](docs/extra-services.md)
7. [Deploying in production](docs/production.md)
8. [Debugging with Xdebug](docs/xdebug.md)
9. [TLS Certificates](docs/tls.md)
10. [Using MySQL instead of PostgreSQL](docs/mysql.md)
11. [Using Alpine Linux instead of Debian](docs/alpine.md)
12. [Using a Makefile](docs/makefile.md)
13. [Updating the template](docs/updating.md)
14. [Troubleshooting](docs/troubleshooting.md)
15. [Using AI coding agents](docs/agents.md)

## License

Laravel Docker is available under the MIT License.

## Credits

Adapted from [Symfony Docker](https://github.com/dunglas/symfony-docker),
created by [Kévin Dunglas](https://dunglas.dev), co-maintained by [Maxime Helias](https://twitter.com/maxhelias)
and sponsored by [Les-Tilleuls.coop](https://les-tilleuls.coop).
