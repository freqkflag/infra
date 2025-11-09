SHELL := /bin/bash

DEVICE ?= vps.host
ENV ?= prod
HARVEST_SCRIPT := scripts/harvest_$(DEVICE).sh
REDEPLOY_SCRIPT := scripts/redeploy_$(DEVICE).sh
STATUS_SCRIPT := scripts/status.sh
DC ?= $(shell if docker compose version >/dev/null 2>&1; then printf '%s' "docker compose"; elif docker-compose version >/dev/null 2>&1; then printf '%s' "docker-compose"; else printf '%s' "docker compose"; fi)
HARVEST ?= $(shell ls -1t harvest_${DEVICE}_*/harvest_${DEVICE}_*.tar.gz 2>/dev/null | head -n1)

ifndef QUIET
ECHO := @echo
else
ECHO :=
endif

.PHONY: help plan harvest ingest deploy rollout status check-device

help:
	$(ECHO) "Available targets:"
	$(ECHO) "  make plan DEVICE=<node> [ENV=prod]        # Render compose config via Infisical"
	$(ECHO) "  make harvest DEVICE=<node>                # Run harvest script (read-only)"
	$(ECHO) "  make ingest DEVICE=<node> [HARVEST=...]   # Ingest latest harvest artifacts"
	$(ECHO) "  make deploy DEVICE=<node>                 # Redeploy node via docker compose"
	$(ECHO) "  make rollout DEVICE=<node>                # Redeploy + status checks"
	$(ECHO) "  make status                               # Aggregate status checks"

check-device:
	@if [ ! -x "$(HARVEST_SCRIPT)" ]; then \
		echo "Unknown device '$(DEVICE)' (missing $(HARVEST_SCRIPT))" >&2; \
		exit 1; \
	fi
	@if [ ! -x "$(REDEPLOY_SCRIPT)" ]; then \
		echo "Unknown device '$(DEVICE)' (missing $(REDEPLOY_SCRIPT))" >&2; \
		exit 1; \
	fi

plan: check-device
	@if [ -z "$(shell command -v infisical)" ]; then \
		echo "infisical CLI not found in PATH" >&2; \
		exit 1; \
	fi
	$(ECHO) "Rendering plan for $(DEVICE) using env=$(ENV)"
	infisical run --env=$(ENV) -- $(DC) -f nodes/$(DEVICE)/compose.yml config

harvest: check-device
	$(ECHO) "Harvesting $(DEVICE)"
	./$(HARVEST_SCRIPT) $(ARGS)

ingest: check-device
	@if [ -z "$(HARVEST)" ]; then \
		echo "No harvest archive found for $(DEVICE); set HARVEST=<path>" >&2; \
		exit 1; \
	fi
	$(ECHO) "Ingesting $(HARVEST) into nodes/$(DEVICE) (env=$(ENV))"
	./scripts/ingest_harvest.sh "$(DEVICE)" "$(HARVEST)"

deploy: check-device
	$(ECHO) "Redeploying $(DEVICE)"
	./$(REDEPLOY_SCRIPT) $(ARGS)

rollout: deploy
	$(ECHO) "Running global status checks post-rollout"
	@if [ -x "$(STATUS_SCRIPT)" ]; then ./$(STATUS_SCRIPT); else echo "status script not found"; fi

status:
	@if [ -x "$(STATUS_SCRIPT)" ]; then ./$(STATUS_SCRIPT); else echo "status script not found"; fi

