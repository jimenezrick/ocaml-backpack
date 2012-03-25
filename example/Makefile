.PHONY: all clean

all: mq

mq: mq.ml
	ocamlfind ocamlopt -linkpkg -package backpack mq.ml -o mq

clean:
	rm -f mq mq.o mq.cm*
