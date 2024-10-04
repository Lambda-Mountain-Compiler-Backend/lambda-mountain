
work: compile-production
	./production tests/regress/hello-world.lm
	as tmp.s -o tmp.o
	ld tmp.o -o tmp
	./tmp

build-docs:
	lm --blob -o docs/index.html docs/index.html.lm
	doby doc -o docs/default.html.html.lm LIB/default.html
	doby doc -o docs/default.lm.html.lm LIB/default.lm
	doby doc -o docs/lm.lm.html.lm SRC/index-index.lm
	lm --blob -o docs/default.html.html docs/default.html.html.lm
	lm --blob -o docs/default.lm.html docs/default.lm.html.lm
	lm --blob -o docs/lm.lm.html docs/lm.lm.html.lm

develop:
	lmv tests/regress/hello_world.s.v
	coqc tmp.v
	coqchk tmp.vo

build: compile-production
	time ./production -o deploy.s SRC/index-index.lm
	as deploy.s -o deploy.o
	ld deploy.o -o deploy
	time ./deploy -o deploy2.s SRC/index-index.lm
	diff deploy.s deploy2.s
	mv deploy.s BOOTSTRAP/cli.s
	cargo test regression_tests

deploy: build build-docs

compile-production: compile-bootstrap
	rm -f production production.o production.s
	./bootstrap -o production.s SRC/index-index.lm
	as -o production.o production.s
	ld -o production   production.o
	cp production re-production

compile-bootstrap:
	rm -f bootstrap bootstrap.o
	as -o bootstrap.o BOOTSTRAP/cli.s
	ld -o bootstrap   bootstrap.o

install:
	as -o lm_raw.o BOOTSTRAP/cli.s
	ld -o lm lm_raw.o
	mv lm /usr/local/bin/
	rm lm_raw.o
	#lm LMV/cli.lm -o lmv.s
	#as -o lmv.o lmv.s
	#ld -o lmv   lmv.o
	#mv lmv /usr/local/bin
	#rm lmv.s lmv.o
	#lm DOBY/cli.lm -o doby.s
	#as -o doby.o doby.s
	#ld -o doby   doby.o
	#mv doby /usr/local/bin
	#rm doby.s doby.o

validate:
	coqc LIB/default_validator.v
	coqchk LIB/default_validator.vo

disassemble:
	objdump -S hello_world
