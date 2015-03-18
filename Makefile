TARGETS = okyoto.cma okyoto.cmxa okyoto.cmxs okyoto.a libocamlkyoto.a dllocamlkyoto.so kyoto.cmi kyoto.cma kyoto.cmx
LIB = $(addprefix _build/, $(TARGETS))

all:
	ocamlbuild $(TARGETS)

install:
	ocamlfind install okyoto META $(LIB)

uninstall:
	ocamlfind remove okyoto

tests: tests.native
	_build/tests.native

tests.native: tests.ml
	ocamlbuild -libs okyoto tests.native

kyotoselect.native: kyotoselect.ml
	ocamlbuild -libs okyoto kyotoselect.native

clean:
	ocamlbuild -clean

.PHONY: all clean tests install
