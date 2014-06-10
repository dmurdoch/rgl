#ifndef LIGHT_HPP
#define LIGHT_HPP

#include "SceneNode.hpp"

#include "rglmath.h"
#include "Color.hpp"
#include "RenderContext.hpp"

#include "opengl.hpp"

namespace rgl {

//
// CLASS
//   Light
//

class Light : public SceneNode
{
public:
  Light( PolarCoord in_position = PolarCoord(0.0,0.0) , 
  	 Vertex in_finposition=Vertex(0.0f,0.0f,0.0f), 
  	 bool in_viewpoint=true, bool in_posisfinite=false, 
  	 Color ambient=Color(1.0f,1.0f,1.0f), Color diffuse=Color(1.0,1.0,1.0), 
  	 Color specular=Color(1.0,1.0,1.0) );
  void setup(RenderContext* renderContext);

  int getAttributeCount(AABox& bbox, AttribID attrib);
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "light", buflen); };

private:
  float position[4];
  Vertex finposition;
  Color ambient;
  Color diffuse;
  Color specular;
  GLenum id;
  bool viewpoint;
  bool posisfinite;
  friend class Scene;
  friend class Subscene;
};

} // namespace rgl

#endif // LIGHT_HPP
