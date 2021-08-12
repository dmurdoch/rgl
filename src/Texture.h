#ifndef TEXTURE_H
#define TEXTURE_H

#include "pixmap.h"
#include "types.h"
#include "String.h"

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

  Texture(int nfilenames
   , char** in_filenames
   , Type type
   , bool mipmap
   , unsigned int minfilter
   , unsigned int magfilter
   , bool envmap);
  virtual ~Texture();
  bool isValid();
  void beginUse(RenderContext* renderContext);
  void endUse(RenderContext* renderContext);
  bool is_envmap() const { return envmap; }
  bool hasAlpha() const { return (type == ALPHA || type == LUMINANCE_ALPHA || type == RGBA ); }
  void getParameters(Type *out_type, bool *out_mipmap, unsigned int *out_minfilter, 
                     unsigned int *out_magfilter, bool *out_envmap, int *out_nfilenames) ;
  String getFilename(int i);
  Pixmap* getPixmap(int i) { return pixmaps.get(i); }
private:
  void init(RenderContext* renderContext);
  ARRAY<Pixmap*> pixmaps; /* one per filename after init */
  GLuint  texName;
  Type    type;
  bool    mipmap;
  GLenum  minfilter;
  GLenum  magfilter;
  bool    envmap;
  StringArray  filenames;
};

} // namespace rgl

#endif // TEXTURE_H
