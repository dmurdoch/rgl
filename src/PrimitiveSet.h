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
  virtual std::string getTypeName() { return "primitive"; }
  /**
   * overloaded
   **/
  virtual int getElementCount(void) { return nprimitives; }
  int getAttributeCount(SceneNode* subscene, AttribID attrib);
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);
  
  /**
   * overloaded
   **/
  virtual Vertex getPrimitiveCenter(int item) { return getCenter(item); }

  /**
   * begin sending primitives 
   * interface
   **/
  virtual void drawBegin(RenderContext* renderContext);
  
  /**
   * send primitive
   * interface
   **/
  virtual void drawPrimitive(RenderContext* renderContext, int index);
  
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
  void initPrimitiveSet(int in_nvertices, double* in_vertices,
                        int in_nindices = 0, int* in_indices = NULL);

  /** 
   * prepare for shader use
   */
  virtual void initialize();
  
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
      int in_nindices, 
      int* in_indices,
      bool in_bboxChange = false
  );
  PrimitiveSet(
    Material& in_material,
    int in_type,
    int in_verticesperelement,
    bool in_ignoreExtent,
    bool in_bboxChange
  );
  
  ~PrimitiveSet();

  /**
   * get primitive center point
   **/
  inline Vertex getCenter(int index)
  {
    Vertex accu;
    int begin = index*nverticesperelement;
    int end   = begin+nverticesperelement;
    for (int i = begin ; i < end ; ++i ) {
      if (nindices)
        accu += vertexArray[indices[i]];
      else
        accu += vertexArray[i];
    }
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
  VertexArray vertexArray,  /* the vertices given by the user */
              verticesTodraw; /* the margin vertices in data coords */
  bool hasmissing; 	/* whether any vertices contain missing values */
  int nindices;
  unsigned int* indices;

  /**
   * shader program
   */
  GLuint   shaderProgram;
#ifndef RGL_NO_OPENGL
  std::vector<GLubyte> vertexbuffer;
  GLuint vbo;
  void loadBuffer();
  void printUniform(const char *name, int rows, int cols, int transposed,
                    GLint type);
  void printUniforms(); /* for debugging */
  void printAttribute(const char *name);
  void printAttributes();
  void printBufferInfo();
#endif
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
  virtual std::string getTypeName() { return "faces"; };  
  
  int getAttributeCount(SceneNode* subscene, AttribID attrib);
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);

protected:
  /**
   * Constructor
   **/
  FaceSet(
    Material& in_material, 
    int in_nvertex, 
    double* in_vertex,
    double* in_normals,
    double* in_texcoords,
    int in_type, 
    int in_nverticesperelement,
    bool in_ignoreExtent,
    int in_nindices, 
    int* in_indices,
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
  void initFaceSet(int in_nvertex, double* in_vertex, double* in_normals, double* in_texcoords);
 
  /* set up normals */
  void initNormals(double* in_normals);
  
  /* shader inits */
  virtual void initialize();
private:
  NormalArray normalArray, normalsToDraw;
  TexCoordArray texCoordArray;
};

//
// CLASS
//   PointSet
//

class PointSet : public PrimitiveSet
{ 
public:
  PointSet(Material& material, int nvertices, double* vertices, bool in_ignoreExtent, int nindices, int* indices,
           bool bboxChange=false
           );
  /**
   * overloaded
   **/  
  virtual std::string getTypeName() { return "points"; };
};

//
// CLASS
//   LineSet
//

class LineSet : public PrimitiveSet
{ 
public:
  LineSet(Material& material, int nvertices, double* vertices, bool in_ignoreExtent, 
          int in_nindices, int* in_indices, bool in_bboxChange=false);
  LineSet(Material& in_material, bool in_ignoreExtent, bool in_bboxChange);

  /**
   * overloaded
   **/  
  virtual std::string getTypeName() { return "lines"; };
};

//
// CLASS
//   TriangleSet
//

class TriangleSet : public FaceSet
{ 
public:
  TriangleSet(Material& in_material, int in_nvertex, double* in_vertex, double* in_normals,
              double* in_texcoords, bool in_ignoreExtent, 
              int in_nindices, int* in_indices, int in_useNormals, int in_useTexcoords, bool in_bboxChange = false)
    : FaceSet(in_material,in_nvertex, in_vertex, in_normals, in_texcoords, 
              GL_TRIANGLES, 3, in_ignoreExtent, in_nindices, in_indices,
                in_useNormals, in_useTexcoords, in_bboxChange)
  { }
  TriangleSet(Material& in_material, bool in_ignoreExtent, bool in_bboxChange) : 
    FaceSet(in_material, GL_TRIANGLES, 3, in_ignoreExtent, in_bboxChange) 
  { }
  /**
   * overloaded
   **/  
  virtual std::string getTypeName() { return "triangles"; };
};

//
// CLASS
//   QuadSet
//

class QuadSet : public FaceSet
{ 
public:
  QuadSet(Material& in_material, int in_nvertex, double* in_vertex, double* in_normals,
          double* in_texcoords, bool in_ignoreExtent, int in_nindices, int* in_indices,
          int in_useNormals, int in_useTexcoords)
    : FaceSet(in_material,in_nvertex,in_vertex, in_normals, in_texcoords, 
              GL_QUADS, 4, in_ignoreExtent, in_nindices, in_indices, in_useNormals, in_useTexcoords)
  { }
  
  /**
   * overloaded
   **/  
  virtual std::string getTypeName() { return "quads"; };
};

//
// CLASS
//   LineStripSet
//

class LineStripSet : public PrimitiveSet
{
public:
  LineStripSet(Material& material, int in_nvertex, double* in_vertex, bool in_ignoreExtent, 
               int in_nindices, int* in_indices, bool in_bboxChange = false);
  void drawPrimitive(RenderContext* renderContext, int index);
  /**
   * overloaded
   **/  
  virtual std::string getTypeName() { return "linestrip"; };
};

} // namespace rgl 

#endif // PRIMITIVE_SET_H
