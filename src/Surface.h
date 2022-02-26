#ifndef SURFACE_H
#define SURFACE_H

#include "Shape.h"

#include "render.h"

#include <map>

namespace rgl {

//
// CLASS
//   Surface
//

class Surface : public Shape {
public:
  Surface(Material& material, int nx, int nz, double* x, double* z, double* y,
	         double* normal_x, double* normal_z, double* normal_y,
	         double* texture_s, double* texture_t,
	         int* coords, int orientation, int* flags, int ignoreExtent);
  /**
   * overload
   **/
  virtual void draw(RenderContext* renderContext);
  
  /* Center of square with upper left at (ix, iz) */
  Vertex getCenter(int ix, int iz);  
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "surface", buflen); };
  
  int getAttributeCount(SceneNode* subscene, AttribID attrib);
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);
  
  virtual int getElementCount(void) { return (nx-1)*(nz-1); }
  
  /**
   * location of individual items
   **/
  
  virtual Vertex getPrimitiveCenter(int item) ;

  /**
   * begin sending items 
   **/
  virtual void drawBegin(RenderContext* renderContext) ;

  /**
   * send one item
   **/
  virtual void drawPrimitive(RenderContext* renderContext, int index) ;

  /**
   * end sending items
   **/
  virtual void drawEnd(RenderContext* renderContext) ;
  
private:
  Vertex getNormal(int ix, int iz);

  VertexArray vertexArray;
  NormalArray normalArray;
  TexCoordArray texCoordArray;
  int nx, nz, coords[3], orientation, user_normals, user_textures;
  bool use_normal, use_texcoord; 
};

} // namespace rgl

#endif // SURFACE_H
