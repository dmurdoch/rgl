#ifndef BBOX_DECO_HPP
#define BBOX_DECO_HPP

#include "SceneNode.hpp"

//
// CLASS
//   BBoxDeco
//

#include "math.h"
#include "geom.hpp"

#include "RenderContext.hpp"
#include "String.hpp"
#include "Material.hpp"

enum {
  AXIS_CUSTOM,
  AXIS_LENGTH,
  AXIS_UNIT,
  AXIS_NONE
};

struct AxisInfo {
  AxisInfo();
  AxisInfo(int in_nticks, double* in_values, char** in_texts, int xlen, float xunit);
  AxisInfo(AxisInfo& from);
  ~AxisInfo();
  void draw(RenderContext* renderContext, Vertex4& v, Vertex4& dir, float marklen, String& string);

  int    mode;
  int    nticks;
  float* ticks;
  StringArray textArray;
  int    len;
  float  unit;
};


class BBoxDeco : public SceneNode 
{
public:
  BBoxDeco(Material& in_material=defaultMaterial, AxisInfo& xaxis=defaultAxis, AxisInfo& yaxis=defaultAxis, AxisInfo& zaxis=defaultAxis, float marklen=15.0, bool marklen_fract=true);
  void render(RenderContext* renderContext);
  AABox getBoundingBox(const AABox& boundingBox) const;
  float getMarkLength(const AABox& boundingBox) const;
private:
  Material material;
  AxisInfo xaxis, yaxis, zaxis;
  float marklen_value;
  bool  marklen_fract;

  static Material defaultMaterial;
  static AxisInfo defaultAxis;
};


#endif // BBOX_DECO_HPP
