#include "Texture.hpp"

#include "pixmap.h"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Texture
//

Texture::Texture(const char* filename, Type in_type, bool in_mipmap, unsigned int in_minfilter, unsigned int in_magfilter)
{
  texName = 0;
  pixmap = new Pixmap();
  type   = in_type;
  mipmap = in_mipmap;
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

  if ( !pixmap->load(filename) ) {
    delete pixmap;
    pixmap = NULL;
  }
}

Texture::~Texture()
{
  if (texName) {
    glDeleteTextures(1, &texName);
  }
  if (pixmap)
    delete pixmap;
}


bool Texture::isValid() const 
{
  return (pixmap) ? true : false;
}

unsigned int texsize(unsigned int s)
{
  return 1U << msb(s-1);
}

#include "lib.hpp"

static void printGluErrorMessage(GLint error) 
{
  const GLubyte* gluError;
  char buf[256];        
  gluError = gluErrorString (error);
  sprintf(buf, "GLU Library Error : %s", (const char*) gluError);
  lib::printMessage(buf);
}

void Texture::beginUse(RenderContext* renderContext)
{
  if (!texName) {
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
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

    switch(pixmap->typeID)
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
        lib::printMessage(buf);
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
    
    delete pixmap;
    pixmap = NULL;
  }

  glPushAttrib(GL_TEXTURE_BIT|GL_ENABLE_BIT|GL_CURRENT_BIT);

  glEnable(GL_TEXTURE_2D);
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glBindTexture(GL_TEXTURE_2D, texName);

  if (type == ALPHA) {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  }
}

void Texture::endUse(RenderContext* renderContext)
{
  glPopAttrib();
}


