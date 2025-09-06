SERVICES := $(shell ls -1 services 2>/dev/null)

.PHONY: install preflight test

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
