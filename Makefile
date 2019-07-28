all: t

t: src/t.cr src/t/version.cr
	crystal build --error-trace src/t.cr
