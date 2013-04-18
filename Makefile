all: kyoto.cma kyoto.cmxa

DESTDIR=`ocamlc -where`
install: kyoto.cmxa kyoto.cma
	cp kyoto.mli kyoto.cmi kyoto.cmxa kyoto.cma libkyoto.a dllkyoto.so $(DESTDIR)

.SUFFIXES: .c .cpp .o .ml .mli .cmo .cmx .cmi

.c.o:
	gcc -O2 -fpic -Wall -c $<

.cpp.o:
	g++ -O2 -fpic -c $<

.mli.cmi: 
	ocamlc -c $<

.ml.cmo: 
	ocamlc -c $<

.ml.cmx: 
	ocamlopt -c $<

.ml.o: 
	ocamlopt -c $<

kyoto.ml: kyoto.cmi

libkyoto.a: kyoto_ocaml_wrapper.o
	rm -f $@
	ar rc $@ kyoto_ocaml_wrapper.o

kyoto.cmxa: kyoto.cmx libkyoto.a
	ocamlopt -a -o kyoto.cmxa kyoto.cmx -cclib -lkyoto -cclib -lkyotocabinet

kyoto.cma: kyoto.cmo kyoto.cmx kyoto_ocaml_wrapper.o
	ocamlmklib -o kyoto kyoto.cmo kyoto_ocaml_wrapper.o -lkyotocabinet

test: kyoto.cmxa tests.cmx
	ocamlopt -I . -o tests.native kyoto.cmxa tests.cmx
	./tests.native

clean:
	rm -f *.o *.cmo *.cmx *.cmi *.so *.a *.cma *.cmxa tests.native
