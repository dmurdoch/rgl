#include "R.h"
#include <Rinternals.h>
#include <array>
#include "api.h"
#include "earcut.h"

// The number type to use for tessellation
using Coord = double;

// The index type. Defaults to uint32_t, but you can also pass uint16_t if you know that your
// data won't have more than 65536 vertices.
using N = uint32_t;

// Create array
using Point = std::array<Coord, 2>;

SEXP rgl::rgl_earcut(SEXP x, SEXP y) {
  std::vector<std::vector<Point>> polygon = {};
  std::vector<Point> chain = {};
  
  PROTECT(x = Rf_coerceVector(x, REALSXP));
  PROTECT(y = Rf_coerceVector(y, REALSXP));
  
  int n = Rf_length(x);
  
  if (n != Rf_length(y))
    Rf_error("x and y must be the same length");
  
  std::vector<int> orig = {}; /* original index */
  for (int i = 0; i < n; i++) {
    double xi = REAL(x)[i],
           yi = REAL(y)[i];
    if (ISNAN(xi) || ISNAN(yi)) {
      if (chain.size() > 0) {
        /* Delete last point if it repeats the first one */
        if (chain.front()[0] == chain.back()[0] &&
            chain.front()[1] == chain.back()[1]) {
          chain.pop_back();
          orig.pop_back();
          Rf_warning("polygon vertices should not repeat");
        }
        polygon.push_back(chain);
        chain.clear();
      }
    } else {
      chain.push_back({xi, yi});
      orig.push_back(i);
    }
  }
  if (chain.size() > 0)
    polygon.push_back(chain);
  
  std::vector<N> indices = mapbox::earcut<N>(polygon);
  
  SEXP value;
  PROTECT(value = Rf_allocVector(INTSXP, indices.size()));
  for (int i = 0; i < indices.size(); i++)
    INTEGER(value)[i] = orig[indices[i]];
  
  UNPROTECT(3);
  return value;
}
