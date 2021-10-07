#ifndef MATERIAL_H
#define MATERIAL_H

#include "Color.h"
#include "Texture.h"
#include "RenderContext.h"
#include <string>

namespace rgl {

//
// STRUCT
//   Material
//

class Material {
public:

  enum PolygonMode { 
    FILL_FACE=1, 
    LINE_FACE, 
    POINT_FACE, 
    CULL_FACE 
  };

  Material( Color bg, Color fg );

  void setup();
  // called when complete

  void beginUse(RenderContext* renderContext);
  void endUse(RenderContext* renderContext);
  void useColor(int index);
  void colorPerVertex(bool enable, int numVertices=0);
  bool isTransparent() const { return alphablend; }

  Color        ambient;
  Color        specular;
  Color        emission;
  float        shininess;
  float        size;          // point size
  float        lwd;           // line width
  float        polygon_offset_factor;
  float        polygon_offset_units;
  ColorArray   colors;        // color or if lit, represents diffuse color
  Ref<Texture> texture;
  PolygonMode  front;
  PolygonMode  back;
  bool         alphablend;
  bool         smooth;
  bool         lit;
  bool         fog;
  bool         useColorArray;
  bool         point_antialias;
  bool         line_antialias;
  bool         depth_mask;
  int	       depth_test;  // 0=GL_NEVER, 1=GL_LESS, etc.
  Texture::Type textype;
  bool	       mipmap;
  unsigned int minfilter;
  unsigned int magfilter;
  bool         envmap;
  bool         polygon_offset;
  int          marginCoord;
  int          edge[3];
  bool         floating;
  string       tag;
  
  double       glVersion;
};

} // namespace rgl

#endif // MATERIAL_H
