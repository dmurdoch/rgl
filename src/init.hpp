#ifndef RGL_INIT_H
#define RGL_INIT_H

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

#include <R.h>
#include <Rdefines.h> 
#include <Rinternals.h> 
/*
// RGL initialization
//
*/

/* library service */

EXPORT_SYMBOL SEXP rgl_init          (SEXP initValue);

#ifdef __cplusplus
}
#endif

#endif /* RGL_INIT_H */

