#ifndef SPHERE_MESH_H
#define SPHERE_MESH_H

#include "render.h"

namespace rgl {

//
// CLASS
//   SphereMesh
//

class SphereMesh
{
public:

  enum Type { GLOBE, TESSELATION };

  SphereMesh();

  inline void setGenNormal   (bool in_genNormal)
  { genNormal = in_genNormal; }
  inline void setGenTexCoord (bool in_genTexCoord)
  { genTexCoord = in_genTexCoord; }

  void setGlobe       (int segments, int sections);
  void setTesselation (int level);

  void setCenter      (const Vertex& center);
  void setRadius      (float radius);
  void update();
  void update	      (const Vertex& scale);
  void dosort	      (bool in_sort);

/*
  void beginDraw(RenderContext* renderContext);
  void drawSection(int section);
  void endDraw(RenderContext* renderContext);
*/

  void draw(RenderContext* renderContext);

private:
  
  Vertex center;
  float  radius;
  float  philow;
  float  phihigh;
  
  VertexArray   vertexArray;
  NormalArray   normalArray;
  TexCoordArray texCoordArray;

  int    segments;
  int    sections;
  Type   type;
  bool   genNormal;
  bool   genTexCoord;
  bool   sort;

  void   setupMesh();
};

} // namespace rgl

#endif // SPHERE_MESH_H
