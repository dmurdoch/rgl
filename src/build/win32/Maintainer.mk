# RGL Win32 BUILDER SITE
# This file is part of rgl
#
# Usage: copy this Makefile to a working direction where rgl's
#        source tree lives in.
#        $ make target  - builds mingw,vc and src tar-ball (default)
#        $ make upload  - uploads a v$(VERSION) directory
#	 $ make clean   - clean up previous build with this version
#
# $Id: Maintainer.mk,v 1.5 2003/11/19 22:57:10 dadler Exp $
#

all: info

CVSDIR=cvs
SRCDIR=current
DESTDIR=release

-include $(CVSDIR)/rgl/src/build/VERSION

# --- CVS ---------------------------------------------------------------------

checkout:
	rm -Rf $(CVSDIR)
	mkdir -p $(CVSDIR)
	cd $(CVSDIR) ; cvs checkout rgl

update:
	cd $(CVSDIR)/rgl ; cvs update

# --- SOURCE SETUP ------------------------------------------------------------
	
version:
	cd $(CVSDIR) ; sh rgl/src/build/setversion.sh

# --- SOURCE BUILD ------------------------------------------------------------
	
source:
	cd $(CVSDIR)/rgl ; sh ./cleanup.win ; ./setup.bat mingw
	cd $(CVSDIR) ; Rcmd build --force rgl
	mkdir -p $(DESTDIR)/src
	mv -f $(CVSDIR)/rgl_$(VERSION).tar.gz $(DESTDIR)/src

# --- BINARY BUILD ------------------------------------------------------------

unpack:
	rm -Rf $(SRCDIR)/rgl
	mkdir -p $(SRCDIR)
	tar -xzvf $(DESTDIR)/src/rgl_$(VERSION).tar.gz -C $(SRCDIR)

mingw:
	cd $(SRCDIR)/rgl ; sh ./cleanup.win ; ./setup.bat mingw
	cd $(SRCDIR) ; Rcmd build --binary rgl
	mkdir -p $(DESTDIR)/win32-mingw
	mv -f $(SRCDIR)/rgl_$(VERSION).zip $(DESTDIR)/win32-mingw
	cd $(SRCDIR)/rgl ; sh ./cleanup.win

vc:
	cd $(SRCDIR)/rgl ; sh ./cleanup.win ; ./setup.bat vc
	cd $(SRCDIR) ; Rcmd build --binary rgl
	mkdir -p $(DESTDIR)/win32-vc
	mv -f $(SRCDIR)/rgl_$(VERSION).zip $(DESTDIR)/win32-vc
	cd $(SRCDIR)/rgl ; sh ./cleanup.win
	

info:
	@echo "Win32 RGL BUILDER SITE"

release: clean update source unpack mingw vc upload

clean:
	rm -Rf $(DESTDIR)
	
upload:
	scp -r $(DESTDIR) dadler@wsopuppenkiste.wiso.uni-goettingen.de:~/public_html/rgl/download

destdir:
	mkdir -p $(DESTDIR)/win32-mingw
	mkdir -p $(DESTDIR)/win32-vc
	mkdir -p $(DESTDIR)/src

