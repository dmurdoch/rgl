#
# win32 maintainer Makefile
# This file is part of rgl
#
# Usage: copy this Makefile to a working direction where rgl's
#        source tree lives in.
#        $ make target  - builds mingw,vc and src tar-ball (default)
#        $ make upload  - uploads a v$(VERSION) directory
#	 $ make clean   - clean up previous build with this version
#
# $Id: Maintainer.mk,v 1.4 2003/11/19 19:46:49 dadler Exp $
#

SRCDIR=rgl

include $(SRCDIR)/src/build/VERSION

DESTDIR=release


TMINGW=$(DESTDIR)/win32-mingw/rgl_$(VERSION).zip
TVC=$(DESTDIR)/win32-vc/rgl_$(VERSION).zip
TSRC=$(DESTDIR)/src/rgl_$(VERSION).tar.gz

target: release 

upload:
	scp -r $(DESTDIR) dadler@wsopuppenkiste.wiso.uni-goettingen.de:~/public_html/rgl/$(VERSION)

destdir:
	mkdir -p $(DESTDIR)/win32-mingw
	mkdir -p $(DESTDIR)/win32-vc
	mkdir -p $(DESTDIR)/src

release: destdir mingw vc src

$(TMINGW):
	cd rgl ; sh ./cleanup.win ; ./setup.bat mingw
	Rcmd build --binary rgl
	mv -f rgl_$(VERSION).zip $(TMINGW)
	cd rgl ; sh cleanup.win

$(TVC):
	cd rgl ; sh .cleanup.win ; ./setup.bat vc 
	Rcmd build --binary rgl
	mv -f rgl_$(VERSION).zip $(TVC)
	cd rgl ; sh cleanup.win

$(TSRC):
	cd rgl ; sh ./cleanup.win ; ./setup.bat mingw
	Rcmd build rgl
	mv -f rgl_$(VERSION).tar.gz $(TSRC)
	cd rgl ; sh cleanup

src: $(TSRC)
vc: $(TVC)
mingw: $(TMINGW)

clean:
	rm -Rf $(DESTDIR)

