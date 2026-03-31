# ---------------------------------------------------------------------------
# Image Builder - Local Builds
# ---------------------------------------------------------------------------
##@ Image Builder (Local)

# ---------------------------------------------------------------------------
# PHP-FPM
# ---------------------------------------------------------------------------
phpfpm-build: buildx-builder-create ## Build PHP-FPM image for current PHP_VERSION (local)
	@echo "🔧 Building PHP-FPM image for PHP $(PHP_VERSION)..."
	@docker buildx build \
		--load \
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
		-f ./src/php/Dockerfile \
		./src/php \
		$(BUILD_EXTRA_FLAGS)
	@echo "✅ Built $(PHPFPM_IMAGE):$(PHP_VERSION)"
.PHONY: phpfpm-build

phpfpm-build-all: buildx-builder-create ## Build PHP-FPM images for all PHP versions (local)
	@for v in $(PHP_VERSIONS); do \
		echo "🔧 Building PHP-FPM image for PHP $$v..."; \
		docker buildx build \
			--load \
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
			-t $(PHPFPM_IMAGE):$$v \
			-f ./src/php/Dockerfile \
			./src/php \
			$(BUILD_EXTRA_FLAGS); \
		echo "✅ Built $(PHPFPM_IMAGE):$$v"; \
	done
	@docker tag $(PHPFPM_IMAGE):$(PHP_LATEST) $(PHPFPM_IMAGE):latest
	@echo "✅ Tagged $(PHPFPM_IMAGE):$(PHP_LATEST) as latest"
.PHONY: phpfpm-build-all

# ---------------------------------------------------------------------------
# Nginx
# ---------------------------------------------------------------------------
nginx-build: buildx-builder-create ## Build Nginx image (local)
	@echo "🔧 Building Nginx image..."
	@docker buildx build \
		--load \
		--build-arg WEBSERVER_VERSION=$(WEBSERVER_VERSION) \
		--build-arg PUID=$(PUID) \
		--build-arg PGID=$(PGID) \
		-t $(NGINX_IMAGE):$(WEBSERVER_VERSION) \
		-t $(NGINX_IMAGE):latest \
		-f ./src/nginx/Dockerfile \
		./src/nginx \
		$(BUILD_EXTRA_FLAGS)
	@echo "✅ Built $(NGINX_IMAGE):$(WEBSERVER_VERSION)"
.PHONY: nginx-build

# ---------------------------------------------------------------------------
# Bundles
# ---------------------------------------------------------------------------
build-all: phpfpm-build-all nginx-build ## Build all images locally
	@echo "✅ All images built successfully"
.PHONY: build-all
