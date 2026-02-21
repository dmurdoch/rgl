#include "TextSet.h"

#include "R.h"
#include "BBoxDeco.h"
#include "subscene.h"
#include "Texture.h"
#ifdef HAVE_FREETYPE
#include <map>
#endif

using namespace rgl;

#define PT_X(i) xy + i 
#define PT_Y(i) xy + i + n


extern "C" {
  rasterText_measure_text_func        measure_text;
  rasterText_pack_text_func           pack_text;
  rasterText_get_buffer_stride_func   get_buffer_stride;
  rasterText_draw_text_to_buffer_func draw_text_to_buffer;
}

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
   0.0),                     // offset
   measures(in_ntexts),
   placement(in_ntexts)
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
  texture_initialized = false;
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

void TextSet::do_measure_text()
{
  int n = getElementCount();
  if (!n) return;
  
  const char * texts[n];
  int done = 0; /* the count of entries done */
  text_extents_t *res = measures.data();
  int fsize = family.size();

  for (int i = 0; i < n; i++) {
    
    texts[i] = textArray[i].c_str();
    
    if (i == n-1 || 
        family[i % fsize] != family[(i+1) % fsize] ||
        style[i % fsize]  != style[(i+1) % fsize] ||
        cex[i % fsize]    != cex[(i+1) % fsize]) {
      int fnt = done % fsize;
      res = measure_text(i - done + 1,
                           texts + done,
                           family[fnt].c_str(),
                           style[fnt],
                           fontfile[fnt].c_str(),
                           20*cex[fnt],
                           res);
      done = i + 1;
    }
  }
}

static inline GLuint NextPowerOf2(GLuint in)
{
  in -= 1;
  
  in |= in >> 16;
  in |= in >> 8;
  in |= in >> 4;
  in |= in >> 2;
  in |= in >> 1;
  
  return in + 1;
}

void TextSet::do_pack_text()
{
  int n = getElementCount();
  if (!n) return;
  
  text_extents_t *m = measures.data();
  text_placement_t *xy = placement.data();
  
  std::vector<std::string> keys;

  for (int i = 0; i < n; i++)
    keys.push_back(textArray[i] + "_" +
              family[i % family.size()] + "_" + 
              std::to_string(style[i % style.size()]) + "_" + 
              fontfile[i % fontfile.size()] + "_" +
              std::to_string(cex[i % cex.size()]));
  std::vector<const char*> c_strs;
  c_strs.reserve(n);
  for (int i = 0; i < n; i++)
    c_strs.push_back(keys[i].c_str());
  texture_width = 0;
  for (int i=0; i < n; i++) {
    if (texture_width < measures[i].width) texture_width = measures[i].width;
  }
  texture_width = NextPowerOf2(texture_width);
  texture_height = pack_text(n, c_strs.data(), 
                             m, xy, texture_width);

  texture_height = NextPowerOf2(texture_height);

  placement.assign(xy, xy + n);
}

void TextSet::draw_to_texture() {
  int n = getElementCount();
  if (!n) return;
    
  const char *texts[n];

  for (int i = 0; i < n; i++)
    texts[i] = textArray[i].c_str();
  
  int stride = get_buffer_stride(texture_width);
  
  unsigned char *buffer = new unsigned char[stride*texture_height](); /* init'd to zero */
  
  int done = 0;
  text_placement_t *xy = placement.data();
  int fsize = family.size();
  for (int i = 0; i < n; i++) {
    if (i == n-1 ||
        family[i % fsize] != family[(i+1) % fsize] ||
        style[i % fsize] != style[i % fsize] ||
        cex[i % fsize] != cex[i % fsize]) {
      int fnt = done % fsize;
      draw_text_to_buffer(i - done + 1, 
                          xy + done, 
                          texts + done,
                          family[fnt].c_str(),
                          style[fnt],
                          fontfile[fnt].c_str(),
                          20*cex[fnt],
                          texture_width, 
                          texture_height, 
                          stride,
                          buffer);
      done = i + 1;
    }
  }
  
  // load buffer into texture's pixmap
  
  material.textype = Texture::ALPHA;
  material.texmode = Texture::REPLACE;
  material.texture = new Texture("", 
                            /* type= */ material.textype, 
                            /* mode= */ material.texmode,
                            /* mipmap= */ false,
                            /* minfilter= */GL_LINEAR, 
                            /* magfilter= */GL_LINEAR, 
                            /* envmap= */ false,
                            /* deleteFile= */ false);

  if ( !material.texture->isValid() ||
       !material.texture->getPixmap()->init(GRAY8, stride, texture_height, 8) ||
       !material.texture->getPixmap()->load(buffer)) {
       Rprintf("some error in the texture!\n");
    material.texture->unref();
    material.texture = NULL;
    Rf_error("Texture not loaded.");
  }
  material.alphablend = true;
  
  delete[] buffer;
}

