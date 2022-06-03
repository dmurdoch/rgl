#include "PrimitiveSet.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   LineStripSet
//

LineStripSet::LineStripSet(Material& in_material, int in_nvertices, double* in_vertex, bool in_ignoreExtent, 
                           int in_nindices, int* in_indices, bool in_bboxChange)
  : PrimitiveSet(in_material, in_nvertices, in_vertex, GL_LINE_STRIP, 1, in_ignoreExtent, 
    in_nindices, in_indices, in_bboxChange)
{
  material.lit = false;
  if (material.line_antialias) blended = true;
}

void LineStripSet::drawPrimitive(RenderContext* renderContext, int index)
{
#ifndef RGL_NO_OPENGL
  if (index < nvertices-1) {
    if (hasmissing) {
      int elt0 = index, elt1 = index + 1;
      if (nindices) {
        elt0 = indices[elt0];
        elt1 = indices[elt1];
      }
      if (vertexArray[elt0].missing() ||
          vertexArray[elt1].missing()) return;
    }
    if (nindices)
      glDrawElements(type, 2, GL_UNSIGNED_INT, indices + index);
    else
      glDrawArrays(type, index, 2);
  }
#endif
}  
