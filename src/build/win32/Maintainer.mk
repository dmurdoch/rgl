# RGL Win32 BUILDER SITE
# This file is part of rgl
#
# Usage: make info 
#
# $Id: Maintainer.mk,v 1.7 2004/01/30 13:36:25 dadler Exp $
#

all: info

CVSDIR=cvs
SRCDIR=current
DESTDIR=release
ARCDIR=arc

# --- DEPENDEND SOURCE FILES --------------------------------------------------

ZLIB=zlib114
LPNG=lpng125

-include $(CVSDIR)/rgl/src/build/VERSION

# --- CVS ---------------------------------------------------------------------

checkout:
	rm -Rf $(CVSDIR)
	mkdir -p $(CVSDIR)
	cd $(CVSDIR) ; cvs checkout -P rgl

update:
	cd $(CVSDIR)/rgl ; cvs update -dP


# --- SOURCE SETUP ------------------------------------------------------------
	
gen:
	cd $(CVSDIR) ; sh rgl/src/build/setversion.sh

# --- SOURCE BUILD ------------------------------------------------------------
	
package:
	cd $(CVSDIR)/rgl ; sh ./cleanup.win ; ./setup.bat mingw
	cd $(CVSDIR) ; Rcmd build --force rgl
	mkdir -p $(DESTDIR)/src
	mv -f $(CVSDIR)/rgl_$(VERSION).tar.gz $(DESTDIR)/src


# --- BINARY BUILD ------------------------------------------------------------


download:
	mkdir -p $(ARCDIR)
	wget -nc -P $(ARCDIR) www.gzip.org/zlib/$(ZLIB).zip
	wget -nc -P $(ARCDIR) download.sourceforge.net/libpng/$(LPNG).zip

unpack:
	rm -Rf $(SRCDIR)/rgl
	mkdir -p $(SRCDIR)
	tar -xzvf $(DESTDIR)/src/rgl_$(VERSION).tar.gz -C $(SRCDIR)
	unzip $(ARCDIR)/$(ZLIB).zip -d $(SRCDIR)/rgl/src/zlib
	unzip $(ARCDIR)/$(LPNG).zip -d $(SRCDIR)/rgl/src
	mv $(SRCDIR)/rgl/src/$(LPNG) $(SRCDIR)/rgl/src/lpng

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
	@echo " checkout   - check out cvs tree"
	@echo " update     - update cvs tree dep: checkout"
	@echo " gen        - generate auto files dep: checkout/update" 
	@echo " package    - build source package dep: gen"
	@echo " download   - download aux libs (zlib and libpng)"
	@echo " unpack     - unpack source package and aux libs dep: package, download"
	@echo " mingw      - build binary package using mingw dep: unpack"
	@echo " vc         - build binary package using vc dep: unpack"  


release: clean update source unpack mingw vc upload

clean:
	rm -Rf $(DESTDIR)
	
upload:
	scp -r $(DESTDIR) dadler@wsopuppenkiste.wiso.uni-goettingen.de:~/public_html/rgl/download

destdir:
	mkdir -p $(DESTDIR)/win32-mingw
	mkdir -p $(DESTDIR)/win32-vc
	mkdir -p $(DESTDIR)/src

maintainer-clean:
	rm -Rf $(CVSDIR) $(SRCDIR) $(DESTDIR) $(ARCDIR)
