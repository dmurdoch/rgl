#
# win32 platform config
# GNU Make include file
#

PLATFORM_MODULES=\
win32lib	\
win32gui

PLATFORM_OBJS=$(foreach x, $(PLATFORM_MODULES), $x.o)

