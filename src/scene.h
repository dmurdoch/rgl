#ifndef SCENE_H
#define SCENE_H

// C++ header file
// This file is part of RGL
//
// $Id: scene.h,v 1.3 2003/11/21 21:56:03 dadler Exp $


#include "types.h"
#include "opengl.h"
#include "gui.h"
#include "pixmap.h"
#include "math.h"

//
// CLASS
//   StringArray
//

struct String
{
  String(int in_length, char* in_text) {
    length = in_length;
    text   = in_text;
  }
  int   length;
  char* text;
};

class StringArrayImpl;

class StringArray
{
public:
  StringArray();
  StringArray(int ntexts, char** in_texts);
  StringArray(StringArray& from);
  ~StringArray();
private:
  StringArrayImpl* impl;
  friend class StringArrayIterator;
};

class StringArrayIterator
{
public:
  StringArrayIterator(StringArray* array);
  void first();
  void next();
  String getCurrent();
  bool isDone() const;
private:
  StringArray* array;
  int   cnt;
  char* textptr;
};


//
// CLASS
//   VertexArray
//

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


//
// CLASS
//   RenderContext
//

class Scene;
class Viewpoint;

struct RenderContext
{
  Scene* scene;
  RectSize size;
  Viewpoint* viewpoint;
  GLBitmapFont* font;
  double time;
  double lastTime;
  double deltaTime;
};

//
// ABSTRACT BASE CLASS
//   SceneNode
//

enum TypeID { SHAPE=1, LIGHT, BBOXDECO, VIEWPOINT, BACKGROUND };

class SceneNode : public Node
{

public:


  inline const TypeID getTypeID() const { return typeID; }
  virtual ~SceneNode() { };

protected:

  SceneNode(const TypeID in_typeID) : typeID(in_typeID) { };


private:

  const TypeID typeID;

};

class Viewpoint : public SceneNode
{

#define VIEWPOINT_MAX_ZOOM  10

public:

  Viewpoint(PolarCoord position=PolarCoord(0.0f,15.0f), float fov=90.0f, float zoom=0.0f, bool interactive=true);
  
  PolarCoord& getPosition();
  void        setPosition(const PolarCoord& position);
  float       getZoom(void) const; 
  void        setZoom(const float zoom);
  float       getFOV(void) const;
  void        setFOV(const float in_fov);
  void        setupFrustum(RenderContext* rctx, const Sphere& viewvolumeSphere);
  void        setupTransformation(RenderContext* rctx, const Sphere& viewvolumeSphere);
  void        setupOrientation(RenderContext* rctx) const;
  bool        isInteractive() const;
  Frustum     frustum;

private:
  PolarCoord  position;
  float       fov;
  float       zoom;
  bool        interactive;

};



//
// CLASS
//   Color
// IMPLEMENTATION
//   uses floats as the general format for single colors, clear colors,
//   lighting and material color properties
//

class Color
{
public:
  Color();
  Color(float red, float green, float blue, float alpha=1.0f);
  Color(u8 red, u8 green, u8 blue, u8 alpha);
  Color(const char* string);
  float  getRedf()   const { return data[0]; }
  float  getGreenf() const { return data[1]; }
  float  getBluef()  const { return data[2]; }
  float  getAlphaf() const { return data[3]; }
  u8     getRedub()  const { return (u8) (data[0]/255.0f); }
  u8     getGreenub()const { return (u8) (data[1]/255.0f); }
  u8     getBlueub() const { return (u8) (data[2]/255.0f); }
  u8     getAlphaub()const { return (u8) (data[3]/255.0f); }
  float* getFloatPtr() const { return (float*) data; }
  /// set by integer ptr
  void   set3iv(int* color);
  void useClearColor() const;
  void useColor() const;
  float data[4];
};

//
// CLASS
//   ColorArray
// IMPLEMENTATION
//   uses unsigned bytes as interal format for mass color datas
//   carries alpha values
//

class ColorArray
{
public:
  ColorArray();
  ColorArray( ColorArray& src );
  ColorArray( Color& bg, Color& fg );
  ~ColorArray();
//  void set( int ncolor, RColor* rcolors, u8 alpha=255 );
  void set( int ncolor, char** colors, int nalpha, double* alphas );
  void set( int ncolor, int* colors, int nalpha, double* alphas );
  void useColor( int index ) const;
  void useArray() const;
  unsigned int getLength() const;
  Color getColor( int index ) const;
  void recycle( unsigned int newsize );
  bool hasAlpha() const;
private:
  bool hint_alphablend;
  unsigned int ncolor;
  unsigned int nalpha;
  u8* arrayptr;
  friend class Material;
};

