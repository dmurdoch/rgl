#ifndef TEXTURE_H
#define TEXTURE_H

#include <string>
#include "pixmap.h"
#include "types.h"

namespace rgl {

//
// CLASS
//   Texture
//

class RenderContext;
class Pixmap;

#include "opengl.h"

class Texture : public AutoDestroy
{
public:
 
  enum Type { ALPHA = 1 , LUMINANCE, LUMINANCE_ALPHA, RGB, RGBA };
  enum Mode { REPLACE = 0, MODULATE = 1, DECAL = 2, BLEND = 3, ADD = 4};

  Texture(const char* in_filename
   , Type type
   , Mode mode
   , bool mipmap
   , unsigned int minfilter
   , unsigned int magfilter
   , bool envmap
   , bool deleteFile);
  virtual ~Texture();
  bool isValid() const;
  void beginUse(RenderContext* renderContext);
  void endUse(RenderContext* renderContext);
  bool is_envmap() const { return envmap; }
  bool hasAlpha() const { return (type == ALPHA || type == LUMINANCE_ALPHA || type == RGBA ); }
  void getParameters(Type *out_type, Mode *out_mode, bool *out_mipmap, 
                     unsigned int *out_minfilter, 
                     unsigned int *out_magfilter, 
                     std::string *out_filename);
  Pixmap* getPixmap() const { return pixmap; }
#ifndef RGL_NO_OPENGL
  void setSamplerLocation(GLint loc);
#endif
  
private:
  void init(RenderContext* renderContext);
  Pixmap* pixmap;
  GLuint  texName;
  Type    type;
  Mode    mode;
  bool    mipmap;
  GLenum  minfilter;
  GLenum  magfilter;
  bool    envmap;
  std::string   filename;
#ifndef RGL_NO_OPENGL
  GLint   internalMode;
  GLint   location;
#endif
  bool    deleteFile;
};

} // namespace rgl

#endif // TEXTURE_H
