#ifndef SPHERESET_HPP
#define SPHERESET_HPP

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
  void draw(RenderContext* renderContext);
  
  /**
   * overload
   **/
  
  /* Check whether scale has changed before rendering */
  void render(RenderContext* renderContext);
  
  /* Sort spheres by depth */
  void renderZSort(RenderContext* renderContext);
  
  void drawElement(RenderContext* renderContext, int i);
};

#endif // SPHERESET_HPP
