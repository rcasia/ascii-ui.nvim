.PHONY: test

test:
	 bash scripts/test $(filter-out $@, $(MAKECMDGOALS))

busted:
	eval $(luarocks path --lua-version=5.1 --lua-dir=/opt/lua-5.1.5) &&  busted --run unit

%:
	@:
