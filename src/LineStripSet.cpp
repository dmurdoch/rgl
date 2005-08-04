#include "PrimitiveSet.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   LineStripSet
//

LineStripSet::LineStripSet(Material& in_material, int in_nvertices, double* in_vertex)
  : PrimitiveSet(in_material, in_nvertices, in_vertex, GL_LINE_STRIP, 1)
{
  material.lit = false;
}

void LineStripSet::drawElement(RenderContext* renderContext, int index)
{
  if (index < nvertices-1) 
    glDrawArrays(type, index*nverticesperelement, 2*nverticesperelement);
}  