//
// CLASS
//   SphereMesh
//

class SphereMesh
{
public:

  enum Type { GLOBE, TESSELATION };

  SphereMesh();

  inline void setGenNormal   (bool in_genNormal)
  { genNormal = in_genNormal; }
  inline void setGenTexCoord (bool in_genTexCoord)
  { genTexCoord = in_genTexCoord; }

  void setGlobe       (int segments, int sections);
  void setTesselation (int level);

  void setCenter      (const Vertex& center);
  void setRadius      (float radius);
  void update();

/*
  void beginDraw(RenderContext* renderContext);
  void drawSection(int section);
  void endDraw(RenderContext* renderContext);
*/

  void draw(RenderContext* renderContext);

private:
  
  Vertex center;
  float  radius;
  float  philow;
  float  phihigh;
  float  thetalow;
  float  thetahigh;
  
  VertexArray   vertexArray;
  NormalArray   normalArray;
  TexCoordArray texCoordArray;

  int    segments;
  int    sections;
  int    flags;
  Type   type;
  bool   genNormal;
  bool   genTexCoord;

  void   setupMesh();
};

//
// CLASS
//   Texture
//

class Texture : public AutoDestroy
{
public:
 
  enum Type { ALPHA = 1 , LUMINANCE, LUMINANCE_ALPHA, RGB, RGBA };

  Texture(const char* filename, Type type, bool mipmap, unsigned int minfilter, unsigned int magfilter);
  virtual ~Texture();
  bool isValid() const;
  void beginUse(RenderContext* renderContext);
  void endUse(RenderContext* renderContext);
private:
  Pixmap* pixmap;
  GLuint  texName;
  Type    type;
  bool    mipmap;
  GLenum  minfilter;
  GLenum  magfilter;
};

//
// STRUCT
//   Material
//

class Material {
public:

  enum PolygonMode { 
    FILL_FACE=1, 
    LINE_FACE, 
    POINT_FACE, 
    CULL_FACE 
  };

  Material( Color bg, Color fg );

  void setup();
  // called when complete

  void beginUse(RenderContext* renderContext);
  void endUse(RenderContext* renderContext);
  void useColor(int index);
  void colorPerVertex(bool enable, int numVertices=0);

  Color        ambient;
  Color        specular;
  Color        emission;
  float        shininess;
  float        size;          // point size, line width
  ColorArray   colors;        // color or if lit, represents diffuse color
  Ref<Texture> texture;
  PolygonMode  front;
  PolygonMode  back;
  bool         alphablend;
  bool         smooth;
  bool         lit;
  bool         fog;
  bool         useColorArray;
};


//
// CLASS
//   Shape
//

class Shape : public SceneNode
{
public:
  Shape(Material& in_material,TypeID in_typeID=SHAPE);
  virtual void render(RenderContext* renderContext);
  virtual void update(RenderContext* renderContext);
  virtual void draw(RenderContext* renderContext) = 0;
  const AABox& getBoundingBox() const { return boundingBox; }
  const Material& getMaterial() const { return material; }
protected:
  AABox    boundingBox;
  Material material;
private:
  GLuint   displayList;
protected:
  bool     doUpdate;
};

//
// CLASS
//   Surface
//

class Surface : public Shape {
public:
  Surface(Material& material, int nx, int nz, double* x, double* z, double* y);
  void draw(RenderContext* renderContext);
private:
  void setNormal(int ix, int iz);

  VertexArray vertexArray;
  TexCoordArray texCoordArray;
  int nx, nz;
};

//
// ABSTRACT CLASS
//   PrimitiveSet
//

class PrimitiveSet : public Shape {
public:
  virtual void draw(RenderContext* renderContext);
protected:
  PrimitiveSet(Material& material, GLenum type, int nelements, double* vertex);
  int nelements;
  VertexArray vertexArray;
private:
  GLenum type;
};

class PointSet : public PrimitiveSet 
{ 
public:
  PointSet(Material& material, int in_nelements, double* in_vertex);

};

class LineSet : public PrimitiveSet 
{ 
public:
  LineSet(Material& material, int in_nelements, double* in_vertex);
};

//
// ABSTRACT CLASS
//   FaceSet
//

class FaceSet : public PrimitiveSet
{
public:
  void draw(RenderContext* renderContext);
protected:
  FaceSet(Material& material, GLenum type, int in_nelements, double* in_vertex);
  NormalArray normalArray;
};

class TriangleSet : public FaceSet
{ 
public:
  TriangleSet(Material& material, int in_nelements, double* in_vertex);
};

