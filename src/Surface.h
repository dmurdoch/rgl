#ifndef SURFACE_H
#define SURFACE_H

#include "Shape.h"
#include "PrimitiveSet.h"

#include "render.h"

#include <map>

namespace rgl {

//
// CLASS
//   Surface
//

class Surface : public FaceSet {
public:
  Surface(Material& material, int nx, int nz, double* x, double* z, double* y,
	         double* normal_x, double* normal_z, double* normal_y,
	         double* texture_s, double* texture_t,
	         int* coords, int orientation, int* flags, int ignoreExtent);
  /**
   * overload
   **/
  Vertex getCenter(int ix, int iz);  
  virtual std::string getTypeName() { return "surface"; };
  
  int getAttributeCount(SceneNode* subscene, AttribID attrib);
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);
  
  virtual int getElementCount(void) { return (nx-1)*(nz-1); }
  
  /**
   * location of individual items
   **/
  
  virtual Vertex getPrimitiveCenter(int item) ;
  
private:
  Vertex getNormal(int ix, int iz);

  int nx, nz, coords[3], orientation, user_normals, user_textures;
};

} // namespace rgl

#endif // SURFACE_H
