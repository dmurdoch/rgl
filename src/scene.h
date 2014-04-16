#ifndef SCENE_HPP
#define SCENE_HPP

// C++ header file
// This file is part of RGL
//
// $Id$

#include <vector>
#include "types.h"
#include "Subscene.hpp"

namespace rgl {

class Scene {
public:
  Scene();
  ~Scene();

  // ---[ client services ]---------------------------------------------------

  /**
   * remove all nodes of the given type.  This is always recursive through subscenes.
   **/
  bool clear(TypeID stackTypeID);
  
  /**
   * add node to current subscene (and possibly to scene)
   **/
  bool add(SceneNode* node);
  
  /**
   * remove specified node of given type, or last-added if id==0
   **/
  bool pop(TypeID stackTypeID, int id);
  
  /**
   * get information about stacks
   */
  int get_id_count(TypeID type);
  void get_ids(TypeID type, int* ids, char** types);
  
  /**
   * get a SceneNode of any type
   */
   
  SceneNode* get_scenenode(int id, bool recursive = false);
  
  /**
   * get information about particular shapes
   **/
  Shape* get_shape(int id, bool recursive = false);
  
  /**
   * get information about particular lights
   **/
  Light* get_light(int id);
  
  /**
   * get the background
   */
  Background* get_background() const { return currentSubscene->get_background(); }
  
  /**
   * get the bbox
   */
  BBoxDeco* get_bboxdeco() const { return currentSubscene->get_bboxdeco(); }
  
  /**
   * get subscene
   */
  Subscene* getSubscene(int id);

  /** 
   * set/get the current subscene
   **/
  void setCurrentSubscene(Subscene* subscene);
  Subscene* getCurrentSubscene() const { return currentSubscene; }
  const Subscene* getRootSubscene() const { return &rootSubscene; }
  
  // ---[ grouping component ]-----------------------------------------------
  
  /**
   * obtain subscene's axis-aligned bounding box. 
   **/
  const AABox& getBoundingBox() const { return currentSubscene->getBoundingBox(); }
  
  // ---[ Renderable interface ]---------------------------------------------
  
  /**
   * TODO: implements Renderable
   **/
  void render(RenderContext* renderContext);

  // ---[ bindable component ]-----------------------------------------------
  
  /**
   * obtain bounded viewpoint
   **/
  Viewpoint* getViewpoint();
  
  /**
   * Get and set flag to ignore elements in bounding box
   **/
  
  int getIgnoreExtent(void) const { return currentSubscene->getIgnoreExtent(); }
  void setIgnoreExtent(int in_ignoreExtent) const { currentSubscene->setIgnoreExtent(in_ignoreExtent); }
  
  /**
   * invalidate display lists so objects will be rendered again
   **/
  void invalidateDisplaylists();

  Subscene rootSubscene;  

private:


  void setupLightModel();

  /**
   * add shapes
   **/
  void addShape(Shape* shape);
  
  /**
   * add light
   **/
  void addLight(Light* light);
  

  // --- [ Subscenes ]-------------------------------------------------------

  Subscene* currentSubscene;

  // ---[ bounded slots ]----------------------------------------------------
  


  // ---[ stacks ]-----------------------------------------------------------
  
  /**
   * list of light sources.  The scene owns them, the subscenes display a subset.
   **/
  std::vector<Light*> lights;

  /**
   * list of shapes.  The scene owns them, the subscenes display a subset.
   **/
  std::vector<Shape*> shapes;
  
  void deleteAll(std::vector<SceneNode*> list);

  void deleteShapes();
  void deleteLights();
  
  // ---[ grouping data ]----------------------------------------------------
  

};

} // namespace rgl

#endif /* SCENE_HPP */

