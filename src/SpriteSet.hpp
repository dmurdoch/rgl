#ifndef SPRITE_SET_HPP
#define SPRITE_SET_HPP

#include "Shape.hpp"
#include <vector>

//
// SPRITESET
//

class SpriteSet : public Shape {
private:
  ARRAY<Vertex> vertex;
  ARRAY<float>  size;

public:
  SpriteSet(Material& material, int nvertex, double* vertex, int nsize, double* size, 
            int ignoreExtent, int count = 0, Shape** shapelist = NULL, double* userMatrix = NULL);
  ~SpriteSet();

  /**
   * overload
   **/
  virtual void render(RenderContext* renderContext);
  
  virtual void getShapeName(char* buffer, int buflen) { strncpy(buffer, "sprites", buflen); };
  
  virtual int getElementCount(void);
  int getAttributeCount(AABox& bbox, AttribID attrib);
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);
  String getTextAttribute(AABox& bbox, AttribID attrib, int index);
  
  /**
   * location of individual items
   **/
  
  virtual Vertex getElementCenter(int index);
  
  /**
   * begin sending items 
   **/
  virtual void drawBegin(RenderContext* renderContext);
  
  /**
   * send one item
   **/
  virtual void drawElement(RenderContext* renderContext, int index);
  
  /**
   * end sending items
   **/
  virtual void drawEnd(RenderContext* renderContext);
  
  /**
   * extract individual shape
   */
  virtual Shape* get_shape(int id);
  
private:
  GLdouble userMatrix[16]; /* Transformation for 3D sprites */
  Matrix4x4 m;             /* Modelview matrix cache */
  bool doTex;
  std::vector<Shape*> shapes;

};

#endif // SPRITE_SET_HPP
