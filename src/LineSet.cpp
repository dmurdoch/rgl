#include "PrimitiveSet.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   LineSet
//

LineSet::LineSet(Material& in_material, int in_nvertices, double* in_vertices) 
  : PrimitiveSet(in_material, in_nvertices, in_vertices, GL_LINES, 2)
{
  material.lit = false;
}
