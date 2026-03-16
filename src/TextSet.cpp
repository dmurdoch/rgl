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
  texture_generation = -1;
}

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


void TextSet::initialize() {
#ifndef RGL_NO_OPENGL
  getScene();
  Glyph_atlas& atlas = scene->mono_atlas;
  if (texture_generation < atlas.getGeneration()) {
    string_num.clear();
    for (int i=0; i < textArray.size(); i++) {
      void *font = atlas.getFont(family[i].c_str(), style[i],
                                 nullptr, cex[i]*20.0);
      size_t fontnum = atlas.find_font(font);
      string_num.push_back(atlas.find_string(textArray[i].c_str(), fontnum));
    }
    
    texture_generation = atlas.getGeneration();
  }
  
  SpriteSet::initialize();
  
//  printUniforms(true);
//  printAttributes(8, true);
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