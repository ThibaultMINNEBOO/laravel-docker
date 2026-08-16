# Executables (local)
DOCKER_COMP      = docker compose
DOCKER_COMP_PROD = docker compose -f compose.yaml -f compose.prod.yaml

# Docker containers
PHP_CONT = $(DOCKER_COMP) exec php
DB_CONT  = $(DOCKER_COMP) exec database

# Executables
PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
NPM      = $(PHP_CONT) npm
ARTISAN  = $(PHP) artisan

# Misc
.DEFAULT_GOAL = help
.PHONY        : help build up start stop down restart logs ps sh bash \
                composer vendor npm dev assets \
                art migrate fresh seed key cc optimize test tinker \
                psql db-reset \
                prod-build prod-up prod-down prod-logs

help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-20s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

build: ## Build fresh images, pass the parameter "c=" to add options, example: make build c="--no-cache"
	@$(eval c ?=)
	@$(DOCKER_COMP) build --pull $(c)

up: ## Start the containers in detached mode and wait for them to be healthy
	@$(DOCKER_COMP) up --detach --wait

start: build up ## Build then start the containers

stop: ## Stop the containers without removing them
	@$(DOCKER_COMP) stop

down: ## Stop and remove the containers
	@$(DOCKER_COMP) down --remove-orphans

restart: down up ## Restart the containers

logs: ## Show live logs, pass the parameter "c=" to target a service, example: make logs c=database
	@$(eval c ?=)
	@$(DOCKER_COMP) logs --tail=100 --follow $(c)

ps: ## List the running containers and their state
	@$(DOCKER_COMP) ps

sh: ## Open a shell in the FrankenPHP container
	@$(PHP_CONT) sh

bash: ## Open a bash session in the FrankenPHP container (arrow keys, history)
	@$(PHP_CONT) bash

composer: ## Run composer, pass the parameter "c=" to run a given command, example: make composer c="require laravel/horizon"
	@$(eval c ?=)
	@$(COMPOSER) $(c)

vendor: ## Install the dependencies of composer.lock
vendor: c=install --prefer-dist --no-progress --no-interaction
vendor: composer

npm: ## Run npm, pass the parameter "c=" to run a given command, example: make npm c="install"
	@$(eval c ?=)
	@$(NPM) $(c)

dev: ## Start the Vite dev server (see docs/vite.md)
	@$(NPM) run dev

assets: ## Build the assets for production
	@$(NPM) run build

art: ## List all Artisan commands or pass the parameter "c=" to run one, example: make art c="route:list"
	@$(eval c ?=)
	@$(ARTISAN) $(c)

migrate: ## Run the pending migrations
	@$(ARTISAN) migrate

fresh: ## Drop all the tables, re-run the migrations and the seeders (destroys the data!)
	@$(ARTISAN) migrate:fresh --seed

seed: ## Run the database seeders
	@$(ARTISAN) db:seed

key: ## Generate the application key
	@$(ARTISAN) key:generate

cc: ## Clear all the caches (config, routes, events, views)
	@$(ARTISAN) optimize:clear

optimize: ## Cache the config, the routes, the events and the views
	@$(ARTISAN) optimize

test: ## Run the tests, pass the parameter "c=" to add options, example: make test c="--filter=UserTest"
	@$(eval c ?=)
	@$(ARTISAN) test $(c)

tinker: ## Start a Tinker session
	@$(ARTISAN) tinker

psql: ## Open a psql session on the database
	@$(DB_CONT) psql -U $${POSTGRES_USER:-app} -d $${POSTGRES_DB:-app}

db-reset: ## Remove the database container and its volume, then start over (destroys the data!)
	@$(DOCKER_COMP) rm --force --stop --volumes database
	@$(DOCKER_COMP) up --detach --wait database

prod-build: ## Build the production images
	@$(DOCKER_COMP_PROD) build --pull --no-cache

prod-up: ## Start the production stack, requires APP_KEY to be set
	@$(DOCKER_COMP_PROD) up --detach --wait

prod-down: ## Stop the production stack
	@$(DOCKER_COMP_PROD) down --remove-orphans

prod-logs: ## Show live logs of the production stack
	@$(DOCKER_COMP_PROD) logs --tail=100 --follow
