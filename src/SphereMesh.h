#ifndef SPHERE_MESH_H
#define SPHERE_MESH_H

#include <unordered_map>
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
  
  Matrix4x4 MVmodification(const Vertex& scale);

  void draw(RenderContext* renderContext);
  
  void drawBegin(RenderContext* renderContext, bool endcap);
  void drawPrimitive(RenderContext* renderContext, int i);
  void drawEnd(RenderContext* renderContext);

  int getPrimitiveCount() { return segments*sections; }
  int getSegments() { return segments; }
  Vertex getPrimitiveCenter(int i);
#ifndef RGL_NO_OPENGL  
  void initialize(
      std::unordered_map<std::string, GLint> &glLocs,
      std::vector<GLubyte> &vertexbuffer);
#endif
  
private:
  
  Vertex center;
  float  radius;
  float  philow;
  float  phihigh;
  
  Matrix4x4 origMV;
  
  VertexArray   vertexArray;
  NormalArray   normalArray;
  TexCoordArray texCoordArray;

  int    segments;
  int    sections;
  int    nvertex;
  Type   type;
  bool   genNormal;
  bool   genTexCoord;

  void   setupMesh();
};

} // namespace rgl

#endif // SPHERE_MESH_H
