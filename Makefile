.PHONY: test

SHELL := /bin/bash
NVIM  ?= nvim
INIT  ?= tests/minimal.lua

TEST_CMD = $(NVIM) --headless -u $(INIT) -c "lua MiniTest.run()"

check:
	# running luacheck...
	
	# skipping lx check for now, it does not support offline mode
	lx lint

	# running doc check...
	./scripts/check-docs

ifdef GITHUB_ACTIONS
build:
	echo "Skipping build in GitHub Actions"
else
build:
	echo "Building project..."
	lx build
endif

test: build
	 # bash scripts/test $(filter-out $@, $(MAKECMDGOALS))
	@echo "🧪 Running tests at $$(date '+%Y-%m-%d %H:%M:%S')"
	@$(TEST_CMD)
	@echo "✅ Finished at $$(date '+%Y-%m-%d %H:%M:%S')"

docs:
	./scripts/gendocs

%:
	@:
