all:
	jbuilder build @install

install: all
	jbuilder install

uninstall:
	jbuilder uninstall

tests:
	jbuilder runtest

clean:
	jbuilder clean

.PHONY: all clean tests install uninstall
