/*********************************************
 Pango-specific functions are in this file
 **********************************************/
#ifndef RGL_NO_OPENGL

#include "atlas.h"
#include "R.h"                 // for debugging
#include <fontconfig/fontconfig.h>
#include <pango/pangocairo.h>  // Main PangoCairo integration
#include <pango/pango.h>       // Pango layout and font handling
#include <cairo.h>             // Base Cairo surface and context functions
#include <numeric>

extern "C" {
  void build_atlasC(void* patlas,
                   const char* text,
                   const char* family,
                   int rfont,
                   float size, int color) {
    auto atlas = static_cast<rgl::Glyph_atlas*>(patlas);
    // this adds a ref to font
    void *font = atlas->getFont(family, rfont, nullptr, size);
    size_t fontnum = atlas->find_font(font);
    // this removes the ref.  We can assume the
    // one we found had a ref added.
    g_object_unref(font);
    atlas->find_string(text, fontnum, color);
  }

}


using namespace rgl;

PangoFontDescription * getFontDesc(
    const char *family,
    int font,
    const char *fontfile,
    double size
)
{
  char *family_name = NULL;
  if (!fontfile || !strlen(fontfile))
    family_name = strdup(family);
  else {
    FcConfigAppFontAddFile(FcConfigGetCurrent(), (const FcChar8 *)fontfile);

    FcPattern *pattern = FcFreeTypeQuery((const FcChar8 *)fontfile, 0, NULL, NULL);
    if (pattern) {
      FcChar8 *fc_family;
      if (FcPatternGetString(pattern, FC_FAMILY, 0, &fc_family) == FcResultMatch) {
        family_name = strdup((char *)fc_family);
      }
      FcPatternDestroy(pattern);
    }
    if (!family_name)
      family_name = strdup("sans");
  }
  PangoFontDescription *desc = pango_font_description_new();
  pango_font_description_set_family(desc, family_name);
  pango_font_description_set_style(desc, font < 3 ? PANGO_STYLE_NORMAL : PANGO_STYLE_ITALIC);
  pango_font_description_set_weight(desc, font % 2 == 1 ? PANGO_WEIGHT_NORMAL : PANGO_WEIGHT_BOLD);
  pango_font_description_set_size(desc, size*PANGO_SCALE);
  free(family_name);
  return desc;
}

PangoFont* getPangoFont(Font_record& font);

struct Pango_Cairo_Context {
  PangoContext* pcontext;
  cairo_surface_t* csurface;
  cairo_t* ccontext;
};

Pango_Cairo_Context* getContexts(Glyph_atlas& atlas);

void clearContexts(Glyph_atlas& atlas);

PangoContext* getPangoContext(Glyph_atlas& atlas);

cairo_surface_t* getCairoSurface(Glyph_atlas& atlas);

cairo_t* getCairoContext(Glyph_atlas& atlas);

PangoFontDescription* getPangoFontDesc(Font_record& font);

PangoFont* getPangoFont(Font_record& font);

void Glyph_atlas::initContext() {
  if (context)
    clearContext();
  Pango_Cairo_Context* contexts = new Pango_Cairo_Context{nullptr, nullptr, nullptr};
  context = static_cast<void*>(contexts);
}

void Glyph_atlas::clearContext() {
  clearContexts(*this);
  delete getContexts(*this);
  context = nullptr;
}

Pango_Cairo_Context* getContexts(Glyph_atlas& atlas) {
  if (!atlas.context) {
    atlas.initContext();
  }
  return static_cast<Pango_Cairo_Context*>(atlas.context);
}

void clearContexts(Glyph_atlas& atlas) {
  for (int i=0; i < atlas.fonts.size(); i++) {
    if (atlas.fonts[i].font) {
      g_object_unref(atlas.fonts[i].font);
      atlas.fonts[i].font = nullptr;
    }
  }
  auto contexts = getContexts(atlas);
  if (contexts->pcontext) {
    g_object_unref(contexts->pcontext);
    contexts->pcontext = nullptr;
  }
  if (contexts->ccontext) {
    cairo_destroy(contexts->ccontext);
    contexts->ccontext = nullptr;
  }
  if (contexts->csurface) {
    cairo_surface_destroy(contexts->csurface);
    contexts->csurface = nullptr;
  }
}

