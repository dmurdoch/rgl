GLSDKDIR = ..\..

INCS = -I$(GLSDKDIR)
INCS = $(INCS) -I..         # add demogl directory

LIBS = GDI32.lib User32.lib OpenGL32.lib GLU32.lib

!if ("$(BLDENV)" == "")
CFLAGS  = -c
LNFLAGS =
!else
CFLAGS  = -c -Od -Zi 
LNFLAGS = -debug -debugtype:cv -pdbtype:con
!endif

#*********************************************************************
# Since this is a multi-thread/multi-device application, we define
# our own proctable.

CFLAGS = $(CFLAGS) -D_APP_PROCTABLE

#*********************************************************************

demo: demo.obj demogl.obj glprocs.obj
    link demo.obj demogl.obj glprocs.obj $(LIBS) $(LNFLAGS)

demo.obj: demo.c ..\demogl.h
    cl $(CFLAGS) $(INCS) demo.c

demogl.obj: ..\demogl.c ..\demogl.h
    cl $(CFLAGS) $(INCS) ..\demogl.c

glprocs.obj: $(GLSDKDIR)\GL\glprocs.c
    cl $(CFLAGS) $(INCS) $(GLSDKDIR)\GL\glprocs.c

clean: 
    @erase demo.obj glprocs.obj demogl.obj demo.exe *.pdb *.ilk > nul
