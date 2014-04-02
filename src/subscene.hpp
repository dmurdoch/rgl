#ifndef SUBSCENE_HPP
#define SUBSCENE_HPP

#include "Shape.hpp"
#include "ClipPlane.hpp"
#include "Viewpoint.hpp"
#include "Background.hpp"
#include <map>

namespace rgl {

#define PREPROJ 1
#define PROJ 2
#define MODEL 3

class Subscene : public SceneNode {
private:
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
  
  /* Subscenes do their own projection.  The M and P matrices are model and projection
     matrices; E embeds the subscene in its parent; "where" says where it is embedded:
     PREPROJ = before the projection
     PROJ    = between projection and model
     MODEL   = after the model
  */
  int where;
  Matrix4x4 E;
  Viewpoint* viewpoint;
  /**
   * bounded background
   **/
  Background* background;
  /**
   * bounded decorator
   **/
  BBoxDeco*  bboxDeco;    
public:
  Subscene(Subscene* in_parent, int in_where);
  virtual ~Subscene( );

  bool add(SceneNode* node);
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
   * remove all nodes of the given type, optionally recursively.
   **/
  bool clear(TypeID stackTypeID, bool recursive);

 /**
   * get information about stacks
   */
  int get_id_count(TypeID type);
  void get_ids(TypeID type, int* ids, char** types);

  virtual int getAttributeCount(AABox& bbox, AttribID attrib);
  
  virtual void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);
  virtual String getTextAttribute(AABox& bbox, AttribID attrib, int index);

  void renderClipplanes(RenderContext* renderContext);
  void disableClipplanes(RenderContext* renderContext);
  
  void renderUnsorted(RenderContext* renderContext);
  void renderZsort(RenderContext* renderContext);
  
  Viewpoint* getViewpoint();
  
  Background* get_background(); 
    
  BBoxDeco* get_bboxdeco();

private:

  /**
   * bounding box of subscene
   **/
  AABox data_bbox;
  
  bool ignoreExtent;
  bool bboxChanges;
};

} // namespace rgl

#endif // SUBSCENE_HPP
