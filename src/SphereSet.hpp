#ifndef SPHERESET_HPP
#define SPHERESET_HPP

#include "scene.h"
#include "Shape.hpp"
#include "SphereMesh.hpp"
#include <map>

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
   
  virtual AABox& getBoundingBox(Scene* scene);


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

  virtual void getShapeName(char* buffer, int buflen) { strncpy(buffer, "spheres", buflen); };

};

#endif // SPHERESET_HPP
