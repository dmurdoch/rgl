
#include "Texture.h"
#include "pixmap.h"
#include "config.h"
#include "platform.h"
#include "RenderContext.h"
#include "R.h"

using namespace std;
using namespace rgl;

static bool isPowerOfTwo(int x) {
  return (x & (x - 1)) == 0;
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Texture
//

Texture::Texture(
  int nfilenames
, char** in_filenames
, Type in_type
, bool in_mipmap
, unsigned int in_minfilter
, unsigned int in_magfilter
, bool in_envmap) :
  pixmaps(nfilenames),
  filenames(nfilenames, in_filenames)
{
  texName = 0;
  for (int i=0; i<nfilenames; i++)
    pixmaps.get(i) = new Pixmap();
  type   = in_type;
  mipmap = in_mipmap;
  envmap = in_envmap;
  magfilter = (in_magfilter) ? GL_LINEAR : GL_NEAREST;
  if (mipmap) {
    switch(in_minfilter) {
      case 0:
        minfilter = GL_NEAREST;
        break;
      case 1:
        minfilter = GL_LINEAR;
        break;
      case 2:
        minfilter = GL_NEAREST_MIPMAP_NEAREST;
        break;
      case 3:
        minfilter = GL_NEAREST_MIPMAP_LINEAR;
        break;
      case 4:
        minfilter = GL_LINEAR_MIPMAP_NEAREST;
        break;
      default:
        minfilter = GL_LINEAR_MIPMAP_LINEAR;
        break;
    }
  } else {
    switch(in_minfilter) {
      case 0:
        minfilter = GL_NEAREST;
        break;
      default:
        minfilter = GL_LINEAR;
        break;
    }
  }
  
  if (!filenames.size() || !pixmaps.get(0)->load(filenames[0].text) ) {
    delete pixmaps.get(0);
  }
  
  if (pixmaps.get(0) && filenames.size() > 1) {
    Pixmap *pixmap = pixmaps.get(0);
    int i, width = pixmap->width, height = pixmap->height;
    if (!isPowerOfTwo(width) || !isPowerOfTwo(height))
      error("Initial image must have power-of-two sizes");
    for (i = 1; i < filenames.size(); i++) {
      pixmap = pixmaps.get(i);
      if (!pixmap->load(filenames[i].text))
        error("Pixmap failed to load.");
      if (pixmap->width != getMax(width/2, 1) ||
          pixmap->height != getMax(height/2, 1))
        error("Pixmaps in texture must follow mipmap sizing sequence.");
      width = pixmap->width;
      height = pixmap->height;
    }
    if (i != filenames.size())
      error("%d filenames given, %d files used.", filenames.size(), i);
  }
}

Texture::~Texture()
{
#ifndef RGL_NO_OPENGL
  if (texName) {
    glDeleteTextures(1, &texName);
  }
#endif
  for (int i=0; i < pixmaps.size(); i++)
    if (pixmaps.get(i))
      delete pixmaps.get(i);
}


bool Texture::isValid() 
{
  return pixmaps.get(0) ? true : false;
}

void Texture::getParameters(Type *out_type, bool *out_mipmap, 
                            unsigned int *out_minfilter, unsigned int *out_magfilter, 
                            bool *out_envmap, int *out_nfilenames)
{
  *out_type = type;
  *out_mipmap = mipmap;
  switch(minfilter) {
      case GL_NEAREST:
        *out_minfilter = 0;
        break;
      case GL_LINEAR:
        *out_minfilter = 1;      
        break;
      case GL_NEAREST_MIPMAP_NEAREST:
        *out_minfilter = 2;
        break;
      case GL_NEAREST_MIPMAP_LINEAR:
        *out_minfilter = 3;
        break;
      case GL_LINEAR_MIPMAP_NEAREST:
        *out_minfilter = 4;
        break;
      case GL_LINEAR_MIPMAP_LINEAR:
        *out_minfilter = 5;
        break;
      default:
        *out_minfilter = 6;
        break;
  }
  *out_magfilter = (magfilter == GL_LINEAR) ? 1 : 0;
  *out_envmap = envmap;
  *out_nfilenames = filenames.size();
}

String Texture::getFilename(int i)
{
  if (i < filenames.size())
    return filenames[i];
  else
    return String(0, nullptr);
}


#ifndef MODERN_OPENGL
#ifndef RGL_NO_OPENGL
static unsigned int texsize(unsigned int s)
{
  return 1U << msb(s-1);
}

#include "lib.h"

static void printGluErrorMessage(GLint error) 
{
  const GLubyte* gluError;
  char buf[256];        
  gluError = gluErrorString (error);
  sprintf(buf, "GLU Library Error : %s", (const char*) gluError);
  printMessage(buf);
}
#endif
#endif

void Texture::init(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  glGenTextures(1, &texName);
  glBindTexture(GL_TEXTURE_2D, texName);
  if (pixmaps.size() < 2) {
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  } else{
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, pixmaps.size() - 1);
  }
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minfilter);                                                       
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magfilter);

  GLint  internalFormat = 0;
  GLenum format = 0;
  GLint  ualign;
  unsigned int bytesperpixel = 0;

  switch(type)
  {
  case ALPHA:
    internalFormat = GL_ALPHA;
    break;
  case LUMINANCE:
    internalFormat = GL_LUMINANCE;
    break;
  case LUMINANCE_ALPHA:
    internalFormat = GL_LUMINANCE_ALPHA;
    break;
  case RGB:
    internalFormat = GL_RGB;
    break;
  case RGBA:
    internalFormat = GL_RGBA;
    break;
  }

  switch(pixmaps.get(0)->typeID)
  {
  case GRAY8:
    ualign = 1;
    bytesperpixel = 1;
    switch(internalFormat)
    {
    case GL_LUMINANCE:
      format = GL_LUMINANCE;
      break;
    case GL_ALPHA:
      format = GL_ALPHA;
      break;
    case GL_LUMINANCE_ALPHA:
      format = GL_LUMINANCE;
      break;
    }
    break;
  case RGB24:
    ualign = 1;
    format = GL_RGB;
    bytesperpixel = 3;
    break;
  case RGB32:
    ualign = 2;
    format = GL_RGB;
    bytesperpixel = 4;
    break;
  case RGBA32:
    ualign = 2;
    format = GL_RGBA;
    bytesperpixel = 4;
    break;
  default: // INVALID
    return;
  }

  glPixelStorei(GL_UNPACK_ALIGNMENT, ualign);
  GLenum gl_type = GL_UNSIGNED_BYTE;
  
  GLint glTexSize;
  glGetIntegerv(GL_MAX_TEXTURE_SIZE,  &glTexSize );        
  
  Pixmap* pixmap;
  if (mipmap && pixmaps.size() > 1) {
    for (int i=0; i < pixmaps.size(); i++) {
      pixmap = pixmaps.get(i);
      glTexImage2D(GL_TEXTURE_2D, i, internalFormat, pixmap->width, pixmap->height, 0, format, gl_type, pixmap->data);
    }
  } else {
    #ifdef MODERN_OPENGL
    pixmap = pixmaps.get(0);
    glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, pixmap->width, pixmap->height, 0, format, gl_type , pixmap->data);
    if (mipmap)
      glGenerateMipmap(GL_TEXTURE_2D);
    #else
    unsigned int maxSize = static_cast<unsigned int>(glTexSize);
    if (mipmap) {                  
      int gluError = gluBuild2DMipmaps(GL_TEXTURE_2D, internalFormat, pixmap->width, pixmap->height, format, gl_type, pixmap->data);    
      if (gluError)
        printGluErrorMessage(gluError);
    } else {
      unsigned int width  = texsize(pixmap->width);
      unsigned int height = texsize(pixmap->height);
    
      if ( (width > maxSize) || (height > maxSize) ) {
        char buf[256];
        sprintf(buf, "GL Library : Maximum texture size of %dx%d exceeded.\n(Perhaps enabling mipmapping could help.)", maxSize,maxSize);
        printMessage(buf);
      } else if ( (pixmap->width != width) || ( pixmap->height != height) ) {
        char* data = new char[width * height * bytesperpixel];
        int gluError = gluScaleImage(format, pixmap->width, pixmap->height, gl_type, pixmap->data, width, height, gl_type, data);
        if (gluError)
          printGluErrorMessage(gluError);
        glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, width, height, 0, format, gl_type , data);
        delete[] data;
      } else {
        glTexImage2D(GL_TEXTURE_2D, 0, internalFormat, pixmap->width, pixmap->height, 0, format, gl_type , pixmap->data);
      }
    }
    #endif /* not MODERN_OPENGL */
  }
  
  if (envmap) {
    glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    glEnable(GL_TEXTURE_GEN_S);
    glEnable(GL_TEXTURE_GEN_T);
  }
#endif
}

void Texture::beginUse(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  if (!texName) {
    init(renderContext);
  }
  glPushAttrib(GL_TEXTURE_BIT|GL_ENABLE_BIT|GL_CURRENT_BIT);
  

  glEnable(GL_TEXTURE_2D);
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glBindTexture(GL_TEXTURE_2D, texName);

  if (type == ALPHA) {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
  }
#endif
}

void Texture::endUse(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  glPopAttrib();
#endif
}


