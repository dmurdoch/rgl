#ifndef CLIPPLANE_HPP
#define CLIPPLANE_HPP

#include "geom.hpp"
#include "Shape.hpp"
#include "PrimitiveSet.hpp"
#include <map>

namespace rgl {

class ClipPlaneSet : public Shape {
private:		/* Use parametrization ax + by + cz + d = 0 */
  int		nPlanes;
  GLenum	firstPlane;
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
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "clipplanes", buflen); };
  
  virtual void renderBegin(RenderContext* renderContext);
  
  virtual void drawElement(RenderContext* renderContext, int index);
  
  virtual int getElementCount(void) { return nPlanes; }

  virtual int getAttributeCount(AABox& bbox, AttribID attrib);
  
  virtual void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);

  void enable(bool show);  // after it has been drawn, this enables it or disables it
  
  bool isClipPlane(void) { return true; }

};

} // namespace rgl

#endif // CLIPPLANE_HPP
