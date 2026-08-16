# Support for Extra Services

Unlike Symfony Flex, Laravel has no recipe system able to modify your
`compose.yaml` and `Dockerfile` automatically: extra services are added by hand.
Here are ready-to-use snippets for the most common ones.

Add them under the `services` key of `compose.yaml`, and the related volumes
under the `volumes` key.

> [!NOTE]
>
> When a service requires a PHP extension, add it to the `install-php-extensions`
> call of the `Dockerfile` and rebuild the images with
> `docker compose build --pull --no-cache`.

## Redis (cache, sessions, queues)

```yaml
services:
  redis:
    image: redis:8-alpine
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      timeout: 5s
      retries: 5
      start_period: 60s
    volumes:
      - redis_data:/data

volumes:
  redis_data:
```

Add the `redis` PHP extension to the `Dockerfile`, then set in the environment of
the `php` service:

```yaml
REDIS_HOST: redis
CACHE_STORE: redis
SESSION_DRIVER: redis
QUEUE_CONNECTION: redis
```

## Mailpit (catch the mails sent in development)

Add it to `compose.override.yaml`, it is a development tool:

```yaml
services:
  php:
    environment:
      MAIL_MAILER: smtp
      MAIL_HOST: mailer
      MAIL_PORT: 1025

  mailer:
    image: axllent/mailpit
    ports:
      - "1025"
      - "8025:8025"
    environment:
      MP_SMTP_AUTH_ACCEPT_ANY: 1
      MP_SMTP_AUTH_ALLOW_INSECURE: 1
```

The web interface is available on [http://localhost:8025](http://localhost:8025).

## Meilisearch (Laravel Scout)

```yaml
services:
  meilisearch:
    image: getmeili/meilisearch:latest
    restart: unless-stopped
    environment:
      MEILI_MASTER_KEY: ${MEILISEARCH_KEY:-!ChangeMe!}
      MEILI_NO_ANALYTICS: "true"
    volumes:
      - meilisearch_data:/meili_data

volumes:
  meilisearch_data:
```

Then `composer require laravel/scout meilisearch/meilisearch-php` and set
`SCOUT_DRIVER: meilisearch`, `MEILISEARCH_HOST: http://meilisearch:7700`.

## MinIO (S3-compatible storage)

```yaml
services:
  minio:
    image: minio/minio
    restart: unless-stopped
    command: server /data --console-address ":8900"
    environment:
      MINIO_ROOT_USER: ${MINIO_USER:-app}
      MINIO_ROOT_PASSWORD: ${MINIO_PASSWORD:-!ChangeMe!}
    volumes:
      - minio_data:/data

volumes:
  minio_data:
```

## Queue Workers and Scheduler

See [Queues and scheduled tasks](queue-scheduler.md).
