#include "PrimitiveSet.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   PointSet
//

PointSet::PointSet(Material& in_material, int in_nvertices, double* in_vertices, bool in_ignoreExtent, 
                   int in_nindices, int* in_indices, bool in_bboxChange) 
  : PrimitiveSet(in_material, in_nvertices, in_vertices, GL_POINTS, 1, in_ignoreExtent, 
    in_nindices, in_indices)
{
  material.lit = false;
  if (material.point_antialias) blended = true;
} 

