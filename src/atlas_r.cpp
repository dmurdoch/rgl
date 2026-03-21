/* This file contains functions related to the R
 * interface
 */

#include "atlas.h"
#include "Rinternals.h"
#include <numeric>

using namespace rgl;

void Font_record::Rprint(bool verbose) {
  Rprintf("%8x %s\n", hash, description.c_str());
}

void Glyph_record::Rprint(bool verbose) {
  Rprintf("%5zu %5x %5d %5d %5d %5d %5.2f %5.2f %8x\n",
          fontnum, glyph, x_atlas, y_atlas,
          width, height,
          x, y, color);
}

void String_record::Rprint(bool verbose) {
  Rprintf("\"%s\"\n  Font %zu\n  Glyph     xofs     yofs\n", text.c_str(), fontnum);
  if (verbose)
    for (int i=0; i < glyphnum.size(); i++)
      Rprintf("  %5zu %8.2f %8.2f\n",
              glyphnum[i], x_offset[i], y_offset[i]);
}

void Glyph_atlas::Rprint(bool verbose) {
  Rprintf("Atlas with %zu fonts %zu glyphs %zu strings, buffer %d x %d\n", fonts.size(), glyphs.size(), strings.size(), width, height);
  if (verbose) {
    Rprintf("Fonts:\n");
    for (size_t i=0; i<fonts.size(); i++) {
      Rprintf("%5zu ", i);
      fonts[i].Rprint();
    }
    Rprintf("Glyphs:\n  num  font glyph x_atl y_atl width    ht     x     y\n");
    for (size_t i=0; i<glyphs.size(); i++) {
      Rprintf("%5zu ", i);
      glyphs[i].Rprint();
    }
    Rprintf("Strings:\n");
    for (size_t i=0; i < strings.size(); i++) {
      Rprintf("%zu: ", i);
      strings[i].Rprint();
    }
  }
}

void Glyph_atlas::RprintBuffer(const char* title, std::vector<unsigned char>& buf, int rows, int cols) {
  Rprintf("%s\n", title);
  int pixelsize = mono ? 1 : 4;
  for (int i=0; i < std::min(height, rows); i++) {
    Rprintf("%4d:", i*width*pixelsize);
    for (int j=0; j < std::min(width, cols); j++) {
      for (int k=0; k < pixelsize; k++)
        Rprintf("%02x", buf[i*width*pixelsize + j*pixelsize + k]);
      Rprintf(" ");
    }
    if (cols < width)
      Rprintf("...");
    Rprintf("\n");
  }
  if (rows < height)
    Rprintf("     ...\n");
}

SEXP get_buffer(Glyph_atlas& atlas);
SEXP get_fonts (Glyph_atlas& atlas);
SEXP get_glyphs(Glyph_atlas& atlas);
SEXP get_fragments(Glyph_atlas& atlas);
SEXP get_strings(Glyph_atlas& atlas);
SEXP get_atlas(Glyph_atlas& atlas);

void set_buffer(Glyph_atlas& atlas, SEXP buffer);
void set_fonts (Glyph_atlas& atlas, SEXP fonts);
void set_glyphs(Glyph_atlas& atlas, SEXP glyphs);
void set_fragments(Glyph_atlas& atlas, SEXP fragments);
void set_strings(Glyph_atlas& atlas, SEXP strings);
void set_atlas(Glyph_atlas& atlas, SEXP in_atlas);

SEXP get_buffer(Glyph_atlas& atlas) {
  SEXP result;
  int w = atlas.width, h = atlas.height,
    pixelsize = atlas.mono ? 1 : 4,
    stride = w*pixelsize;
  if (atlas.mono)
    PROTECT(result = Rf_allocMatrix(INTSXP, w, h));
  else
    PROTECT(result = Rf_alloc3DArray(INTSXP, 4, h, w));
  int *res = INTEGER(result);
  int k = 0;
  for (int i = 0; i < h; i++) {
    if (atlas.mono) {
      unsigned char *row = atlas.buffer.data() + i*stride;
      for (int j = 0; j < w; j++)
        res[k++] = row[j];
    } else {
      uint32_t *row32 = (uint32_t*)(atlas.buffer.data() + i*stride);
      for (int j = 0; j < w; j++) {
        uint32_t* argb = row32 + j;
        uint8_t a = (*argb) >> 24;
        if (a == 0) {
          res[k++] = 0;
          res[k++] = 0;
          res[k++] = 0;
          res[k++] = 0;
        } else {
          uint8_t
          r = ((((*argb) >> 16) & 0xFF) * 255) / a,
            g = ((((*argb) >> 8) & 0xFF) * 255) / a,
            b = (((*argb) & 0xFF) * 255) / a;
          res[k++] = r;
          res[k++] = g;
          res[k++] = b;
          res[k++] = a;
        }
      }
    }
  }
  UNPROTECT(1);
  return result;
}

