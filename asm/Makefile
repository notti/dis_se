ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

asm: src/scanner/scanner.go src/parser/parser.go asm.go
	GOPATH=$(ROOT_DIR) go build

src/scanner/scanner.go: scanner.rl src/parser/parser.go
	@mkdir -p src/scanner
	ragel -Z -o src/scanner/scanner.go scanner.rl

src/parser/parser.go: parser.y
	@mkdir -p src/parser
	go tool yacc -p Parser -o src/parser/parser.go parser.y
