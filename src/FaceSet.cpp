#include "PrimitiveSet.hpp"

#if 0
//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   FaceSet
//


template<int T, int N>
void FaceSet<T,N>::draw(RenderContext* renderContext) {
  if (material.lit)
    normalArray.beginUse();

  PrimitiveSet<T,N>::draw(renderContext);

  if (material.lit)
    normalArray.endUse();
}



#endif 
