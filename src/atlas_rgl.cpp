/* This file contains functions related to the rgl
 * interface
 */

#include "atlas.h"
#include "Texture.h"
#include "R.h"


using namespace rgl;

void Glyph_atlas::updateTexture() {
#ifndef RGL_NO_OPENGL
  if (!texture) {
    texture = new Texture("",
                          /* type= */ mono ? Texture::ALPHA : Texture::RGBA,
                          /* mode= */ Texture::REPLACE,
                          /* mipmap= */ false,
                          /* minfilter= */GL_LINEAR,
                          /* magfilter= */GL_LINEAR,
                          /* envmap= */ false,
                          /* deleteFile= */ false);
    texture->ref();
  }
  if (buffer_generation > prev_generation ||
      last_x != prev_last_x ||
      last_y != prev_last_y) {
    bool okay = texture->isValid();
    okay = okay && texture->getPixmap()->init(mono ? GRAY8 : RGBA32, width, height, 8);
    if (mono)
      okay = okay && texture->getPixmap()->load(buffer.data());
    else {
      uint32_t* view = reinterpret_cast<uint32_t*>(buffer.data());
      size_t view_size = buffer.size() / sizeof(uint32_t);
      std::vector<uint32_t> rgba;
      for (int i=0; i < view_size; i++) {
        rgba.push_back(rgl::unmultiply(view[i]));
      }
      unsigned char* rgbabytes = reinterpret_cast<unsigned char*>(rgba.data());
      okay = okay && texture->getPixmap()->load(rgbabytes);
    }
    if (!okay) {
      Rprintf("some error in the text atlas texture!\n");
      texture = NULL;
      Rf_error("texture not loaded");
    }
    prev_generation = buffer_generation;
    prev_last_x = last_x;
    prev_last_y = last_y;
    
    texture->notifyChanged();
  }
#endif
}
