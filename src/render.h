#ifndef RENDER_H
#define RENDER_H

#include "RenderContext.h"

#include "types.h"

namespace rgl {

//
// CLASS
//   VertexArray
//

/**
 * VertexArray
 **/
class VertexArray
{
public:

  VertexArray();
  ~VertexArray();

  void alloc(int nvertex);
  void copy(int nvertex, double* vertices);
  void beginUse();
  void endUse();
  Vertex& operator[](int index);
  void setVertex(int index, double* v);

  Vertex getNormal(int v1, int v2, int v3);

protected:
  float* arrayptr;
};

inline Vertex& VertexArray::operator[](int index) {
  return (Vertex&) arrayptr[index*3];
}

/**
 * NormalArray
 **/
class NormalArray : public VertexArray 
{
public:
  void beginUse();
  void endUse();
};

struct TexCoord
{
  float s,t;
};

/**
 * TexCoordArray
 **/
class TexCoordArray 
{
public:
  TexCoordArray();
  ~TexCoordArray();

  void alloc(int in_nvertex);
  void beginUse();
  void endUse();
  TexCoord& operator[](int index);
  int size() { return nvertex; };

private:
  int nvertex;
  float* arrayptr;
};

} // namespace rgl

#endif // RENDER_H
