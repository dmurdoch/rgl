#ifndef RGL_INIT_H
#define RGL_INIT_H

#include <string>
#include "R.h"
#include <Rdefines.h> 
#include <Rinternals.h> 

namespace rgl {

extern std::string rglHome;

#ifdef __cplusplus
extern "C" {
#endif

/*
// RGL initialization
//
*/

/* library service */

SEXP rgl_init (SEXP initValue, SEXP onlyNULL, SEXP in_namespace, 
               SEXP debug, SEXP home);

#ifdef __cplusplus
}
#endif

} // namespace rgl

#endif /* RGL_INIT_H */

