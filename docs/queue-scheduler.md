# Queues and Scheduled Tasks

The `php` service only runs the web server.
[Queue workers](https://laravel.com/docs/queues) and the
[scheduler](https://laravel.com/docs/scheduling) need their own containers.

## In Development

Run them on demand in the existing container:

```console
docker compose exec php php artisan queue:listen
docker compose exec php php artisan schedule:work
```

## In Production

Uncomment the `worker` service in `compose.prod.yaml`, or add both services:

```yaml
# compose.prod.yaml

services:
  worker:
    image: ${IMAGES_PREFIX:-}app-php-prod
    restart: unless-stopped
    depends_on:
      database:
        condition: service_healthy
    environment:
      APP_ENV: production
      APP_DEBUG: "false"
      APP_KEY: ${APP_KEY}
      DB_CONNECTION: pgsql
      DB_HOST: database
      DB_PORT: 5432
      DB_DATABASE: ${POSTGRES_DB:-app}
      DB_USERNAME: ${POSTGRES_USER:-app}
      DB_PASSWORD: ${POSTGRES_PASSWORD:-!ChangeMe!}
    # Skip the init logic of the entrypoint: the php service already ran the migrations
    entrypoint: ["docker-php-entrypoint"]
    command: ["php", "artisan", "queue:work", "--tries=3", "--max-time=3600"]
    healthcheck:
      disable: true

  scheduler:
    image: ${IMAGES_PREFIX:-}app-php-prod
    restart: unless-stopped
    depends_on:
      database:
        condition: service_healthy
    environment:
      # Same variables as the worker service
      APP_KEY: ${APP_KEY}
    entrypoint: ["docker-php-entrypoint"]
    command: ["php", "artisan", "schedule:work"]
    healthcheck:
      disable: true
```

> [!NOTE]
>
> These services reuse the image built for the `php` service, so they are not
> rebuilt: build `php` first, then start everything with
> `docker compose -f compose.yaml -f compose.prod.yaml up --wait`.

> [!TIP]
>
> Restart the workers after each deployment, otherwise they keep running the
> previous version of your code:
> `docker compose -f compose.yaml -f compose.prod.yaml restart worker`.

## Using Redis Instead of the Database

The default `QUEUE_CONNECTION` is `database`, which requires no extra service.
To use Redis, add the service as described in [extra services](extra-services.md),
install the extension in the `Dockerfile`:

```diff
 	install-php-extensions \
 		@composer \
 		apcu \
+		redis \
```

and set `QUEUE_CONNECTION: redis` and `REDIS_HOST: redis` in the environment of
the `php` and `worker` services.
