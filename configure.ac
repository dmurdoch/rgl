## 
## This file is part of RGL
##
## Process this file with autoconf to produce a configure script.
##
##
## $Id$
##

AC_PREREQ(2.50)

## ---[ VERSION ]-------------------------------------------------------------

AC_INIT()
AC_CONFIG_AUX_DIR(src/build/autoconf)
AC_ARG_ENABLE([carbon],
[  --disable-carbon           os x: use X11 instead of Carbon]
)

if test `uname` = "Darwin" -a "x$enable_carbon" != "xno" ; then
  AGLCPPFLAGS="${CPPFLAGS} -DRGL_USE_CARBON -I/System/Library/Frameworks/AGL.framework/Headers"
  AGLLIBS="${LIBS} -framework AGL"
  BUILD_AGL_TRUE=""
else
  BUILD_AGL_TRUE="#"
fi

  AC_PATH_X
  if test x$no_x = xyes ; then
    AC_MSG_ERROR([X11 not found but required, configure aborted.])
  fi
  if test "x${x_includes}" != "x" ; then 
    CPPFLAGS="${CPPFLAGS} -I${x_includes}"; 
  fi
  LIBS="${LIBS} -L${x_libraries} -lX11"
  if test `uname` = "Darwin" ; then
    CPPFLAGS="${CPPFLAGS} -DDarwin"
    # Apple's OpenGL is different from the X11 one - it must be loaded *before* X11
    if test -e /System/Library/Frameworks/OpenGL.framework ; then
      CPPFLAGS="-I/System/Library/Frameworks/OpenGL.framework/Headers ${CPPFLAGS} -DNO_GL_PREFIX"
      LIBS="-framework OpenGL ${LIBS}"
    fi
    # X11 must come *after* the OpenGL stuff
    CPPFLAGS="${CPPFLAGS} -I/usr/X11R6/include"
  fi

## --- OpenGL ----------------------------------------------------------------

AC_ARG_WITH(gl-includes,
[  --with-gl-includes=DIR  specify location of OpenGL headers],
[CPPFLAGS="${CPPFLAGS} -I${withval}"]
)

AC_ARG_WITH(gl-libs,
[  --with-gl-libs=DIR      specify location of OpenGL libs],
[LIBS="${LIBS} -L${withval}"]
)

AC_ARG_WITH(gl-libname,
[  --with-gl-libname=NAME specify Library name (defaults to "GL")], 
[LIBS="${LIBS} -l${withval}"], [LIBS="${LIBS} -lGL"]
)

AC_ARG_WITH(glu-libname,
[  --with-glu-libname=NAME specify GLU Library name (defaults to "GLU")],
[LIBS="${LIBS} -l${withval}"], [LIBS="${LIBS} -lGLU"]
)

## --- LibPNG ----------------------------------------------------------------

AC_ARG_ENABLE([libpng],
[  --disable-libpng           compile without PNG image support]
)
AC_ARG_WITH(libpng-prefix,
[  --with-libpng-prefix=PREFIX specify libpng prefix],
[libpng_prefix="${withval}"]
)
AC_ARG_ENABLE([libpng-config],
[  --disable-libpng-config    disable libpng-config test and configuration]
)
AC_ARG_ENABLE([libpng-dynamic],
[  --disable-libpng-dynamic   disable dynamic libpng linkage, force static version linkage]
)

if test "x$enable_libpng" != "xno"; then

  if test "x$libpng_prefix" = "x"; then
    if test "x$enable_libpng_config" != "xno"; then
      AC_CHECK_PROG([HAVE_LIBPNG_CONFIG],[libpng-config],[yes],[no])
    fi

    if test "x$HAVE_LIBPNG_CONFIG" = "xyes" ; then
      AC_MSG_NOTICE([using libpng-config])
      CPPFLAGS="${CPPFLAGS} -DHAVE_PNG_H `libpng-config --I_opts`"
      if test "x$enable_libpng_dynamic" != "xno"; then
        AC_MSG_NOTICE([using libpng dynamic linkage])
        LIBS="${LIBS} `libpng-config --ldflags`"
      else
        libpng_prefix="`libpng-config --prefix`"
      fi
    else
      TEST_DIRS="/usr/local /usr"
      ## FIXME: Linux 64bit systems mainly use lib64
      ## and Solaris ones use lib/sparcv9
      ## This should use proper autoconf tests.
      for I in $TEST_DIRS ; do
        AC_MSG_CHECKING([libpng in $I])
        if ( test -f $I/lib/libpng.so || test -f $I/lib/libpng.a ) && 
           ( test -f $I/include/png.h ) ; then
          AC_MSG_RESULT([found])
          CPPFLAGS="${CPPFLAGS} -DHAVE_PNG_H -I${I}/include"
          libpng_prefix="${I}"
          break
        else
          AC_MSG_RESULT([not found])
        fi
      done
    fi
  fi

  if test "x$libpng_prefix" != "x"; then
    if test "x$enable_libpng_dynamic" != "xno"; then
      AC_MSG_NOTICE([using libpng dynamic linkage])
      LIBS="${LIBS} -L${libpng_prefix}/lib -lpng"
    else
      AC_MSG_NOTICE([using libpng static linkage])
      LIBS="${LIBS} ${libpng_prefix}/lib/libpng.a"
    fi
  fi

fi

## --- Darwin ----------------------------------------------------------------

## --- Output ----------------------------------------------------------------

AC_SUBST(CPPFLAGS)
AC_SUBST(CFLAGS)
AC_SUBST(CXXFLAGS)
AC_SUBST(LIBS)
AC_SUBST(AGLCPPFLAGS)
AC_SUBST(AGLLIBS)
AC_SUBST(BUILD_AGL_TRUE)

AC_OUTPUT(src/Makevars)

