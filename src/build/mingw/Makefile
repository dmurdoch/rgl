# 
# Makefile for win32/mingwl
# This file is part of RGL
#
# $Id: Makefile,v 1.10 2004/08/09 19:33:29 murdoch Exp $
#

all: target

.PHONY : clean deps


# ---[ C PREPROCESSOR ]--------------------------------------------------------

# ---[ C LANGUAGE ]------------------------------------------------------------

ifeq ($(strip $(DEBUG) ),1)
CPPFLAGS+=-DDEBUG
CFLAGS+=-g
else
CPPFLAGS+=-DDEBUG
CFLAGS+=-g
endif

# ---[ C++ LANGUAGE ]----------------------------------------------------------

# ---[ WINDOWS RESOURCES ]-----------------------------------------------------

RESCOMP=windres

COMPILE.rc=$(RESCOMP) $(RESFLAGS) -i $< -o $@

%.o: %.rc
	$(COMPILE.rc)

# ---[ WINDOWS DLL ]-----------------------------------------------------------

LINK.dll=$(LINK.cc) --shared $^ $(LOADLIBES) $(LDLIBS) -o $@

# ---[ LINKER ]----------------------------------------------------------------

# ---[ UTILITIES ]-------------------------------------------------------------

RM=rm -f

# ---[ R PACKAGE ]-------------------------------------------------------------

ifndef R_HOME
	R_HOME=C:/Programme/R/rw1080
endif

ifndef R_CMD
	R_CMD=$(R_HOME)/bin/Rcmd.exe
endif

RESFLAGS=--include-dir=$(R_HOME)/src/include

MAKE.RDLLRC=$(R_CMD) ../src/gnuwin32/makeDllRes.pl $(DLLNAME) >$@

$(DLLNAME).rc: ../DESCRIPTION $(R_HOME)/src/include/Rversion.h
	$(MAKE.RDLLRC)

# ===[ PROJECT ]===============================================================

include build/project.mk
include build/win32.mk

OBJS=$(foreach x, $(MODS), $x.o)
SRCS=$(foreach x, $(MODS), $x.cpp)

CFLAGS+=-Wall -pedantic
CXXFLAGS=$(CFLAGS) -fno-exceptions -fno-rtti
LDLIBS=-lopengl32 -lglu32 -lgdi32

# ---[ PNG ADD-ON ]-----------------------------------------------------------

ZLIBDIR=zlib
LIBPNGDIR=lpng

ZLIB=$(ZLIBDIR)/libz.a
LIBPNG=$(LIBPNGDIR)/libpng.a

CPPFLAGS+=-I$(ZLIBDIR) -I$(LIBPNGDIR) -DHAVE_PNG_H
LOADLIBES=-L$(ZLIBDIR) -L$(LIBPNGDIR) -lpng -lz

$(ZLIB):
	CFLAGS="$(CFLAGS)" make -e -C zlib -f nt/makefile.gcc

$(LIBPNG): $(ZLIB)
	CFLAGS="$(CFLAGS) -I../zlib" make -e -C lpng -f scripts/makefile.gcc

LIB_TARGETS+=$(LIBPNG)

# ---[ R PACKAGE ]-------------------------------------------------------------

DLLNAME=rgl
target: libs $(DLLNAME).dll

# ---[ CXX PROJECT ]-----------------------------------------------------------

# RESOURCE FILE
	
# TARGET

libs: $(LIB_TARGETS)

rgl_res.rc:
	$(MAKE.RDLLRC)

rgl_res.o: rgl_res.rc

rgl.dll: $(OBJS) rgl_res.o
	$(LINK.dll)

# MISC
	
clean:
	if test -d $(ZLIBDIR) ; then make -C $(ZLIBDIR) clean ; fi
	if test -d $(LIBPNGDIR) ; then make -C $(LIBPNGDIR) -f scripts/makefile.gcc clean ; fi
	$(RM) *.o *.a *.dll *.def .deps rgl_res.rc

deps: 
	$(CC) -MM $(SRCS) >$@

-include .deps
