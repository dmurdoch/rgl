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

TextSet* TextSet::create(Material& in_material, 
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
                 int* in_pos,
                 bool mono) {
  Scene* scene = getScene();
  Glyph_atlas& atlas = mono ? scene->mono_atlas : scene->color_atlas;
  std::vector<size_t> string_nums;
  std::vector<double> vertices;
  int nglyphs = 0;
  for (int i=0; i < in_ntexts; i++) {
    int j = i % in_nfonts;
    void *font = atlas.getFont(in_family[j],
                               in_style[j], 
                               nullptr, 
                               in_cex[j]*20.0);
    size_t fontnum = atlas.find_font(font);
    if (mono)
      string_nums.push_back(atlas.find_string(in_texts[i], fontnum));
    else {
      Color col = in_material.colors.getColor(i);
      uint32_t rgba = (col.getRedub() << 24) + 
        (col.getGreenub() << 16) +
        (col.getBlueub() << 8) +
        col.getAlphaub();
      string_nums.push_back(atlas.find_string(in_texts[i], fontnum, rgba));
    }
    int n = atlas.strings[string_nums.back()].glyphnum.size();
    nglyphs += n;
    for (int g=0; g < n; g++) {
      vertices.push_back(in_center[3*i]);
      vertices.push_back(in_center[3*i+1]);
      vertices.push_back(in_center[3*i+2]);
    }
  }
  atlas.updateTexture();
  
  Material material = in_material;
  material.lit = false;  
  material.colorPerVertex(true, 4*nglyphs);
  material.alphablend = true; 
  material.textype = mono ? Texture::ALPHA : Texture::RGBA;
  material.texmode = Texture::REPLACE;
  material.setTexture("uSampler", atlas.texture);
  material.depth_test = 3; /* LEQUAL */
  
  return new TextSet(material, in_ntexts, in_texts,
                 vertices.data(), in_adj, in_ignoreExtent,
                 in_nfonts, in_family, in_style, 
                 in_cex, in_fontfile, 
                 in_npos, in_pos,
                 atlas, string_nums);
}

TextSet::TextSet(Material& in_material, 
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
                 int in_npos, int* in_pos,                 
                 Glyph_atlas& in_atlas,
                 std::vector<size_t>& in_stringnum)
  : SpriteSet(in_material, 
    in_atlas.glyphCount(in_stringnum),
    in_center, 
    in_atlas.glyphCount(in_stringnum), in_cex,       // nsize, size
    in_ignoreExtent, 
    0, NULL,                 // count, shapelist
    0, NULL,                 // nshapelens, shapelens
    NULL,                    // userMatrix
    true, false,             // fixedSize, rotating
    NULL,                    // scene,
    in_adj,
    in_npos, in_pos,
    0.0),
    string_num(in_stringnum),
    atlas(in_atlas),
    texture_generation(-1) {
  
  // init arrays
  if (in_ntexts != in_stringnum.size())
    Rf_error("ntexts not consistent!");
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
}                   // offset

TextSet::~TextSet()
{
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

void TextSet::set_texture() {
  int n = getElementCount();
  if (!n) return;

  atlas.updateTexture();
  material.alphablend = true;
}

bool TextSet::is_initialized() {
  return texture_generation == atlas.buffer_generation && SpriteSet::is_initialized();
}

void TextSet::initialize() {
#ifndef RGL_NO_OPENGL
  SpriteSet::initialize();

  set_coordinates();
  atlas.updateTexture();
  texture_generation = atlas.buffer_generation;
  
  if (glLocs_has_key("uSampler") &&
      glLocs_has_key("aTexcoord")) {
    atlas.texture->setSamplerLocation(glLocs["uSampler"]);
  }
  
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
  Scene* scene = nullptr;
  extern DeviceManager* deviceManager;
  Device* device;
  if (deviceManager && (device = deviceManager->getCurrentDevice()))
    scene = device->getScene();
  else
    Rf_error("Can't determine scene.");
  return scene;
}

void TextSet::set_coordinates() {
#ifndef RGL_NO_OPENGL
  int n = string_num.size();
  // Count the glyphs
  int n_glyphs = atlas.glyphCount(string_num);
  float rescale = fixedSize ? 1.55 : 0.013; /* Adjust to match rglwidget */
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
    Color c = material.colors.getColor(i % ncolor);
    for (int j=0; j < s.glyphnum.size(); j++) {
      Vertex& v = vertex.get(g);
      for (int k=0; k < 4; k++) {
        posArray.setVertex(4*g + k, v);
        if (ncolor > 1)
          colArray.setColor(4*g + k, c);
      }
      
      Glyph_record& glyph = atlas.glyphs[s.glyphnum[j]];

      // Set texcoords
      texCoordArray[4*g].s = (glyph.x_atlas)/texture_width;
      texCoordArray[4*g + 1].s = texCoordArray[4*g].s + glyph.width/texture_width;
      texCoordArray[4*g + 2].s = texCoordArray[4*g + 1].s;
      texCoordArray[4*g + 3].s = texCoordArray[4*g].s;

      double texture_height = atlas.height;
      texCoordArray[4*g].t = (glyph.y_atlas + glyph.height)/texture_height;
      texCoordArray[4*g + 1].t = texCoordArray[4*g].t;
      texCoordArray[4*g + 2].t = texCoordArray[4*g].t - glyph.height/texture_height;
      texCoordArray[4*g + 3].t = texCoordArray[4*g + 2].t;
      
      // Set adjustments
      adjArray.setVertex(4*g,
        Vertex((-adj.x*s.width + s.x_offset[j] + glyph.x)*rescale,
                (-adj.y*s.height + s.y_offset[j] - glyph.y - glyph.height)*rescale,
                0) );      
      adjArray.setVertex(4*g + 1,
        Vertex(adjArray[4*g].x + glyph.width*rescale,
               adjArray[4*g].y,
               0));
      adjArray.setVertex(4*g + 2,
        Vertex(adjArray[4*g + 1].x,
               adjArray[4*g].y + glyph.height*rescale,
               0));
      adjArray.setVertex(4*g + 3,
        Vertex(adjArray[4*g].x,
               adjArray[4*g + 2].y,
               0));
      
      indices[h] = 4*g;
      indices[h + 1] = 4*g + 1;
      indices[h + 2] = 4*g + 2;
      indices[h + 3] = 4*g;
      indices[h + 4] = 4*g + 2;
      indices[h + 5] = 4*g + 3;
      g++;
      h += 6;
    }
  }
  texCoordArray.appendToBuffer(vertexbuffer);
  texCoordArray.setAttribLocation(glLocs["aTexcoord"]);
  adjArray.appendToBuffer(vertexbuffer);
  adjArray.setAttribLocation(glLocs["aOfs"]);

#endif
}
