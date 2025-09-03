.PHONY: test

check:
	# running luacheck...
	
	# skipping lx check for now, it does not support offline mode
	# lx check

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

ifdef GITHUB_ACTIONS
test: build
	 bash scripts/test $(filter-out $@, $(MAKECMDGOALS))
else
test: build
	 bash scripts/test_mini $(filter-out $@, $(MAKECMDGOALS))
endif

docs:
	./scripts/gendocs

%:
	@:
