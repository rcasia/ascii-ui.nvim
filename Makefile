.PHONY: test

check:
	# running luacheck...
	lx check

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

%:
	@:
