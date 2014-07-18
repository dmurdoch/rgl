#include "PrimitiveSet.h"

using namespace rgl;

#if 0

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   QuadSet
//

QuadSet::QuadSet(Material& in_material, int in_nelements, double* in_vertex) 
  : FaceSet<GL_QUADS,4>(in_material, in_nelements, in_vertex) 
{
  if (material.lit) {
    normalArray.alloc(nvertices);
    for (int i=0;i<nvertices-3;i+=4) {
      normalArray[i+3] = normalArray[i+2] = normalArray[i+1] = normalArray[i] = vertexArray.getNormal(i,i+1,i+2);
    }
  }
}



#endif

