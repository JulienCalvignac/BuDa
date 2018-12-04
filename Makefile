.PHONY: all build-babel build-code build-elm

all: public/index.html

public/index.html: code/js/cytoutils.babel.js
	mkdir -p public
	cp code/css/*.css public/
	cp -r code/js public/
	mv public/js/cytoutils.babel.js public/js/cytoutils.js
	cp code/src/*.html public/
	cp code/img/*.png public/
	mv public/BuDa.html public/index.html

code/js/cytoutils.babel.js: code/js/cytoutils.js build-babel build-code
	docker run -t --rm -v $(shell pwd):/work -w /work -u $(shell id -u):$(shell id -g) babel

build-code: build-elm
	cd code && make

build-elm:
	cd elm && make

build-babel:
	cd babel && make
