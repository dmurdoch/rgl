#include "PrimitiveSet.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   LineSet
//

LineSet::LineSet(Material& in_material, int in_nvertices, double* in_vertices, bool in_ignoreExtent, 
                 int in_nindices, int* in_indices, bool in_bboxChange) 
  : PrimitiveSet(in_material, in_nvertices, in_vertices, GL_LINES, 2, in_ignoreExtent, 
    in_nindices, in_indices, in_bboxChange)
{
  material.lit = false;
  if (material.line_antialias) blended = true;
}

LineSet::LineSet(Material& in_material, bool in_ignoreExtent, bool in_bboxChange) 
  : PrimitiveSet(in_material, GL_LINES, 2, in_ignoreExtent, in_bboxChange)
{
  material.lit = false;
  if (material.line_antialias) blended = true;
}

