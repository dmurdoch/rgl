/* This file contains functions related to the rgl
 * interface
 */

#include "atlas.h"
#include "Texture.h"
#include "R.h"


using namespace rgl;

void Glyph_atlas::updateTexture() {
  if (!texture) {
    texture = new Texture("",
                          /* type= */ Texture::ALPHA,
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
    int stride = width*(mono ? 1 : 4);
    bool okay = texture->isValid();
    okay = okay && texture->getPixmap()->init(GRAY8, stride, height, 8);
    okay = okay && texture->getPixmap()->load(buffer.data());
    if (!okay) {
      Rprintf("some error in the text atlas texture!\n");
      texture = NULL;
      Rf_error("texture not loaded");
    }
    prev_generation = buffer_generation;
    prev_last_x = last_x;
    prev_last_y = last_y;
  }
}
