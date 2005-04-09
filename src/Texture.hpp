#ifndef TEXTURE_HPP
#define TEXTURE_HPP

#include "types.h"

//
// CLASS
//   Texture
//

class RenderContext;
class Pixmap;

#include "opengl.hpp"

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

#endif // TEXTURE_HPP
