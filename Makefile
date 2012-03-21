LIB = backpack

MLS  = $(wildcard src/*.ml)
MLIS = $(MLS:.ml=.inferred.mli)

STUBS = $(wildcard src/*.c)
OBJS  = $(STUBS:.c=.o)

TEST_MLS = $(wildcard test/*.ml)
TESTS    = $(TEST_MLS:.ml=.byte) $(TEST_MLS:.ml=.native)

OFLAGS = -I src -no-links -tag debug -ocamlrun 'ocamlrun -b' #-classic-display

.PHONY: all test clean $(MLIS) $(OBJS) $(LIB) $(TESTS)

all: $(MLIS) $(LIB)

$(MLIS) $(OBJS):
	@ocamlbuild $(OFLAGS) $@

$(LIB): $(OBJS)
	@ocamlbuild $(OFLAGS) $@.cma
	@ocamlbuild $(OFLAGS) $@.cmxa
	@cd _build; ocamlmklib -o $@ $+

test: $(LIB) $(TESTS)

$(TESTS):
	@LD_LIBRARY_PATH=_build ocamlbuild $(OFLAGS) $@ --

clean:
	@ocamlbuild $(OFLAGS) -clean
