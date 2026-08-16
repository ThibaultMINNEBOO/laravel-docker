# Using MySQL

By default, this template installs PostgreSQL.
If you prefer to work with MySQL, follow these steps.

## Docker Configuration

Change the database image to use MySQL instead of PostgreSQL in `compose.yaml`:

<!-- markdownlint-disable MD013 -->

```diff
   database:
-    image: postgres:${POSTGRES_VERSION:-17}-alpine
+    image: mysql:${MYSQL_VERSION:-8.4}
     restart: unless-stopped
     environment:
-      POSTGRES_DB: ${POSTGRES_DB:-app}
+      MYSQL_DATABASE: ${MYSQL_DATABASE:-app}
       # You should definitely change the password in production
+      MYSQL_RANDOM_ROOT_PASSWORD: "true"
-      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-!ChangeMe!}
+      MYSQL_PASSWORD: ${MYSQL_PASSWORD:-!ChangeMe!}
-      POSTGRES_USER: ${POSTGRES_USER:-app}
+      MYSQL_USER: ${MYSQL_USER:-app}
     healthcheck:
-      test: ["CMD", "pg_isready", "-d", "${POSTGRES_DB:-app}", "-U", "${POSTGRES_USER:-app}"]
+      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
       timeout: 5s
       retries: 5
       start_period: 60s
     volumes:
-      - database_data:/var/lib/postgresql/data:rw
+      - database_data:/var/lib/mysql:rw
       # You may use a bind-mounted host directory instead, so that it is harder to accidentally remove the volume and lose all your data!
-      # - ./docker/db/data:/var/lib/postgresql/data:rw
+      # - ./docker/db/data:/var/lib/mysql:rw
```

<!-- markdownlint-enable MD013 -->

Then update the environment of the `php` service in the same file:

```diff
-      DB_CONNECTION: pgsql
+      DB_CONNECTION: mysql
       DB_HOST: database
-      DB_PORT: 5432
+      DB_PORT: 3306
-      DB_DATABASE: ${POSTGRES_DB:-app}
+      DB_DATABASE: ${MYSQL_DATABASE:-app}
-      DB_USERNAME: ${POSTGRES_USER:-app}
+      DB_USERNAME: ${MYSQL_USER:-app}
-      DB_PASSWORD: ${POSTGRES_PASSWORD:-!ChangeMe!}
+      DB_PASSWORD: ${MYSQL_PASSWORD:-!ChangeMe!}
```

Since we changed the port, we also have to update `compose.override.yaml`:

```diff
   database:
     ports:
-      - "5432"
+      - "3306"
```

Last but not least, we need to install the MySQL driver instead of the PostgreSQL
one in the `Dockerfile`:

```diff
 	install-php-extensions \
 		@composer \
 		apcu \
 		bcmath \
 		intl \
 		opcache \
 		pcntl \
-		pdo_pgsql \
+		pdo_mysql \
 		zip
```

## Final steps

Rebuild the Docker environment:

```console
docker compose down --remove-orphans && docker compose build --pull --no-cache
```

Start the services:

```console
docker compose up --wait
```

Test your setup:

```console
docker compose exec php php artisan db:show
```
