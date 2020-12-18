## 
## This file is part of RGL
##
## Process configure.ac with autoconf to produce a configure script.
## NB:  the files in src/build/autoconf may need updating for a new
##      version of autoconf
##
##
##

AC_PREREQ(2.50)

## ---[ VERSION ]-------------------------------------------------------------

AC_INIT()
AC_CONFIG_AUX_DIR(src/build/autoconf)

## pick up compiler as will be used by R CMD INSTALL/SHLIB
if test -n "${R_HOME}"; then
  CC=`${R_HOME}/bin/R CMD config CC`
  CFLAGS=`${R_HOME}/bin/R CMD config CFLAGS`
fi

AC_PROG_CPP
AC_PROG_CC

if test `uname` = "Darwin" ; then
  darwin="yes"
  ## we want the *build* cputype and not the host one.
  cmd=`echo $CC $CFLAGS | grep -E 'x86_64|ppc64|-m64'`
  if test -n "$cmd"; then
    have_64bit="yes"
  else
    have_64bit="no"
  fi 
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
	LIBS="${LIBS} -lpng"
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

# ---[ OpenGL enabled?]---------------------------------------------------------------

AC_ARG_ENABLE([opengl],
[  --disable-opengl           compile without OpenGL support]
)

# ---[ X11 ]------------------------------------------------------------------

if test "x$enable_opengl" = "xno"; then
  saveCPPFLAGS="${CPPFLAGS}"
  saveLIBS="${LIBS}"
else
  AC_PATH_X
  if test x$no_x = xyes ; then
    AC_MSG_WARN([X11 not found, continuing without OpenGL support.])
    enable_opengl=no
  else
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
        # OSX 10.5 messes up X11; this works around it
        LIBS="-framework OpenGL -dylib_file /System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib:/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib ${LIBS}"
      fi
      if test -e /System/Library/Frameworks/GLKit.framework ; then
        LIBS="-framework GLKit ${LIBS}"
      fi    
      # some X11 installations on OSX 10.5 feature -rpath which doesn't work when used in
      # conjunction with 10.4u SDK (and is redundant anyway since OS X always uses full paths)
      if test rpath`echo "${LIBS}" | sed -n 's/.*-Wl,-rpath,.*/Yes/p' 2>/dev/null` = rpathYes; then
        LIBS=`echo "${LIBS}" | sed 's:-Wl,-rpath,[[^ ]]*::'`
      fi
      # X11 must come *after* the OpenGL stuff
      CPPFLAGS="${CPPFLAGS} -I/opt/X11/include"
    fi
  fi
fi

if test "x$enable_opengl" != "xno"; then
  ## --- OpenGL ----------------------------------------------------------------

  AC_ARG_WITH(gl-includes,
  [  --with-gl-includes=DIR  specify location of OpenGL headers],
  [CPPFLAGS="${CPPFLAGS} -I${withval}"]
  )

  if test $darwin != yes; then
    AC_CHECK_HEADERS(GL/gl.h GL/glu.h)
    if test "x$ac_cv_header_GL_gl_h" = xno; then
      AC_WARN([missing required header GL/gl.h, continuing without OpenGL])
      enable_opengl=no
    fi
    if test "x$ac_cv_header_GL_glu_h" = xno; then
      AC_WARN([missing required header GL/glu.h, continuing without OpenGL])
      enable_opengl=no
    fi
  fi
fi

if test "x$enable_opengl" != "xno"; then
  AC_ARG_WITH(gl-libs,
  [  --with-gl-libs=DIR      specify location of OpenGL libs],
  [LDFLAGS="${LDFLAGS} -L${withval}"
  L_LIB="-L${withval}"]
  )

  AC_ARG_WITH(gl-libname,
  [  --with-gl-libname=NAME  specify Library name (defaults to "GL")], 
  [lGL=${withval}], [lGL=GL]
  )
  AC_CHECK_LIB($lGL, glEnd)
  this=`eval echo '${'$as_ac_Lib'}'`
  if test "x$this" != xyes; then
    AC_WARN([missing required library ${lGL}, continuing without OpenGL])
    enable_opengl=no
  fi
fi

if test "x$enable_opengl" != "xno"; then
  AC_ARG_WITH(glu-libname,
  [  --with-glu-libname=NAME specify GLU Library name (defaults to "GLU")],
  [lGLU=${withval}], [lGLU=GLU]
  )
  AC_CHECK_LIB($lGLU, gluProject)
  this=`eval echo '${'$as_ac_Lib'}'`
  if test "x$this" != xyes; then
    AC_WARN([missing required library ${lGLU}, continuing without OpenGL])
    enable_opengl=no
  fi
fi

if test "x$enable_opengl" != "xno"; then
  if test x$L_LIB != x; then
    LIBS="${L_LIB} ${LIBS}"
  fi

  ## --- FTGL ------------------------------------------------------------------

  AC_ARG_ENABLE([ftgl],
  [  --disable-ftgl             compile without FTGL font support]
  )
  if test "x$enable_ftgl" != "xno"; then
    if test "x$darwin" = "xyes"; then
      AC_MSG_NOTICE([Darwin, so ensuring /opt/X11/bin is at the head of the PATH...])
      PATH=/opt/X11/bin:${PATH}
    fi
    ## new pkg-config bit
    AC_CHECK_PROG([HAVE_PKG_CONFIG],[pkg-config],[yes],[no])
    if test "x$HAVE_PKG_CONFIG" = "xyes" -a "x`pkg-config freetype2 --cflags`" != "x"; then
      CPPFLAGS="${CPPFLAGS} -DHAVE_FREETYPE -Iext/ftgl `pkg-config freetype2 --cflags`"
      LIBS="${LIBS} `pkg-config freetype2 --libs`"
      AC_MSG_NOTICE([using Freetype and FTGL])
    else
      AC_CHECK_PROG([HAVE_FREETYPE_CONFIG],[freetype-config],[yes],[no])
      if test "x$HAVE_FREETYPE_CONFIG" = "xyes"; then
        CPPFLAGS="${CPPFLAGS} -DHAVE_FREETYPE -Iext/ftgl `freetype-config --cflags`"
        LIBS="${LIBS} `freetype-config --libs`"
        AC_MSG_NOTICE([using Freetype and FTGL])
      else
        AC_MSG_NOTICE([compiling without FTGL support])
      fi
    fi
  else
    AC_MSG_NOTICE([compiling without FTGL support])
  fi
fi

if test "x$enable_opengl" = "xno"; then
  RGL_NO_OPENGL=TRUE
  CPPFLAGS="${saveCPPFLAGS} -DRGL_NO_OPENGL"
  LIBS="${saveLIBS}"
else
  RGL_NO_OPENGL=FALSE
fi

## --- Output ----------------------------------------------------------------

AC_SUBST(CPPFLAGS)
AC_SUBST(LIBS)
AC_SUBST(RGL_NO_OPENGL)
AC_CONFIG_FILES([R/noOpenGL.R])

AC_OUTPUT(src/Makevars)

