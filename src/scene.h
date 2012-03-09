#ifndef SCENE_HPP
#define SCENE_HPP

// C++ header file
// This file is part of RGL
//
// $Id$

#include "types.h"
#include <vector>

#include "SceneNode.hpp"

#include "geom.hpp"

#include "String.hpp"
#include "Color.hpp"
#include "Texture.hpp"
#include "Material.hpp"
#include "Light.hpp"
#include "Shape.hpp"
#include "PrimitiveSet.hpp"
#include "TextSet.hpp"
#include "SpriteSet.hpp"
#include "SphereSet.hpp"
#include "PlaneSet.hpp"
#include "ABCLineSet.hpp"
#include "Surface.hpp"
#include "Viewpoint.hpp"
#include "Background.hpp"
#include "BBoxDeco.hpp"

class Scene {
public:
  Scene();
  ~Scene();

  // ---[ client services ]---------------------------------------------------

  /**
   * remove all nodes of the given type.
   **/
  bool clear(TypeID stackTypeID);
  
  /**
   * add node to scene
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
   * get information about particular shapes
   **/
  Shape* get_shape(int id);
  
  /**
   * get information about particular lights
   **/
  Light* get_light(int id);
  
  /**
   * get the background
   */
  Background* get_background() const { return background; }

  // ---[ grouping component ]-----------------------------------------------
  
  /**
   * obtain scene's axis-aligned bounding box
   **/
  const AABox& getBoundingBox() const { return data_bbox; }

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
  
  int getIgnoreExtent(void);
  void setIgnoreExtent(int in_ignoreExtent);
  
  /**
   * invalidate display lists so objects will be rendered again
   **/
  void invalidateDisplaylists();

private:

  // ---[ Renderable implementation ]---------------------------------------- 

  /**
   * sub-pass: setup global lighting model
   **/
  void setupLightModel(RenderContext* renderContext);
  /**
   * compute bounding-box
   **/
  void calcDataBBox();
  /**
   * compute bounding-box for a changeable scene
   **/
  void calcDataBBox(RenderContext* renderContext);
  /**
   * add shapes
   **/
  void addShape(Shape* shape);

  // ---[ bounded slots ]----------------------------------------------------
  
  /**
   * bounded background
   **/
  Background* background;
  /**
   * bounded viewpoint
   **/
  Viewpoint* viewpoint;
  /**
   * bounded decorator
   **/
  BBoxDeco*  bboxDeco;

  // ---[ stacks ]-----------------------------------------------------------
  
  /**
   * number of lights
   **/
  int  nlights;
  
  /**
   * list of light sources
   **/
  std::vector<Light*> lights;

  /**
   * list of shapes
   **/
  std::vector<Shape*> shapes;

  std::vector<Shape*> unsortedShapes;
  std::vector<Shape*> zsortShapes;
  
  void renderZsort(RenderContext* renderContext);
  
  void deleteAll(std::vector<SceneNode*> list);

  void deleteShapes();
  void deleteLights();
  
  // ---[ grouping data ]----------------------------------------------------
  
  /**
   * bounding box of overall scene
   **/
  AABox data_bbox;
  
  bool ignoreExtent;
  bool bboxChanges;
};


#endif /* SCENE_HPP */

