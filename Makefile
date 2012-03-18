#MAIN=main.byte
MODS=$(wildcard src/*.ml)
IFS=$(MODS:.ml=.inferred.mli)

TEST_MODS=$(wildcard test/*.ml)
TESTS=$(TEST_MODS:.ml=.byte)

OFLAGS=-I src -tag debug -no-links -ocamlrun 'ocamlrun -b'

.PHONY: all test clean $(IFS) $(MAIN) $(TESTS)

all: $(IFS) $(MAIN)

$(IFS) $(MAIN):
	@ocamlbuild $(OFLAGS) $@

test: $(TESTS)

$(TESTS):
	@ocamlbuild $(OFLAGS) $@ --

clean:
	@ocamlbuild $(OFLAGS) -clean
