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
  TextSet(Material& in_material, int in_ntexts, char** in_texts, double *in_center, double in_adj);
  ~TextSet();
  void draw(RenderContext* renderContext);
private:

  VertexArray vertexArray;
  StringArray textArray;

  double adj;
};

#endif // TEXTSET_HPP

