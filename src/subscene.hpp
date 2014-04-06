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
  void setupModelMatrix(RenderContext* rctx, const Sphere& viewSphere);
  void disableLights(RenderContext* rctx);
  void setupLights(RenderContext* rctx);

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
  
  Viewpoint* viewpoint;
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
  void addBboxdeco(BBoxDeco* newbboxdeco);
  void addShape(Shape* shape);
  void addLight(Light* light);
  void addSubscene(Subscene* subscene);
  
  /**
   * remove specified node of given type
   **/
  void	 pop(TypeID type, int id, bool destroy = false);

  /**
   * recursive search for subscene; could return self, or NULL if not found
   **/
  Subscene* get_subscene(int id);

  /**
   * get the bbox
   */
  BBoxDeco* get_bboxdeco();
  

  /**
   * obtain subscene's axis-aligned bounding box. 
   **/
  const AABox& getBoundingBox();

/**
   * remove all nodes of the given type, optionally recursively.
   **/
  bool clear(TypeID stackTypeID, bool recursive);

 /**
   * get information about stacks
   */
  int get_id_count(TypeID type, bool recursive = false);
  void get_ids(TypeID type, int* ids, char** types, bool recursive = false);

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
  
  Viewpoint* getViewpoint();
  
  Background* get_background(); 
    
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
