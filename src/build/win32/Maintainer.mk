#
# win32 maintainer Makefile
# This file is part of rgl
#
# Usage: copy this Makefile to a working direction where rgl's
#        source tree lives in.
#        $ make target - builds mingw,vc and src tar-ball
#        $ make upload - uploads a v$(VERSION) directory
#
# $Id: Maintainer.mk,v 1.1 2003/03/25 03:26:06 dadler Exp $
#

VERSION=0.64-4
TMINGW=rgl_$(VERSION)_R_win32_mingw.zip
TVC=rgl_$(VERSION)_R_win32_vc.zip
TSRC=rgl_$(VERSION).tar.gz

target: release

release: mingw vc src

upload:
	mkdir v$(VERSION)
	cp rgl_$(VERSION)* v$(VERSION)
	scp -r v$(VERSION) dadler@wsopuppenkiste.wiso.uni-goettingen.de:~/public_html/rgl

	
$(TMINGW):
	cd rgl ; ./setup.bat mingw
	rcmd build --binary rgl
	mv rgl_$(VERSION).zip $(TMINGW)
	cd rgl ; sh cleanup.win

$(TVC):
	cd rgl ; ./setup.bat vc
	rcmd build --binary rgl
	mv rgl_$(VERSION).zip $(TVC)
	cd rgl ; sh cleanup.win

$(TSRC):
	rcmd build rgl

src: $(TSRC)
vc: $(TVC)
mingw: $(TMINGW)

clean:
	cd rgl ; sh cleanup ; sh cleanup.win

dist-clean:
	rm -f rgl_$(VERSION)*

