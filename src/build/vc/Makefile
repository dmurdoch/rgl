#
# Microsoft Visual C++ Compiler Makefile
#

all: rc release

DLLNAME=rgl

include build/win32/res.mk

rc: $(DLLNAME)_res.rc

release:
	cmd /C msdev build\\vc\\rgl\\rgl.dsw /MAKE "rgl - Win32 Release" 

debug:
	cmd /C msdev build\\vc\\rgl\\rgl.dsw /MAKE "rgl - Win32 Debug"
	
clean:
	rm -Rf \
$(DLLNAME).dll \
$(DLLNAME)_res.* \
build/vc/rgl/Release \
build/vc/rgl/Debug \
build/vc/rgl/zlib/Release \
build/vc/rgl/zlib/Debug \
build/vc/rgl/libpng/Release \
build/vc/rgl/libpng/Debug \
build/vc/rgl/rgl.ncb \
build/vc/rgl/rgl.opt \
build/vc/rgl/zlib/zlib.plg

