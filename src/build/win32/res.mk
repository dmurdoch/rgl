#
# make R generated DLL Resource file
#

ifndef R_HOME
	R_HOME=C:/Programme/R/rw1080
endif

ifndef R_CMD
	R_CMD=$(R_HOME)/bin/Rcmd.exe
endif

RESFLAGS=--include-dir=$(R_HOME)/src/include

MAKE.RDLLRC=$(R_CMD) ../src/gnuwin32/makeDllRes.pl $(DLLNAME) >$@

$(DLLNAME)_res.rc: ../DESCRIPTION $(R_HOME)/src/include/Rversion.h
	$(MAKE.RDLLRC)

