#ifndef ATLAS_H
#define ATLAS_H

#include "Rinternals.h"
#include <cstdint>
#include <string>
#include <vector>

extern "C" {
void build_atlasC(void* patlas,
                  const char* text,
                  const char* family,
                  int rfont,
                  float size, int color);

  
SEXP rgl_build_atlasR(SEXP text, SEXP family, 
                  SEXP font, SEXP cex, 
                  SEXP rgb, SEXP monochrome, 
                  SEXP prevatlas);
}
namespace rgl {

struct Glyph_atlas;

struct Font_record {
  explicit Font_record(Glyph_atlas& in_atlas, void* in_font, const char* in_description);
  ~Font_record();
  void setFont(void* new_font, const char* new_description);
  void Rprint(bool verbose = true);

  Glyph_atlas* atlas;

  /* This depends on the rendering system.  For
   * PangoCairo, font would be a PangoFont*. Those
   * are both only valid during short intervals, but
   * is cached here when known to be valid, and
   * set to nullptr otherwise.
   */
  void* font;
  double height;
  unsigned int hash;
  std::string description;
};

struct Glyph_record
{
  Glyph_record(Glyph_atlas& in_atlas,
               uint32_t glyph,
               size_t fontnum,
               int color = 0xFF);
  Glyph_record(const Glyph_record& prev);
  void Rprint(bool verbose = true);

  Glyph_atlas* atlas;

  uint32_t glyph;
  size_t fontnum;
  uint32_t color; // color in rgba format.  Currently ignored.

  int x_atlas, y_atlas;
  int width, height;
  double x, y;
};

struct String_record
{
  String_record(Glyph_atlas& in_atlas,
                const char* in_text,
                size_t in_fontnum,
                int in_color = 0xFF);
  void Rprint(bool verbose = true);

  Glyph_atlas* atlas;

  std::string text;
  size_t fontnum; // This is the font that was requested
  int color;

  std::vector<size_t> glyphnum;

  /* These are shaping adjustments */

  std::vector<double> x_offset;
  std::vector<double> y_offset;
  
  double width, height;
};

/* Glyphs are rendered into the bitmap with increasing
 * x until width is reached.  last_x is the last used
 * x value.  last_y is the max of all of the y values
 * in the current row.
 */

class Texture;

struct Glyph_atlas
{
  Glyph_atlas(int in_width, int in_height, bool in_mono);
  ~Glyph_atlas();
  int width, height;
  bool mono;
  int buffer_generation;  // If this changes, all glyph positions may have changed.
  bool has_new_glyphs;    // This is set true every time new glyphs are added
  std::vector<unsigned char> buffer;
  int last_x, last_y, row_height;

  // When the first new glyph is added, these record
  // last_x and last_y, so only part of the buffer needs to
  // be copied.
  int prev_generation, prev_last_x, prev_last_y;


  /* expand the atlas to hold at least g */
  void expand_atlas(Glyph_record& g);

  std::vector<Font_record> fonts;
  std::vector<Glyph_record> glyphs;
  std::vector<String_record> strings;

  size_t find_font(void* font); /* checks and adds if necessary */
  size_t add_font(Font_record& f);

  size_t find_glyph(uint32_t glyph, size_t fontnum, int color);
  size_t add_glyph(Glyph_record& g);

  void draw_glyph_to_buffer(Glyph_record& g, int x, int y);

  size_t find_string(const char *text, size_t fontnum,
                     int color = 0xFF);
  size_t add_string(const char *new_string, size_t fontnum,
                  int color = 0xFF);

  void* getFont(const char *family, int font,
                const char *fontfile, double size);

  int getGeneration() { return buffer_generation; }

  void copy_glyphs_to_buffer(int old_width, int old_height, std::vector<unsigned char>& old_buffer);
  
  void updateTexture();
  
  void Rprint(bool verbose = true);
  void RprintBuffer(const char* title, std::vector<unsigned char>& buf, int rows = 8, int cols = 8);

  void* context;
  void initContext();
  void clearContext();
  
  int glyphCount(std::vector<size_t> stringnums);
  
  Texture* texture;
};

/* Convert pango-cairo premultiplied argb format to
 * rgba format
 */
uint32_t unmultiply(uint32_t argb);

};

#endif // ATLAS_H
