#ifndef RGL_INIT_H
#define RGL_INIT_H

#include "R.h"
#include <Rdefines.h> 
#include <Rinternals.h> 

#ifdef __cplusplus
extern "C" {
#endif

/*
// RGL API EXPORT MACRO
*/

#ifdef _WIN32
#define EXPORT_SYMBOL   __declspec(dllexport)
#else
#define EXPORT_SYMBOL   extern
#endif

/*
// RGL initialization
//
*/

/* library service */

EXPORT_SYMBOL SEXP rgl_init          (SEXP initValue, SEXP onlyNULL, SEXP in_namespace);

#ifdef __cplusplus
}
#endif

#endif /* RGL_INIT_H */

