# User Documentation (USER_DOC)

## 1. Services Overview
This infrastructure deploys a containerized WordPress website running with the following services:
- **Web Server (NGINX)**: The single secure HTTPS entrypoint on port 443 with TLSv1.2/1.3.
- **Application Server (WordPress + PHP-FPM)**: Executes WordPress PHP scripts and processes user requests.
- **Database Server (MariaDB)**: Persists all WordPress tables, comments, posts, and user accounts.

---

## 2. Starting and Stopping the Project

### Starting the Project
From the repository root directory, run:
```bash
make
```
This builds any missing container images and starts all services in the background.

### Stopping the Project
To temporarily pause services without removing data:
```bash
make stop
```
To restart them afterwards:
```bash
make start
```
To completely shut down and remove containers and network:
```bash
make down
```

---

## 3. Accessing the Website & Admin Panel

### Host Domain Setup
Before accessing the site for the first time, ensure your computer resolves `mohel-bo.42.fr` to `127.0.0.1`:
```bash
echo "127.0.0.1 mohel-bo.42.fr" | sudo tee -a /etc/hosts
```

### URLs
- **Public WordPress Website**: [https://mohel-bo.42.fr](https://mohel-bo.42.fr)
- **WordPress Administration Panel**: [https://mohel-bo.42.fr/wp-admin](https://mohel-bo.42.fr/wp-admin)

> [!NOTE]
> Since the website uses a self-signed SSL certificate generated at runtime for `mohel-bo.42.fr`, your browser will display a security warning. Click **Advanced** and then **Proceed to mohel-bo.42.fr (unsafe)**.

---

## 4. Locating and Managing Credentials
Credentials are configured in `srcs/.env` (created from `srcs/env-example`).

### WordPress Accounts
The database is initialized with two users:
1. **Administrator User**:
   - Username: `wp_supervisor` (defined in `WP_ADMIN_USER`)
   - Password: defined in `WP_ADMIN_PASS`
   - Role: Administrator (full management rights)
2. **Regular User**:
   - Username: `wp_editor` (defined in `WP_USER`)
   - Password: defined in `WP_PASS`
   - Role: Author

### Database Credentials
- Database Name: `wordpress_db` (defined in `DB_NAME`)
- Database User: `wp_user` (defined in `DB_USER`)
- Database Password: defined in `DB_PASS`
- Database Root Password: defined in `DB_ROOT_PASS`

---

## 5. Checking Service Health
To verify that all containers are healthy and running:
```bash
docker compose -f srcs/docker-compose.yml ps
```
All services (`nginx`, `wordpress`, `mariadb`) should display status `running` or `healthy`.

To inspect live service logs:
```bash
docker compose -f srcs/docker-compose.yml logs -f
```
