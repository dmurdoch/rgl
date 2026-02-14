#ifndef TEXTSET_H
#define TEXTSET_H

#include <vector>
#include <string>

#include "SpriteSet.h"


#include "render.h"

namespace rgl {

typedef struct text_extents
{
  double height, width,
  x_advance, x_bearing,
  y_advance, y_bearing,
  ascent, descent,
  baseline;
} text_extents_t;

typedef struct text_placement
{
  double x, y;
} text_placement_t;

typedef int (*rasterText_version_func) (void);

typedef text_extents_t* (*rasterText_measure_text_func)(
        int n, const char *text[], /* must be UTF-8! */
        const char *family,
        int font,
        const char *fontfile,
        double size,
        text_extents_t *result);

typedef int (*rasterText_pack_text_func)(int n, const char * texts[], 
             text_extents_t *measures, text_placement_t *placement, int width);

typedef int (*rasterText_get_buffer_stride_func)(int width);

typedef void (*rasterText_draw_text_to_buffer_func)(int n,
              const text_placement_t *xy,
              const char *text[],
              const char *family, int font,
              const char *fontfile, double size,
              int width, int height, int stride,
              unsigned char *buffer);

//
// TEXTSET
//

class TextSet : public SpriteSet {
public:
  TextSet(Material& in_material, 
          int in_ntexts, 
          char** in_texts, 
          double *in_center, 
          double *in_adj,
          int in_ignoreExtent,
          int in_nfonts,
          const char** in_family,
          int* in_style,
          double* in_cex,
          int in_npos, 
          int* in_pos);
  ~TextSet();
  std::string getTypeName() override { return "text"; };

  int getAttributeCount(SceneNode* subscene, AttribID attrib) override;
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result) override;
  std::string getTextAttribute(SceneNode* subscene, AttribID attrib, int index) override;
  
  void initialize() override;

private:

  bool texture_initialized;
  std::vector<std::string> textArray;
  std::vector<std::string> family;
  std::vector<int> style;
  std::vector<double> cex;
  std::vector<std::string> fontname; // the font filename, or ""
  std::vector<text_extents_t> measures;
  std::vector<text_placement_t> placement;
  GLuint texture_width, texture_height;
  
  void do_measure_text();
  void do_pack_text();
  void draw_to_texture();
  void set_coordinates();
};

} // namespace rgl

#endif // TEXTSET_H

