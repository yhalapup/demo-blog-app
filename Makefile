.PHONY:  down dbmigrate save-prod-images-to-archive up

down:
	@docker compose down

dbmigrate:
	@docker compose exec app bash -c "rails db:migrate RAILS_ENV=development"

up:
	@mkdir -p vendor/bundle
	@docker compose --env-file docker/.env.development up --build

up-prod:
	@docker compose --env-file docker/.env.production -f docker-compose.prod.yml up --build

prepare-db-prod:
	@docker compose --env-file docker/.env.production -f docker-compose.prod.yml exec app bash -c "rails db:create"
	@docker compose --env-file docker/.env.production -f docker-compose.prod.yml exec app bash -c "rails db:migrate"
	@docker compose --env-file docker/.env.production -f docker-compose.prod.yml exec app bash -c "rails db:seed"

generate-csv-prod:
	@docker compose --env-file docker/.env.production -f docker-compose.prod.yml exec app bash -c "ruby generate_comments_csv.rb"

import-comments-prod:
	@docker compose --env-file docker/.env.production -f docker-compose.prod.yml exec app bash -c "rake import_from_csv:comments"

build-prod-images:
	@docker compose --env-file docker/.env.production -f docker-compose.prod.yml build

save-prod-images-to-archive:
	@docker compose -f docker-compose.prod.yml build
	@docker compose -f docker-compose.prod.yml pull redis db
	@docker save -o dockerimages.tar ruby-challenge-app-prod:latest ruby-challenge-web-prod:latest redis
