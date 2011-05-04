#ifndef ABCLINESET_HPP
#define ABCLINESET_HPP

#include "scene.h"
#include "geom.hpp"
#include "Shape.hpp"
#include "PrimitiveSet.hpp"
#include <map>

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
  virtual AABox& getBoundingBox(RenderContext* renderContext);

  /**
   * overload to update segments first.
   */
  virtual void renderBegin(RenderContext* renderContext);

  /**
   * update mesh
   */
  void updateSegments(const AABox& sceneBBox);
};

#endif // PLANESET_HPP
