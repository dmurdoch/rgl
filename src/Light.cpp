#include "R.h"
#include "Light.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Light
//

Light::Light( PolarCoord in_position, Vertex in_finposition, 
              bool in_viewpoint, bool in_posisfinite, 
              Color in_ambient, Color in_diffuse, Color in_specular )
: SceneNode(LIGHT), 
  finposition(in_finposition),  
  ambient(in_ambient),
  diffuse(in_diffuse),
  specular(in_specular),
  id(GL_FALSE),
  viewpoint(in_viewpoint),
  posisfinite(in_posisfinite)
{
  if (posisfinite) {
    position[0] = finposition.x;
    position[1] = finposition.y;
    position[2] = finposition.z;

    position[3] = 1.0f;
  } else {
      Vertex v(0.0f, 0.0f, 1.0f);
    
    v.rotateX( -in_position.phi );
    v.rotateY(  in_position.theta );
    
    position[0] = v.x;
    position[1] = v.y;
    position[2] = v.z;
    
    position[3] = 0.0f;
  }
}

int Light::getAttributeCount(SceneNode* subscene, AttribID attrib)
{
  switch (attrib) {
    case COLORS: return 3;
    case VERTICES: return 1;
    case FLAGS: return 2;
  }  
  
  return 0;
}

void Light::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    switch (attrib) {
      case COLORS: {
        while (first < n) {
          Color color;
          switch(first) {
          case 0: color = ambient; break;
          case 1: color = diffuse; break;
          case 2: color = specular;break;
          }
          *result++ = color.data[0];
          *result++ = color.data[1];
          *result++ = color.data[2];
          *result++ = color.data[3];
          first++;
        }
        return;
      }
      case VERTICES: {
        *result++ = position[0];
        *result++ = position[1];
        *result++ = position[2];
        return;
      }
      case FLAGS: {
	if (first == 0)  
          *result++ = (double) viewpoint;
        *result++ = (double) posisfinite;
        return;
      }
    }
  }
}
