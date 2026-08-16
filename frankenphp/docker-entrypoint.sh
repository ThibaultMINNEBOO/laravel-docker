#!/bin/sh
set -e

if [ "$1" = 'frankenphp' ] || [ "$1" = 'php' ] || [ "$1" = 'artisan' ]; then
	###> laravel-docker ###
	# Install the project the first time PHP is started
	# This block will remove itself after the installation
	if [ "$(cat composer.json)" = '{}' ]; then
		rm -Rf tmp/
		# --no-scripts: the scripts of the skeleton require the vendors, which are installed below
		composer create-project "laravel/laravel $LARAVEL_VERSION" tmp --stability="$STABILITY" --prefer-dist --no-progress --no-interaction --no-install --no-scripts

		cd tmp
		cp -Rp . ..
		cd -
		rm -Rf tmp/

		cp .env.example .env
		composer require "php:>=$PHP_VERSION"

		# Remove the project install block from this script and the compose.yaml
		sed -i '/^\t###> laravel-docker ###/,/^\t###< laravel-docker ###/d' frankenphp/docker-entrypoint.sh
		sed -i '/###> laravel-docker ###/,/###< laravel-docker ###/d' compose.yaml
	fi
	###< laravel-docker ###

	if [ -z "$(ls -A 'vendor/' 2>/dev/null)" ]; then
		composer install --prefer-dist --no-progress --no-interaction
	fi

	# Create the local .env file in development
	# In production the app directory is read-only and everything comes from the environment
	if [ ! -f .env ] && [ -f .env.example ] && [ -w . ]; then
		cp .env.example .env
	fi

	# Generate the application key if none has been provided
	if [ -z "$APP_KEY" ] && [ -f .env ] && ! grep -qE '^APP_KEY=.+' .env; then
		php artisan key:generate --no-interaction
	fi

	# Display information about the current project
	# Or about an error in project initialization
	php artisan --version

	mkdir -p \
		bootstrap/cache \
		storage/app/public \
		storage/framework/cache/data \
		storage/framework/sessions \
		storage/framework/testing \
		storage/framework/views \
		storage/logs

	if [ ! -e public/storage ]; then
		php artisan storage:link --no-interaction || true
	fi

	if [ "${DB_CONNECTION:-}" = 'sqlite' ]; then
		DB_FILE="${DB_DATABASE:-database/database.sqlite}"
		if [ "$DB_FILE" != ':memory:' ] && [ ! -e "$DB_FILE" ]; then
			mkdir -p "$(dirname "$DB_FILE")"
			touch "$DB_FILE"
		fi
	else
		echo 'Waiting for database to be ready...'
		ATTEMPTS_LEFT_TO_REACH_DATABASE=60
		until [ $ATTEMPTS_LEFT_TO_REACH_DATABASE -eq 0 ] || DATABASE_ERROR=$(php artisan db:show 2>&1 >/dev/null); do
			sleep 1
			ATTEMPTS_LEFT_TO_REACH_DATABASE=$((ATTEMPTS_LEFT_TO_REACH_DATABASE - 1))
			echo "Still waiting for database to be ready... Or maybe the database is not reachable. $ATTEMPTS_LEFT_TO_REACH_DATABASE attempts left."
		done

		if [ $ATTEMPTS_LEFT_TO_REACH_DATABASE -eq 0 ]; then
			echo 'The database is not up or not reachable:'
			echo "$DATABASE_ERROR"
			exit 1
		else
			echo 'The database is now ready and reachable'
		fi
	fi

	# Comment the next block to run the migrations manually instead
	if find ./database/migrations -iname '*.php' -print -quit | grep --quiet .; then
		php artisan migrate --force --no-interaction
	fi

	if [ "${APP_ENV:-production}" != 'local' ]; then
		# Cache the configuration, the routes, the events and the Blade views
		php artisan optimize --no-interaction
	fi

	echo 'PHP app ready!'
fi

exec docker-php-entrypoint "$@"
