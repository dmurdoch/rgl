#include "PrimitiveSet.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   PointSet
//

PointSet::PointSet(Material& in_material, int in_nvertices, double* in_vertices) 
  : PrimitiveSet(in_material, in_nvertices, in_vertices, GL_POINTS, 1)
{
  material.lit = false;
} 


