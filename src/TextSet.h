#ifndef TEXTSET_H
#define TEXTSET_H

#include <vector>
#include <string>

#include "SpriteSet.h"
#include "R.h"

#include "render.h"

namespace rgl {

struct Glyph_atlas;

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
          const char** in_fontfile,
          int in_npos, 
          int* in_pos);
  ~TextSet();
  std::string getTypeName() override { return "text"; };

  // elements are glyphs once initialized
  int getElementCount(void) override;
  
  int getAttributeCount(SceneNode* subscene, AttribID attrib) override;
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result) override;
  std::string getTextAttribute(SceneNode* subscene, AttribID attrib, int index) override;
  
  void initialize() override;

private:

  std::vector<std::string> textArray;
  std::vector<std::string> family;
  std::vector<int> style;
  std::vector<double> cex;
  std::vector<std::string> fontfile; // the font filename, or ""
  std::vector<size_t> string_num;
  Scene* getScene(); 
  void set_coordinates(Glyph_atlas& atlas);
  void set_texture(Glyph_atlas& atlas);
  const char* get_family(int i) {
    return family[i % family.size()].c_str();
  }
  int get_style(int i) {
    return style[i % style.size()];
  }
  double get_cex(int i) {
    return cex[i % cex.size()];
  }
};

} // namespace rgl

#endif // TEXTSET_H

