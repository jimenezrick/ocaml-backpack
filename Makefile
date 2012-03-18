#MAIN = main.byte
#MAIN = main.native
MODS  = $(wildcard src/*.ml)
IFS   = $(MODS:.ml=.inferred.mli)

TEST_MODS = $(wildcard test/*.ml)
TESTS     = $(TEST_MODS:.ml=.byte)

OFLAGS = -I src -tag debug -ocamlrun 'ocamlrun -b'

.PHONY: all test clean $(IFS) $(MAIN) $(TESTS)

all: $(IFS) $(MAIN)

$(IFS) $(MAIN):
	@ocamlbuild $(OFLAGS) $@

test: $(TESTS)

$(TESTS):
	@ocamlbuild $(OFLAGS) -no-links $@ --

clean:
	@ocamlbuild $(OFLAGS) -clean