void set_buffer(Glyph_atlas& atlas, SEXP buffer) {
  bool mono = atlas.mono;
  SEXP dim = Rf_getAttrib(buffer, R_DimSymbol);
  int w, h;
  if (mono) {
    w = INTEGER_ELT(dim, 0);
    h = INTEGER_ELT(dim, 1);
  } else {
    w = INTEGER_ELT(dim, 2);
    h = INTEGER_ELT(dim, 1);
  }
  atlas.width = w;
  atlas.height = h;
  atlas.buffer.clear();
  int pixelsize = mono ? 1 : 4,
    n = w*h*pixelsize;
  atlas.buffer.reserve(n);
  int* value = INTEGER(buffer);
  if (atlas.mono) {
    for (int i=0; i < n; i++)
      atlas.buffer.push_back(*value++);
  } else {
    for (int i=0; i < w*h; i++) {
      uint8_t r = *value++,
              g = *value++,
              b = *value++,
              a = *value++;
      atlas.buffer.push_back(a*b/255);
      atlas.buffer.push_back(a*g/255);
      atlas.buffer.push_back(a*r/255);
      atlas.buffer.push_back(a);
    }
  }
}

SEXP get_fonts(Glyph_atlas& atlas) {
  SEXP result;
  PROTECT(result = Rf_allocVector(STRSXP, atlas.fonts.size()));
  for (int i=0; i < atlas.fonts.size(); i++) {
    Font_record f = atlas.fonts[i];
    SET_STRING_ELT(result, i, Rf_mkChar(f.description.c_str()));
  }
  UNPROTECT(1);
  return result;
}

void set_fonts(Glyph_atlas& atlas, SEXP fonts) {
  atlas.fonts.clear();
  for (int i=0; i < Rf_length(fonts); i++) {
    atlas.fonts.push_back(Font_record(atlas, nullptr, CHAR(STRING_ELT(fonts, i))));
  }
}

SEXP get_glyphs(Glyph_atlas& atlas) {
  SEXP result;
  const char *nms[] = {"fontnum", "glyphid", "x_atlas", "y_atlas", "width", "height",
                       "x", "y", "color", ""};
  PROTECT(result = Rf_mkNamed(VECSXP, nms));
  for (int i=0; i<9; i++)
    SET_VECTOR_ELT(result, i, Rf_allocVector((i == 6 || i == 7) ? REALSXP : INTSXP, atlas.glyphs.size()));
  Rf_classgets(VECTOR_ELT(result, 8), Rf_mkString("hexmode"));
  for (int i=0; i < atlas.glyphs.size(); i++) {
    Glyph_record& g = atlas.glyphs[i];
    SET_INTEGER_ELT(VECTOR_ELT(result, 0), i, g.fontnum + 1);
    SET_INTEGER_ELT(VECTOR_ELT(result, 1), i, g.glyph);
    SET_INTEGER_ELT(VECTOR_ELT(result, 2), i, g.x_atlas);
    SET_INTEGER_ELT(VECTOR_ELT(result, 3), i, g.y_atlas);
    SET_INTEGER_ELT(VECTOR_ELT(result, 4), i, g.width);
    SET_INTEGER_ELT(VECTOR_ELT(result, 5), i, g.height);
    SET_REAL_ELT(VECTOR_ELT(result, 6), i, g.x);
    SET_REAL_ELT(VECTOR_ELT(result, 7), i, g.y);
    SET_INTEGER_ELT(VECTOR_ELT(result, 8), i, g.color);
  }
  Rf_classgets(result, Rf_mkString("data.frame"));
  SEXP rownames = PROTECT(Rf_allocVector(INTSXP, 2));
  SET_INTEGER_ELT(rownames, 0, NA_INTEGER);
  SET_INTEGER_ELT(rownames, 1, -atlas.glyphs.size());
  Rf_setAttrib(result, R_RowNamesSymbol, rownames);
  UNPROTECT(2);
  return result;
}

