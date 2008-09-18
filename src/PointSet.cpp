#include "PrimitiveSet.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   PointSet
//

PointSet::PointSet(Material& in_material, int in_nvertices, double* in_vertices, int in_ignoreExtent) 
  : PrimitiveSet(in_material, in_nvertices, in_vertices, GL_POINTS, 1, in_ignoreExtent)
{
  material.lit = false;
  if (material.point_antialias) blended = true;
} 