void TextSet::initialize() {
#ifndef RGL_NO_OPENGL
  if (!texture_initialized) {
    
    // Measure the texts
    do_measure_text();
    
    do_pack_text();
    
    // Draw the texts to the texture
    draw_to_texture(); 
    
    texture_initialized = true;
  }
  
  SpriteSet::initialize();
  
  // Set the vertex and texture coordinates
  
  set_coordinates();
//  printUniforms(true);
//  printAttributes(8, true);
#endif
}

void TextSet::set_coordinates() {
#ifndef RGL_NO_OPENGL
  int n = getElementCount();
  /* There are two important boxes
   * here.  The bounding box is used
   * for the texture coordinates,
   * and the inner box is used for 
   * placement of the text.
   */
  
  // Set texcoords
  for (int i=0; i < n; i++) {
    texCoordArray[4*i].s = (placement[i].x + measures[i].x_bearing)/texture_width;
    texCoordArray[4*i + 1].s = texCoordArray[4*i].s + measures[i].width/texture_width;
    texCoordArray[4*i + 2].s = texCoordArray[4*i + 1].s;
    texCoordArray[4*i + 3].s = texCoordArray[4*i].s;
    
    texCoordArray[4*i].t = (placement[i].y + measures[i].y_bearing + measures[i].height + measures[i].ascent)/texture_height;
    texCoordArray[4*i + 1].t = texCoordArray[4*i].t;
    texCoordArray[4*i + 2].t = texCoordArray[4*i].t - measures[i].height/texture_height;
    texCoordArray[4*i + 3].t = texCoordArray[4*i + 2].t;
  }
  texCoordArray.appendToBuffer(vertexbuffer);
  texCoordArray.setAttribLocation(glLocs["aTexcoord"]);
  
  float rescale = fixedSize ? 1.8 : 0.013; /* Adjust to match rglwidget */
  // Set offsets for the corners
  for (int i=0; i < n; i++ ) {
    getAdj(i); /* The value specified by the user */
    text_extents_t m = measures[i];
    adjArray.setVertex(4*i, 
                       Vertex(
                         -adj.x*m.width*rescale,
                         (-adj.y*(m.ascent - m.descent) 
                           + m.baseline - m.ascent
                           - m.y_bearing - m.height)*rescale,
                         0) );
    adjArray.setVertex(4*i+1, 
                       Vertex(
                         adjArray[4*i].x + m.width*rescale,
                         adjArray[4*i].y,
                         adjArray[4*i].z));
    adjArray.setVertex(4*i+2, 
                       Vertex(
                         adjArray[4*i+1].x,
                         adjArray[4*i].y + m.height*rescale,
                         adjArray[4*i].z));
    adjArray.setVertex(4*i+3, 
                       Vertex(
                         adjArray[4*i].x,
                         adjArray[4*i+2].y,
                         adjArray[4*i].z));

  }
  adjArray.appendToBuffer(vertexbuffer);
  adjArray.setAttribLocation(glLocs["aOfs"]);

#endif
}