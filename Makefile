
develop: compile-production
	cp production re-production
	rm -f tmp tmp.o tmp.s
	./production -o tmp.s tests/btstrp/test27.lm
	as tmp.s -o tmp.o
	ld tmp.o -o tmp
	./tmp

re:
	rm -f tmp tmp.o tmp.s
	./re-production -o tmp.s tests/btstrp/test27.lm
	as tmp.s -o tmp.o
	ld tmp.o -o tmp
	./tmp

deploy: compile-production
	time ./production -o deploy.s SRC/cli.lm
	diff production.s deploy.s
	mv deploy.s BOOTSTRAP/cli.s

compile-production: compile-bootstrap
	rm -f production production.o production.s
	./bootstrap -o production.s SRC/cli.lm
	as -o production.o production.s
	ld -o production   production.o

compile-bootstrap:
	rm -f bootstrap bootstrap.o
	as -o bootstrap.o BOOTSTRAP/cli.s
	ld -o bootstrap   bootstrap.o

install:
	as -o lm_raw.o BOOTSTRAP/cli.s
	ld -o lm lm_raw.o
	mv lm /usr/local/bin/
	rm lm_raw.o
