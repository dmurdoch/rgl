#ifndef SUBSCENE_HPP
#define SUBSCENE_HPP

#include "Shape.hpp"
#include "ClipPlane.hpp"
#include "Viewpoint.hpp"
#include "Background.hpp"
#include "BBoxDeco.hpp"
#include "Light.hpp"
#include <map>

namespace rgl {

enum Embedding { EMBED_INHERIT=1, EMBED_MODIFY, EMBED_REPLACE };

class Subscene : public SceneNode {
  /* Subscenes do their own projection.  They can inherit, modify or replace the
     viewport, projection and model matrices.  The root viewport always replaces them,
     since it doesn't have anything to inherit.
  */
private:

  void setupViewport(RenderContext* rctx);
  void setupProjMatrix(RenderContext* rctx, const Sphere& viewSphere);
  void setupModelMatrix(Vertex center);
  void setupModelViewMatrix(Vertex center);
  
  void disableLights(RenderContext* rctx);
  void setupLights(RenderContext* rctx);
  
  void newEmbedding();

  /* These lists contain pointers to lights and shapes, but don't actually manage them:  the Scene does that. */
  std::vector<Light*> lights;
  std::vector<Shape*> shapes;
  std::vector<Shape*> unsortedShapes;
  std::vector<Shape*> zsortShapes;
  std::vector<ClipPlaneSet*> clipPlanes;  

  /* Subscenes form a tree; this is the parent subscene.  The root has a NULL parent. */
  Subscene* parent;
  /* Here are the children */
  std::vector<Subscene*> subscenes;
  
  UserViewpoint* userviewpoint;
  ModelViewpoint* modelviewpoint;
  /**
   * bounded background
   **/
  Background* background;
  /**
   * bounded decorator
   **/
  BBoxDeco*  bboxdeco;  
  
  /** 
   * How is this subscene embedded in its parent?
   **/
  Embedding do_viewport, do_projection, do_model;
  
  /**
   * This viewport on the (0,0) to (1,1) scale
   **/
  Rect2d viewport;
public:
  Subscene(Subscene* in_parent, Embedding in_viewport, Embedding in_projection, Embedding in_model);
  virtual ~Subscene( );

  bool add(SceneNode* node);
  void addBackground(Background* newbackground);
  void addBBoxDeco(BBoxDeco* bboxdeco);
  void addShape(Shape* shape);
  void addLight(Light* light);
  void addSubscene(Subscene* subscene);
  
  /**
   * hide shape or light or bboxdeco
   **/
   
  void hideShape(int id);
  void hideLight(int id);
  void hideBBoxDeco(int id);
  void hideBackground(int id);
  Subscene* hideSubscene(int id, Subscene* current);

  /**
   * recursive search for subscene; could return self, or NULL if not found
   **/
  Subscene* getSubscene(int id);
  Subscene* whichSubscene(int mouseX, int mouseY); /* coordinates are pixels within the window */
  
  /**
   * get parent, or NULL for the root
   **/  
  Subscene* getParent() const { return parent; }

  /**
   * get children
   **/
  int getChildCount() const { return subscenes.size(); }
  Subscene* getChild(int which) const { return subscenes[which]; }
  
  /**
   * get the bbox
   */
  BBoxDeco* get_bboxdeco();
  
   /**
   * get a bbox
   */
  BBoxDeco* get_bboxdeco(int id);
  
  /**
   * get the background
   */
  Background* get_background() const { return background; }
  
  /** 
   * get a background
   */
  Background* get_background(int id);
  
  /**
   * obtain subscene's axis-aligned bounding box. 
   **/
  const AABox& getBoundingBox();

 /**
   * get information about stacks
   */
  int get_id_count(TypeID type, bool recursive);
  int get_ids(TypeID type, int* ids, char** types, bool recursive);

  virtual int getAttributeCount(AABox& bbox, AttribID attrib);
  
  virtual void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);
  virtual String getTextAttribute(AABox& bbox, AttribID attrib, int index);

  void render(RenderContext* renderContext);

  void renderClipplanes(RenderContext* renderContext);
  void disableClipplanes(RenderContext* renderContext);
  
  void renderUnsorted(RenderContext* renderContext);
  void renderZsort(RenderContext* renderContext);
  
  /**
   * Get and set flag to ignore elements in bounding box
   **/
  
  int getIgnoreExtent(void) const { return (int) ignoreExtent; }
  void setIgnoreExtent(int in_ignoreExtent);
  
  void setEmbedding(int which, Embedding value);  /* which is 0=viewport, 1=projection, 2=model */
  Embedding getEmbedding(int which);
  
  void setViewport(double x, double y, double width, double height); /* Sets relative (i.e. [0,1]x[0,1]) viewport size */
  
  float getDistance(const Vertex& v) const;

// Translate from OpenGL window-relative coordinates (relative to bottom left corner of window) to
// viewport relative (relative to bottom left corner of viewport)
  void translateCoords(int* mouseX, int* mouseY) const { *mouseX = *mouseX - pviewport[0]; *mouseY = *mouseY - pviewport[1]; }
  
  
  UserViewpoint* getUserViewpoint();
  ModelViewpoint* getModelViewpoint();
  
  void getModelMatrix(double* modelMatrix, Vertex center);

  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "subscene", buflen); };
  
  Background* get_background(); 
  
  // These are set after rendering the scene
  Vec4 Zrow;
  Vec4 Wrow;
  GLdouble modelMatrix[16], projMatrix[16];
  GLint pviewport[4];  // viewport in pixels
    
private:
    
  /**
   * compute bounding-box
   **/
  void calcDataBBox();

  /**
   * bounding box of subscene
   **/
  AABox data_bbox;
  
  bool ignoreExtent;
  bool bboxChanges;
};

} // namespace rgl

#endif // SUBSCENE_HPP
