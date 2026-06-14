# ---------------------------------------------------------------------------
# Image Builder - Configuration & Helpers
# ---------------------------------------------------------------------------
##@ Image Builder

# ---------------------------------------------------------------------------
# Version Defaults
# ---------------------------------------------------------------------------
PHP_VERSIONS ?= 8.2 8.3 8.4
PHP_LATEST   ?= 8.4

# ---------------------------------------------------------------------------
# Image Names
# ---------------------------------------------------------------------------
PHPFPM_IMAGE    = $(DOCKER_HUB)/phpfpm
NGINX_IMAGE     = $(DOCKER_HUB)/nginx

# ---------------------------------------------------------------------------
# Immutable date tag (UTC), added alongside the moving :<ver>/:latest tags in
# the push targets only. Lets consumers pin a reproducible image for rollback
# (e.g. headgent/phpfpm:8.4-20260614, headgent/nginx:1.28-20260614) while the
# moving tags stay current for patch hygiene. Override for reproducible re-tags.
# ---------------------------------------------------------------------------
IMAGE_DATE      ?= $(shell date -u +%Y%m%d)

# ---------------------------------------------------------------------------
# Build Flags (can be overridden via command line)
# ---------------------------------------------------------------------------
BUILD_EXTRA_FLAGS  ?=
BUILD_ATTEST_FLAGS ?= --provenance=mode=max --attest=type=sbom

# ---------------------------------------------------------------------------
# Buildx Helper
# ---------------------------------------------------------------------------
buildx-builder-create: ## Create/use multiarch builder
	@if ! docker buildx ls | grep -q multiarch-builder; then \
		echo "🔧 Creating multiarch-builder..."; \
		docker buildx create --name multiarch-builder --use --driver docker-container; \
	else \
		echo "✅ multiarch-builder already exists"; \
		docker buildx use multiarch-builder; \
	fi
.PHONY: buildx-builder-create

build-cache-delete: ## Delete all cached image layers
	@docker buildx prune -a -f
.PHONY: build-cache-delete

builder-reset: ## Delete and recreate multiarch builder
	@echo "🔄 Resetting multiarch-builder..."
	@docker buildx rm multiarch-builder 2>/dev/null || true
	@docker buildx create --name multiarch-builder --use
	@echo "✅ multiarch-builder wurde neu erstellt"
.PHONY: builder-reset
