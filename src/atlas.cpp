/* This file contains generic functions that
 * could be used with any back end
 */
#include "atlas.h"
#include "R.h"          // for debugging
#include <numeric>
#include <algorithm>

using namespace rgl;

Font_record::Font_record(Glyph_atlas& in_atlas, void* in_font, const char* in_description) :
  atlas(&in_atlas),
  font(nullptr)
{
  setFont(in_font, in_description);
}

Glyph_record::Glyph_record(const Glyph_record& prev) :
  atlas(prev.atlas),
  glyph(prev.glyph),
  fontnum(prev.fontnum),
  color(prev.color),
  x_atlas(prev.x_atlas),
  y_atlas(prev.y_atlas),
  width(prev.width),
  height(prev.height),
  x(prev.x),
  y(prev.y){
  setUV();
};

void Glyph_record::setUV() {
  u[0] = u[3] = x_atlas;
  u[1] = u[2] = x_atlas + width;
  v[0] = v[1] = y_atlas;
  v[2] = v[3] = y_atlas + height;
}

String_record::String_record(Glyph_atlas& in_atlas,
              const char* in_text,
              size_t in_fontnum,
              int in_color) :
  atlas(&in_atlas),
  text(in_text),
  fontnum(in_fontnum),
  color(in_color) {}

Glyph_atlas::Glyph_atlas(int in_width, int in_height, bool in_mono) :
  width(in_width),
  height(in_height),
  mono(in_mono),
  buffer_generation(0),
  has_new_glyphs(false),
  buffer(width*height*(mono ? 1 : 4), 0),
  last_x(0),
  last_y(0),
  row_height(0),
  prev_generation(-1), // First time always refreshes
  prev_last_x(0),
  prev_last_y(0),
  context(nullptr),
  texture(nullptr)
{
}

Glyph_atlas::~Glyph_atlas() {
  clearContext();
}

size_t Glyph_atlas::find_glyph(uint32_t glyph, size_t fontnum, int color) {
  for (size_t i=0; i < glyphs.size(); i++)
    if (glyphs[i].glyph == glyph &&
        glyphs[i].fontnum  == fontnum &&
        (mono || glyphs[i].color == color))
      return i;
    Glyph_record g(*this, glyph, fontnum, color);
    return add_glyph(g);
}

size_t Glyph_atlas::add_glyph(Glyph_record& g) {
  /* FIXME:  if the new row height is bigger than
   * the old one, it may be more efficient to go to
   * a new line (wasting space at the end of the current
   * one) instead of increasing the row height (wasting
   * space above all the other glyphs)
   */
  if (!has_new_glyphs) {
    prev_last_x = last_x;
    prev_last_y = last_y;
  }
  if (g.width + 2 > width ||
      (last_x + g.width + 2 > width &&
      last_y + row_height + g.height + 2 > height) ||
      last_y + g.height + 2 > height)
    expand_atlas(g);

  if (last_x + g.width + 2 > width) {
    last_x = 0;
    last_y += row_height + 2;
    row_height = g.height;
  } else
    row_height = std::max(row_height, g.height);

  draw_glyph_to_buffer(g, last_x + 1, last_y + 1);
  g.x_atlas = last_x + 1;
  g.y_atlas = last_y + 1;
  last_x += g.width + 2;
  has_new_glyphs = true;
  glyphs.push_back(g);
  return glyphs.size()-1;
}

void Glyph_atlas::expand_atlas(Glyph_record& g) {
  clearContext();
  int new_width = width, new_height = height;
  while (g.width + 2 > new_width ||
         g.height + 2 > new_height) {
    new_width *= 2;
    new_height *= 2;
  }
  if ((last_x + g.width + 2 > new_width &&
      last_y + row_height + g.height + 2 > new_height) ||
      last_y + g.height + 2 > new_height) {
    new_width *= 2;
    new_height *= 2;
  }
  if (new_width > width) {
    std::vector<unsigned char> old_buffer(buffer);
    int old_width = width, old_height = height;
    buffer.assign(new_width*new_height*(mono ? 1 : 4), 0);
    width = new_width;
    height = new_height;
    last_x = last_y = row_height = 0;
    buffer_generation++;
    copy_glyphs_to_buffer(old_width, old_height, old_buffer);
  }
  width = new_width;
  height = new_height;
}

void Glyph_atlas::copy_glyphs_to_buffer(int old_width,
                                        int old_height,
                                        std::vector<unsigned char>& old_buffer) {
  int pixelsize = mono ? 1 : 4;

  /* sort by height so they pack better.
   We don't want to move any glyphs since
  the string records refer to them, but we
  can render them in a new order. */

  std::vector<size_t> indices(glyphs.size());
  std::iota(indices.begin(), indices.end(), 0);
  std::sort(indices.begin(), indices.end(),
            [&](size_t i, size_t j){
              return glyphs[i].height < glyphs[j].height;
            });
  for (int i=0; i < glyphs.size(); i++) {
    Glyph_record& g = glyphs[indices[i]];
    if (g.width + 2 > width ||
        (last_x + g.width + 2 > width &&
        last_y + g.height + 2 > height))
      Rf_error("Cannot copy glyphs:  not enough space!");

    if (last_x + g.width + 2 > width) {
      last_x = 0;
      last_y += row_height + 2;
      row_height = g.height;
    } else
      row_height = std::max(row_height, g.height);

    for (int j=0; j<g.height; j++) {
      int old_start = (old_width*(g.y_atlas + j) + g.x_atlas)*pixelsize,
        new_start = (width*(last_y + 1 + j) + last_x + 1)*pixelsize;
      std::copy(old_buffer.begin() + old_start,
                old_buffer.begin() + old_start + g.width*pixelsize,
                buffer.begin() + new_start);
    }
    g.x_atlas = last_x + 1;
    g.y_atlas = last_y + 1;
    g.setUV();
    last_x += g.width + 2;
  }
  has_new_glyphs = true;
}

