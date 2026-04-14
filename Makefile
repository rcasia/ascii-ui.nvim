.PHONY: test bench

check:
	# running luacheck...
	
	lx --lua-version 5.1 lint
	stylua --check .

	# running ast-grep rules...
	ast-grep scan lua/ --error=no-print-statements

	# running doc check...
	./scripts/check-docs

ifdef GITHUB_ACTIONS
build:
	echo "Skipping build in GitHub Actions"
else
build:
	echo "Building project..."
	lx --lua-version 5.1 build
endif

test: build
	 bash scripts/test $(filter-out $@, $(MAKECMDGOALS))

bench: build
	bash scripts/bench

docs-check:
	./scripts/check-docs

docs:
	./scripts/gendocs

%:
	@:
