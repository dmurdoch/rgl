#ifndef ABCLINESET_HPP
#define ABCLINESET_HPP

#include "scene.h"
#include "geom.hpp"
#include "Shape.hpp"
#include "PrimitiveSet.hpp"
#include <map>

namespace rgl {

class ABCLineSet : public LineSet {
private:		/* Use parametrization (x,y,z) + s*(a,b,c) */
  int		nLines;
  ARRAY<Vertex> base; /* (x,y,z) */  
  ARRAY<Vertex> direction; /* (a,b,c) */
public:
  ABCLineSet(Material& in_material, int in_nbase, double* in_base, int in_ndir, double* in_dir);
  
  /**
   * tell type.
   **/
  virtual void getShapeName(char* buffer, int buflen) { strncpy(buffer, "abclines", buflen); };

  /**
   * overload to update segments first.
   */
  virtual AABox& getBoundingBox(Scene* scene);

  /**
   * overload to update segments first.
   */
  virtual void renderBegin(RenderContext* renderContext);

  /**
   * update mesh
   */
  void updateSegments(const AABox& sceneBBox);
  
  /**
   * update then get attributes 
   */
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);

};

} // namespace rgl

#endif // PLANESET_HPP
