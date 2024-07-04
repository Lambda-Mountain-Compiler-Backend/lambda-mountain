
develop: compile-production
	time ./production -o tmp.s tests/regress/forward-type-definition.lm
	as tmp.s -o tmp.o
	ld tmp.o -o tmp
	./tmp

deploy: compile-production
	time ./production -o deploy.s SRC/cli.lm
	as deploy.s -o deploy.o
	ld deploy.o -o deploy
	time ./deploy -o deploy2.s SRC/cli.lm
	diff deploy.s deploy2.s
	mv deploy.s BOOTSTRAP/cli.s
	cargo test regression_tests

compile-dev: compile-bootstrap
	rm -f dev dev.o dev.s
	./bootstrap -o dev.s DEV/cli.lm
	as -o dev.o dev.s
	ld -o dev   dev.o

compile-production: compile-bootstrap
	rm -f production production.o production.s
	./bootstrap -o production.s SRC/cli.lm
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
