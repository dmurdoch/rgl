#include "TextSet.h"

#include "R.h"
#include "BBoxDeco.h"
#include "subscene.h"
#include "Texture.h"
#include "DeviceManager.h"
#include "Device.h"

#ifdef HAVE_FREETYPE
#include <map>
#endif

using namespace rgl;

#define PT_X(i) xy + i 
#define PT_Y(i) xy + i + n


//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   TextSet
//
// INTERNAL TEXTS STORAGE
//   texts are copied to a buffer without null byte
//   a separate length buffer holds string lengths in order
//

TextSet::TextSet(Material& in_material, 
                 int in_ntexts, 
                 char** in_texts, 
                 double *in_center, 
                 double* in_adj,
                 int in_ignoreExtent, 
                 int in_nfonts,
                 const char** in_family,
                 int* in_style,
                 double* in_cex,
                 const char** in_fontfile,
                 int in_npos,
                 int* in_pos)
 : SpriteSet(in_material, in_ntexts, in_center, 
   in_nfonts, in_cex,       // nsize, size
   in_ignoreExtent, 
   0, NULL,                 // count, shapelist
   0, NULL,                 // nshapelens, shapelens
   NULL,                    // userMatrix
   true, false,             // fixedSize, rotating
   NULL,                    // scene,
   in_adj,
   in_npos, in_pos,
   0.0)                    // offset
{
  material.lit = false;
  material.colorPerVertex(true, in_ntexts);

  // init arrays

  for (int i = 0; i < in_ntexts; i++) {
  	textArray.push_back(in_texts[i]);
  }

  family.clear();
  style.clear();
  cex.clear();
  fontfile.clear();
  for (int i = 0; i < in_nfonts; i++) {
    family.push_back(in_family[i]);
    style.push_back(in_style[i]);
    cex.push_back(in_cex[i]);
    fontfile.push_back(in_fontfile[i]);
  }
#ifdef HAVE_FREETYPE  
  blended = true;
#endif  
}

TextSet::~TextSet()
{
}

/* Count glyphs if initialized, else strings */
int TextSet::getElementCount(void) {
  if (is_initialized())
    return posArray.size() >> 2;
  else
    return SpriteSet::getElementCount();
}

int TextSet::getAttributeCount(SceneNode* subscene, AttribID attrib) 
{
  switch (attrib) {
    case FAMILY: 
    case FONT:
    case CEX: return static_cast<int>(family.size());
    case TEXTS: return static_cast<int>(textArray.size());
  }
  return SpriteSet::getAttributeCount(subscene, attrib);
}

void TextSet::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
  int fsize = family.size();
  if (first + count < n) n = first + count;
  if (first < n) {
    switch(attrib) {
    case CEX:
      while (first < n) 
        *result++ = cex[first++ % fsize];
      return;
    case FONT:
      while (first < n)
      	*result++ = style[first++ % fsize];
      return;
    }
    SpriteSet::getAttribute(subscene, attrib, first, count, result);
  }
}

std::string TextSet::getTextAttribute(SceneNode* subscene, AttribID attrib, int index)
{
  int n = getAttributeCount(subscene, attrib);
  int fsize = family.size();
  if (index < n) {
    switch (attrib) {
    case TEXTS: 
      return textArray[index];
    case FAMILY:
      std::string fam = family[index % fsize];
      return fam;
    }
  }
  return SpriteSet::getTextAttribute(subscene, attrib, index);
}

void TextSet::set_texture(Glyph_atlas& atlas) {
  int n = getElementCount();
  if (!n) return;

  atlas.updateTexture();
  material.alphablend = true;
}

void TextSet::initialize() {
#ifndef RGL_NO_OPENGL
  getScene();
  Glyph_atlas& atlas = scene->mono_atlas;

  string_num.clear();
  for (int i=0; i < textArray.size(); i++) {
    void *font = atlas.getFont(get_family(i), get_style(i),
                                 nullptr, get_cex(i)*20.0);
    size_t fontnum = atlas.find_font(font);
    string_num.push_back(atlas.find_string(textArray[i].c_str(), fontnum));
  }
  
  material.textype = Texture::ALPHA;
  material.texmode = Texture::REPLACE;
  material.alphablend = true;
  
  SpriteSet::initialize();

  set_coordinates(atlas);
  atlas.updateTexture();
  
  if (glLocs_has_key("uSampler") &&
      glLocs_has_key("aTexcoord")) {
    atlas.texture->setSamplerLocation(glLocs["uSampler"]);
  }
  material.texture = atlas.texture;
  
  posArray.appendToBuffer(vertexbuffer);
  posArray.setAttribLocation(glLocs["aPos"]);
  adjArray.appendToBuffer(vertexbuffer);
  adjArray.setAttribLocation(glLocs["aOfs"]);
  texCoordArray.appendToBuffer(vertexbuffer);
  texCoordArray.setAttribLocation(glLocs["aTexcoord"]);
  
  if (material.useColorArray) 
    colArray.appendToBuffer(vertexbuffer, colArray.getLength());

#endif
}

