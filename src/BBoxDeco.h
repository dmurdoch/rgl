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
  AXIS_CUSTOM,  // "custom"
  AXIS_LENGTH,  // "fixednum"
  AXIS_UNIT,    // "fixedstep"
  AXIS_PRETTY,  // "pretty"
  AXIS_USER,    // "user"
  AXIS_NONE     // "none"
};

struct AxisInfo {
  AxisInfo();
  AxisInfo(int in_nticks, double* in_ticks, char** in_texts, int in_len, float in_unit);
  AxisInfo(AxisInfo& from);
  ~AxisInfo();
  void draw(RenderContext* renderContext, Vertex4& v, Vertex4& dir, Matrix4x4& modelview, 
            Vertex& marklen, String& string);
            
  int getNticks(float low, float high);
  double getTick(float low, float high, int index); /* double since it might be NA_REAL */

  int    mode;
  int    nticks;
  float* ticks;
  StringArray textArray;
  int    len;
  float  unit;
};

typedef void (*userAxisPtr)(void *userData, int axis, int edge[3]);

class BBoxDeco : public SceneNode 
{
public:
  BBoxDeco(Material& in_material=defaultMaterial, AxisInfo& in_xaxis=defaultAxis, AxisInfo& in_yaxis=defaultAxis, AxisInfo& in_zaxis=defaultAxis, float in_marklen_value=15.0, bool in_marklen_fract=true,
           float in_expand=1.0, bool in_front=false);
  void render(RenderContext* renderContext);
  AABox getBoundingBox(const AABox& in_bbox) const;
  Vertex getMarkLength(const AABox& boundingBox) const;
  int getAttributeCount(SceneNode* subscene, AttribID attrib);
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);
  String  getTextAttribute(SceneNode* subscene, AttribID attrib, int index);
  Material* getMaterial()  { return &material; }
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "bboxdeco", buflen); };
  Vec3 marginVecToDataVec(Vec3 marginvec, RenderContext* renderContext, Material* material);
  Vec3 marginNormalToDataNormal(Vec3 marginvec, RenderContext* renderContext, Material* material);
  void setAxisCallback(userAxisPtr fn, void * user, int axis);
  void getAxisCallback(userAxisPtr *fn, void ** user, int axis);
private:
  struct BBoxDecoImpl;
  Material material;
  AxisInfo xaxis, yaxis, zaxis;
  float marklen_value;
  bool  marklen_fract;
  float expand;
  bool  draw_front;
  
#ifndef RGL_NO_OPENGL
  bool axisBusy;
#endif
  userAxisPtr axisCallback[3];
  void* axisData[3];

  static Material defaultMaterial;
  static AxisInfo defaultAxis;
};

} // namespace rgl

#endif // BBOX_DECO_H
