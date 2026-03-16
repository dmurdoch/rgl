#include "atlasrgl.h"
#include <rasterText.h>

Glyph_atlas::Glyph_atlas(int in_width, int in_height, bool in_mono) {
  rasterText_atlas = Glyph_atlas_constructor(in_width, in_height, in_mono);
}

size_t Glyph_atlas::find_string(const char *text, size_t fontnum,
                         int color) {
  return Glyph_atlas_find_string(rasterText_atlas, text, fontnum, color);
}

void* Glyph_atlas::getFont(const char *family, int font,
                           const char *fontfile, double size) {
  return Glyph_atlas_getFont(rasterText_atlas, family, font,
                             fontfile, size);
}

size_t Glyph_atlas::find_font(void* font) {
  return Glyph_atlas_find_font(rasterText_atlas, font);
}

int Glyph_atlas::getGeneration() {
  return Glyph_atlas_getGeneration(rasterText_atlas);
}

Glyph_atlas::~Glyph_atlas() {
  Glyph_atlas_destructor(rasterText_atlas);
}