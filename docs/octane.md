# Worker Mode With Laravel Octane

By default, this template runs Laravel in the classic way: the framework is
booted at every request.
It is the safest mode, and the one every Laravel package supports.

For a large performance boost, [FrankenPHP can keep the application in memory
between requests](https://frankenphp.dev/docs/worker/).
With Laravel, this mode is provided by [Laravel Octane](https://laravel.com/docs/octane).

> [!WARNING]
>
> In worker mode the application is booted once and reused.
> Code that relies on a fresh process at every request (static properties,
> singletons holding request data, globals) leaks state between requests.
> Read [the Octane caveats](https://laravel.com/docs/octane#dependency-injection-and-octane)
> before enabling it.

## Installation

```console
docker compose exec php composer require laravel/octane
docker compose exec php php artisan octane:install --server=frankenphp
```

## Option 1: Keep the Provided `Caddyfile` (recommended)

Point the `php_server` directive of `frankenphp/Caddyfile` at the Octane worker
script through the `FRANKENPHP_SITE_CONFIG` environment variable:

```yaml
# compose.override.yaml

services:
  php:
    environment:
      FRANKENPHP_SITE_CONFIG: |
        worker {
          file /app/vendor/laravel/octane/bin/frankenphp-worker.php
          env APP_PUBLIC_PATH /app/public
        }
```

Check the exact worker path and the variables it expects in
`vendor/laravel/octane/` after installing the package, as they may change between
Octane releases.

The dev image already starts FrankenPHP with `--watch`, so workers are restarted
when you edit a file.
In production, restart the container after each deployment.

## Option 2: Let Octane Drive FrankenPHP

Octane can start its own FrankenPHP server.
Override the command of the `php` service:

```yaml
# compose.override.yaml

services:
  php:
    command:
      ["php", "artisan", "octane:frankenphp", "--host=0.0.0.0", "--port=80", "--watch"]
```

In this mode the `Caddyfile` of this repository is ignored (Octane generates its
own), so you lose the automatic HTTPS configuration unless you pass your own file
with the `--caddyfile` option.

## Checking That It Works

```console
docker compose exec php php artisan octane:status
```
