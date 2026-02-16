#ifndef SELECT_H
#define SELECT_H

// C++ header file
// This file is part of RGL

#include "PrimitiveSet.h"

namespace rgl {

//
// Mouse selection rectangle
//

class SelectionBox : public LineStripSet
{
public:
  SelectionBox(Material& material, int in_nvertex, double* in_vertex);
  void drawBegin(RenderContext* renderContext);
  void drawEnd(RenderContext* renderContext);
  /**
   * overloaded
   **/  
  virtual std::string getTypeName() { return "selectionbox"; };
  
private:
  Matrix4x4 savedModelMatrix, savedProjMatrix;
};

} // namespace rgl

#endif // SELECT_H