void Font_record::setFont(void* new_font, const char* new_description) {
  if (font) {
    g_object_unref(font);
    font = nullptr;
  }
  if (new_font) {
    PangoFont* pfont = static_cast<PangoFont*>(new_font);
    PangoFontDescription* desc = pango_font_describe(pfont);
    hash = pango_font_description_hash(desc);
    char * descstring = pango_font_description_to_string(desc);
    description = descstring;
    g_free(static_cast<gpointer>(descstring));
    g_object_ref(new_font);
    font = new_font;
  } else if (new_description) {
    PangoFontDescription* desc = pango_font_description_from_string(new_description);
    hash = pango_font_description_hash(desc);
    description = new_description;
  }
}

void* Glyph_atlas::getFont(const char *family, int font,
                           const char *fontfile, double size) {
  PangoFontDescription* desc = getFontDesc(
    family, font, fontfile, size);

  PangoContext* context = getPangoContext(*this);
  PangoFont* pfont = pango_context_load_font(context, desc);
  return static_cast<void*>(pfont);

}

cairo_surface_t* getCairoSurface(Glyph_atlas& atlas) {
  auto contexts = getContexts(atlas);
  if (!contexts->csurface) {
    int stride = atlas.width*(atlas.mono ? 1 : 4);
    contexts->csurface = cairo_image_surface_create_for_data(
      atlas.buffer.data(),
      atlas.mono ? CAIRO_FORMAT_A8 : CAIRO_FORMAT_ARGB32,
      atlas.width,
      atlas.height,
      stride
    );
  }
  return contexts->csurface;
}

cairo_t* getCairoContext(Glyph_atlas& atlas) {
  auto contexts = getContexts(atlas);
  if (!contexts->ccontext) {
    auto surface = getCairoSurface(atlas);
    contexts->ccontext = cairo_create(surface);
  }
  return contexts->ccontext;
}

PangoContext* getPangoContext(Glyph_atlas& atlas) {
  auto contexts = getContexts(atlas);
  if (!contexts->pcontext) {
    auto ccontext = getCairoContext(atlas);

    contexts->pcontext = pango_cairo_create_context(ccontext);
  }
  return contexts->pcontext;
}

PangoFont* getPangoFont(Font_record& font) {

  if (font.font) return static_cast<PangoFont*>(font.font);

  PangoContext* context = getPangoContext(*(font.atlas));

  PangoFontDescription* desc = getPangoFontDesc(font);

  PangoFont* result = pango_context_load_font(context, desc);

  pango_font_description_free(desc);

  font.font = (void *)result;

  return result;
}

PangoFontDescription* getPangoFontDesc(Font_record& font) {
  return pango_font_description_from_string(font.description.c_str());
}

Font_record::~Font_record() {
}

Glyph_record::Glyph_record(Glyph_atlas& in_atlas,
                           uint32_t in_glyph, size_t in_font, int in_color) :
  atlas(&in_atlas),
  glyph(in_glyph),
  fontnum(in_font),
  color(in_color),
  x_atlas(0),
  y_atlas(0){
  PangoRectangle ink_rect;
  pango_font_get_glyph_extents(getPangoFont(atlas->fonts[fontnum]), glyph, &ink_rect, NULL);
  width = PANGO_PIXELS_CEIL(ink_rect.width);
  height = PANGO_PIXELS_CEIL(ink_rect.height);

  x = ink_rect.x/PANGO_SCALE;
  y = ink_rect.y/PANGO_SCALE;

  // Draw to x_atlas + Harfbuzz x_offset + x;
};

/* NB:  this function
 * will add to the ref count if we're keeping
 * it, but not if it is found. */
size_t Glyph_atlas::find_font(void* font) {
  for (size_t i=0; i < fonts.size(); i++)
    if (font == fonts[i].font)
      return i;

    PangoFont* pfont = static_cast<PangoFont*>(font);
    PangoFontDescription* desc = pango_font_describe(pfont);
    unsigned int hash = pango_font_description_hash(desc);
    char * descstring;
    for (size_t i = 0; i < fonts.size(); i++)
      if (hash == fonts[i].hash) {
        descstring = pango_font_description_to_string(desc);
        if (fonts[i].description == descstring) {
          pango_font_description_free(desc);
          g_free(static_cast<gpointer>(descstring));
          fonts[i].font = font;
          g_object_ref(pfont);
          return i;
        }
        g_free(static_cast<gpointer>(descstring));
      }
      PangoContext* context = getPangoContext(*this);
      PangoFontMetrics* metrics = pango_context_get_metrics(context, desc, NULL);
      int ascent = pango_font_metrics_get_ascent(metrics);
      pango_font_metrics_unref(metrics);
      pango_font_description_free(desc);
      Font_record f(*this, font, nullptr);
      f.height = ascent / (double)PANGO_SCALE;
      fonts.push_back(f);
      return fonts.size()-1;
}

