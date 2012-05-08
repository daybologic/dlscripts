all : nopath_unix nopathd_unix

nopath_unix : nopath_unix.c Makefile
	cc -DNDEBUG -O3 -ansi -pedantic -onopath_unix nopath_unix.c
	strip --strip-all nopath_unix

nopathd_unix : nopath_unix.c Makefile
	cc -g -ansi -pedantic -onopathd_unix nopath_unix.c

clean:
	-rm -f *~ nopath_unix nopath_unix.o core nopath_unix.core
	-rm -f nopathd_unix nopathd_unix.o nopathd_unix.core
