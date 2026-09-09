*This project has been created as part of the 42 curriculum by mohel-bo.*

# Inception

## Description
Inception is a System Administration project in the 42 core curriculum designed to broaden knowledge of virtualization and containerization using Docker. The infrastructure consists of a multi-container web application orchestrated with Docker Compose. Each service runs in its own dedicated container built from Alpine Linux (penultimate stable version) using custom Dockerfiles.

The stack includes:
- **NGINX**: The sole entrypoint to the infrastructure, exposing only port 443 with TLSv1.2/TLSv1.3.
- **WordPress + PHP-FPM**: The web application and FastCGI process manager running on port 9000, serving content without NGINX.
- **MariaDB**: The database engine running on port 3306, serving WordPress data without NGINX.
- **Persistent Storage**: Two Docker named volumes storing database files and website content respectively in `/home/mohel-bo/data`.
- **Docker Bridge Network**: An isolated network (`inception`) connecting all internal containers securely.

---

## Instructions

### Prerequisites
1. Ensure `docker` and `docker compose` (v2+) are installed.
2. Add the domain resolution to your local `/etc/hosts`:
   ```bash
   echo "127.0.0.1 mohel-bo.42.fr" | sudo tee -a /etc/hosts
   ```
3. Prepare persistent data folders (handled automatically by the Makefile):
   ```bash
   mkdir -p /home/mohel-bo/data/mariadb /home/mohel-bo/data/wordpress
   ```

### Execution
Run the stack using the root Makefile:
- **Build and start services in detached mode**:
  ```bash
  make
  # or
  make up
  ```
- **Stop services**:
  ```bash
  make stop
  ```
- **Start stopped services**:
  ```bash
  make start
  ```
- **Stop and remove containers and network**:
  ```bash
  make down
  ```
- **Clean volumes and containers**:
  ```bash
  make clean
  ```
- **Full purge (containers, images, volumes, and persistent storage)**:
  ```bash
  make fclean
  ```
- **Rebuild and restart from scratch**:
  ```bash
  make re
  ```

---

## Resources

### References
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Specification](https://docs.docker.com/compose/)
- [NGINX Documentation & SSL Configuration](https://nginx.org/en/docs/)
- [WordPress CLI Documentation (WP-CLI)](https://make.wordpress.org/cli/handbook/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [Alpine Linux Package Management](https://wiki.alpinelinux.org/wiki/Package_management)

### AI Usage Statement
Artificial Intelligence was utilized as an engineering assistant during this project to:
- Conduct static code analysis against the 42 Inception Version 5.4 subject specifications.
- Identify compliance bugs such as illegal port exposures (Port 80), administrator username restrictions, FastCGI SSL parameters, and database bootstrap races.
- Assist in structuring technical documentation adhering to the 42 evaluation rubrics.
- Review Dockerfile caching, multi-stage practices, and POSIX signal handling (PID 1).

---

## Project Description

### Architecture & Design Choices
- **Alpine Linux Base**: Chosen for its lightweight footprint (~5MB base), minimal attack surface, and high efficiency.
- **No Infinite Loop Hacks**: Containers do not use anti-patterns such as `tail -f`, `sleep infinity`, or `while true`. Daemons run in the foreground as PID 1 (`exec nginx`, `exec mariadbd --console`, `exec php-fpm83 -F`), properly receiving POSIX shutdown signals (`SIGTERM`).
- **Dynamic Self-Signed SSL**: NGINX generates an X.509 certificate for `mohel-bo.42.fr` at runtime during container boot.
- **Synchronous MariaDB Bootstrapping**: Uses `mariadbd --bootstrap` to initialize databases and users deterministically without background daemon races.
- **HTTPS FastCGI Forwarding**: NGINX explicitly passes `fastcgi_param HTTPS on;` to PHP-FPM, eliminating infinite HTTP-to-HTTPS redirect loops.

### Technical Comparisons

#### 1. Virtual Machines vs Docker
| Feature | Virtual Machine (VM) | Docker Container |
| :--- | :--- | :--- |
| **Virtualization Level** | Hardware-level (Hypervisor: Type 1 or 2) | OS-level (Linux Kernel namespaces & cgroups) |
| **Guest OS** | Full guest operating system with dedicated kernel | Shares the host Linux kernel |
| **Resource Usage** | High RAM, disk space, and CPU overhead | Extremely lightweight, near-native performance |
| **Startup Time** | Minutes | Milliseconds to seconds |
| **Isolation** | Strong hardware-level boundary | Process-level isolation via kernel features |

#### 2. Secrets vs Environment Variables
| Feature | Environment Variables | Docker Secrets |
| :--- | :--- | :--- |
| **Storage Location** | Process environment memory table | In-memory tmpfs mounts (`/run/secrets/`) |
| **Exposure Risk** | Leaks in `docker inspect`, process trees (`/proc/*/environ`), child processes, and crash dumps | Restrained to explicitly mounted containers; unreadable from outside the container |
| **Persistence** | Kept in plain text in compose files or `.env` | Handled securely by the Docker engine |
| **Best Use Case** | Non-sensitive configs (domain, ports, debug flags) | Sensitive credentials (passwords, private keys, API tokens) |

#### 3. Docker Network vs Host Network
| Feature | Docker Bridge Network (`docker network`) | Host Network (`network_mode: host`) |
| :--- | :--- | :--- |
| **Isolation** | Containers live in an isolated subnet; ports are not bound to host unless published | Container shares host network namespace directly; no port mapping needed |
| **DNS Resolution** | Automatic internal DNS resolving container/service names (e.g. `wordpress:9000`) | No container DNS; containers must bind to distinct host ports |
| **Security** | Internal ports (e.g. 3306, 9000) are inaccessible from outside the host | Every container port is immediately exposed on the host's physical network |
| **Subject Rule** | Required (`inception` network) | Explicitly forbidden by subject |

#### 4. Docker Volumes vs Bind Mounts
| Feature | Docker Named Volumes | Bind Mounts |
| :--- | :--- | :--- |
| **Management** | Fully managed by Docker engine (`docker volume ls`) | Direct reference to arbitrary host filesystem paths |
| **Host Dependency** | Abstracted; Docker handles storage driver options | Highly dependent on host directory existence and absolute path layout |
| **Permissions** | Managed cleanly across container boundaries | Prone to host UID/GID mismatch and permission conflicts |
| **Subject Rule** | Mandatory for persistent storage (configured with local driver opts) | Prohibited for persistent storage |
