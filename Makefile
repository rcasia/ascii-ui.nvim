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

test: build
	 bash scripts/test $(filter-out $@, $(MAKECMDGOALS))

docs:
	./scripts/gendocs

%:
	@:
