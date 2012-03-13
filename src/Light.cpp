#include "Light.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Light
//

Light::Light( PolarCoord in_position, bool in_viewpoint, Color in_ambient, Color in_diffuse, Color in_specular )
: SceneNode(LIGHT), 
  ambient(in_ambient),
  diffuse(in_diffuse),
  specular(in_specular),
  id(GL_FALSE),
  viewpoint(in_viewpoint)
{
  Vertex v(0.0f, 0.0f, 1.0f);

  v.rotateX( -in_position.phi );
  v.rotateY(  in_position.theta );

  position[0] = v.x;
  position[1] = v.y;
  position[2] = v.z;

  position[3] = 0.0f;
}

void Light::setup(RenderContext* renderContext) 
{
  glLightfv(id, GL_AMBIENT,   ambient.data  );
  glLightfv(id, GL_DIFFUSE,   diffuse.data  );
  glLightfv(id, GL_SPECULAR,  specular.data );
  glLightfv(id, GL_POSITION,  position );

  glLightf(id, GL_SPOT_EXPONENT, 0.0f);
  glLightf(id, GL_SPOT_CUTOFF, 180.0f);

  glLightf(id, GL_CONSTANT_ATTENUATION, 1.0f);
  glLightf(id, GL_LINEAR_ATTENUATION, 0.0f);
  glLightf(id, GL_QUADRATIC_ATTENUATION, 0.0f);


  glEnable(id);
}

int Light::getAttributeCount(AABox& bbox, AttribID attrib)
{
  switch (attrib) {
    case COLORS: return 3;
    case VERTICES: return 1;
  }  
  
  return 0;
}

void Light::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);
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
        *result++ = position[3];
        return;
      }
    }
  }
}
