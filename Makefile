.PHONY: test

check:
	lx check

build:
	lx build

test: build
	 bash scripts/test $(filter-out $@, $(MAKECMDGOALS))

%:
	@:
