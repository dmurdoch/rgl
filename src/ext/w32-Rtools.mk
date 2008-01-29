#
# FreeType 2 configuration rules for mingw32
#


# Copyright 1996-2000, 2003, 2005 by
# David Turner, Robert Wilhelm, and Werner Lemberg.
#
# This file is part of the FreeType project, and may only be used, modified,
# and distributed under the terms of the FreeType project license,
# LICENSE.TXT.  By continuing to use, modify, or distribute this file you
# indicate that you have read the license and understand and accept it
# fully.

# default definitions of the export list
#
EXPORTS_LIST      = $(OBJ_DIR)/freetype.def
EXPORTS_OPTIONS   = $(EXPORTS_LIST)
APINAMES_OPTIONS := -dfreetype.dll -w

# modified Win32-specific definitions

DELETE    := rm -f
CAT       := cat
SEP       := /
BUILD_DIR := $(TOP_DIR)/builds/win32
PLATFORM  := Rtools

# The executable file extension (for tools). NOTE: WE INCLUDE THE DOT HERE !!
#
E := .exe


# The directory where all library files are placed.
#
# By default, this is the same as $(OBJ_DIR); however, this can be changed
# to suit particular needs.
#
LIB_DIR := $(OBJ_DIR)


# The name of the final library file.  Note that the DOS-specific Makefile
# uses a shorter (8.3) name.
#
LIBRARY := $(PROJECT)


# The NO_OUTPUT macro is used to ignore the output of commands.
#
NO_OUTPUT = 2> /dev/null

LIBRARY := lib$(PROJECT)

# include gcc-specific definitions
include $(TOP_DIR)/builds/compiler/gcc.mk

# include linking instructions
include $(TOP_DIR)/builds/link_dos.mk


# EOF