void set_glyphs(Glyph_atlas& atlas, SEXP glyphs) {
  atlas.glyphs.clear();

  SEXP fontnum = VECTOR_ELT(glyphs, 0),
    glyphid = VECTOR_ELT(glyphs, 1),
    x_atlas = VECTOR_ELT(glyphs, 2),
    y_atlas = VECTOR_ELT(glyphs, 3),
    width =   VECTOR_ELT(glyphs, 4),
    height =  VECTOR_ELT(glyphs, 5),
    x =       VECTOR_ELT(glyphs, 6),
    y =       VECTOR_ELT(glyphs, 7),
    color =   VECTOR_ELT(glyphs, 8);
  for (int i=0; i < Rf_length(fontnum); i++) {
    Glyph_record g(atlas,
                   INTEGER_ELT(glyphid, i),
                   INTEGER_ELT(fontnum, i) - 1,
                   INTEGER_ELT(color, i));
    g.x_atlas = INTEGER_ELT(x_atlas, i);
    g.y_atlas = INTEGER_ELT(y_atlas, i);
    g.width =   INTEGER_ELT(width, i);
    g.height =  INTEGER_ELT(height, i);
    g.x =       REAL_ELT(x, i);
    g.y =       REAL_ELT(y, i);
    atlas.glyphs.push_back(g);
  }
}


SEXP get_fragments(Glyph_atlas& atlas) {
  SEXP result;
  const char *nms[] = {"stringnum", "glyphnum", "x_offset", "y_offset", ""};
  PROTECT(result = Rf_mkNamed(VECSXP, nms));
  int size = 0;
  for (int i=0; i < atlas.strings.size(); i++)
    size += atlas.strings[i].glyphnum.size();
  SET_VECTOR_ELT(result, 0, Rf_allocVector(INTSXP, size));
  SET_VECTOR_ELT(result, 1, Rf_allocVector(INTSXP, size));
  SET_VECTOR_ELT(result, 2, Rf_allocVector(REALSXP, size));
  SET_VECTOR_ELT(result, 3, Rf_allocVector(REALSXP, size));
  int j=0;
  for (int i=0; i < atlas.strings.size(); i++) {
    String_record& s = atlas.strings[i];
    for (int k=0; k < s.glyphnum.size(); k++) {
      SET_INTEGER_ELT(VECTOR_ELT(result, 0), j, i+1);
      SET_INTEGER_ELT(VECTOR_ELT(result, 1), j, s.glyphnum[k]+1);
      SET_REAL_ELT(VECTOR_ELT(result, 2), j, (double)s.x_offset[k]);
      SET_REAL_ELT(VECTOR_ELT(result, 3), j, (double)s.y_offset[k]);
      j++;
    }
  }
  Rf_classgets(result, Rf_mkString("data.frame"));
  SEXP rownames = PROTECT(Rf_allocVector(INTSXP, 2));
  SET_INTEGER_ELT(rownames, 0, NA_INTEGER);
  SET_INTEGER_ELT(rownames, 1, -size);
  Rf_setAttrib(result, R_RowNamesSymbol, rownames);
  UNPROTECT(2);
  return result;
}

void set_fragments(Glyph_atlas& atlas, SEXP fragments) {
  for (int i=0; i < atlas.strings.size(); i++) {
    String_record& s = atlas.strings[i];
    s.glyphnum.clear();
    s.x_offset.clear();
    s.y_offset.clear();
  }
  SEXP stringnum = VECTOR_ELT(fragments, 0),
       glyphnum = VECTOR_ELT(fragments, 1),
       x_offset = VECTOR_ELT(fragments, 2),
       y_offset = VECTOR_ELT(fragments, 3);
  for (int i=0; i < Rf_length(stringnum); i++) {
    String_record& s = atlas.strings[INTEGER_ELT(stringnum, i) - 1];
    s.glyphnum.push_back(INTEGER_ELT(glyphnum, i) - 1);
    s.x_offset.push_back(REAL_ELT(x_offset, i));
    s.y_offset.push_back(REAL_ELT(y_offset, i));
  }
}

SEXP get_strings(Glyph_atlas& atlas) {
  SEXP result;
  const char *nms[] = { "text", "fontnum", "color", ""};
  PROTECT(result = Rf_mkNamed(VECSXP, nms));
  int size = atlas.strings.size();
  SET_VECTOR_ELT(result, 0, Rf_allocVector(STRSXP, size));
  SET_VECTOR_ELT(result, 1, Rf_allocVector(INTSXP, size));
  SET_VECTOR_ELT(result, 2, Rf_allocVector(INTSXP, size));
  Rf_classgets(VECTOR_ELT(result, 2), Rf_mkString("hexmode"));
  for (int i=0; i < atlas.strings.size(); i++) {
    String_record& s = atlas.strings[i];
    SET_STRING_ELT(VECTOR_ELT(result, 0), i, Rf_mkChar(s.text.c_str()));
    SET_INTEGER_ELT(VECTOR_ELT(result, 1), i, s.fontnum + 1);
    SET_INTEGER_ELT(VECTOR_ELT(result, 2), i, s.color);
  }
  Rf_classgets(result, Rf_mkString("data.frame"));
  SEXP rownames = PROTECT(Rf_allocVector(INTSXP, 2));
  SET_INTEGER_ELT(rownames, 0, NA_INTEGER);
  SET_INTEGER_ELT(rownames, 1, -size);
  Rf_setAttrib(result, R_RowNamesSymbol, rownames);
  UNPROTECT(2);
  return result;
}

