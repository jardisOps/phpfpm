# ---------------------------------------------------------------------------
# Image Builder - Remote Push
# ---------------------------------------------------------------------------
##@ Image Builder (Push to Registry)

# ---------------------------------------------------------------------------
# PHP-FPM
# ---------------------------------------------------------------------------
phpfpm-push: buildx-builder-create .check-docker-login ## Build and push PHP-FPM image for current PHP_VERSION (multi-arch)
	@echo "🚀 Building and pushing PHP-FPM image for PHP $(PHP_VERSION)..."
	@docker buildx build \
		--platform linux/amd64,linux/arm64 \
		$(BUILD_ATTEST_FLAGS) \
		--push \
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
		--build-arg FPM_PM_MAX_REQUESTS=$(FPM_PM_MAX_REQUESTS) \
		-t $(PHPFPM_IMAGE):$(PHP_VERSION) \
		$(if $(filter $(PHP_VERSION),$(PHP_LATEST)),-t $(PHPFPM_IMAGE):latest) \
		-f ./src/php/Dockerfile \
		./src/php \
		$(BUILD_EXTRA_FLAGS)
	@echo "✅ Pushed $(PHPFPM_IMAGE):$(PHP_VERSION)"
.PHONY: phpfpm-push

phpfpm-push-all: buildx-builder-create .check-docker-login ## Build and push PHP-FPM images for all PHP versions (multi-arch)
	@for v in $(PHP_VERSIONS); do \
		echo "🚀 Building and pushing PHP-FPM image for PHP $$v..."; \
		LATEST_TAG=""; \
		if [ "$$v" = "$(PHP_LATEST)" ]; then LATEST_TAG="-t $(PHPFPM_IMAGE):latest"; fi; \
		docker buildx build \
			--platform linux/amd64,linux/arm64 \
			$(BUILD_ATTEST_FLAGS) \
			--push \
			--build-arg COMPOSER_VERSION=$(COMPOSER_VERSION) \
			--build-arg PHP_VERSION=$$v \
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
			--build-arg FPM_PM_MAX_REQUESTS=$(FPM_PM_MAX_REQUESTS) \
			-t $(PHPFPM_IMAGE):$$v $$LATEST_TAG \
			-f ./src/php/Dockerfile \
			./src/php \
			$(BUILD_EXTRA_FLAGS); \
		echo "✅ Pushed $(PHPFPM_IMAGE):$$v"; \
	done
.PHONY: phpfpm-push-all

# ---------------------------------------------------------------------------
# Nginx
# ---------------------------------------------------------------------------
nginx-push: buildx-builder-create .check-docker-login ## Build and push Nginx image (multi-arch)
	@echo "🚀 Building and pushing Nginx image..."
	@docker buildx build \
		--platform linux/amd64,linux/arm64 \
		$(BUILD_ATTEST_FLAGS) \
		--push \
		--build-arg WEBSERVER_VERSION=$(WEBSERVER_VERSION) \
		--build-arg PUID=$(PUID) \
		--build-arg PGID=$(PGID) \
		-t $(NGINX_IMAGE):$(WEBSERVER_VERSION) \
		-t $(NGINX_IMAGE):latest \
		-f ./src/nginx/Dockerfile \
		./src/nginx \
		$(BUILD_EXTRA_FLAGS)
	@echo "✅ Pushed $(NGINX_IMAGE):$(WEBSERVER_VERSION)"
.PHONY: nginx-push

# ---------------------------------------------------------------------------
# Bundles
# ---------------------------------------------------------------------------
build-and-push-all: phpfpm-push-all nginx-push ## Build and push all images (multi-arch)
	@echo "✅ All images pushed successfully"
.PHONY: build-and-push-all

# ---------------------------------------------------------------------------
# Docker Login Check
# ---------------------------------------------------------------------------
.check-docker-login:
	@if [ -z "$(DOCKER_HUB)" ]; then \
		echo "❌ DOCKER_HUB muss gesetzt sein."; exit 1; \
	fi
	@if ! docker info 2>/dev/null | grep -q "Username"; then \
		echo "⚠️  Nicht bei Docker Hub eingeloggt. Bitte 'docker login' ausführen."; \
	fi
.PHONY: .check-docker-login
