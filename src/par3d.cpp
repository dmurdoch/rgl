/* Avoid conflict with Rinternals.h */
// #undef DEBUG

#include <R.h>

#include "api.h"

/* These defines are not in the installed version of R */

#define _  
#define streql(s, t)	(!strcmp((s), (t)))

extern "C" {
#include <Rdefines.h>
#include <Rinternals.h>
EXPORT_SYMBOL SEXP par3d(SEXP args);
}
/* par3d implementation based on R's par implementation
 *
 *  Main functions:
 *	par3d(.)	
 *	Specify(.)	[ par(what = value) ]
 *	Query(.)	[ par(what) ]
 */

static void par_error(char *what)
{
    error(_("invalid value specified for rgl parameter \"%s\""),  what);
}

static void lengthCheck(char *what, SEXP v, int n)
{
    if (length(v) != n)
	error(_("parameter \"%s\" has the wrong length"), what);
}

static void dimCheck(char *what, SEXP v, int r, int c)
{
    SEXP dim = coerceVector(getAttrib(v, R_DimSymbol), INTSXP);
    if (length(dim) != 2 || INTEGER(dim)[0] != r || INTEGER(dim)[1] != c)
    	error(_("parameter \"%s\" has the wrong dimension"), what);
}

#ifdef UNUSED
static void nonnegIntCheck(int x, char *s)
{
    if (x == NA_INTEGER || x < 0)
	par_error(s);
}

static void posIntCheck(int x, char *s)
{
    if (x == NA_INTEGER || x <= 0)
	par_error(s);
}

static void naIntCheck(int x, char *s)
{
    if (x == NA_INTEGER)
	par_error(s);
}
#endif

static void posRealCheck(double x, char *s)
{
    if (!R_FINITE(x) || x <= 0)
	par_error(s);
}

#ifdef UNUSED
static void nonnegRealCheck(double x, char *s)
{
    if (!R_FINITE(x) || x < 0)
	par_error(s);
}

static void naRealCheck(double x, char *s)
{
    if (!R_FINITE(x))
	par_error(s);
}
#endif

static void BoundsCheck(double x, double a, double b, char *s)
{
/* Check if   a <= x <= b */
    if (!R_FINITE(x) || (R_FINITE(a) && x < a) || (R_FINITE(b) && x > b))
	par_error(s);
}

/* These modes must match the definitions of mmTRACKBALL etc in rglview.h ! */ 

char* mouseModes[] = {"none", "trackball", "polar", "selecting", "zoom", "fov"};

static void Specify(char *what, SEXP value)
{
 
 /* Do NOT forget to update  ../R/par3d.R */
 /* if you  ADD a NEW  par !! 

 */
    SEXP x;
    double v;
    int iv;
    int success;

    success = 0;

    if (streql(what, "FOV")) {
    	lengthCheck(what, value, 1);	v = asReal(value);
	BoundsCheck(v, 1.0, 179.0, what);
	rgl_setFOV(&success, &v);
    }
    else if (streql(what, "mouseMode")) {
    	value = coerceVector(value, STRSXP);
	if (length(value) > 3) par_error(what);   
        for (int i=1; i<=3 && i <= length(value); i++) {
            if (STRING_ELT(value, i-1) != NA_STRING) {
		success = 0;
		/* check exact first, then partial */
		for (int mode = 0; mode < 6; mode++) {
		    if (psmatch(mouseModes[mode], CHAR(STRING_ELT(value, i-1)), (Rboolean)TRUE)) {
			rgl_setMouseMode(&success, &i, &mode);
			break;
		    }
		}
		if (!success) {
		    for (int mode = 0; mode < 6; mode++) {
			if (psmatch(mouseModes[mode], CHAR(STRING_ELT(value, i-1)), (Rboolean)FALSE)) {
			    rgl_setMouseMode(&success, &i, &mode);
			    break;
			}
		    }		
		}
		if (!success) par_error(what);
	    }
   	}
    }
    else if (streql(what, "skipRedraw")) {
    	lengthCheck(what, value, 1);	iv = asLogical(value);
    	rgl_setSkipRedraw(&success, &iv);
    }
    else if (streql(what, "userMatrix")) {
	dimCheck(what, value, 4, 4);
	x = coerceVector(value, REALSXP);
	
	rgl_setUserMatrix(&success, REAL(x));
    }
    else if (streql(what, "zoom")) {
    	lengthCheck(what, value, 1);	v = asReal(value);
	posRealCheck(v, what);
	rgl_setZoom(&success, &v);
    }
    
     else warning(_("parameter \"%s\" cannot be set"), what);
 
    if (!success) par_error(what);
    
    return;
} 
 
 
 /* Do NOT forget to update  ../R/par3d.R */
 /* if you  ADD a NEW  par !! */
 
 
