BASENAME=holiship
FILENAME := ./$(BASENAME)-bin$(shell date +_%Y%m%d_%Hh%M).tar.gz
all:run

stop:
	# cd elm && make stop && cd ..

run: stop
	export NETWORK=hnet
	# cd elm && make run && cd ..


GRAPHTOOL_BINARIES=./graphTool/Makefile ./graphTool/run ./graphTool/gui/src/js ./graphTool/gui/src/LogoSirehna_DC.png ./graphTool/gui/src/elm.js ./graphTool/gui/src/elm-package.json ./graphTool/gui/src/*.css ./graphTool/gui/src/graphTool.html
BINARIES=./angular/ ./elm Makefile ./mqreceiver/ ./neo4j/ ./rabbitmq/ ./nginx $(GRAPHTOOL_BINARIES)


archive:
	tar -cvzf $(FILENAME) $(BINARIES)

build:
	# cd elm && make build && cd ..
