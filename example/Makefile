.PHONY: all clean

all: mq cp term

mq: mq.ml
	ocamlfind ocamlopt -linkpkg -package backpack mq.ml -o mq

cp: cp.ml
	ocamlfind ocamlopt -linkpkg -package backpack cp.ml -o cp

term: term.ml
	ocamlfind ocamlopt -linkpkg -package backpack term.ml -o term

clean:
	rm -f mq cp term *.o *.cm*
