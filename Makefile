all: t

t: src/t.cr src/t/version.cr
	crystal build src/t.cr
