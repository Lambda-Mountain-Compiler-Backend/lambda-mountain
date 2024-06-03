
develop: compile-production
	rm -f tmp tmp.o tmp.s
	./production -o tmp.s tests/regress/paradata.lm
	as tmp.s -o tmp.o
	ld tmp.o -o tmp
	./tmp

re: compile-production
	rm -f tmp tmp.o tmp.s
	./re-production -o tmp.s tests/regress/parametric.lm
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
