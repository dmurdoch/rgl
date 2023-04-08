#ifndef SPRITE_SET_H
#define SPRITE_SET_H

#include <vector>
#include "Shape.h"
#include "scene.h"

namespace rgl {

//
// SPRITESET
//

class SpriteSet : public Shape {
private:
  ARRAY<Vertex> vertex;
  ARRAY<float>  size;
  ARRAY<int>    pos;
  float         offset;

public:
  SpriteSet(Material& material, int nvertex, double* vertex, int nsize, double* size, 
            int ignoreExtent, int count = 0, Shape** shapelist = NULL, double* userMatrix = NULL,
            bool fixedSize = false, 
            bool rotating = false, 
            Scene* scene = NULL, double* adj = NULL,
            int npos = 0, int* pos = NULL, double offset = 0.0);
  ~SpriteSet();

  /**
   * overload
   **/
  virtual void render(RenderContext* renderContext);
  
  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "sprites", buflen); };
  
  virtual int getElementCount(void);
  int getAttributeCount(SceneNode* subscene, AttribID attrib);
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);
  std::string getTextAttribute(SceneNode* subscene, AttribID attrib, int index);
  
  /**
   * location of individual items
   **/
  
  virtual Vertex getPrimitiveCenter(int index);
  
  /**
   * begin sending items 
   **/
  virtual void drawBegin(RenderContext* renderContext);
  
  /**
   * send one item
   **/
  virtual void drawPrimitive(RenderContext* renderContext, int index);
  
  /**
   * end sending items
   **/
  virtual void drawEnd(RenderContext* renderContext);
  
  /**
   * extract individual shape
   */
  virtual Shape* get_shape(int id);
  
  /**
   * delete a shape
   */
  void remove_shape(int id);
  
private:
  GLdouble userMatrix[16]; /* Transformation for 3D sprites */
  Matrix4x4 m;             /* Modelview matrix cache */
  Matrix4x4 p;             /* Projection matrix cache */
#ifndef RGL_NO_OPENGL  
  bool doTex;
#endif
  std::vector<int> shapes;
  bool fixedSize;
  bool rotating;
  Scene* scene;
  Vec3 adj;
  void getAdj(int index);
};

} // namespace rgl

#endif // SPRITE_SET_H
