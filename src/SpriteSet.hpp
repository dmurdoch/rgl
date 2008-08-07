#ifndef SPRITE_SET_HPP
#define SPRITE_SET_HPP

#include "Shape.hpp"

//
// SPRITESET
//

class SpriteSet : public Shape {
private:
  ARRAY<Vertex> vertex;
  ARRAY<float>  size;

public:
  SpriteSet(Material& in_material, int nvertex, double* vertex, int nsize, double* size, int in_ignoreExtent);
  ~SpriteSet();

  /**
   * overload
   **/
  virtual void render(RenderContext* renderContext);
  
  virtual void getShapeName(char* buffer, int buflen) { strncpy(buffer, "sprites", buflen); };
  
  virtual int getElementCount(void);
  
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
  
private:
  Matrix4x4 m;
  bool doTex;

};

#endif // SPRITE_SET_HPP
