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
# $Id: Maintainer.mk,v 1.3 2003/05/27 13:02:14 dadler Exp $
#

SRCDIR=rgl

include $(SRCDIR)/src/build/VERSION

DESTDIR=release/$(VERSION)


TMINGW=$(DESTDIR)/rgl_$(VERSION)_R_win32_mingw.zip
TVC=$(DESTDIR)/rgl_$(VERSION)_R_win32_vc.zip
TSRC=$(DESTDIR)/rgl_$(VERSION).tar.gz

target: release 

upload:
	scp -r $(DESTDIR) dadler@wsopuppenkiste.wiso.uni-goettingen.de:~/public_html/rgl/$(VERSION)

destdir:
	mkdir -p $(DESTDIR)

release: destdir mingw vc src

$(TMINGW):
	cd rgl ; ./setup.bat mingw
	rcmd build --binary rgl
	mv -f rgl_$(VERSION).zip $(TMINGW)
	cd rgl ; sh cleanup.win

$(TVC):
	cd rgl ; ./setup.bat vc
	rcmd build --binary rgl
	mv -f rgl_$(VERSION).zip $(TVC)
	cd rgl ; sh cleanup.win

$(TSRC):
	rcmd build rgl
	mv -f rgl_$(VERSION).tar.gz $(TSRC)
	cd rgl ; sh cleanup

src: $(TSRC)
vc: $(TVC)
mingw: $(TMINGW)

clean:
	rm -Rf $(DESTDIR)

