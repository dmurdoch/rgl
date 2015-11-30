#ifndef PLANESET_H
#define PLANESET_H

#include "scene.h"
#include "geom.h"
#include "Shape.h"
#include "PrimitiveSet.h"
#include <map>

namespace rgl {

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
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "planes", buflen); };

  /**
   * overload to update triangles first.
   */
  virtual AABox& getBoundingBox(Subscene* subscene);

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
  int getAttributeCount(AABox& bbox, AttribID attrib);
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);  
};

} // namespace rgl

#endif // PLANESET_H
