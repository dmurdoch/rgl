#ifndef PRIMITIVE_SET_HPP
#define PRIMITIVE_SET_HPP

#include "Shape.hpp"

#include "render.h"

#include <map>

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
  virtual void renderZSort(RenderContext* renderContext);
protected:

  /**
   * abstract class constructor
   **/
  PrimitiveSet (
      Material& in_material, 
      int in_nvertices, 
      double* vertex, 
      int in_type, 
      int in_nverticesperelement
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
   * begin sending primitives 
   * interface
   **/
  virtual void drawBegin(RenderContext* renderContext);
  
  /**
   * send all elements
   * interface
   **/
  virtual void drawAll(RenderContext* renderContext);
  
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

  int type;
  int nverticesperelement;
  int nvertices;
  int nprimitives;
  VertexArray vertexArray;

};


//
// ABSTRACT CLASS
//   FaceSet
//

class FaceSet : public PrimitiveSet
{
protected:
  /**
   * Constructor
   **/
  FaceSet(
    Material& in_material, 
    int in_nelements, 
    double* in_vertex, 
    int in_type, 
    int in_nverticesperelement
  );
  
  /**
   * overload
   **/
  virtual void drawBegin(RenderContext* renderContext);

  /**
   * overload
   **/
  virtual void drawEnd(RenderContext* renderContext);
private:
  NormalArray normalArray;
};

//
// CLASS
//   PointSet
//

class PointSet : public PrimitiveSet
{ 
public:
  PointSet(Material& material, int nvertices, double* vertices);
};

//
// CLASS
//   LineSet
//

class LineSet : public PrimitiveSet
{ 
public:
  LineSet(Material& material, int nvertices, double* vertices);
};

//
// CLASS
//   TriangleSet
//

class TriangleSet : public FaceSet
{ 
public:
  TriangleSet(Material& in_material, int in_nvertex, double* in_vertex)
    : FaceSet(in_material,in_nvertex, in_vertex, GL_TRIANGLES, 3)
  { }
};

//
// CLASS
//   QuadSet
//

class QuadSet : public FaceSet
{ 
public:
  QuadSet(Material& in_material, int in_nvertex, double* in_vertex)
    : FaceSet(in_material,in_nvertex,in_vertex, GL_QUADS, 4)
  { }
};

//
// CLASS
//   LineStripSet
//

class LineStripSet : public PrimitiveSet
{
public:
  LineStripSet(Material& material, int in_nelements, double* in_vertex);
};

#endif // PRIMITIVE_SET_HPP
