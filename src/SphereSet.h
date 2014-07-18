#ifndef SPHERESET_H
#define SPHERESET_H

#include "scene.h"
#include "Shape.h"
#include "SphereMesh.h"

namespace rgl {

class SphereSet : public Shape {
private:
  ARRAY<Vertex> center;
  ARRAY<float>  radius;
  SphereMesh    sphereMesh;
public:
  SphereSet(Material& in_material, int nsphere, double* center, int nradius, double* radius, 
            int in_ignoreExtent);
  ~SphereSet();

  /**
   * overload
   **/
  
  /* Check whether scale has changed before rendering */
  void render(RenderContext* renderContext);
  
  int getElementCount(void){ return center.size(); }
  int getAttributeCount(AABox& bbox, AttribID attrib);
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);
  
  /**
   * location of individual items
   **/
  
  Vertex getElementCenter(int index) { return center.get(index); }
  
  /**
   * Spheres appear as spheres, so their bbox depends on scaling
   **/
   
  virtual AABox& getBoundingBox(Subscene* subscene);


  /**
   * begin sending items 
   **/
  void drawBegin(RenderContext* renderContext);

  /**
   * send one item
   **/
  void drawElement(RenderContext* renderContext, int index);

  /**
   * end sending items
   **/
  void drawEnd(RenderContext* renderContext);

  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "spheres", buflen); };

};

} // namespace rgl

#endif // SPHERESET_H
