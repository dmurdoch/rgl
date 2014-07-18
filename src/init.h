#ifndef RGL_INIT_H
#define RGL_INIT_H

#include "R.h"
#include <Rdefines.h> 
#include <Rinternals.h> 

namespace rgl {

#ifdef __cplusplus
extern "C" {
#endif

/*
// RGL initialization
//
*/

/* library service */

SEXP rgl_init          (SEXP initValue, SEXP onlyNULL, SEXP in_namespace);

#ifdef __cplusplus
}
#endif

} // namespace rgl

#endif /* RGL_INIT_H */

