LIB = backpack

MLS  = $(wildcard src/*.ml)
MLIS = $(MLS:.ml=.inferred.mli)

STUBS = $(wildcard src/*.c)
OBJS  = $(STUBS:.c=.o)

TEST_MLS = $(wildcard test/*.ml)
TESTS    = $(TEST_MLS:.ml=.byte) $(TEST_MLS:.ml=.native)

OFLAGS = -I src -tag debug -ocamlrun 'ocamlrun -b' #-classic-display

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
	@ocamlbuild $(OFLAGS) -no-links $@ --

clean:
	@ocamlbuild $(OFLAGS) -clean
