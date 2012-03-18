#MAIN = main.byte
#MAIN = main.native
MODS  = $(wildcard src/*.ml)
IFS   = $(MODS:.ml=.inferred.mli)

TEST_MODS = $(wildcard test/*.ml)
TESTS     = $(TEST_MODS:.ml=.byte)

OFLAGS = -I src -tag debug -no-links -ocamlrun 'ocamlrun -b'

.PHONY: all test clean $(MAIN) $(IFS) $(TESTS)

all: $(MAIN) $(IFS)

$(MAIN) $(IFS):
	@ocamlbuild $(OFLAGS) $@

test: $(TESTS)

$(TESTS):
	@ocamlbuild $(OFLAGS) $@ --

clean:
	@ocamlbuild $(OFLAGS) -clean
