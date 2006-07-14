#ifndef SPHERE_MESH_HPP
#define SPHERE_MESH_HPP

#include "render.h"

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
  float  thetalow;
  float  thetahigh;
  
  VertexArray   vertexArray;
  NormalArray   normalArray;
  TexCoordArray texCoordArray;

  int    segments;
  int    sections;
  int    flags;
  Type   type;
  bool   genNormal;
  bool   genTexCoord;

  void   setupMesh();
};



#endif // SPHERE_MESH_HPP
