MODULES = trailDB.cmi
LIB = trailDB.cma trailDB.cmxa trailDB.cmxs trailDB.a dllocamltraildb.so libocamltraildb.a $(MODULES)
BIN = tests.native

all:
	ocamlbuild -use-ocamlfind $(LIB) $(BIN)

install:
	ocamlfind install traildb META $(addprefix _build/, $(LIB))

uninstall:
	ocamlfind remove traildb

tests: all
	_build/tests.native

clean:
	ocamlbuild -clean

.PHONY: all clean tests install
