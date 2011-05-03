#include "PrimitiveSet.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   PointSet
//

PointSet::PointSet(Material& in_material, int in_nvertices, double* in_vertices, bool in_ignoreExtent, bool in_bboxChange) 
  : PrimitiveSet(in_material, in_nvertices, in_vertices, GL_POINTS, 1, in_ignoreExtent)
{
  material.lit = false;
  if (material.point_antialias) blended = true;
} 

