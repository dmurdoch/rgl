#ifndef ABCLINESET_H
#define ABCLINESET_H

#include "scene.h"
#include "geom.h"
#include "Shape.h"
#include "PrimitiveSet.h"
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
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "abclines", buflen); };

  /**
   * overload to update segments first.
   */
  virtual AABox& getBoundingBox(Subscene* subscene);

  /**
   * overload to update segments first.
   */
  virtual void renderBegin(RenderContext* renderContext);

  /**
   * update mesh
   */
  void updateSegments(SceneNode* subscene);
  
  /**
   * update then get attributes 
   */
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);

};

} // namespace rgl

#endif // PLANESET_H
