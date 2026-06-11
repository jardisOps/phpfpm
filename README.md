# 🐘 Jardis PHP-FPM & Nginx Docker Images

![Build Status](https://github.com/jardisOps/phpfpm/actions/workflows/phpfpm.yml/badge.svg)
[![Docker Image Version](https://img.shields.io/docker/v/headgent/phpfpm?sort=semver)](https://hub.docker.com/r/headgent/phpfpm)

### Production-grade PHP-FPM images built for high-performance web applications

Ship faster, scale smarter, and deploy with confidence. Our battle-tested images power **PHP 8.2–8.4** web workloads on **linux/amd64** and **linux/arm64**, delivering enterprise performance with developer-friendly defaults.

Part of **[Jardis](https://jardis.io)** — the platform for Domain-Driven Design in PHP. These images run the production-ready hexagonal code that Jardis-based applications are built on.

---

## 🚀 Why Choose Jardis PHP-FPM?

### Built for Production, Optimized for Performance

Modern PHP applications demand more than basic runtime environments. **Jardis PHP-FPM** delivers a complete, production-ready foundation that eliminates infrastructure complexity and accelerates your deployment pipeline:

- **🔄 One Image for All Environments** – The same image runs in development, staging, and production. No separate builds, no configuration drift. Just set your environment variables and go.

- **⚡ Maximum Performance** – OPcache + JIT enabled by default, FPM pool tuning via ENV, and optimized buffer settings deliver blazing-fast response times out of the box

- **🔒 Security-First Design** – Non-root user, minimal attack surface, Xdebug disabled by default, security headers pre-configured in Nginx, and regular Alpine security updates

- **🖥️ True Multi-Arch Support** – Native ARM64 support means seamless deployment on Apple Silicon, AWS Graviton, and modern cloud infrastructure

- **📦 Enterprise Extensions Included** – Redis, RabbitMQ (AMQP), Kafka (rdkafka) pre-installed for microservices, caching, and distributed systems

- **🪶 Ultra-Lightweight** – Only ~130MB for a fully-loaded PHP-FPM image with 15+ extensions. Built on Alpine Linux with zero bloat.

- **⚙️ 30+ Runtime Options** – Memory limits, OPcache settings, FPM pool tuning, Xdebug—all configurable via environment variables without rebuilding

---

## ✨ What's Inside

### Complete Extension Stack for Professional PHP

**Database Connectivity:**
- `pdo`, `pdo_mysql`, `mysqli`, `pdo_pgsql` – Full MySQL/MariaDB and PostgreSQL support

**Message Queue & Caching:**
- `amqp` (PECL 2.1.2) – RabbitMQ client for reliable message delivery
- `rdkafka` (PECL 6.0.5) – Apache Kafka client for high-throughput event streaming
- `apcu` (PECL 5.1.27) – In-memory user cache for blazing-fast data access
- `redis` (PECL 6.2.0) – Redis client for distributed caching and pub/sub

**Web Services & I/O:**
- `curl`, `soap` – HTTP/REST API clients and SOAP web services
- `sockets` – Low-level network socket programming
- `dom`, `zip` – XML processing and archive manipulation

**Internationalization & Data:**
- `mbstring`, `intl` – Unicode and multi-language support
- `bcmath` – Arbitrary precision mathematics

**Media Processing:**
- `gd` (FreeType + JPEG support) – Image generation and manipulation
- `exif` – Extract image metadata

**Development & Debugging:**
- `xdebug` (PECL 3.4.5) – Step debugging with breakpoint support (disabled by default)
- `pcov` (PECL 1.0.12) – Fast code coverage for CI/CD pipelines (disabled by default)

**Performance Foundation:**
- **OPcache** enabled – Eliminates PHP compilation overhead
- **JIT** enabled by default (mode `1254`) – Up to 3x performance boost for CPU-intensive code
- **Multi-stage build** – Full toolchain isolated to build stage, lean runtime (~130MB)

---

## 🎯 Perfect For

- **Modern Web Applications** – Laravel, Symfony, Slim, custom PHP frameworks
- **API Backends** – RESTful services, GraphQL endpoints, microservices
- **Content Management** – WordPress, Drupal, custom CMS solutions
- **E-Commerce Platforms** – High-traffic storefronts, checkout systems
- **SaaS Applications** – Multi-tenant platforms, subscription services
- **Enterprise Portals** – Intranets, dashboards, admin panels

---

## 🏗️ Architecture & Tags

### Multi-Architecture Support
- **linux/amd64** – Intel/AMD x86_64 processors
- **linux/arm64** – Apple Silicon (M1/M2/M3), AWS Graviton, Ampere

### PHP-FPM Version Tags
| Tag | PHP Version | Status |
|-----|-------------|--------|
| `8.4`, `latest` | PHP 8.4 | Current |
| `8.3` | PHP 8.3 | Supported |
| `8.2` | PHP 8.2 | Supported |

### Nginx Tags
| Tag | Nginx Version | Status |
|-----|---------------|--------|
| `1.28`, `latest` | Nginx 1.28 | Current |

**Published under the `headgent/` Docker Hub namespace:**
- https://hub.docker.com/r/headgent/phpfpm
- https://hub.docker.com/r/headgent/nginx

---

## ⚡ Performance: OPcache & JIT

PHP 8.2+ delivers production-stable JIT (Just-In-Time) compilation on both AMD64 and ARM64. Our images enable JIT by default with optimal settings for web workloads.

### Configuration Modes

**🚀 Production Mode (Default)**
```bash
XDEBUG_MODE=off                    # Xdebug disabled
OPCACHE_VALIDATE_TIMESTAMPS=0      # No file change checks
```
- ✅ JIT fully operational (up to 3x faster execution)
- ✅ Maximum throughput, minimal overhead
- 🎯 Ready for production out of the box

**🛠️ Development Mode**
```bash
XDEBUG_MODE=debug                  # Enable step debugging
OPCACHE_VALIDATE_TIMESTAMPS=1      # Check file changes
```
- ✅ Step debugging with breakpoints
- ⚠️ PHP automatically disables JIT when Xdebug is active
- 🎯 Optimized for local development workflows

**💡 Key Insight:** Xdebug and JIT cannot run simultaneously. This is by design—when `XDEBUG_MODE=debug`, PHP automatically disables JIT to ensure debugging reliability.

---

## 🌐 Nginx Image

Pre-configured Nginx optimized for PHP-FPM applications:

- **Gzip Compression** – Automatic compression for text, JSON, CSS, JS
- **Static Asset Caching** – 1-year cache headers for images, fonts, scripts
- **Security Headers** – XSS protection, HSTS, X-Frame-Options, CSP
- **FastCGI Optimization** – Tuned buffers and timeouts for PHP-FPM
- **Reverse Proxy Ready** – Real IP headers for Traefik, nginx-proxy, load balancers

### Configuration
```yaml
services:
  webserver:
    image: headgent/nginx:latest
    environment:
      HOST: example.com
      APP_ROOT: /app
      DOCUMENT_ROOT: /public
      INDEX_FILE: index.php
      PHP_PORT: 9000
```

---

## 🔧 Configuration

All settings can be overridden at runtime via environment variables:

### PHP Core
| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_MEMORY_LIMIT` | `512M` | Maximum memory per script |
| `PHP_MAX_EXECUTION_TIME` | `30` | Max execution time (seconds) |
| `PHP_TIMEZONE` | `UTC` | Default timezone |
| `PHP_DISPLAY_ERRORS` | `Off` | Display errors (use `On` for dev) |
| `PHP_LOG_ERRORS` | `On` | Log errors to stderr |

### OPcache & JIT
| Variable | Default | Description |
|----------|---------|-------------|
| `OPCACHE_MEMORY_CONSUMPTION` | `128` | OPcache memory (MB) |
| `OPCACHE_MAX_ACCELERATED_FILES` | `4000` | Max cached scripts |
| `OPCACHE_VALIDATE_TIMESTAMPS` | `0` | Check file changes (`1` for dev) |
| `OPCACHE_JIT` | `1254` | JIT mode (1254=tracing, off=disabled) |
| `OPCACHE_JIT_BUFFER_SIZE` | `128M` | JIT buffer size |

### APCu
| Variable | Default | Description |
|----------|---------|-------------|
| `APCU_SHM_SIZE` | `64M` | Shared memory size |

### Xdebug
| Variable | Default | Description |
|----------|---------|-------------|
| `XDEBUG_MODE` | `off` | Mode: `off`, `debug`, `coverage`, `profile` |
| `XDEBUG_START_WITH_REQUEST` | `yes` | Auto-start debugging |
| `XDEBUG_CLIENT_HOST` | `host.docker.internal` | IDE host (macOS/Windows) |
| `XDEBUG_CLIENT_PORT` | `9003` | IDE port |
| `XDEBUG_IDEKEY` | `PHPSTORM` | IDE key |

### PCOV (Code Coverage)
| Variable | Default | Description |
|----------|---------|-------------|
| `PCOV_ENABLED` | `0` | Enable PCOV (`1` to enable) |

### PHP-FPM Pool
| Variable | Default | Description |
|----------|---------|-------------|
| `FPM_PM` | `dynamic` | Process manager mode |
| `FPM_PM_MAX_CHILDREN` | `5` | Max worker processes |
| `FPM_PM_START_SERVERS` | `2` | Initial workers |
| `FPM_PM_MIN_SPARE_SERVERS` | `1` | Min idle workers |
| `FPM_PM_MAX_SPARE_SERVERS` | `3` | Max idle workers |
| `FPM_PM_MAX_REQUESTS` | `500` | Requests before worker restart |

### PECL Extension Versions
| Extension | Version | Purpose |
|-----------|---------|---------|
| `amqp` | `2.1.2` | RabbitMQ AMQP 0-9-1 protocol client |
| `rdkafka` | `6.0.5` | Apache Kafka high-performance client |
| `apcu` | `5.1.27` | In-memory user cache |
| `redis` | `6.2.0` | Redis client for caching/pub-sub |
| `xdebug` | `3.4.5` | Step debugging with breakpoints |
| `pcov` | `1.0.12` | Fast code coverage collection |

---

## 🚀 Quick Start

### Pull & Run
```bash
# Pull latest images
docker pull headgent/phpfpm:8.4
docker pull headgent/nginx:latest

# Check PHP version and extensions
docker run --rm headgent/phpfpm:8.4 php -v
docker run --rm headgent/phpfpm:8.4 php -m

# Verify JIT is active
docker run --rm headgent/phpfpm:8.4 \
  php -r '$s=opcache_get_status(); echo "JIT: ".($s["jit"]["on"]?"✅ ACTIVE":"❌ OFF")."\n";'
```

### Docker Compose Example
```yaml
services:
  app:
    image: headgent/phpfpm:8.4
    volumes:
      - ./src:/app
    environment:
      PHP_MEMORY_LIMIT: 256M
      OPCACHE_VALIDATE_TIMESTAMPS: 1  # Development mode

  webserver:
    image: headgent/nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./src:/app
    environment:
      APP_ROOT: /app
      DOCUMENT_ROOT: /public
    depends_on:
      - app
```

### Development with Xdebug
```yaml
services:
  app:
    image: headgent/phpfpm:8.4
    environment:
      XDEBUG_MODE: debug
      XDEBUG_CLIENT_HOST: host.docker.internal
      OPCACHE_VALIDATE_TIMESTAMPS: 1
```

---

## 🔬 Build & Customize

### Prerequisites
- Docker with BuildKit enabled
- `make` (GNU Make)

### Local Build
```bash
# Build single PHP version
make phpfpm-build PHP_VERSION=8.4

# Build all PHP versions (8.2, 8.3, 8.4)
make phpfpm-build-all

# Build Nginx
make nginx-build

# Build everything
make build-all
```

### Push to Registry
```bash
# Login to Docker Hub
docker login

# Push all images (multi-arch)
make build-and-push-all
```

### Makefile Targets
| Target | Description |
|--------|-------------|
| `make info` | Display build configuration |
| `make phpfpm-build` | Build PHP-FPM (current version) |
| `make phpfpm-build-all` | Build PHP-FPM (all versions) |
| `make nginx-build` | Build Nginx image |
| `make build-all` | Build all images locally |
| `make phpfpm-push` | Push PHP-FPM (current version) |
| `make build-and-push-all` | Build and push all images |
| `make build-cache-delete` | Clear buildx cache |

---

## 📊 Image Size

**Optimized for Production:**
- PHP-FPM 8.2/8.3/8.4: **~130MB** (compressed)
- Nginx: **~25MB** (compressed)

**What's Included:**
- Complete PHP runtime with 15+ extensions
- RabbitMQ + Kafka support
- Composer 2.9
- OPcache + JIT
- Development tools (Xdebug, PCOV)

**What's NOT Included:**
- Build toolchain (isolated to build stage)
- Unnecessary system packages
- Development headers

---

## 🔒 Security

- **Non-root user:** Processes run as `appuser` with automatic UID/GID matching to mounted volumes (fixes macOS UID 501, GitHub Actions UID 1001)
- **Minimal attack surface:** Only runtime dependencies in final image
- **Production defaults:** Xdebug disabled, secure error handling, `expose_php=Off`
- **Security headers:** Pre-configured in Nginx (XSS, HSTS, CSP, X-Frame-Options)
- **Regular updates:** Built on Alpine Linux with security patches
- **Health checks:** PHP-FPM ping endpoint for container orchestration

---

## 💡 Origin

This project emerged from the development of **JardisCore** – a PHP framework built for Domain-Driven Design (DDD) and Hexagonal Architecture. The images are battle-tested in complex enterprise applications following clean architecture principles.

---

## 📄 License

MIT © Headgent GmbH

---

## 📚 Documentation

Full documentation, guides, and reference:

**[docs.jardis.io/en/devops/phpfpm](https://docs.jardis.io/en/devops/phpfpm)**

## 💬 Support

- **Issues:** https://github.com/jardisOps/phpfpm/issues
- **Docker Hub:** https://hub.docker.com/r/headgent/phpfpm
- **Email:** jardisDev@headgent.com

---

**Built with ❤️ by the Jardis team** – Empowering developers to ship production-ready PHP applications with confidence.
