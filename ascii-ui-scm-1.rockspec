rockspec_format = "3.0"
package = "ascii-ui"
version = "scm-1"

test_dependencies = {
	"lua >= 5.1",
	"nlua",
}

source = {
	url = "git://github.com/mrcjkb/" .. package,
}

build = {
	type = "builtin",
}
