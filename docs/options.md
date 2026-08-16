# Docker Build Options

You can customize the Docker build process using these environment variables.

> [!NOTE]
>
> All Laravel-specific environment variables are used only if no `composer.json`
> file is found in the project directory.

## Selecting a Specific Laravel Version

Use the `LARAVEL_VERSION` environment variable to select a specific Laravel version.
The value is passed to `composer create-project laravel/laravel`.

On Linux:

```console
LARAVEL_VERSION=12.* docker compose up --wait
```

On Windows:

```console
set LARAVEL_VERSION=12.* && docker compose up --wait&set LARAVEL_VERSION=
```

## Installing Development Versions of Laravel

To install a non-stable version of Laravel,
use the `STABILITY` environment variable during the build.

The value must be [a valid Composer stability option](https://getcomposer.org/doc/04-schema.md#minimum-stability).

For instance, use the following command to use the development branch of Laravel:

On Linux:

```console
STABILITY=dev docker compose up --wait
```

On Windows:

```console
set STABILITY=dev && docker compose up --wait&set STABILITY=
```

## Using Custom HTTP Ports

Use the environment variables `HTTP_PORT`, `HTTPS_PORT` and/or `HTTP3_PORT`
to adjust the ports to your needs, e.g.

```console
HTTP_PORT=8000 HTTPS_PORT=4443 HTTP3_PORT=4443 docker compose up --wait
```

to access your application on [https://localhost:4443](https://localhost:4443).

> [!NOTE]
>
> Let's Encrypt only supports the standard HTTP and HTTPS ports.
> Creating a Let's Encrypt certificate for another port will not work,
> you have to use the standard ports or to configure Caddy to use another provider.

## Database Options

The PostgreSQL service and the `DB_*` variables passed to the `php` service are
configured with these variables:

<!-- markdownlint-disable MD013 -->

| Environment variable | Description                                                      | Default value |
| -------------------- | ---------------------------------------------------------------- | ------------- |
| `POSTGRES_VERSION`   | the tag of the `postgres` image                                  | `17`          |
| `POSTGRES_DB`        | the database name, exposed to Laravel as `DB_DATABASE`           | `app`         |
| `POSTGRES_USER`      | the database user, exposed to Laravel as `DB_USERNAME`           | `app`         |
| `POSTGRES_PASSWORD`  | the database password, exposed to Laravel as `DB_PASSWORD`       | `!ChangeMe!`  |
| `VITE_PORT`          | the host port the Vite dev server is published on, in dev only   | `5173`        |

<!-- markdownlint-enable MD013 -->

The database driver itself (`DB_CONNECTION`) is hardcoded to `pgsql` in
`compose.yaml`, see [Using MySQL](mysql.md) to change it.

> [!NOTE]
>
> Variables defined in `compose.yaml` take precedence over the values of your
> `.env` file: Laravel never overrides variables that already exist in the
> environment of the process.

> [!WARNING]
>
> The `.env` file of Laravel is also the file Docker Compose reads to resolve
> `${...}` placeholders. Avoid using a variable name in `compose.yaml` that also
> exists in `.env`, unless you really want the value of your app configuration to
> configure the containers too.

## `Caddyfile` Options

You can also customize the `Caddyfile` by using the following environment variables
to inject options block, directive or configuration.

> [!TIP]
>
> All the following environment variables can be defined in your `.env` file
> at the root of the project to keep them persistent at each startup.

<!-- markdownlint-disable MD013 -->

| Environment variable            | Description                                                                                                                                                                             | Default value |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- |
| `CADDY_GLOBAL_OPTIONS`          | the [global options block](https://caddyserver.com/docs/caddyfile/options#global-options), one per line                                                                                 |               |
| `CADDY_EXTRA_CONFIG`            | the [snippet](https://caddyserver.com/docs/caddyfile/concepts#snippets) or the [named-routes](https://caddyserver.com/docs/caddyfile/concepts#named-routes) options block, one per line |               |
| `CADDY_SERVER_EXTRA_DIRECTIVES` | the [`Caddyfile` directives](https://caddyserver.com/docs/caddyfile/concepts#directives)                                                                                                |               |
| `CADDY_SERVER_LOG_OPTIONS`      | the [server log options block](https://caddyserver.com/docs/caddyfile/directives/log), one per line                                                                                     |               |
| `SERVER_NAME`                   | the server name or address                                                                                                                                                              | `localhost`   |
| `FRANKENPHP_CONFIG`             | a list of extra [FrankenPHP global directives](https://frankenphp.dev/docs/config/#caddyfile-config), one per line                                                                      |               |
| `FRANKENPHP_SITE_CONFIG`        | extra directives for the `php_server` block, e.g. `hot_reload` or the [Octane worker](octane.md)                                                                                        |               |

<!-- markdownlint-enable MD013 -->

### Customizing the Server Name

```console
SERVER_NAME="app.localhost" docker compose up --wait
```
