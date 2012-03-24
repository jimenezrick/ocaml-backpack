LIB = backpack

MLS  = $(wildcard src/*.ml)
MLIS = $(MLS:.ml=.inferred.mli)

STUBS = $(wildcard src/*.c)
OBJS  = $(STUBS:.c=.o)

TEST_MLS = $(wildcard test/*.ml)
TESTS    = $(TEST_MLS:.ml=.d.byte) $(TEST_MLS:.ml=.native)

OFLAGS = -I src -no-links

INSTALL_FILES =                  \
	src/META                 \
	src/backpack.mli         \
	_build/src/backpack.a    \
	_build/src/backpack.cma  \
	_build/src/backpack.cmi  \
	_build/src/backpack.cmxa \
	_build/libbackpack.a     \
	_build/dllbackpack.so

.PHONY: all test clean install uninstall $(MLIS) $(OBJS) $(LIB) $(TESTS)

all: $(MLIS) $(LIB)
	@cp _build/src/*.mli src
	@rename .inferred '' src/*.mli

$(MLIS) $(OBJS):
	@ocamlbuild $(OFLAGS) $@

$(LIB): $(OBJS)
	@ocamlbuild $(OFLAGS) $@.cma
	@ocamlbuild $(OFLAGS) $@.cmxa
	@cd _build; ocamlmklib -o $@ $+

test: all $(TESTS)

$(TESTS):
	@LD_LIBRARY_PATH=_build ocamlbuild $(OFLAGS) $@ --

clean:
	@ocamlbuild $(OFLAGS) -clean
	@rm -f src/*.mli

install: all
	@strip _build/dll$(LIB).so
	@ocamlfind install $(LIB) $(INSTALL_FILES)

uninstall:
	@ocamlfind remove $(LIB)
