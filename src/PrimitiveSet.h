#ifndef PRIMITIVE_SET_H
#define PRIMITIVE_SET_H

#include "Shape.h"

#include "render.h"

#include <map>

namespace rgl {

//
// ABSTRACT CLASS
//   PrimitiveSet
//

class PrimitiveSet : public Shape {
public:
  /**
   * overloaded
   **/
  virtual void draw(RenderContext* renderContext);
  /**
   * overloaded
   **/
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "primitive", buflen); }
  /**
   * overloaded
   **/
  virtual int getElementCount(void) { return nprimitives; }
  int getAttributeCount(AABox& bbox, AttribID attrib);
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);
  
  /**
   * overloaded
   **/
  virtual Vertex getElementCenter(int item) { return getCenter(item); }

  /**
   * begin sending primitives 
   * interface
   **/
  virtual void drawBegin(RenderContext* renderContext);
  
  /**
   * send primitive
   * interface
   **/
  virtual void drawElement(RenderContext* renderContext, int index);
  
  /**
   * end sending primitives
   * interface
   **/
  virtual void drawEnd(RenderContext* renderContext);
  
  /**
   * set a vertex
   **/
  const void setVertex(int index, double* v) { vertexArray.setVertex(index, v); }

  /**
   * setup all vertices
   **/
  void initPrimitiveSet(int in_nvertices, double* in_vertices);

protected:

  /**
   * abstract class constructor
   **/
  PrimitiveSet (
      Material& in_material, 
      int in_nvertices, 
      double* vertex, 
      int in_type, 
      int in_nverticesperelement,
      bool in_ignoreExtent,
      bool in_bboxChange = false
  );
  PrimitiveSet(
    Material& in_material, 
    int in_type, 
    int in_verticesperelement,
    bool in_ignoreExtent,
    bool in_bboxChange 
  );

  /**
   * get primitive center point
   **/
  inline Vertex getCenter(int index)
  {
    Vertex accu;
    int begin = index*nverticesperelement;
    int end   = begin+nverticesperelement;
    for (int i = begin ; i < end ; ++i )
      accu += vertexArray[i];
    return accu * ( 1.0f / ( (float) nverticesperelement ) );
  }

  // ---[ PRIMITIVE DRAW INTERFACE ]------------------------------------------

  
  /**
   * send all elements
   * interface
   **/
  virtual void drawAll(RenderContext* renderContext);
  
  void initPrimitiveSet (
      int in_nvertices, 
      double* vertex, 
      int in_type, 
      int in_nverticesperelement,
      bool in_ignoreExtent,
      bool in_bboxChange 
  );

  int type;
  int nverticesperelement;
  int nvertices;
  int nprimitives;
  VertexArray vertexArray;
  bool hasmissing; 	/* whether any vertices contain missing values */
};


//
// ABSTRACT CLASS
//   FaceSet
//

class FaceSet : public PrimitiveSet
{
public:
  /**
   * overload
   **/
  virtual void drawBegin(RenderContext* renderContext);

  /**
   * overload
   **/
  virtual void drawEnd(RenderContext* renderContext);
  /**
   * overloaded
   **/  
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "faces", buflen); };  
  
  int getAttributeCount(AABox& bbox, AttribID attrib);
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);

protected:
  /**
   * Constructor
   **/
  FaceSet(
    Material& in_material, 
    int in_nelements, 
    double* in_vertex,
    double* in_normals,
    double* in_texcoords,
    int in_type, 
    int in_nverticesperelement,
    bool in_ignoreExtent,
    int in_useNormals,
    int in_useTexcoords,
    bool in_bboxChange = false
  );
  
  FaceSet(
    Material& in_material, 
    int in_type, 
    int in_verticesperelement,
    bool in_ignoreExtent,
    bool in_bboxChange = false
  );
  
  /* (re-)set mesh */
  void initFaceSet(int in_nelements, double* in_vertex, double* in_normals, double* in_texcoords);
 
private:
  NormalArray normalArray;
  TexCoordArray texCoordArray;
};

//
// CLASS
//   PointSet
//

class PointSet : public PrimitiveSet
{ 
public:
  PointSet(Material& material, int nvertices, double* vertices, bool in_ignoreExtent, bool bboxChange=false);
  /**
   * overloaded
   **/  
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "points", buflen); };
};

//
// CLASS
//   LineSet
//

class LineSet : public PrimitiveSet
{ 
public:
  LineSet(Material& material, int nvertices, double* vertices, bool in_ignoreExtent, bool in_bboxChange=false);
  LineSet(Material& in_material, bool in_ignoreExtent, bool in_bboxChange);

  /**
   * overloaded
   **/  
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "lines", buflen); };
};

//
// CLASS
//   TriangleSet
//

class TriangleSet : public FaceSet
{ 
public:
  TriangleSet(Material& in_material, int in_nvertex, double* in_vertex, double* in_normals,
              double* in_texcoords, bool in_ignoreExtent, int in_useNormals, int in_useTexcoords, bool in_bboxChange = false)
    : FaceSet(in_material,in_nvertex, in_vertex, in_normals, in_texcoords, 
              GL_TRIANGLES, 3, in_ignoreExtent, in_useNormals, in_useTexcoords, in_bboxChange)
  { }
  TriangleSet(Material& in_material, bool in_ignoreExtent, bool in_bboxChange) : 
    FaceSet(in_material, GL_TRIANGLES, 3, in_ignoreExtent, in_bboxChange) 
  { }
  /**
   * overloaded
   **/  
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "triangles", buflen); };
};

//
// CLASS
//   QuadSet
//

class QuadSet : public FaceSet
{ 
public:
  QuadSet(Material& in_material, int in_nvertex, double* in_vertex, double* in_normals,
          double* in_texcoords, bool in_ignoreExtent, int in_useNormals, int in_useTexcoords)
    : FaceSet(in_material,in_nvertex,in_vertex, in_normals, in_texcoords, 
              GL_QUADS, 4, in_ignoreExtent, in_useNormals, in_useTexcoords)
  { }
  
  /**
   * overloaded
   **/  
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "quads", buflen); };
};

//
// CLASS
//   LineStripSet
//

class LineStripSet : public PrimitiveSet
{
public:
  LineStripSet(Material& material, int in_nelements, double* in_vertex, bool in_ignoreExtent, bool in_bboxChange = false);
  void drawElement(RenderContext* renderContext, int index);
  /**
   * overloaded
   **/  
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "linestrip", buflen); };
};

} // namespace rgl 

#endif // PRIMITIVE_SET_H
