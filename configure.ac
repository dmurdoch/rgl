## 
## This file is part of RGL
##
## Process this file with autoconf to produce a configure script.
##
## $Id: configure.ac,v 1.2 2003/03/25 03:50:48 dadler Exp $
##

AC_PREREQ(2.50)


## ---[ VERSION ]-------------------------------------------------------------

AC_INIT([rgl], [0.64-4], [dadler@gwdg.de])
AC_CONFIG_AUX_DIR(src/build/autoconf)

## ---[ check host ]----------------------------------------------------------

AC_CANONICAL_HOST

case "${host_os}" in
  macos*)
    echo "MacOS port not supported yet."
    exit -1
  ;;
  cygwin*|mingw*|windows*|winnt)

    echo "Windows port: use R CMD INSTALL to build (configure.win)"
    exit -1
  ;;
  *)
  ;;
esac


##
## ===[ X11 Port ]============================================================
##

PLATFORM_MODULES="x11lib x11gui"
LIBS=""


## C language

CPPFLAGS=""
CFLAGS=""


## C++ language

LIBS="-lstdc++"
CXXFLAGS="-fno-exceptions -fno-rtti"


## X11 backend

AC_PATH_X
LIBS="${LIBS} -L${x_libraries} -lX11"


## OpenGL backend

AC_ARG_WITH(gl-includes,
[  --with-gl-includes=DIR  specify location of OpenGL headers],
[CPPFLAGS="${CPPFLAGS} -I${withval}"],
)

AC_ARG_WITH(gl-libs,
[  --with-gl-libs=DIR      specify location of OpenGL libs],
[LIBS="${LIBS} -L${withval}"]
)

AC_ARG_WITH(gl-prefix,
[  --with-gl-prefix=PREFIX specify Library prefix ("GL" (default) or "MesaGL")], 
[LIBS="${LIBS} -l${withval}"], [LIBS="${LIBS} -lGL"]
)

## LibPNG support

AC_ARG_ENABLE(png,
[  --disable-png           compile without PNG image support])
AC_MSG_RESULT([$enable_png])
if test "x$enable_png" != "xno"; then
AC_CHECK_HEADERS(png.h,CPPFLAGS="${CPPFLAGS} -DHAVE_PNG_H=1"; LIBS="${LIBS} ${PNGLIB:=-lpng}")
fi

## Output

AC_SUBST(PLATFORM_MODULES)
AC_SUBST(CPPFLAGS)
AC_SUBST(CFLAGS)
AC_SUBST(CXXFLAGS)
AC_SUBST(LIBS)
    
AC_OUTPUT(
src/Makefile
src/Makevars
)
