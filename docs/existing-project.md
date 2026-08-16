# Installing on an Existing Project

It's also possible to use Laravel Docker with existing projects!

First, download this skeleton.

If you cloned the Git repository, be sure to not copy the `.git` directory
to prevent conflicts with the `.git` directory already in your existing project.

You can copy the contents of the repository using Git and tar.
This will not contain `.git` or any uncommitted changes.

```console
git archive --format=tar HEAD | tar -xC my-existing-project/
```

If you downloaded the skeleton as a ZIP you can just copy the extracted files:

```console
cp -Rp laravel-docker/. my-existing-project/
```

Then remove the installation block of `frankenphp/docker-entrypoint.sh` and of
`compose.yaml` (the parts surrounded by `###> laravel-docker ###` and
`###< laravel-docker ###`): your project is already installed, the entrypoint
must not create a new one.

Double-check the changes, and revert the ones that you don't want to keep:

```console
git diff
```

Things to look at in particular:

- The `DB_*` variables of `compose.yaml`: they point to the PostgreSQL service
  shipped with this template. Adapt them, or [switch to MySQL](mysql.md).
- The PHP extensions installed in the `Dockerfile`:
  `pdo_pgsql` is installed by default, add the ones your project needs
  (`pdo_mysql`, `redis`, `gd`, `imagick`…).
- The services your project needs, see [extra services](extra-services.md).
- Your `vite.config.js`, see [building assets with Vite](vite.md).

Build the Docker images:

```console
docker compose build --pull --no-cache
```

Start the project!

```console
docker compose up --wait
```

Browse `https://localhost`, your Docker configuration is ready!

> [!NOTE]
>
> The entrypoint runs `php artisan migrate --force` at every start.
> Comment out this block in `frankenphp/docker-entrypoint.sh` if you prefer to
> run your migrations manually.
