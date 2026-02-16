// C++ source
// This file is part of RGL.
//

#include "select.h"
#include "subscene.h"

#include <cstdio>

using namespace rgl;

SelectionBox::SelectionBox(Material& material, int in_nvertex, double* in_vertex) : LineStripSet(material, in_nvertex, in_vertex, true, 0, NULL, false) {}

void SelectionBox::drawBegin(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL  
  Subscene* subscene = renderContext->subscene;
  
  savedModelMatrix = subscene->modelMatrix;
  subscene->modelMatrix.setIdentity();
  savedProjMatrix = subscene->projMatrix;
  subscene->projMatrix.setIdentity();
  
  LineStripSet::drawBegin(renderContext);
  
  GLdouble llx, lly, urx, ury;
  double* position = subscene->getMousePosition();
  llx = 2.0*position[0] - 1.0;
  lly = 2.0*position[1] - 1.0;
  urx = 2.0*position[2] - 1.0;
  ury = 2.0*position[3] - 1.0;
  std::array<GLdouble, 3> v = {llx, lly, 0.0};
  setVertex(0, v.data());
  v = {urx, lly, 0.0};
  setVertex(1, v.data());
  v = {urx, ury, 0};
  setVertex(2, v.data());
  v = {llx, ury, 0};
  setVertex(3, v.data());
  v = {llx, lly, 0};
  setVertex(4, v.data());
  
  updateBuffer();
  
#endif
}

void SelectionBox::drawEnd(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL   
  LineStripSet::drawEnd(renderContext);
  
  Subscene* subscene = renderContext->subscene;
  
  subscene->projMatrix.loadData(savedProjMatrix);
  subscene->modelMatrix.loadData(savedModelMatrix);
#endif  
}
