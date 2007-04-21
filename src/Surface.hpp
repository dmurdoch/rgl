#ifndef SURFACE_HPP
#define SURFACE_HPP

#include "Shape.hpp"

#include "render.h"

#include <map>

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
  /**
   * overload
   **/
  virtual void renderZSort(RenderContext* renderContext);
  
  /* Center of square with upper left at (ix, iz) */
  Vertex getCenter(int ix, int iz);  
  virtual void getShapeName(char* buffer, int buflen) { strncpy(buffer, "surface", buflen); };

private:
  void setNormal(int ix, int iz);

  VertexArray vertexArray;
  NormalArray normalArray;
  TexCoordArray texCoordArray;
  int nx, nz, coords[3], orientation, user_normals, user_textures;
};

#endif // SURFACE_HPP
