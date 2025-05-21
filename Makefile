# Makefile for jpeg2ps
# (C) Thomas Merz 1994-2002

VERSION=1.9.1
DIRNAME = jpeg2ps-$(VERSION)
TARFILE = jpeg2ps-$(VERSION).tar
ZIPFILE = jpeg2ps-$(VERSION).zip

# ----------------------------------------------------------------------------
# Supported compile time options:
# -DA4 gives A4 as default page size, omitting -DA4 gives U.S. letter format
# -DDOS adds DOS and OS/2 support

# The following was reported to work for emx/gcc 0.9c fix04 under OS/2:
# make -f Makefile "CFLAGS=-c -DA4 -DDOS -O2" "LDFLAGS=-Zexe -s"

WARN=-Wall -Wextra -Wwrite-strings -Wdeclaration-after-statement \
	-Wignored-qualifiers -Wmissing-field-initializers -Wtype-limits \
	-Wuninitialized -Winit-self -Wredundant-decls -Wparentheses \
	-Wunused-parameter -Wunused-variable -Wunused-function -Wunused-value \
	-Wswitch-default -Wreturn-type -Wshadow -Wformat-security -Wformat-y2k \
	-Wswitch-enum -Wstrict-prototypes -Wundef -Wunused-macros \
	-Wcast-align -Wpacked -Wmissing-prototypes -Wmissing-declarations \
	-Wnested-externs -Wbad-function-cast -Wconversion
CFLAGS=-c -DVERSION=\"$(VERSION)\" -DA4 -Ofast -fomit-frame-pointer $(WARN) -pipe
LD=$(CC)
LDFLAGS=
OBJ=o
EXE=
RM=rm -f
SHELL=/bin/bash

.PHONY: all dist test check clean install uninstall

.c.$(OBJ) :
	$(CC) $(CFLAGS) $*.c

all:	jpeg2ps$(EXE)

# If your system doesn't have getopt(), add getopt.$(OBJ)
# at the end of the next two lines below.

jpeg2ps$(EXE):	jpeg2ps.$(OBJ) readjpeg.$(OBJ) asc85ec.$(OBJ)
	$(LD) $(LDFLAGS) -o jpeg2ps$(EXE) jpeg2ps.$(OBJ) readjpeg.$(OBJ) asc85ec.$(OBJ)

DISTFILES = \
	jpeg2ps.c psimage.h readjpeg.c asc85ec.c getopt.c	\
	mac_prefix.h						\
	Makefile jpeg2ps.dsp jpeg2ps.mcp			\
	jpeg2ps.txt descrip.mms nesrin.jpg jpeg2ps.1

DOSDISTFILES = $(DISTFILES) jpeg2ps.exe

# Installation prefix
PREFIX = /usr/local

# Location where to install the binary. This is a suitable value for Linux
# (and possibly other unix-like) systems.
BINDIR = $(PREFIX)/bin

# Location where to install the manual page.
MANDIR = $(PREFIX)/man/man1

CONVFILES = \
	jpeg2ps.c psimage.h readjpeg.c asc85ec.c getopt.c	\
	mac_prefix.h						\
	Makefile jpeg2ps.txt

dist:
	$(RM) $(ZIPFILE) $(TARFILE).gz;				\
	ln -s . $(DIRNAME);					\
	lineend -d $(CONVFILES);		 		\
	(for i in $(DOSDISTFILES); do				\
		echo $$i;					\
	done) | sed "s;.*;$(DIRNAME)/&;" >distfiles;		\
	zip -9 $(ZIPFILE) `cat distfiles`;			\
	(for i in $(DISTFILES); do				\
		echo $$i;					\
	done) | sed "s;.*;$(DIRNAME)/&;" >distfiles;		\
	lineend -u $(CONVFILES); 				\
	tar cvf  $(TARFILE) `cat distfiles`;			\
	gzip -9 $(TARFILE);					\
	$(RM) $(DIRNAME) distfiles;

test:	jpeg2ps$(EXE)
	./jpeg2ps -o nesrin.eps nesrin.jpg
	@if diff -q <(grep -v '^%%CreationDate' nesrin.eps) <(grep -v '^%%CreationDate' nesrin.txt) ; \
	then echo "OK" ; else echo "Error: nesrin.eps does not match nesrin.txt" ; fi

check:	test

clean:
	$(RM) *.$(OBJ) jpeg2ps$(EXE) $(TARFILE) $(TARFILE).gz $(ZIPFILE) \
	nesrin.eps

install: jpeg2ps$(EXE)
	cp jpeg2ps$(EXE) $(DESTDIR)$(BINDIR)
	cp jpeg2ps.1 $(DESTDIR)$(MANDIR)

uninstall:
	rm -f $(BINDIR)/jpeg2ps$(EXE)
	rm -f $(MANDIR)/jpeg2ps.1

jpeg2ps.$(OBJ):		jpeg2ps.c psimage.h

readjpeg.$(OBJ):	readjpeg.c psimage.h

asc85ec.$(OBJ):		asc85ec.c psimage.h

getopt.$(OBJ):		getopt.c
