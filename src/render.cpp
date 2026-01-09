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
#ifndef RGL_NO_OPENGL	
	location = -1;
	offset = -1;
#endif
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
    Rf_warning("Only %d values copied", nvertex);
    in_nvertex = nvertex;
  }
    
  for(int i=0;i<in_nvertex;i++) {
    arrayptr[i*3+0] = (float) vertices[i*3+0];
    arrayptr[i*3+1] = (float) vertices[i*3+1];
    arrayptr[i*3+2] = (float) vertices[i*3+2];
  }
}

void VertexArray::copy(int in_nvertex, float* vertices)
{
  if (in_nvertex > nvertex) {
    Rf_warning("Only %d values copied", nvertex);
    in_nvertex = nvertex;
  }
  
  for(int i=0;i<in_nvertex;i++) {
    arrayptr[i*3+0] = (float) vertices[i*3+0];
    arrayptr[i*3+1] = (float) vertices[i*3+1];
    arrayptr[i*3+2] = (float) vertices[i*3+2];
  }
}

void VertexArray::duplicate(VertexArray& source, bool copyVertices)
{
  alloc(source.size());
	if (copyVertices)
    copy(nvertex, source.arrayptr);
  state = source.state;
  location = source.location;
  offset = source.offset;
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
	if (location >= 0) {
		glEnableVertexAttribArray(location);
		glVertexAttribPointer(location, 3, GL_FLOAT, GL_FALSE, 0, (GLbyte*)0 + offset);
	}
#endif
}

void VertexArray::endUse() {
#ifndef RGL_NO_OPENGL
	if (location >= 0)
		glDisableVertexAttribArray(location);
#endif
}

#ifndef RGL_NO_OPENGL
void VertexArray::appendToBuffer(std::vector<GLubyte>& buffer) {
	offset = buffer.size();
	const GLubyte* p = reinterpret_cast<const GLubyte*>(arrayptr);
	buffer.insert(buffer.end(), p, p + 3*nvertex*sizeof(float));
}

void VertexArray::replaceInBuffer(std::vector<GLubyte>& buffer) {
  const GLubyte* p = reinterpret_cast<const GLubyte*>(arrayptr);
  size_t size = 3*nvertex*sizeof(float);
  if (offset < 0 || offset + size > buffer.size())
    Rf_error("can't replace what's not there!");
  /* the next line is only for debugging... */
  std::copy(p, p + size, buffer.begin() + offset);
  glBufferSubData(GL_ARRAY_BUFFER, offset,
                  size, p);
}

void VertexArray::setAttribLocation(GLint loc)
{
	location = loc;
}

#endif

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

NormalArray::NormalArray() :
	VertexArray() {
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
  location = -1;
  offset = -1;
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
  	if (location >= 0) {
  		glEnableVertexAttribArray(location);
  		glVertexAttribPointer(location, 2, GL_FLOAT, GL_FALSE, 0, (GLbyte*)0 + offset);
  	}
  }
#endif
}

void TexCoordArray::endUse() {
#ifndef RGL_NO_OPENGL
  if (arrayptr) {
  	if (location >= 0)
  		glDisableVertexAttribArray(location);
  }
#endif
}

#ifndef RGL_NO_OPENGL
void TexCoordArray::appendToBuffer(std::vector<GLubyte>& buffer) {
	offset = buffer.size();
	const GLubyte* p = reinterpret_cast<const GLubyte*>(arrayptr);
	buffer.insert(buffer.end(), p, p + 2*nvertex*sizeof(float));
}

void TexCoordArray::setAttribLocation(GLint loc)
{
	location = loc;
}

#endif
