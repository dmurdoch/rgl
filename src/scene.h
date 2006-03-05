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
   * remove last-added node of given type.
   **/
  bool pop(TypeID stackTypeID);

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
  List lights;

  /**
   * list of shapes
   **/
  List shapes;

  std::vector<Shape*> unsortedShapes;
  std::vector<Shape*> zsortShapes;

  // ---[ grouping data ]----------------------------------------------------
  
  /**
   * bounding box of overall scene
   **/
  AABox data_bbox;
  
  bool ignoreExtent;
};


#endif /* SCENE_HPP */

