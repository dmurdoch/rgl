## This code is extracted from R's R.m4 file.  From that file:

### Copyright (C) 1998-2013 R Core Team
###
### This file is part of R.
###
### R is free software; you can redistribute it and/or modify it under
### the terms of the GNU General Public License as published by the Free
### Software Foundation; either version 2 of the License, or (at your
### option) any later version.
###
### R is distributed in the hope that it will be useful, but WITHOUT ANY
### WARRANTY; without even the implied warranty of MERCHANTABILITY or
### FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
### License for more details.
###
### You should have received a copy of the GNU General Public License
### along with R; if not, a copy is available at
### http://www.r-project.org/Licenses/

## R_GCC4_VISIBILITY
## Sets up suitable macros for visibility attributes in gcc4/gfortran
AC_DEFUN([R_GCC4_VISIBILITY],
[AC_CACHE_CHECK([whether __attribute__((visibility())) is supported],
                [r_cv_visibility_attribute],
[cat > conftest.c <<EOF
int foo __attribute__ ((visibility ("hidden"))) = 1;
int bar __attribute__ ((visibility ("default"))) = 1;
EOF
r_cv_visibility_attribute=no
if AC_TRY_COMMAND(${CC-cc} -Werror -S conftest.c -o conftest.s 1>&AS_MESSAGE_LOG_FD); then
 if grep '\.hidden.*foo' conftest.s >/dev/null; then
    r_cv_visibility_attribute=yes
 fi
fi
rm -f conftest.[cs]
])
if test $r_cv_visibility_attribute = yes; then
  AC_DEFINE(HAVE_VISIBILITY_ATTRIBUTE, 1,
           [Define to 1 if __attribute__((visibility())) is supported])
fi
## test if visibility flag is accepted: NB Solaris compilers do and ignore,
## so only make use of this if HAVE_VISIBILITY_ATTRIBUTE is true.
r_save_CFLAGS=$CFLAGS
CFLAGS="$CFLAGS -fvisibility=hidden"
AC_CACHE_CHECK(whether $CC accepts -fvisibility, r_cv_prog_cc_vis,
               [_AC_COMPILE_IFELSE([AC_LANG_PROGRAM()],
	       [r_cv_prog_cc_vis=yes], [r_cv_prog_cc_vis=no])])
CFLAGS=$r_save_CFLAGS
if test "${r_cv_prog_cc_vis}" = yes; then
  if test "${r_cv_visibility_attribute}" = yes; then
    C_VISIBILITY="-fvisibility=hidden"
  fi
fi
## Need to exclude Intel compilers, where this does not work.
## The flag is documented, and is effective but also hides
## unsatisfied references. We cannot test for GCC, as icc passes that test.
case  "${CC}" in
  ## Intel compiler: note that -c99 may have been appended
  *icc*)
    C_VISIBILITY=
    ;;
esac
AC_SUBST(C_VISIBILITY)
AC_LANG_PUSH(Fortran 77)
r_save_FFLAGS=$FFLAGS
FFLAGS="$FFLAGS -fvisibility=hidden"
AC_CACHE_CHECK(whether $F77 accepts -fvisibility, r_cv_prog_f77_vis,
               [_AC_COMPILE_IFELSE([AC_LANG_PROGRAM()],
               [r_cv_prog_f77_vis=yes], [r_cv_prog_f77_vis=no])])
FFLAGS=$r_save_FFLAGS
AC_LANG_POP(Fortran 77)
if test "${r_cv_prog_f77_vis}" = yes; then
  if test "${r_cv_visibility_attribute}" = yes; then
    F77_VISIBILITY="-fvisibility=hidden"
  fi
fi
## need to exclude Intel compilers.
case  "${F77}" in
  ## Intel compiler
  *ifc|*ifort)
    F77_VISIBILITY=
    ;;
esac
AC_SUBST(F77_VISIBILITY)
])# R_GCC4_VISIBILITY
