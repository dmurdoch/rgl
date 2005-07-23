#!/bin/sh
#
# shell script
# win32 download and unpack script to prepare the source
# with zlib and lpng.
# This file is part of rgl.
#
# $Id$
# 

ZLIB=zlib121
LPNG=lpng125

wget download.sourceforge.net/libpng/$ZLIB.zip
unzip $ZLIB.zip -d rgl/src/zlib 
wget download.sourceforge.net/libpng/$LPNG.zip
unzip $LPNG.zip
mv $LPNG rgl/src/lpng
rm -f $ZLIB.zip $LPNG.zip

