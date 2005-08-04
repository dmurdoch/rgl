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
  SpriteSet(Material& in_material, int nvertex, double* vertex, int nsize, double* size);
  ~SpriteSet();

  /**
   * overload
   **/
  virtual void render(RenderContext* renderContext);
  
  /**
   * overload
   **/
  virtual void renderZSort(RenderContext* renderContext);

  /**
   * overload
   **/
  virtual void draw(RenderContext* renderContext);

};

#endif // SPRITE_SET_HPP
