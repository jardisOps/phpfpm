# ---------------------------------------------------------------------------
# Globale Einstellungen
# ---------------------------------------------------------------------------
MAKEFLAGS      += --warn-undefined-variables
.SHELLFLAGS    := -eu -o pipefail -c
SHELL          := bash
.DEFAULT_GOAL  := info

include ./.env
export

# ---------------------------------------------------------------------------
# Module einbinden
# ---------------------------------------------------------------------------
include ./support/makefiles/docker.helper.mk
include ./support/makefiles/docker.build.local.mk
include ./support/makefiles/docker.build.push.mk
include ./support/makefiles/test.mk
include ./support/makefiles/ssh.mk

# ---------------------------------------------------------------------------
# Info-Target
# ---------------------------------------------------------------------------
##@ Setup
init: ## Git Remote auf GITHUB_ORG/GITHUB_REPO aus .env setzen
	@echo "Setting git remote origin to https://github.com/$(GITHUB_ORG)/$(GITHUB_REPO).git"
	@git remote set-url origin "https://github.com/$(GITHUB_ORG)/$(GITHUB_REPO).git"
	@echo "Done. Current remote:"
	@git remote -v
.PHONY: init

##@ Info
info: ## Build-Konfiguration anzeigen
	@printf "\033[1mHeadgent Docker Image Builder\033[0m\n"
	@printf "\033[1m══════════════════════════════\033[0m\n"
	@echo ""
	@printf "\033[1mGitHub:\033[0m %s/%s\n" "$(GITHUB_ORG)" "$(GITHUB_REPO)"
	@printf "\033[1mDocker Hub:\033[0m %s\n" "$(DOCKER_HUB)"
	@echo ""
	@printf "\033[1mBase Images:\033[0m\n"
	@printf "  %-20s %s\n" "Alpine:" "$(ALPINE_VERSION)"
	@echo ""
	@printf "\033[1mPHP-FPM:\033[0m\n"
	@printf "  %-20s %s\n" "Versions:" "$(PHP_VERSIONS)"
	@printf "  %-20s %s\n" "Latest:" "$(PHP_LATEST)"
	@printf "  %-20s %s\n" "Default:" "$(PHP_VERSION)"
	@echo ""
	@printf "\033[1mNginx:\033[0m\n"
	@printf "  %-20s %s\n" "Version:" "$(WEBSERVER_VERSION)"
	@echo ""
	@printf "\033[1mUser/Group:\033[0m\n"
	@printf "  %-20s %s\n" "PUID:" "$(PUID)"
	@printf "  %-20s %s\n" "PGID:" "$(PGID)"
	@awk '\
		BEGIN { cols = "\033[36m%-28s\033[0m" } \
		/^##@ / { \
			sub(/^##@ /,""); \
			printf "\n\033[1m%s\033[0m\n", $$0; next } \
		/^[A-Za-z0-9_.-]+:.*##/ { \
			split($$0, a, ":"); tgt = a[1]; \
			sub(/^.*## /,""); \
			printf "  " cols " %s\n", tgt, $$0 } \
	' $(MAKEFILE_LIST)
.PHONY: info