static SEXP Query(char *what)
{
    SEXP value, names;
    int i, mode, success;

    success = 0;
    
    if (streql(what, "FOV")) {
	value = allocVector(REALSXP, 1);
	rgl_getFOV(&success, REAL(value));
    }
    else if (streql(what, "modelMatrix")) {
	value = allocMatrix(REALSXP, 4, 4);
	rgl_getModelMatrix(&success, REAL(value));
    }
    else if (streql(what, "mouseMode")) {
    	PROTECT(value = allocVector(STRSXP, 3));
    	for (i=1; i<4; i++) {
	    rgl_getMouseMode(&success, &i, &mode); 
	    if (mode < 0 || mode > 5) mode = 0;
	    SET_STRING_ELT(value, i-1, mkChar(mouseModes[mode]));
    	};    
    	PROTECT(names = allocVector(STRSXP, 3));
    	SET_STRING_ELT(names, 0, mkChar("left"));
    	SET_STRING_ELT(names, 1, mkChar("middle"));  
    	SET_STRING_ELT(names, 2, mkChar("right"));
    	UNPROTECT(2);
    	value = namesgets(value, names);
    	success = 1;
    }
    else if (streql(what, "projMatrix")) {
	value = allocMatrix(REALSXP, 4, 4);
	rgl_getProjMatrix(&success, REAL(value));    
    }
    else if (streql(what, "skipRedraw")) {
    	value = allocVector(LGLSXP, 1);
    	rgl_getSkipRedraw(&success, LOGICAL(value));
    }
    else if (streql(what, "userMatrix")) {
	value = allocMatrix(REALSXP, 4, 4);
	rgl_getUserMatrix(&success, REAL(value));
    }
    else if (streql(what, "viewport")) {
	value = allocVector(INTSXP, 4);
	rgl_getViewport(&success, INTEGER(value));
    }
    else if (streql(what, "zoom")) {
	value = allocVector(REALSXP, 1);
	rgl_getZoom(&success, REAL(value));
    }
    else if (streql(what, "bbox")) {
      value = allocVector(REALSXP, 6);
      rgl_getBoundingbox(&success, REAL(value));
    }
    else
  	value = R_NilValue;
  	
    	
    if (! success) error(_("unknown error getting rgl parameter \"%s\""),  what);

    return value;
}
  
SEXP par3d(SEXP args)
{
    SEXP value;

    int new_spec, nargs;

    new_spec = 0;
    args = CADR(args);
    nargs = length(args);
    if (isNewList(args)) {
	SEXP oldnames, newnames, tag, val;
	int i;
	PROTECT(newnames = allocVector(STRSXP, nargs));
	PROTECT(value = allocVector(VECSXP, nargs));
	oldnames = getAttrib(args, R_NamesSymbol);
	for (i = 0 ; i < nargs ; i++) {
	    if (oldnames != R_NilValue)
		tag = STRING_ELT(oldnames, i);
	    else
		tag = R_NilValue;
	    val = VECTOR_ELT(args, i);
	    if (tag != R_NilValue && CHAR(tag)[0]) {
		new_spec = 1;
		SET_VECTOR_ELT(value, i, Query(CHAR(tag)));
		SET_STRING_ELT(newnames, i, tag);
		Specify(CHAR(tag), val);
	    }
	    else if (isString(val) && length(val) > 0) {
		tag = STRING_ELT(val, 0);
		if (tag != R_NilValue && CHAR(tag)[0]) {
		    SET_VECTOR_ELT(value, i, Query(CHAR(tag)));
		    SET_STRING_ELT(newnames, i, tag);
		}
	    }
	    else {
		SET_VECTOR_ELT(value, i, R_NilValue);
		SET_STRING_ELT(newnames, i, R_NilValue);
	    }
	}
	setAttrib(value, R_NamesSymbol, newnames);
	UNPROTECT(2);
    }
    else {
    	error(_("invalid parameter passed to par3d()"));
    	return R_NilValue/* -Wall */;
    }
    return value;
}