void set_strings(Glyph_atlas& atlas, SEXP strings) {
  atlas.strings.clear();

  SEXP text = VECTOR_ELT(strings, 0),
    fontnum = VECTOR_ELT(strings, 1),
    color =   VECTOR_ELT(strings, 2);
  for (int i=0; i < Rf_length(text); i++) {
    atlas.strings.push_back(
     String_record(atlas,
                   CHAR(STRING_ELT(text, i)),
                   INTEGER_ELT(fontnum, i) - 1,
                   INTEGER_ELT(color, i)));
  }
}

SEXP get_atlas(Glyph_atlas& atlas) {
  SEXP result;
  const char *nms[] = { "buffer", "fonts",
                        "glyphs", "fragments", "strings",
                        "monochrome", "position",
                        ""};
  PROTECT(result = Rf_mkNamed(VECSXP, nms));
  Rf_classgets(result, Rf_mkString("glyph_atlas"));
  SET_VECTOR_ELT(result, 0, get_buffer(atlas));
  SET_VECTOR_ELT(result, 1, get_fonts(atlas));
  SET_VECTOR_ELT(result, 2, get_glyphs(atlas));
  SET_VECTOR_ELT(result, 3, get_fragments(atlas));
  SET_VECTOR_ELT(result, 4, get_strings(atlas));
  SET_VECTOR_ELT(result, 5, Rf_ScalarLogical(atlas.mono));
  const char *posnms[] = { "last_x", "last_y",
                           "row_height",
                           ""};
  SET_VECTOR_ELT(result, 6, Rf_mkNamed(INTSXP, posnms));

  SET_INTEGER_ELT(VECTOR_ELT(result, 6), 0, atlas.last_x);
  SET_INTEGER_ELT(VECTOR_ELT(result, 6), 1, atlas.last_y);
  SET_INTEGER_ELT(VECTOR_ELT(result, 6), 2, atlas.row_height);

  UNPROTECT(1);
  return result;
}

void set_atlas(Glyph_atlas& atlas, SEXP Ratlas) {

  atlas.clearContext();

  SEXP buffer = VECTOR_ELT(Ratlas, 0),
    fonts = VECTOR_ELT(Ratlas, 1),
    glyphs = VECTOR_ELT(Ratlas, 2),
    fragments = VECTOR_ELT(Ratlas, 3),
    strings = VECTOR_ELT(Ratlas, 4),
    monochrome = VECTOR_ELT(Ratlas, 5),
    position = VECTOR_ELT(Ratlas, 6);

  atlas.mono = LOGICAL_ELT(monochrome, 0);
  atlas.buffer_generation++;
  atlas.has_new_glyphs = true;
  set_buffer(atlas, buffer);
  atlas.last_x = INTEGER_ELT(position, 0);
  atlas.last_y = INTEGER_ELT(position, 1);
  atlas.row_height = INTEGER_ELT(position, 2);
  atlas.prev_last_x = 0;
  atlas.prev_last_y = 0;
  set_fonts(atlas, fonts);
  set_glyphs(atlas, glyphs);
  set_strings(atlas, strings);
  set_fragments(atlas, fragments);
}


extern "C" {

  SEXP build_atlasR(SEXP text, SEXP family, SEXP font, SEXP cex, SEXP rgb, SEXP monochrome, SEXP prevatlas);

  SEXP build_atlasR(SEXP text, SEXP family, SEXP font, SEXP cex, SEXP rgb, SEXP monochrome, SEXP prevatlas){
    Glyph_atlas atlas(32, 32, LOGICAL_ELT(monochrome, 0));
    if (!Rf_isNull(prevatlas)) {
      set_atlas(atlas, prevatlas);
    }

    for (int i=0; i < Rf_length(text); i++) {
      int col = (INTEGER_ELT(rgb, 4*i) << 24) +
        (INTEGER_ELT(rgb, 4*i+1) << 16) +
        (INTEGER_ELT(rgb, 4*i+2) << 8) +
        INTEGER_ELT(rgb, 4*i+3);
      build_atlasC(&atlas, CHAR(STRING_ELT(text, i)),
                  CHAR(STRING_ELT(family, i)),
                  INTEGER_ELT(font, i),
                  20*REAL_ELT(cex, i),
                  col);
    }
    atlas.clearContext();
    return get_atlas(atlas);
  }
}
