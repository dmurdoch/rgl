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

## pick up compiler as will be used by R CMD INSTALL/SHLIB
if test -n "${R_HOME}"; then
  CC=`${R_HOME}/bin/R CMD config CC`
  CFLAGS=`${R_HOME}/bin/R CMD config CFLAGS`
  CXX=`${R_HOME}/bin/R CMD config CXX`
  CXXFLAGS=`${R_HOME}/bin/R CMD config CXXFLAGS`
fi

AC_PROG_CPP
AC_PROG_CC

AC_ARG_ENABLE([carbon],
[  --disable-carbon           os x: use X11 instead of Carbon]
)

if test `uname` = "Darwin" ; then
  darwin="yes"
else
  darwin="no"
fi

## --- LibPNG ----------------------------------------------------------------

AC_ARG_ENABLE([libpng],
[  --disable-libpng           compile without PNG image support]
)
AC_ARG_ENABLE([libpng-config],
[  --disable-libpng-config    disable libpng-config test and configuration]
)
AC_ARG_ENABLE([libpng-dynamic],
[  --disable-libpng-dynamic   disable dynamic libpng linkage, force static version linkage (only with --enable-libpng-config)]
)

if test "x$enable_libpng" != "xno"; then

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
      AC_MSG_NOTICE([using libpng static linkage])
      LIBS="${LIBS} `libpng-config --static --L_opts`/libpng.a"
    fi
  else
    AC_MSG_CHECKING([libpng])
    save_LIBS="${LIBS}"
    save_CPPFLAGS="${CPPFLAGS}"
    AC_CHECK_HEADERS(png.h)
    AC_CHECK_LIB(png, png_read_update_info)
    if test "${ac_cv_header_png_h}"; then
      if test "${ac_cv_lib_png_png_read_update_info}"; then
	CPPFLAGS="${CPPFLAGS} -DHAVE_PNG_H"
	AC_MSG_NOTICE([libpng header and lib found])
	if test "x$enable_libpng_dynamic" != "xno"; then
	  AC_MSG_NOTICE([using libpng dynamic linkage])
	else
	  AC_MSG_NOTICE([using libpng static linkage])
	fi
      else
	LIBS=${save_LIBS}
	CPPFLAGS=${save_CPPFLAGS}
	AC_MSG_NOTICE([libpng header and lib not found])
      fi
    fi
  fi

fi

## --- Darwin ----------------------------------------------------------------

if test `uname` = "Darwin" -a "x$enable_carbon" != "xno" ; then
  AGLCPPFLAGS="${CPPFLAGS} -DRGL_USE_CARBON -I/System/Library/Frameworks/AGL.framework/Headers"
  AGLLIBS="${LIBS} -framework AGL"
  BUILD_AGL_TRUE=""
else
  BUILD_AGL_TRUE="#"
fi

# ---[ X11 ]------------------------------------------------------------------

  AC_PATH_X
  if test x$no_x = xyes ; then
    AC_MSG_ERROR([X11 not found but required, configure aborted.])
  fi
  if test -n "${x_includes}"; then
    CPPFLAGS="${CPPFLAGS} -I${x_includes}"
  fi
  if test -n "${x_libraries}"; then
    LIBS="${LIBS} -L${x_libraries} -lX11"
  else
    LIBS="${LIBS} -lX11"
  fi
  if test $darwin = yes; then
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

if test $darwin != yes; then
  AC_CHECK_HEADERS(GL/gl.h GL/glu.h)
  if test "x$ac_cv_header_GL_gl_h" = xno; then
    AC_ERROR([missing required header GL/gl.h])
  fi
  if test "x$ac_cv_header_GL_glu_h" = xno; then
    AC_ERROR([missing required header GL/glu.h])
  fi
fi

AC_ARG_WITH(gl-libs,
[  --with-gl-libs=DIR      specify location of OpenGL libs],
[LIBS="${LIBS} -L${withval}"]
)

AC_ARG_WITH(gl-libname,
[  --with-gl-libname=NAME  specify Library name (defaults to "GL")], 
[lGL=${withval}], [lGL=GL]
)
AC_CHECK_LIB($lGL, glEnd)
this=`eval echo '${'$as_ac_Lib'}'`
if test "x$this" != xyes; then
  AC_ERROR([missing required library ${lGL}])
fi

AC_ARG_WITH(glu-libname,
[  --with-glu-libname=NAME specify GLU Library name (defaults to "GLU")],
[lGLU=${withval}], [lGLU=GLU]
)
AC_CHECK_LIB($lGLU, gluProject)
this=`eval echo '${'$as_ac_Lib'}'`
if test "x$this" != xyes; then
  AC_ERROR([missing required library ${lGLU}])
fi

## --- FTGL ------------------------------------------------------------------

AC_ARG_ENABLE([ftgl],
[  --disable-ftgl             compile without FTGL font support]
)
if test "x$enable_ftgl" != "xno"; then
  AC_CHECK_PROG([HAVE_FREETYPE_CONFIG],[freetype-config],[yes],[no])
  if test "x$HAVE_FREETYPE_CONFIG" = "xyes"; then
    CPPFLAGS="${CPPFLAGS} -DHAVE_FREETYPE -Iext/ftgl `freetype-config --cflags`"
    LIBS="${LIBS} `freetype-config --libs`"
    AGLCPPFLAGS="${AGLCPPFLAGS} -DHAVE_FREETYPE -Iext/ftgl `freetype-config --cflags`"
    AGLLIBS="${AGLLIBS} `freetype-config --libs`"
    AC_MSG_NOTICE([using Freetype and FTGL])
  fi
else
  AC_MSG_NOTICE([compiling without FTGL support])
fi

## --- Output ----------------------------------------------------------------

AC_SUBST(CPPFLAGS)
AC_SUBST(CXXFLAGS)
AC_SUBST(LIBS)
AC_SUBST(AGLCPPFLAGS)
AC_SUBST(AGLLIBS)
AC_SUBST(BUILD_AGL_TRUE)

AC_OUTPUT(src/Makevars)

