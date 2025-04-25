CC = cc

dev: install-production
	lm SRC/index-index.lm
	cc tmp.c

build: compile-production
	time ./production --c -o deploy1.c SRC/index-index.lm
	$(CC) -O3 deploy1.c -o deploy1
	time ./deploy1 --c -o deploy2.c SRC/index-index.lm
	diff deploy1.c deploy2.c
	mv deploy1.c BOOTSTRAP/cli.c
	rm -f deploy1 deploy1.c deploy2.c
	cargo test regression_tests

deploy: build smoke-test
deploy-lite: build smoke-test-lite

gprof:
	$(CC) -O3 -pg -o bootstrap.exe BOOTSTRAP/cli.c
	./bootstrap.exe SRC/index-index.lm

gprof-view-count:
	gprof bootstrap.exe gmon.out | less

gprof-view-call-graph:
	gprof -q bootstrap.exe gmon.out

profile: install-bootstrap
	perf record lm SRC/index-index.lm
	./report.sh

compile-bootstrap:
	rm -f bootstrap.exe
	$(CC) -O3 -o bootstrap.exe BOOTSTRAP/cli.c

compile-production: compile-bootstrap
	rm -f production
	./bootstrap.exe --c -o production.c SRC/index-index.lm
	$(CC) -O3 -o production production.c
	rm -f production.c

install-production: compile-production
ifeq ($(shell test -w /usr/local/bin; echo $$?), 0)
	mv production /usr/local/bin/lm
else
	mkdir -p $${HOME}/.local/bin
	mv production $${HOME}/.local/bin/lm
endif

install-bootstrap: compile-bootstrap
ifeq ($(shell test -w /usr/local/bin; echo $$?), 0)
	mv bootstrap.exe /usr/local/bin/lm
else
	mkdir -p $${HOME}/.local/bin
	mv bootstrap.exe $${HOME}/.local/bin/lm
endif

smoke-test-clang:
	clang BOOTSTRAP/cli.c -o tmp
	rm tmp

smoke-test-gcc:
	gcc BOOTSTRAP/cli.c -o tmp
	rm tmp

smoke-test-musl:
	musl-gcc BOOTSTRAP/cli.c -o tmp
	rm tmp

smoke-test: smoke-test-clang smoke-test-gcc smoke-test-musl
smoke-test-lite: smoke-test-clang smoke-test-gcc

install:
	$(CC) -O3 -o lm BOOTSTRAP/cli.c
ifeq ($(shell test -w /usr/local/bin; echo $$?), 0)
	mv lm /usr/local/bin/lm
else
	mkdir -p $${HOME}/.local/bin
	mv lm $${HOME}/.local/bin/lm
endif
	mkdir -p $${HOME}/.lm/
	cp -rf PLATFORM $${HOME}/.lm/
