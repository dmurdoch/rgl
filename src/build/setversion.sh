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
# $Id: setversion.sh,v 1.4 2003/11/19 22:51:55 dadler Exp $
#

TOPDIR=rgl

# ---[ SET VERSION ]----------------------------------------------------------

. rgl/src/build/VERSION

MODS=`make -s -f rgl/src/build/project.mk dump-mods`
X11_MODS=`make -s -f rgl/src/build/x11.mk dump-x11-mods`

OBJS=
for i in $X11_MODS ; do 
  OBJS="$OBJS $i.o"
done
for i in $MODS ; do 
  OBJS="$OBJS $i.o"
done

# ---[ MAINTAINER CONFIG ]----------------------------------------------------

# path to top-level of package source tree

# ----------------------------------------------------------------------------

DATE=`date +%Y-%m-%d`
# date today

# ----------------------------------------------------------------------------

echo VERSION = $VERSION
echo DATE    = $DATE

echo create src/Makevars.in

sed -e s/@RGL_OBJS@/"${OBJS}"/ >$TOPDIR/src/Makevars.in $TOPDIR/src/build/Makevars.in.in 

echo create DESCRIPTION

sed -e s/@VERSION@/$VERSION/ -e s/@DATE@/$DATE/ >$TOPDIR/DESCRIPTION $TOPDIR/src/build/DESCRIPTION.in


echo create configure.ac 

sed -e s/@VERSION@/$VERSION/ >$TOPDIR/configure.ac $TOPDIR/src/build/autoconf/configure.ac.in
cd $TOPDIR

echo run autoconf

autoconf

echo cleanup

./cleanup

