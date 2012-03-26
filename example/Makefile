.PHONY: all clean

all: mq cp

mq: mq.ml
	ocamlfind ocamlopt -linkpkg -package backpack mq.ml -o mq

cp: cp.ml
	ocamlfind ocamlopt -linkpkg -package backpack cp.ml -o cp

clean:
	rm -f mq cp *.o *.cm*
