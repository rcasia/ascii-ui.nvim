.PHONY: test

check:
	lx check

test:
	 bash scripts/test $(filter-out $@, $(MAKECMDGOALS))

%:
	@:
