# ---------------------------------------------------------------------------
# Smoke tests (Multi-Arch: amd64 & arm64) for the php-fpm + nginx base images.
#
# phpfpm has no application test suite — these are base-image smoke tests that
# prove the freshly built images actually boot and expose what consumers rely on:
#   - php-fpm starts and answers /ping with "pong" (uses the baked HEALTHCHECK)
#   - every expected PHP extension is loaded
#   - OPcache is active (CLI) and JIT is on
#   - the nginx vhost template renders to a syntactically valid config
#
# Test images are built per-arch with --load and tagged :<arch>-test, mirroring
# the phpcli test flow. Override TEST_PLATFORMS=arm64 for a fast native-only run.
# ---------------------------------------------------------------------------
##@ Test

PHPFPM_TEST_IMAGE ?= headgent-phpfpm-test
NGINX_TEST_IMAGE  ?= headgent-nginx-test
TEST_PLATFORMS    ?= amd64 arm64

# Extensions installed by src/php/Dockerfile (docker-php-ext-install + pecl).
# xdebug is omitted on purpose: it is loaded but disabled (XDEBUG_MODE=off).
PHP_EXTENSIONS := apcu redis gd intl mbstring bcmath soap exif sockets dom zip mysqli curl pdo_mysql pdo_pgsql pcov amqp rdkafka

# All build-args required by src/php/Dockerfile (runtime ARGs have no defaults).
FPM_TEST_BUILD_ARGS = \
	--build-arg COMPOSER_VERSION=$(COMPOSER_VERSION) \
	--build-arg PHP_VERSION=$(PHP_VERSION) \
	--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
	--build-arg APCU_VERSION=$(APCU_VERSION) \
	--build-arg REDIS_PECL_VERSION=$(REDIS_PECL_VERSION) \
	--build-arg XDEBUG_VERSION=$(XDEBUG_VERSION) \
	--build-arg PCOV_VERSION=$(PCOV_VERSION) \
	--build-arg AMQP_VERSION=$(AMQP_VERSION) \
	--build-arg RDKAFKA_VERSION=$(RDKAFKA_VERSION) \
	--build-arg PUID=$(PUID) \
	--build-arg PGID=$(PGID) \
	--build-arg PHP_MEMORY_LIMIT=$(PHP_MEMORY_LIMIT) \
	--build-arg PHP_MAX_EXECUTION_TIME=$(PHP_MAX_EXECUTION_TIME) \
	--build-arg PHP_TIMEZONE=$(PHP_TIMEZONE) \
	--build-arg PHP_ERROR_REPORTING=$(PHP_ERROR_REPORTING) \
	--build-arg PHP_DISPLAY_ERRORS=$(PHP_DISPLAY_ERRORS) \
	--build-arg PHP_LOG_ERRORS=$(PHP_LOG_ERRORS) \
	--build-arg APCU_SHM_SIZE=$(APCU_SHM_SIZE) \
	--build-arg OPCACHE_MEMORY_CONSUMPTION=$(OPCACHE_MEMORY_CONSUMPTION) \
	--build-arg OPCACHE_MAX_ACCELERATED_FILES=$(OPCACHE_MAX_ACCELERATED_FILES) \
	--build-arg OPCACHE_VALIDATE_TIMESTAMPS=$(OPCACHE_VALIDATE_TIMESTAMPS) \
	--build-arg OPCACHE_REVALIDATE_FREQ=$(OPCACHE_REVALIDATE_FREQ) \
	--build-arg OPCACHE_JIT=$(OPCACHE_JIT) \
	--build-arg OPCACHE_JIT_BUFFER_SIZE=$(OPCACHE_JIT_BUFFER_SIZE) \
	--build-arg XDEBUG_MODE=$(XDEBUG_MODE) \
	--build-arg XDEBUG_START_WITH_REQUEST=$(XDEBUG_START_WITH_REQUEST) \
	--build-arg XDEBUG_CLIENT_HOST=$(XDEBUG_CLIENT_HOST) \
	--build-arg XDEBUG_CLIENT_PORT=$(XDEBUG_CLIENT_PORT) \
	--build-arg XDEBUG_LOG_LEVEL=$(XDEBUG_LOG_LEVEL) \
	--build-arg XDEBUG_IDEKEY=$(XDEBUG_IDEKEY) \
	--build-arg PCOV_ENABLED=$(PCOV_ENABLED) \
	--build-arg FPM_PM=$(FPM_PM) \
	--build-arg FPM_PM_MAX_CHILDREN=$(FPM_PM_MAX_CHILDREN) \
	--build-arg FPM_PM_START_SERVERS=$(FPM_PM_START_SERVERS) \
	--build-arg FPM_PM_MIN_SPARE_SERVERS=$(FPM_PM_MIN_SPARE_SERVERS) \
	--build-arg FPM_PM_MAX_SPARE_SERVERS=$(FPM_PM_MAX_SPARE_SERVERS) \
	--build-arg FPM_PM_MAX_REQUESTS=$(FPM_PM_MAX_REQUESTS)

# ---------------------------------------------------------------------------
# Build per-arch test images (--load into the local docker engine)
# ---------------------------------------------------------------------------
build-test-images: buildx-builder-create ## Build per-arch php-fpm test images (:amd64-test/:arm64-test) for PHP_VERSION
	@set -e; \
	for arch in $(TEST_PLATFORMS); do \
	  echo "🔧 Building php-fpm test image for $$arch (PHP $(PHP_VERSION))..."; \
	  docker buildx build \
	    --load \
	    --platform=linux/$$arch \
	    $(FPM_TEST_BUILD_ARGS) \
	    -t $(PHPFPM_TEST_IMAGE):$$arch-test \
	    -f ./src/php/Dockerfile \
	    ./src/php; \
	done
