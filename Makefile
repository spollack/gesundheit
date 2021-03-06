LIB_DIR = ./lib
SRC_DIR = ./src
PATH := $(shell npm bin):$(PATH)
HEAD = $(shell git describe --contains --all HEAD)
PACKAGE_VERSION = $(shell node -e 'console.log(require("./package.json").version)')

.PHONY: all
all: $(LIB_DIR)
	@cp $(SRC_DIR)/sql_keywords.txt $(LIB_DIR)/

.PHONY: test
test: unit integration

.PHONY: unit
unit: all
	@node_modules/.bin/tap --stderr test/unit/

.PHONY: integration
integration: all
	@mysql -u root -e 'drop database if exists gesundheit_test'
	@mysql -u root -e 'create database gesundheit_test'
	@psql -U postgres -c 'drop database if exists gesundheit_test' 2>&1 >/dev/null
	@psql -U postgres -c 'create database gesundheit_test' 2>&1 >/dev/null
	@node_modules/.bin/tap --stderr test/integration/*.test.*

.PHONY: clean
clean:
	@rm -rf $(LIB_DIR)
	@rm -rf lib-tmp

$(LIB_DIR): $(SRC_DIR)
	@node_modules/.bin/coffee -o $@ -bc $<

pages: bundle
	make -C doc clean html
	cp bundle.js doc/_build/html/_static
	cp tryit.html doc/_build/html/_static

release: clean test pages
	git checkout gh-pages
	cp -R doc/_build/html/ ./
	[[ -z `git status -suno` ]] || git commit -a -m v$(PACKAGE_VERSION)
	git checkout $(HEAD)
