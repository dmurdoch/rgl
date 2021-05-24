#include "render.h"

#include "opengl.h"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
//  SECTION: MATERIAL
//
//////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   VertexArray
//

VertexArray::VertexArray()
{
  arrayptr = NULL;
}

VertexArray::~VertexArray()
{
  if (arrayptr)
    delete[] arrayptr;
}

void VertexArray::alloc(int in_nvertex)
{
  if (arrayptr) {
    delete[] arrayptr;
    arrayptr = NULL;
  }
  nvertex = in_nvertex;
  if (nvertex)
    arrayptr = new float [nvertex*3];
}

void VertexArray::copy(int in_nvertex, double* vertices)
{
  if (in_nvertex > nvertex) {
    warning("Only %d values copied", nvertex);
    in_nvertex = nvertex;
  }
    
  for(int i=0;i<in_nvertex;i++) {
    arrayptr[i*3+0] = (float) vertices[i*3+0];
    arrayptr[i*3+1] = (float) vertices[i*3+1];
    arrayptr[i*3+2] = (float) vertices[i*3+2];
  }
}

void VertexArray::setVertex(int index, double* v) {
  arrayptr[index*3+0] = (float) v[0];
  arrayptr[index*3+1] = (float) v[1];
  arrayptr[index*3+2] = (float) v[2];
}

void VertexArray::setVertex(int index, Vertex v) {
  arrayptr[index*3+0] = (float) v.x;
  arrayptr[index*3+1] = (float) v.y;
  arrayptr[index*3+2] = (float) v.z;
}

void VertexArray::beginUse() {
#ifndef RGL_NO_OPENGL
  glEnableClientState(GL_VERTEX_ARRAY);
  glVertexPointer(3, GL_FLOAT, 0, (const GLvoid*) arrayptr );
#endif
}

void VertexArray::endUse() {
#ifndef RGL_NO_OPENGL
  glDisableClientState(GL_VERTEX_ARRAY);
#endif
}

Vertex VertexArray::getNormal(int iv1, int iv2, int iv3)
{
  Vertex normal;

  Vertex& v1 = (*this)[iv1];
  Vertex& v2 = (*this)[iv2];
  Vertex& v3 = (*this)[iv3];

  Vertex a(v3-v2), b(v1-v2);

  normal = a.cross(b);

  normal.normalize();

  return normal;
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   NormalArray
//

void NormalArray::beginUse() {
#ifndef RGL_NO_OPENGL
  glEnableClientState(GL_NORMAL_ARRAY);
  glNormalPointer(GL_FLOAT, 0, (const GLvoid*) arrayptr );
#endif
}

void NormalArray::endUse() {
#ifndef RGL_NO_OPENGL
  glDisableClientState(GL_NORMAL_ARRAY);
#endif
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   TexCoordArray
//

TexCoordArray::TexCoordArray()
{
  arrayptr = NULL;
  nvertex = 0;
}

TexCoordArray::~TexCoordArray()
{
  if (arrayptr)
    delete[] arrayptr;
}

void TexCoordArray::alloc(int in_nvertex)
{
  if (arrayptr) {
    delete[] arrayptr;
    arrayptr = NULL;
  }
  nvertex = in_nvertex;
  if (nvertex)
    arrayptr = new float[2*nvertex];
}

TexCoord& TexCoordArray::operator [] (int index) {
  return (TexCoord&) arrayptr[index*2];
}

void TexCoordArray::beginUse() {
#ifndef RGL_NO_OPENGL
  if (arrayptr) {
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid*) arrayptr );
  }
#endif
}

void TexCoordArray::endUse() {
#ifndef RGL_NO_OPENGL
  if (arrayptr)
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
#endif
}