class QuadSet : public FaceSet 
{ 
public:
  QuadSet(Material& material, int in_nelements, double* in_vertex);
};

class SphereSet : public Shape {
private:
  ARRAY<Vertex> center;
  ARRAY<float>  radius;
  SphereMesh    sphereMesh;
/*
  int nsphere;
  VertexArray center;

  int nradius;
  union radiusInfo {
    float* arrayptr;
    float  value;
  } radius;
*/
public:
  SphereSet(Material& in_material, int nsphere, double* center, int nradius, double* radius);
  ~SphereSet();
  void draw(RenderContext* renderContext);
};

//
// SPRITESET
//

class SpriteSet : public Shape {
private:
  ARRAY<Vertex> vertex;
  ARRAY<float>  size;

public:
  SpriteSet(Material& in_material, int nvertex, double* vertex, int nsize, double* size);
  ~SpriteSet();
  void render(RenderContext* renderContext);
  void draw(RenderContext* renderContext);
};


//
// TEXTSET
//

class TextSet : public Shape {
public:
  TextSet(Material& in_material, int in_ntexts, char** in_texts, double *in_center, int in_justify);
  ~TextSet();
  void draw(RenderContext* renderContext);
private:

  VertexArray vertexArray;
  StringArray textArray;

  int justify;
};

//
// CLASS
//   Light
//

class Light : public SceneNode
{
public:
  Light( PolarCoord in_position = PolarCoord(0.0,0.0) , bool in_viewpoint=true, Color ambient=Color(1.0f,1.0f,1.0f), Color diffuse=Color(1.0,1.0,1.0), Color specular=Color(1.0,1.0,1.0) );
  void setup(RenderContext* renderContext);
private:
  float position[4];
  Color ambient;
  Color diffuse;
  Color specular;
  GLenum id;
  bool viewpoint;
  friend class Scene;
};

//
// CLASS
//   Background
//

class Background : public Shape
{
public:
  enum {
    FOG_NONE=1, FOG_LINEAR, FOG_EXP, FOG_EXP2
  };
  Background( Material& in_material = defaultMaterial, bool sphere=false, int fogtype=FOG_NONE);
  void render(RenderContext* renderContext);
  void draw(RenderContext* renderContext);
  GLbitfield setupClear(RenderContext* renderContext);
protected:
  bool clearColorBuffer;
  bool sphere;
  int  fogtype;
  SphereMesh sphereMesh;
//  GLuint displayList;
  friend class Scene;
private:
  static Material defaultMaterial;
};

//
// CLASS
//   BBoxDeco
//

enum {
  AXIS_CUSTOM,
  AXIS_LENGTH,
  AXIS_UNIT,
  AXIS_NONE
};

struct AxisInfo {
  AxisInfo();
  AxisInfo(int in_nticks, double* in_values, char** in_texts, int xlen, float xunit);
  AxisInfo(AxisInfo& from);
  ~AxisInfo();
  void draw(RenderContext* renderContext, Vertex4& v, Vertex4& dir, float marklen, String& string);

  int    mode;
  int    nticks;
  float* ticks;
  StringArray textArray;
  int    len;
  float  unit;
};


class BBoxDeco : public SceneNode 
{
public:
  BBoxDeco(Material& in_material=defaultMaterial, AxisInfo& xaxis=defaultAxis, AxisInfo& yaxis=defaultAxis, AxisInfo& zaxis=defaultAxis, float marklen=15.0, bool marklen_fract=true);
  void render(RenderContext* renderContext);
  AABox getBoundingBox(const AABox& boundingBox) const;
  float getMarkLength(const AABox& boundingBox) const;
private:
  Material material;
  AxisInfo xaxis, yaxis, zaxis;
  float marklen_value;
  bool  marklen_fract;

  static Material defaultMaterial;
  static AxisInfo defaultAxis;
};


//
// CLASS
//   Scene
//
// - is referenced by view
//

class Scene {
public:
  Scene();
  ~Scene();

  // client services:

  bool clear(TypeID stackTypeID);
  bool add(SceneNode* node);
  bool pop(TypeID stackTypeID);

  const AABox& getBoundingBox() const { return data_bbox; }

  // gui services:

  void render(RenderContext* renderContext);
  Viewpoint* getViewpoint();

private:

  void setupLightModel(RenderContext* renderContext);
  void calcDataBBox();

  Background* background;
  Viewpoint* viewpoint;
  BBoxDeco*  bboxDeco;

  int  nlights;
  List lights;

  List shapes;

  AABox data_bbox;
};


#endif /* SCENE_H */
