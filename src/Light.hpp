#ifndef LIGHT_HPP
#define LIGHT_HPP

//
// CLASS
//   Light
//

#include "SceneNode.hpp"

#include "rglmath.h"
#include "Color.hpp"
#include "RenderContext.hpp"

#include "opengl.hpp"

class Light : public SceneNode
{
public:
  Light( PolarCoord in_position = PolarCoord(0.0,0.0) , bool in_viewpoint=true, Color ambient=Color(1.0f,1.0f,1.0f), Color diffuse=Color(1.0,1.0,1.0), Color specular=Color(1.0,1.0,1.0) );
  void setup(RenderContext* renderContext);

  int getAttributeCount(AttribID attrib);
  void getAttribute(AttribID attrib, int first, int count, double* result);

private:
  float position[4];
  Color ambient;
  Color diffuse;
  Color specular;
  GLenum id;
  bool viewpoint;
  friend class Scene;
};

#endif // LIGHT_HPP
