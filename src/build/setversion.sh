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
# $Id: setversion.sh,v 1.1 2003/05/27 13:02:14 dadler Exp $
#

# ---[ SET VERSION ]----------------------------------------------------------

. rgl/src/build/VERSION

# ---[ MAINTAINER CONFIG ]----------------------------------------------------

TOPDIR=rgl
# path to top-level of package source tree

# ----------------------------------------------------------------------------

DATE=`date +%Y-%m-%d`
# date today

# ----------------------------------------------------------------------------

echo VERSION = $VERSION
echo DATA    = $DATE


echo create DESCRIPTION

sed -e s/@VERSION@/$VERSION/ -e s/@DATE@/$DATE/ >$TOPDIR/DESCRIPTION $TOPDIR/src/build/DESCRIPTION.in


echo create configure.ac 

sed -e s/@VERSION@/$VERSION/ >$TOPDIR/configure.ac $TOPDIR/src/build/autoconf/configure.ac.in
cd $TOPDIR

echo create configure

autoconf

echo cleanup

./cleanup

