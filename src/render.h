#ifndef RENDER_H
#define RENDER_H

#include "RenderContext.hpp"

#include "types.h"

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

  void alloc(int nvertex);
  void beginUse();
  void endUse();
  TexCoord& operator[](int index);

private:
  float* arrayptr;
};

#endif // RENDER_H
