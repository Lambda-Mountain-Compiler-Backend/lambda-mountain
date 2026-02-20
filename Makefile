CC = clang
CFLAGS = -w -O2 -march=native -mtune=native

dev: install-production
	time lm --v23 tests/promises/lm-ascript/ascript-integrated.lsts
	gcc tmp.c
	./a.out

build: compile-production
	time ./production --v2 --c -o deploy1.c SRC/index.lsts
	$(CC) $(CFLAGS) deploy1.c -o deploy1
	time ./deploy1 --v2 --c -o deploy2.c SRC/index.lsts
	diff deploy1.c deploy2.c
	mv deploy1.c BOOTSTRAP/cli.c
	rm -f deploy1 deploy1.c deploy2.c
	cargo test regression_tests

deploy: build smoke-test
deploy-lite: build smoke-test-lite

valgrind: install-bootstrap
	valgrind --tool=callgrind lm --v2 SRC/index.lsts

valgrind-view:
	callgrind_annotate callgrind.out.18778

gprof:
	$(CC) $(CFLAGS) -pg -o bootstrap.exe BOOTSTRAP/cli.c
	./bootstrap.exe SRC/index.lsts

gprof-view-count:
	gprof bootstrap.exe gmon.out | less

gprof-view-call-graph:
	gprof -q bootstrap.exe gmon.out

profile: install-bootstrap
	perf record lm --v2 SRC/index.lsts
	./report.sh

compile-bootstrap:
	rm -f bootstrap.exe
	$(CC) $(CFLAGS) -o bootstrap.exe BOOTSTRAP/cli.c

compile-production: compile-bootstrap
	rm -f production
	./bootstrap.exe --v2 --c -o production.c SRC/index.lsts
	$(CC) $(CFLAGS) -o production production.c
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
	clang $(CFLAGS) BOOTSTRAP/cli.c -o tmp
	rm tmp

smoke-test-gcc:
	gcc $(CFLAGS) BOOTSTRAP/cli.c -o tmp
	rm tmp

smoke-test-musl:
	musl-gcc $(CFLAGS) BOOTSTRAP/cli.c -o tmp
	rm tmp

smoke-test: smoke-test-clang smoke-test-gcc smoke-test-musl
smoke-test-lite: smoke-test-clang smoke-test-gcc

install:
	$(CC) $(CFLAGS) -o lm BOOTSTRAP/cli.c
ifeq ($(shell test -w /usr/local/bin; echo $$?), 0)
	mv lm /usr/local/bin/lm
else
	mkdir -p $${HOME}/.local/bin
	mv lm $${HOME}/.local/bin/lm
endif
	mkdir -p $${HOME}/.lm/
	cp -rf lib $${HOME}/.lm/
