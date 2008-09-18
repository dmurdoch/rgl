#include "PrimitiveSet.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   LineSet
//

LineSet::LineSet(Material& in_material, int in_nvertices, double* in_vertices, int in_ignoreExtent) 
  : PrimitiveSet(in_material, in_nvertices, in_vertices, GL_LINES, 2, in_ignoreExtent)
{
  material.lit = false;
  if (material.line_antialias) blended = true;
}
