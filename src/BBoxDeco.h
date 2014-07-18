#ifndef BBOX_DECO_H
#define BBOX_DECO_H

#include "SceneNode.h"

//
// CLASS
//   BBoxDeco
//

#include "rglmath.h"
#include "geom.h"

#include "RenderContext.h"
#include "String.h"
#include "Material.h"

namespace rgl {

enum {
  AXIS_CUSTOM,
  AXIS_LENGTH,
  AXIS_UNIT,
  AXIS_PRETTY,
  AXIS_NONE
};

struct AxisInfo {
  AxisInfo();
  AxisInfo(int in_nticks, double* in_values, char** in_texts, int xlen, float xunit);
  AxisInfo(AxisInfo& from);
  ~AxisInfo();
  void draw(RenderContext* renderContext, Vertex4& v, Vertex4& dir, Matrix4x4& modelview, 
            Vertex& marklen, String& string);
            
  int getNticks(float low, float high);
  float getTick(float low, float high, int index);

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
  BBoxDeco(Material& in_material=defaultMaterial, AxisInfo& xaxis=defaultAxis, AxisInfo& yaxis=defaultAxis, AxisInfo& zaxis=defaultAxis, float marklen=15.0, bool marklen_fract=true,
           float in_expand=1.0, bool in_front=false);
  void render(RenderContext* renderContext);
  AABox getBoundingBox(const AABox& boundingBox) const;
  Vertex getMarkLength(const AABox& boundingBox) const;
  int getAttributeCount(AABox& bbox, AttribID attrib);
  void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);
  String  getTextAttribute(AABox& bbox, AttribID attrib, int index);
  Material* getMaterial()  { return &material; }
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "bboxdeco", buflen); };
private:
  Material material;
  AxisInfo xaxis, yaxis, zaxis;
  float marklen_value;
  bool  marklen_fract;
  float expand;
  bool  draw_front;

  static Material defaultMaterial;
  static AxisInfo defaultAxis;
};

} // namespace rgl

#endif // BBOX_DECO_H
