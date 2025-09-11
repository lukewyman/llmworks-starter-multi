SERVICES := $(shell ls -1 services 2>/dev/null)

.PHONY: install preflight test run help docker-build docker-push

help:
	@echo "Targets:"
	@echo "  install        Fan-out installs for all services"
	@echo "  preflight      Fan-out lint/type/test checks for all services"
	@echo "  test           Fan-out tests for all services"
	@echo "  run-<svc>      Run a specific service (e.g., make run-svc-1 PORT=8080)"
	@echo ""
	@echo "Examples:"
	@echo "  make install"
	@echo "  make preflight"
	@echo "  make run-svc-1 PORT=8080"
	@echo "  make run-svc-2 PORT=8081"

install: ## fan-out installs (each service manages its own venv)
	@for s in $(SERVICES); do \
	  if [ -f services/$$s/Makefile ]; then \
	    echo "== install $$s =="; \
	    $(MAKE) -C services/$$s install || exit 1; \
	  fi; \
	done

preflight: ## fan-out checks
	@for s in $(SERVICES); do \
	  if [ -f services/$$s/Makefile ]; then \
	    echo "== preflight $$s =="; \
	    $(MAKE) -C services/$$s preflight || exit 1; \
	  fi; \
	done

test: ## fan-out tests
	@for s in $(SERVICES); do \
	  if [ -f services/$$s/Makefile ]; then \
	    echo "== test $$s =="; \
	    $(MAKE) -C services/$$s test || exit 1; \
	  fi; \
	done

# Convenience launcher: make run-svc-1 PORT=8080, make run-svc-2 PORT=8081
run-%:
	@svc="$*"; \
	if [ ! -f "services/$$svc/Makefile" ]; then \
	  echo "No Makefile for services/$$svc"; exit 1; \
	fi; \
	$(MAKE) -C services/$$svc run

REGISTRY ?= ghcr.io/lukewyman

docker-build:
	@for s in $(SERVICES); do \
	  img="$(REGISTRY)/llmworks/$$s:dev"; \
	  echo "== building $$img =="; \
	  docker build -f services/$$s/Dockerfile.dev -t $$img services/$$s; \
	done

docker-push:
	@for s in $(SERVICES); do \
	  img="$(REGISTRY)/llmworks/$$s:dev"; \
	  echo "== pushing $$img =="; \
	  docker push $$img; \
	done
