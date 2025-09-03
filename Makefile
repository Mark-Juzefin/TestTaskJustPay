-include .env
export

MIGRATION_DIR=internal/app/migrations

.PHONY: run run-dev start_containers stop_containers lint test integration-test generate migrate seed-db print-db-size clean-db benchmark build-pg-image

run:
	docker compose --profile prod up --build

run-dev: start_containers
	go run ./cmd/app

start_containers:
	docker-compose --profile infra up --build -d

stop_containers:
	docker compose --profile infra --profile prod down --remove-orphans

build-pg-image:
	docker build -f PG.Dockerfile -t pg17-partman:local .

lint:
	golangci-lint run

test:
	go test -race ./...

INTEGRATION_DIRS = \
	./internal/repo/eventsink \
	./integration-test/...

integration-test: start_containers
	go clean -testcache && go test -tags=integration -v  $(INTEGRATION_DIRS)

generate:
	go generate ./...

migrate:
ifndef name
	$(error "Usage: make migrate name=your_migration_name")
endif
	go tool goose -dir=$(MIGRATION_DIR) create $(name) sql

seed-db:
	psql -d "$(PG_URL)" -f ./benchmark/generate_dispute_events.sql

print-db-size:
	psql -d "$(PG_URL)" -c 'SELECT pg_size_pretty(pg_database_size(current_database()));'

clean-db:
	psql -d "$(PG_URL)" -c  'TRUNCATE TABLE dispute_events, disputes, order_events, orders, evidence CASCADE'

benchmark:
	k6 run -e BASE_URL=http://localhost:3000 -e LIMIT=1000 -e VUS=8 -e DURATION=30s benchmark/disputes_bench.js