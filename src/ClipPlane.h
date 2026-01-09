#ifndef CLIPPLANE_H
#define CLIPPLANE_H

#include "geom.h"
#include "Shape.h"
#include "PrimitiveSet.h"
#include <map>

namespace rgl {

class ClipPlaneSet : public Shape {
private:		/* Use parametrization ax + by + cz + d = 0 */
  int		nPlanes;
  ARRAY<Vertex> normal; /* (a,b,c) */
  ARRAY<float>  offset; /* d */  
  
    
public:
  ClipPlaneSet(Material& in_material, int in_nnormal, double* in_normal, int in_noffset, double* in_offset);
  // ~PlaneSet();

  static int num_planes;  // clip plane count for drawing; set to 0 initially, incremented
			 // as each plane is added or drawn.
  
  /**
   * tell type.
   **/
  virtual std::string getTypeName() { return "clipplanes"; };
  
  virtual void renderBegin(RenderContext* renderContext);
  
  virtual void drawPrimitive(RenderContext* renderContext, int index);
  
  virtual int getElementCount(void) { return nPlanes; }

  virtual int getAttributeCount(SceneNode* subscene, AttribID attrib);
  
  virtual void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);

  void enable(bool show);  // after it has been drawn, this enables it or disables it
  
  bool isClipPlane(void) { return true; }
  
  void intersectBBox(AABox& bbox);

};

} // namespace rgl

#endif // CLIPPLANE_H
