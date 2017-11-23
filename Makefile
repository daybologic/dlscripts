all : rmlist rmlistd

rmlist : Makefile rmlist.c
	cc -ansi -pedantic -Wall -O3 -ormlist rmlist.c
	strip --strip-all rmlist

rmlistd : Makefile rmlist.c
	cc -g -ansi -pedantic -Wall -ormlistd rmlist.c

clean:
	-rm -f rmlist rmlistd
	-rm -f rmlist.o rmlistd.o
	-rm -f rmlist.core rmlistd.core
	-rm -f core
	-rm -f *~
