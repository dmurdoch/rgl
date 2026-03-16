#ifndef ATLASRGL_H
#define ATLASRGL_H

#include <string>
#include <vector>

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
  
  void setUV();
  float u[4], v[4];
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
};


struct Glyph_atlas
{
  Glyph_atlas(int in_width, int in_height, bool in_mono);
  ~Glyph_atlas();
  
  
  /* expand the atlas to hold at least g */
  void expand_atlas(Glyph_record& g);
  
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

  int getGeneration();

  void copy_glyphs_to_buffer(int old_width, int old_height, std::vector<unsigned char>& old_buffer);
  void Rprint(bool verbose = true);
  void RprintBuffer(const char* title, std::vector<unsigned char>& buf, int rows = 8, int cols = 8);
  
  void initContext();
  void clearContext();
  
  void* rasterText_atlas;
};

#endif // ATLASRGL_H