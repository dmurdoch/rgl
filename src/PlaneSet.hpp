#ifndef PLANESET_HPP
#define PLANESET_HPP

#include "scene.h"
#include "geom.hpp"
#include "Shape.hpp"
#include "PrimitiveSet.hpp"
#include <map>

class PlaneSet : public TriangleSet {
private:		/* Use parametrization ax + by + cz + d = 0 */
  int		nPlanes;
  ARRAY<Vertex> normal; /* (a,b,c) */
  ARRAY<float>  offset; /* d */  
public:
  PlaneSet(Material& in_material, int in_nnormal, double* in_normal, int in_noffset, double* in_offset);
  // ~PlaneSet();
  
  /**
   * tell type.
   **/
  virtual void getShapeName(char* buffer, int buflen) { strncpy(buffer, "planes", buflen); };

  /**
   * overload to update triangles first.
   */
  virtual AABox& getBoundingBox(Scene* scene);

  /**
   * overload to update triangles first.
   */
  virtual void renderBegin(RenderContext* renderContext);

  /**
   * update mesh
   */
  void updateTriangles(const AABox& sceneBBox);
  
  /**
   * update then get attributes 
   */
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);  
};

#endif // PLANESET_HPP
