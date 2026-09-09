LOGIN       := mohel-bo
DATA_DIR    := /home/$(LOGIN)/data
CONFIG_FILE := srcs/docker-compose.yml
ENV_FILE    := srcs/.env

all: up

$(ENV_FILE):
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "Creating $(ENV_FILE) from srcs/env-example..."; \
		cp srcs/env-example $(ENV_FILE); \
	fi

volumes:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress

build: volumes $(ENV_FILE)
	docker compose -f $(CONFIG_FILE) --env-file $(ENV_FILE) build

up: volumes $(ENV_FILE)
	docker compose -f $(CONFIG_FILE) --env-file $(ENV_FILE) up -d --build

down:
	docker compose -f $(CONFIG_FILE) down

start:
	docker compose -f $(CONFIG_FILE) start

stop:
	docker compose -f $(CONFIG_FILE) stop

clean:
	docker compose -f $(CONFIG_FILE) down -v

fclean: clean
	@docker compose -f $(CONFIG_FILE) down --rmi all -v --remove-orphans 2>/dev/null || true
	@if [ -d "$(DATA_DIR)" ]; then \
		rm -rf $(DATA_DIR)/mariadb/* $(DATA_DIR)/wordpress/* 2>/dev/null || sudo rm -rf $(DATA_DIR)/mariadb/* $(DATA_DIR)/wordpress/* 2>/dev/null || true; \
	fi

re: fclean all

.PHONY: all volumes build up down start stop clean fclean re
