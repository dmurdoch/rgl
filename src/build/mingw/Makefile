# 
# Makefile for win32/mingwl
# This file is part of RGL
#

# TOOLS

ECHO=@echo 
DLL=g++ --shared --dll
RM=rm -f

# AUX LIBRARIES

ZLIBDIR=zlib
LIBPNGDIR=lpng124

# CONFIG

CPPFLAGS=-I$(ZLIBDIR) -I$(LIBPNGDIR) -DHAVE_PNG_H
CFLAGS=-Wall -O2 -fomit-frame-pointer
CXXFLAGS=$(CFLAGS) -fno-exceptions -fno-rtti

DLLFLAGS=-lopengl32 -lgdi32 -L$(ZLIBDIR) -L$(LIBPNGDIR) -lpng -lz

TARGET=rgl.dll

# PROJECT FILES

include build/project.mk
include build/win32.mk

ZLIB=$(ZLIBDIR)/libz.a
LIBPNG=$(LIBPNGDIR)/libpng.a

# RULES

all: $(TARGET)

$(ZLIB):
	CFLAGS="$(CFLAGS)" make -e -C zlib

$(LIBPNG):
	CFLAGS="$(CFLAGS) -I../zlib" make -e -C lpng124 -f scripts/makefile.gcc
	
$(TARGET): $(ZLIB) $(LIBPNG) $(OBJS) $(PLATFORM_OBJS)
	$(DLL) $(OBJS) $(PLATFORM_OBJS) $(DLLFLAGS) $(CXXFLAGS) -o $(TARGET)

# MISC
	
clean:
	make -C $(ZLIBDIR) clean
	make -C $(LIBPNGDIR) -f scripts/makefile.gcc clean
	$(RM) *.o *.a *.dll .deps

deps:
	$(CC) -MM *.cpp *.h >.deps

