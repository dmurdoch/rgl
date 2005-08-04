#include "RenderContext.hpp"

#include <map>

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   RenderContext
//

float RenderContext::getDistance(const Vertex& v)
{
  Vertex4 vec = Vertex4(v, 1.0f);

  return (Zrow*vec) / (Wrow*vec);
}