Scene* TextSet::getScene() {
  if (!scene) {
    extern DeviceManager* deviceManager;
    Device* device;
    if (deviceManager && (device = deviceManager->getCurrentDevice()))
      scene = device->getScene();
    else
      Rf_error("Can't determine scene.");
  }
  return scene;
}

void TextSet::set_coordinates(Glyph_atlas& atlas) {
#ifndef RGL_NO_OPENGL
  int n = string_num.size();
  // Count the glyphs
  int n_glyphs = 0;
  for (int i=0; i < n; i++) {
    String_record& s = atlas.strings[string_num[i]];
    n_glyphs += s.glyphnum.size();
  }
  
  float rescale = fixedSize ? 1.8 : 0.013; /* Adjust to match rglwidget */
  float texture_width = atlas.width;
  
  posArray.alloc(4*n_glyphs);
  texCoordArray.alloc(4*n_glyphs);
  adjArray.alloc(4*n_glyphs);
  indices.resize(6*n_glyphs);
  int ncolor = material.colors.getLength();
  if (material.useColorArray)
    colArray.resize(4*n_glyphs);
  int g = 0, h = 0;
  for (int i=0; i < n; i++) {
    String_record& s = atlas.strings[string_num[i]];
    getAdj(i); /* The value specified by the user */
    Vertex& v = vertex.get(i);
    Color c = material.colors.getColor(i % ncolor);
    for (int j=0; j < s.glyphnum.size(); j++) {
      for (int k=0; k < 4; k++) {
        posArray.setVertex(g + k, v);
        if (ncolor > 1)
          colArray.setColor(g + k, c);
      }
      
      Glyph_record& glyph = atlas.glyphs[s.glyphnum[j]];

      // Set texcoords
      texCoordArray[g].s = (glyph.x_atlas)/texture_width;
      texCoordArray[g + 1].s = texCoordArray[g].s + glyph.width/texture_width;
      texCoordArray[g + 2].s = texCoordArray[g + 1].s;
      texCoordArray[g + 3].s = texCoordArray[g].s;

      double texture_height = atlas.height;
      texCoordArray[g].t = (glyph.y_atlas + glyph.height)/texture_height;
      texCoordArray[g + 1].t = texCoordArray[g].t;
      texCoordArray[g + 2].t = texCoordArray[g].t - glyph.height/texture_height;
      texCoordArray[g + 3].t = texCoordArray[g + 2].t;
      
      // Set adjustments
      adjArray.setVertex(g,
        Vertex((-adj.x*s.width + s.x_offset[j] + glyph.x)*rescale,
                (-adj.y*s.height + s.y_offset[j] - glyph.y - glyph.height)*rescale,
                0) );      
      adjArray.setVertex(g + 1,
        Vertex(adjArray[g].x + glyph.width*rescale,
               adjArray[g].y,
               0));
      adjArray.setVertex(g + 2,
        Vertex(adjArray[g + 1].x,
               adjArray[g].y + glyph.height*rescale,
               0));
      adjArray.setVertex(g + 3,
        Vertex(adjArray[g].x,
               adjArray[g + 2].y,
               0));
      
      indices[h] = g;
      indices[h + 1] = g + 1;
      indices[h + 2] = g + 2;
      indices[h + 3] = g;
      indices[h + 4] = g + 2;
      indices[h + 5] = g + 3;
      g += 4;
      h += 6;
    }
  }
  texCoordArray.appendToBuffer(vertexbuffer);
  texCoordArray.setAttribLocation(glLocs["aTexcoord"]);
  adjArray.appendToBuffer(vertexbuffer);
  adjArray.setAttribLocation(glLocs["aOfs"]);

#endif
}
