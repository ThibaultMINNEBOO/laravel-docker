# Troubleshooting

## Editing Permissions on Linux

If you work on Linux and cannot edit some of the project files right after
the first installation, you can run the following command
to set yourself as owner of the project files that were created by the Docker container:

```console
docker compose run --rm php chown -R $(id -u):$(id -g) .
```

## The Container Exits With "The database is not up or not reachable"

The entrypoint waits up to 60 seconds for the database before giving up.
Check the logs of the `database` service, and that the `DB_*` variables of
`compose.yaml` match the credentials of the PostgreSQL service:

```console
docker compose logs database
docker compose exec php php artisan db:show
```

## Permission Errors on `storage/` or `bootstrap/cache/`

Inside the container, FrankenPHP runs as `root` in development and as `www-data`
in production. If Laravel cannot write its caches or logs, fix the ownership of
the two writable directories:

```console
docker compose exec php chmod -R a+rwX storage bootstrap/cache
```

## Changes to `.env` Are Ignored

Two things can cause this:

- The variable is also defined in `compose.yaml`. Variables coming from the
  environment always win over the `.env` file, this is how Laravel loads them.
- The configuration is cached (this is done automatically when `APP_ENV` is not
  `local`). Run `docker compose exec php php artisan optimize:clear`, or restart
  the container.

## A Variable of `.env` Ends Up Configuring the Containers

`.env` is read by Laravel *and* by Docker Compose, which uses it to resolve the
`${...}` placeholders of `compose.yaml`.
For instance, adding `HTTPS_PORT=8443` to `.env` changes the published port.
This is why `DB_CONNECTION` is hardcoded in `compose.yaml`: a placeholder would
inherit the value written in `.env` by the Laravel installer.

## TLS/HTTPS Issues

See the [TLS section](tls.md) for more details.

## Production Issues

### How To Properly Build Fresh Images for Production Use

Remember that, by default, if you run `docker compose up --wait`,
only the files `compose.yaml` and `compose.override.yaml` will be used.
See ["How Compose works"](https://docs.docker.com/compose/intro/compose-application-model)
and ["Merge Compose files"](https://docs.docker.com/compose/how-tos/multiple-compose-files/merge).

If you need to build images for production environment, you have to use the following
command:

```console
docker compose -f compose.yaml -f compose.prod.yaml build --pull --no-cache
```

### Building Dev and Prod Images

Dev and prod images use distinct image names (`app-php-dev` and `app-php-prod`),
so they won't conflict with each other.

To build and start the dev image:

```console
docker compose up --wait
```

To build and start the prod image:

```console
docker compose -f compose.yaml -f compose.prod.yaml build --pull --no-cache
docker compose -f compose.yaml -f compose.prod.yaml up --wait
```

> [!WARNING]
>
> The order of `-f` arguments matters.
