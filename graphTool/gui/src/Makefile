FILENAME := ../graphTool-bin$(shell date +_%Y%m%d_%Hh%M).tar.gz
FILENAME2 := ../graphTool-src-bin$(shell date +_%Y%m%d_%Hh%M).tar.gz
JSFILES = js/jquery-2.2.4.min.js js/cytoscape.js js/cytoutils.js js/dagre.js js/cytoscape-dagre.js js/download.js js/loadFile.js
BINARIES = graphTool.html graphTool.css cytostylesheet.css maia.css mainstyle.css elm.js m28.json $(JSFILES)
SRC_BINARIES = $(BINARIES) *.elm elm-package.json Makefile

all : clean test app
	elm-make Main.elm --output elm.js --yes

app : clean
	elm-make Main.elm --output elm.js --yes

test: clean-test
	elm-test

clean:
	rm -rf elm-stuff/build-artifacts/

clean-test:
	rm -rf tests/elm-stuff/build-artifacts/

build: $(BINARIES)

	tar -cvzf $(FILENAME) $(BINARIES)

build-src: $(SRC_BINARIES)
	tar -cvzf $(FILENAME2) $(SRC_BINARIES)
