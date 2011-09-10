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

  Texture(const char* in_filename
   , Type type
   , bool mipmap
   , unsigned int minfilter
   , unsigned int magfilter
   , bool envmap);
  virtual ~Texture();
  bool isValid() const;
  void beginUse(RenderContext* renderContext);
  void endUse(RenderContext* renderContext);
  bool is_envmap() const { return envmap; }
  bool hasAlpha() const { return (type == ALPHA || type == LUMINANCE_ALPHA || type == RGBA ); }
  void getParameters(Type *out_type, bool *out_mipmap, unsigned int *out_minfilter, 
                     unsigned int *out_magfilter, bool *out_envmap, int bufsize, char *out_filename) ;
private:
  void init(RenderContext* renderContext);
  Pixmap* pixmap;
  GLuint  texName;
  Type    type;
  bool    mipmap;
  GLenum  minfilter;
  GLenum  magfilter;
  bool    envmap;
  char*   filename;
};

#endif // TEXTURE_HPP
