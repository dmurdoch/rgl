OS=$(shell uname)
ifeq ($(OS),Darwin)
SRCNAME=librgl.dylib
else
SRCNAME=librgl.so
endif

rgl.so: ../build/install/$(SRCNAME)
	cp $< $@

../build/install/$(SRCNAME):
	cd .. ; bjam install

clean:
	cd .. ; bjam clean

