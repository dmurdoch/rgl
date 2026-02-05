#ifndef RENDER_H
#define RENDER_H

#include <vector>
#include "RenderContext.h"

#ifndef RGL_NO_OPENGL
#include "glad/gl.h"
#endif

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

  void alloc(int in_nvertex);
  void copy(int in_nvertex, double* vertices);
  void copy(int in_nvertex, float* vertices);
  void duplicate(VertexArray& source, bool copyVertices = false);
  void beginUse();
  void endUse();
  Vertex& operator[](int index);
  void setVertex(int index, double* v);
  void setVertex(int index, Vertex v);
  
#ifndef RGL_NO_OPENGL
  void setAttribLocation(GLint loc);
  void appendToBuffer(std::vector<GLubyte>& buffer);
  void replaceInBuffer(std::vector<GLubyte>& buffer);
#endif
  
  Vertex getNormal(int v1, int v2, int v3);
  int size() { return nvertex; }

  void Rprint(const char * format = "%.3f ");
protected:
  int nvertex;
  float* arrayptr;
  GLint location;
  GLint offset;
  GLenum state;
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
  NormalArray();
};

struct Vec2
{
public:
  float s,t;
  Vec2() { s = 0; t = 0; }
  Vec2(float s_in, float t_in) { s = s_in; t = t_in; }

};

/**
 * Vec2Array
 **/
class Vec2Array 
{
public:
  Vec2Array();
  ~Vec2Array();

  void alloc(int in_nvertex);
  void beginUse();
  void endUse();
  Vec2& operator[](int index);
  int size() { return nvertex; };
  void Rprint(const char * format = "%.3f ");
#ifndef RGL_NO_OPENGL
  void setAttribLocation(GLint loc);
  void appendToBuffer(std::vector<GLubyte>& buffer);
#endif
  
private:
  int nvertex;
  float* arrayptr;
  GLint location;
  GLint offset;
};

typedef Vec2 TexCoord;
typedef Vec2Array TexCoordArray;

} // namespace rgl

#endif // RENDER_H