size_t Glyph_atlas::find_string(const char *text, size_t fontnum, int color) {
  for (size_t i=0; i < strings.size(); i++)
    if (strings[i].text == text &&
        strings[i].fontnum == fontnum &&
        (mono || strings[i].color == color))
      return i;
    return add_string(text, fontnum, color);
}

size_t Glyph_atlas::add_string(const char *text, size_t fontnum,
                               int color) {

  String_record string(*this, text, fontnum,
                       color);
  float x = 0.0, y = 0.0; /* current position */

PangoContext *context = getPangoContext(*this);

PangoFontDescription* desc = getPangoFontDesc(fonts[fontnum]);

pango_context_set_font_description(context, desc);

GList *items = pango_itemize(context, text, 0, strlen(text), NULL, NULL);

for (GList *l = items; l != NULL; l = l->next) {
  PangoItem *item = (PangoItem *)l->data;
  PangoFont *pfont = item->analysis.font;
  int fontnum = find_font((void *) pfont);

  hb_font_t *hb_font = pango_font_get_hb_font(pfont);

  // Prepare HarfBuzz Buffer
  hb_buffer_t *hb_buffer = hb_buffer_create();
  hb_buffer_add_utf8(hb_buffer, text, -1, item->offset, item->length);
  hb_buffer_guess_segment_properties(hb_buffer);

  // Shape!
  hb_shape(hb_font, hb_buffer, NULL, 0);

  // Extract Glyph Data
  unsigned int glyph_count;
  hb_glyph_info_t *hb_info = hb_buffer_get_glyph_infos(hb_buffer, &glyph_count);
  hb_glyph_position_t *hb_pos = hb_buffer_get_glyph_positions(hb_buffer, &glyph_count);
  for (size_t i = 0; i < glyph_count; i++) {
    size_t glyphnum = find_glyph(hb_info[i].codepoint, fontnum, color);

    string.glyphnum.push_back(glyphnum);

    string.x_offset.push_back((x + hb_pos[i].x_offset)/PANGO_SCALE);
    string.y_offset.push_back((y + hb_pos[i].y_offset)/PANGO_SCALE);

    x += hb_pos[i].x_advance;
    y += hb_pos[i].y_advance;
  }

  // Clean up per item

  hb_buffer_destroy(hb_buffer);
  pango_item_free(item);
}
g_list_free(items);

string.width = x/PANGO_SCALE;
string.height = fonts[string.fontnum].height;

strings.push_back(string);
return strings.size()-1;
}

void Glyph_atlas::draw_glyph_to_buffer(Glyph_record& g, int x, int y) {

  cairo_t* cr = getCairoContext(*this);

  PangoGlyphInfo pg;
  pg.glyph = g.glyph;
  pg.geometry.width = 0;
  pg.geometry.x_offset = 0;
  pg.geometry.y_offset = 0;

  PangoGlyphString* gs = pango_glyph_string_new();
  pango_glyph_string_set_size(gs, 1);
  gs->glyphs[0] = pg;

  double x_pos = -g.x;
  double y_pos = -g.y;

  if (mono)
    cairo_set_source_rgba(cr, 1.0, 1.0, 1.0, 1.0); // Set "Alpha" to 1.0
  else {
    double red = (g.color >> 24)/255.0,
      green = (g.color >> 16 & 0xFF)/255.0,
      blue = (g.color >> 8 & 0xFF)/255.0,
      alpha = (g.color & 0xFF)/255.0;
    cairo_set_source_rgba(cr, red, green, blue, alpha);
  }
  cairo_move_to(cr, x + x_pos, y + y_pos);
  PangoFont* font = getPangoFont(g.atlas->fonts[g.fontnum]);
  pango_cairo_show_glyph_string(cr, font, gs);

  pango_glyph_string_free(gs);
}
#endif