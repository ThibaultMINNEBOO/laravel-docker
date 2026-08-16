# Makefile

A [`Makefile`](/Makefile) ships at the root of the project.
It provides shortcuts for the most common tasks, so that you don't have to
remember the full `docker compose` invocations.

Run `make` (or `make help`) to list all the available commands with their
description.

For example, in the [getting started section](/README.md#getting-started), the
`docker compose` commands can be replaced by:

1. Run `make build` to build fresh images
2. Run `make up` to start the containers (detached, waits for them to be healthy)
3. Run `make down` to stop them

## The Available Targets

<!-- markdownlint-disable MD013 -->

| Target                        | What it does                                                        |
| ----------------------------- | ------------------------------------------------------------------- |
| `make build`                  | Build fresh images, `c="--no-cache"` to add options                 |
| `make up` / `make down`       | Start / stop the containers                                         |
| `make start`                  | Build then start                                                    |
| `make restart`                | `down` then `up`                                                    |
| `make logs`                   | Follow the logs, `c=database` to target a service                   |
| `make ps`                     | State of the containers                                             |
| `make bash` / `make sh`       | Open a shell in the FrankenPHP container                            |
| `make composer c="require …"` | Run Composer in the container                                       |
| `make vendor`                 | Install the dependencies of `composer.lock`                         |
| `make npm c="install"`        | Run npm in the container                                            |
| `make dev` / `make assets`    | Start the Vite dev server / build the assets                        |
| `make art c="route:list"`     | Run any Artisan command                                             |
| `make migrate` / `make fresh` | Run the migrations / drop everything and re-run them with the seeds |
| `make seed` / `make key`      | Run the seeders / generate the application key                      |
| `make cc` / `make optimize`   | Clear / warm up the caches                                          |
| `make test c="--filter=Foo"`  | Run the test suite                                                  |
| `make tinker`                 | Open a Tinker session                                               |
| `make psql`                   | Open a `psql` session on the database                               |
| `make db-reset`               | Recreate the database container and its volume                      |
| `make prod-build`             | Build the production images                                         |
| `make prod-up`                | Start the production stack (needs `APP_KEY`)                        |
| `make prod-down`              | Stop the production stack                                           |
| `make prod-logs`              | Follow the logs of the production stack                             |

<!-- markdownlint-enable MD013 -->

> [!CAUTION]
>
> `make fresh` and `make db-reset` destroy the content of your database.

## Passing Arguments

Targets that wrap a command accept a `c=` parameter:

```console
make art c="make:model Post --migration"
make composer c="require laravel/horizon"
make npm c="install --save-dev vitest"
make test c="--filter=UserTest"
make logs c=database
```

## Adding and Modifying Targets

Makefiles are not compatible with spaces: the recipes must be indented with
tabs. This is already enforced by the [.editorconfig](/.editorconfig) file of
this repository:

```editorconfig
[**/{Dockerfile,Caddyfile,Makefile,*.sh}]
indent_style = tab
```

To make a new target show up in `make help`, add a `##` comment at the end of
its declaration:

```Makefile
horizon: ## Start Horizon
	@$(ARTISAN) horizon
```

> [!NOTE]
>
> If you are using Windows, you have to install [chocolatey.org](https://chocolatey.org/)
> or [Cygwin](http://cygwin.com) to use the `make` command.
>
> Check out this [StackOverflow question](https://stackoverflow.com/q/2532234/633864)
> for more explanations.
