# Developer Documentation (DEV_DOC)

## 1. Environment Setup from Scratch

### Prerequisites
The host system requires:
- Linux OS (Debian/Ubuntu/Alpine VM)
- Docker Engine (v24+)
- Docker Compose Plugin (v2+)
- GNU Make

### Configuration & Environment
1. Configure host DNS in `/etc/hosts`:
   ```bash
   echo "127.0.0.1 mohel-bo.42.fr" | sudo tee -a /etc/hosts
   ```
2. Clone repository and navigate to the project directory:
   ```bash
   cd inception
   ```
3. Initialize the environment configuration file:
   ```bash
   cp srcs/env-example srcs/.env
   ```
   Inspect and customize `srcs/.env` if desired. Ensure `WP_ADMIN_USER` does **not** contain `admin` or `Admin`.

---

## 2. Building and Launching the Infrastructure

### Makefile Workflow
- **Build images explicitly**:
  ```bash
  make build
  ```
- **Build and start services in detached mode**:
  ```bash
  make up
  ```
- **Restart entire stack from clean state**:
  ```bash
  make re
  ```

### Direct Docker Compose Commands
If managing containers directly via `docker compose`:
```bash
# Validate compose syntax and rendered variables
docker compose -f srcs/docker-compose.yml --env-file srcs/.env config

# Build and run
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build

# View container status and health
docker compose -f srcs/docker-compose.yml ps
```

---

## 3. Container and Volume Management Commands

### Inspection & Diagnostics
- View service logs:
  ```bash
  docker compose -f srcs/docker-compose.yml logs nginx
  docker compose -f srcs/docker-compose.yml logs wordpress
  docker compose -f srcs/docker-compose.yml logs mariadb
  ```
- Execute an interactive shell in a container:
  ```bash
  docker exec -it wordpress sh
  docker exec -it mariadb sh
  docker exec -it nginx sh
  ```
- Query database from host:
  ```bash
  docker exec -it mariadb mariadb -u wp_user -pdb_user_secret_pass_42 -e "SHOW DATABASES;"
  ```
- Check WordPress users via WP-CLI inside container:
  ```bash
  docker exec -it wordpress wp user list --allow-root
  ```

### Lifecycle & Cleanup
- Stop running containers:
  ```bash
  make stop
  ```
- Remove containers and networks:
  ```bash
  make down
  ```
- Remove containers, networks, and named volumes:
  ```bash
  make clean
  ```
- Remove everything (containers, networks, volumes, built images, and data storage):
  ```bash
  make fclean
  ```

---

## 4. Data Storage & Persistence Architecture

Persistent data is mapped to host directories via Docker named volumes with local bind options:
- **MariaDB Database Data**:
  - Host Path: `/home/mohel-bo/data/mariadb`
  - Container Target: `/var/lib/mysql`
  - Persistence: Stores raw MySQL/MariaDB database tables and InnoDB transaction logs.
- **WordPress Web Files**:
  - Host Path: `/home/mohel-bo/data/wordpress`
  - Container Target: `/var/www/html/wordpress`
  - Persistence: Stores WordPress core files, `wp-config.php`, and user uploads (`wp-content/uploads/`).

### Verification of Persistence
1. Start the stack: `make up`
2. Connect to `https://mohel-bo.42.fr/wp-login.php` using `wp_supervisor` credentials.
3. Publish a new blog post.
4. Tear down the stack: `make down`
5. Restart the stack: `make up`
6. Reload `https://mohel-bo.42.fr`: verify that the post remains intact.

---

## 5. Live Defense: Configuration Modification Guide
During peer evaluation, the evaluator will ask you to modify the configuration of one service (e.g. changing its port), rebuild, and verify that the stack still works.

### Scenario A: Changing NGINX Port (e.g., from 443 to 8443)
1. In `srcs/docker-compose.yml`:
   Change port mapping under `nginx`:
   ```yaml
   ports:
     - "8443:8443"
   ```
2. In `srcs/requirements/nginx/nginx.conf`:
   Change the listen directive:
   ```nginx
   listen 8443 ssl;
   ```
3. Rebuild and restart:
   ```bash
   make up
   ```
4. Demonstrate access via `https://mohel-bo.42.fr:8443`.

### Scenario B: Changing WordPress PHP-FPM Port (e.g., from 9000 to 9001)
1. In `srcs/requirements/wordpress/setup.sh`:
   Change the listen port in `www.conf`:
   ```sh
   sed -i 's/listen = .*/listen = 9001/1' /etc/php83/php-fpm.d/www.conf
   ```
2. In `srcs/requirements/nginx/nginx.conf`:
   Update the FastCGI upstream target:
   ```nginx
   fastcgi_pass wordpress:9001;
   ```
3. Rebuild and restart:
   ```bash
   make up
   ```
4. Access `https://mohel-bo.42.fr` to demonstrate WordPress is functional.

### Scenario C: Changing MariaDB Port (e.g., from 3306 to 3307)
1. In `srcs/requirements/mariadb/conf/mariadb-server.cnf`:
   Change the port directive:
   ```ini
   port = 3307
   ```
2. In `srcs/requirements/wordpress/setup.sh`:
   Update the `--dbhost` parameter in WP-CLI config:
   ```sh
   --dbhost="mariadb:3307"
   ```
   (And in the connection check: `mariadb-admin ping -h"mariadb" -P3307 ...`)
3. Rebuild and restart:
   ```bash
   make up
   ```
4. Access `https://mohel-bo.42.fr` to demonstrate WordPress is functional.