.PHONY: build-test-images

build-nginx-test-images: buildx-builder-create ## Build per-arch nginx test images (:amd64-test/:arm64-test)
	@set -e; \
	for arch in $(TEST_PLATFORMS); do \
	  echo "🔧 Building nginx test image for $$arch..."; \
	  docker buildx build \
	    --load \
	    --platform=linux/$$arch \
	    --build-arg WEBSERVER_VERSION=$(WEBSERVER_VERSION) \
	    --build-arg PUID=$(PUID) \
	    --build-arg PGID=$(PGID) \
	    -t $(NGINX_TEST_IMAGE):$$arch-test \
	    -f ./src/nginx/Dockerfile \
	    ./src/nginx; \
	done
.PHONY: build-nginx-test-images

# ---------------------------------------------------------------------------
# php-fpm smoke tests
# ---------------------------------------------------------------------------
test-fpm-start: build-test-images ## php-fpm boots and answers /ping with pong (baked HEALTHCHECK) on both archs
	@set -e; \
	for arch in $(TEST_PLATFORMS); do \
	  echo ">>> php-fpm start on $$arch"; \
	  cid=$$(docker run -d --platform=linux/$$arch -e XDEBUG_MODE=off $(PHPFPM_TEST_IMAGE):$$arch-test); \
	  status=starting; \
	  for i in $$(seq 1 30); do \
	    if [ "$$(docker inspect -f '{{.State.Running}}' $$cid 2>/dev/null)" != "true" ]; then status=exited; break; fi; \
	    status=$$(docker inspect -f '{{.State.Health.Status}}' $$cid 2>/dev/null || echo nohealth); \
	    [ "$$status" = "healthy" ] && break; \
	    sleep 2; \
	  done; \
	  docker logs $$cid > /tmp/fpm-$$arch.log 2>&1 || true; \
	  docker rm -f $$cid >/dev/null 2>&1 || true; \
	  if [ "$$status" != "healthy" ]; then \
	    echo "❌ php-fpm not healthy on $$arch (status=$$status)"; echo "--- container log ---"; cat /tmp/fpm-$$arch.log; exit 1; \
	  fi; \
	  echo "✅ php-fpm started & healthy (/ping → pong) on $$arch"; \
	done
.PHONY: test-fpm-start

test-extensions: build-test-images ## All expected PHP extensions loaded on both archs
	@set -e; \
	for arch in $(TEST_PLATFORMS); do \
	  echo ">>> PHP extensions on $$arch"; \
	  for ext in $(PHP_EXTENSIONS); do \
	    docker run --rm --platform=linux/$$arch -e XDEBUG_MODE=off $(PHPFPM_TEST_IMAGE):$$arch-test php -r "\
if (!extension_loaded('$$ext')) {fwrite(STDERR,'Missing: $$ext'); exit(1);} \
"; \
	  done; \
	  echo "✅ All extensions loaded on $$arch"; \
	done
.PHONY: test-extensions

test-opcache: build-test-images ## OPcache loaded + active (enable & enable_cli) and JIT on on both archs
	@set -e; \
	for arch in $(TEST_PLATFORMS); do \
	  echo ">>> OPcache & JIT on $$arch"; \
	  docker run --rm --platform=linux/$$arch -e XDEBUG_MODE=off $(PHPFPM_TEST_IMAGE):$$arch-test php -r "\
if (!(extension_loaded('Zend OPcache') || extension_loaded('opcache'))) {fwrite(STDERR,'OPcache not loaded'); exit(1);} \
if (ini_get('opcache.enable')!=='1')     {fwrite(STDERR,'opcache.enable != '.ini_get('opcache.enable')); exit(1);} \
if (ini_get('opcache.enable_cli')!=='1') {fwrite(STDERR,'opcache.enable_cli != '.ini_get('opcache.enable_cli')); exit(1);} \
\$$jit = ini_get('opcache.jit'); \
if (in_array(strtolower((string)\$$jit), ['', '0','off','disable','disabled'], true)) {fwrite(STDERR,'opcache.jit disabled: '.\$$jit); exit(1);} \
\$$jit_buffer = ini_get('opcache.jit_buffer_size'); \
if (\$$jit_buffer === '0' || \$$jit_buffer === '' || (int)\$$jit_buffer === 0) {fwrite(STDERR,'opcache.jit_buffer_size is 0'); exit(1);} \
"; \
	  echo "✅ OPcache active & JIT on on $$arch"; \
	done
.PHONY: test-opcache

# ---------------------------------------------------------------------------
# nginx smoke test
# ---------------------------------------------------------------------------
nginx-test: build-nginx-test-images ## nginx vhost template renders to a valid config (nginx -t) on both archs
	@set -e; \
	for arch in $(TEST_PLATFORMS); do \
	  echo ">>> nginx -t on $$arch"; \
	  docker run --rm --platform=linux/$$arch \
	    --add-host app:127.0.0.1 \
	    -e APP_ROOT=/app -e DOCUMENT_ROOT=/public -e INDEX_FILE=index.php -e HOST=localhost -e PHP_PORT=9000 \
	    --entrypoint sh $(NGINX_TEST_IMAGE):$$arch-test \
	    -c "envsubst '\$$APP_ROOT \$$DOCUMENT_ROOT \$$INDEX_FILE \$$HOST \$$PHP_PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -t"; \
	  echo "✅ nginx config valid on $$arch"; \
	done
.PHONY: nginx-test

# ---------------------------------------------------------------------------
# Bundle
# ---------------------------------------------------------------------------
test-all: test-fpm-start test-extensions test-opcache ## Run all php-fpm smoke tests (both archs)
	@echo "✅ All php-fpm smoke tests passed for $(TEST_PLATFORMS)!"
.PHONY: test-all
