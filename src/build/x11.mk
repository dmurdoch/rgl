#
# win32 platform config
# GNU Make include file
#

PLATFORM_MODULES=\
x11lib	\
x11gui

PLATFORM_OBJS=$(foreach x, $(PLATFORM_MODULES), $x.o)

