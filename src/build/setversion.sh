#!/bin/sh
#
# setversion.sh shell script
# This file is part of RGL.
#
# invoke:
#	1. change to directory containing "rgl" package source directory
#	2. call shell script
#		(un*x/cygwin) 
#			$ rgl/src/build/setversion.sh
#		(win32 dos/mingw:)  
#			$ sh rgl/src/build/setversion.sh
#
# $Id$
#

# ---[ SET VERSION ]----------------------------------------------------------

. src/build/VERSION

MODS=`make -s -f src/build/project.mk dump-mods`
X11_MODS=`make -s -f src/build/x11.mk dump-x11-mods`

OBJS=
for i in $X11_MODS ; do 
  OBJS="$OBJS $i.o"
done
for i in $MODS ; do 
  OBJS="$OBJS $i.o"
done

# ---[ MAINTAINER CONFIG ]----------------------------------------------------

# date today
DATE=`date +%Y-%m-%d`

# ----------------------------------------------------------------------------

echo VERSION = $VERSION
echo DATE    = $DATE

echo create src/Makevars.in
sed -e s/@RGL_OBJS@/"${OBJS}"/ >src/Makevars.in src/build/Makevars.in.in 

echo create DESCRIPTION
sed -e s/@VERSION@/$VERSION/ -e s/@DATE@/$DATE/ >DESCRIPTION src/build/DESCRIPTION.in

echo create configure.ac 
sed -e s/@VERSION@/$VERSION/ >configure.ac src/build/autoconf/configure.ac.in

echo run autoconf
autoconf

echo cleanup
sh ./cleanup

