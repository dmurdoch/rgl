#ifndef TEXTSET_HPP
#define TEXTSET_HPP

#include "Shape.hpp"

//
// TEXTSET
//

#include "render.h"
#include "String.hpp"

class TextSet : public Shape {
public:
  TextSet(Material& in_material, int in_ntexts, char** in_texts, double *in_center, double in_adj,
          int in_ignoreExtent);
  ~TextSet();
  void draw(RenderContext* renderContext);
  virtual void getShapeName(char* buffer, int buflen) { strncpy(buffer, "text", buflen); };

private:

  VertexArray vertexArray;
  StringArray textArray;

  double adj;
};

#endif // TEXTSET_HPP

