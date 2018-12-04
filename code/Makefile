.PHONY: all clean artifacts

all: js/elm.js

js/elm.js: src/*
	rm -rf elm-stuff/generated-code || true
	docker run -t --rm -v $(shell pwd):/work -u $(shell id -u):$(shell id -g) -w /work elm make --yes --warn src/Main.elm --output js/elm.js

artifacts: BuDa.zip

BuDa.zip: src/BuDa.html js/elm.js src/*.css src/*.png src/*.svg css/* img/*
	zip -r -9 BuDa.zip src/BuDa.html js raphTool/src/css BuDa/src/*.png src/*/svg src/*.css src/*.js

clean:
	rm -rf js/elm.js BuDa.zip elm-stuff/generated-code elm-stuff/build-artifacts
