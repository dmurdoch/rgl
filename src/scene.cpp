// C++ source
// This file is part of RGL.
//
// $Id$


#include "scene.h"
#include "rglmath.h"
#include "render.h"
#include "geom.hpp"
#include <map>
#include <algorithm>
#include <functional>
#include "R.h"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Scene
//

static int gl_light_ids[8] = { GL_LIGHT0, GL_LIGHT1, GL_LIGHT2, GL_LIGHT3, GL_LIGHT4, GL_LIGHT5, GL_LIGHT6, GL_LIGHT7 };

ObjID SceneNode::nextID = BBOXID + 1;

Scene::Scene()
{
  background = NULL;
  viewpoint  = NULL;
  nlights    = 0;
  bboxDeco   = NULL;
  ignoreExtent = false;
  bboxChanges = false;
 
  add( new Background );
  add( new Viewpoint );
  add( new Light ); 
}

Scene::~Scene()
{
  clear(SHAPE);
  clear(LIGHT);
  clear(BBOXDECO);

  if (background)
    delete background;
  if (viewpoint)
    delete viewpoint;
}

Viewpoint* Scene::getViewpoint() 
{
  return viewpoint;
}

void Scene::deleteShapes()
{
  std::vector<Shape*>::iterator iter;
  for (iter = shapes.begin(); iter != shapes.end(); ++iter) {
    delete *iter;
  }
  shapes.clear();
  bboxChanges = false;
}

void Scene::deleteLights()
{
  std::vector<Light*>::iterator iter;
  for (iter = lights.begin(); iter != lights.end(); ++iter) {
    delete *iter;
  }
  lights.clear();
}

bool Scene::clear(TypeID typeID)
{
  bool success = false;

  switch(typeID) {
    case SHAPE:
      deleteShapes();
      SAVEGLERROR;
      zsortShapes.clear();
      SAVEGLERROR;
      unsortedShapes.clear();
      SAVEGLERROR;
      data_bbox.invalidate();
      SAVEGLERROR;
      success = true;
      break;
    case LIGHT:
      deleteLights();
      SAVEGLERROR;
      nlights = 0;
      success = true;
      break;
    case BBOXDECO:
      delete bboxDeco;
      SAVEGLERROR;
      bboxDeco = NULL;
      success = true;
      break;
  }
  return success;
}

void Scene::addShape(Shape* shape) {
  if (!shape->getIgnoreExtent()) {
    const AABox& bbox = shape->getBoundingBox();
    data_bbox += bbox;
    bboxChanges |= shape->getBBoxChanges();
  }

  shapes.push_back(shape);

  if ( shape->isBlended() ) {
    zsortShapes.push_back(shape);
  } else
    unsortedShapes.push_back(shape);
}

bool Scene::add(SceneNode* node)
{
  bool success = false;
  switch( node->getTypeID() )
  {
    case LIGHT:
      if (nlights < 8) {

        Light* light = (Light*) node;

        light->id = gl_light_ids[ nlights++ ];

        lights.push_back( light );

        success = true;
      }
      break;
    case SHAPE:
      {
        Shape* shape = (Shape*) node;
        addShape(shape);

        success = true;
      }
      break;
    case VIEWPOINT:
      {
        if (viewpoint)
          delete viewpoint;
        viewpoint = (Viewpoint*) node;
        success = true;
      }
      break;
    case BACKGROUND:
      {
        if (background)
          delete background;
        background = (Background*) node;
        success = true;
      }
      break;
    case BBOXDECO:
      {
        if (bboxDeco)
          delete bboxDeco;
        bboxDeco = (BBoxDeco*) node;
        success = true;
      }
      break;
    default:
      break;
  }
  return success;
}

bool Scene::pop(TypeID type, int id, bool destroy)
{
  bool success = false;
  std::vector<Shape*>::iterator ishape;
  std::vector<Light*>::iterator ilight;
  
  switch(type) {
    case SHAPE: {
      if (id == BBOXID) {
        type = BBOXDECO; 
        id = 0;
      }
      else if (shapes.empty()) 
        return false;
      break;
    }
    case LIGHT: if (lights.empty()) return false;
    default: break;
  }
  
  if (id == 0) {
    switch(type) {
    case SHAPE:  
      ishape = shapes.end() - 1;
      id = (*ishape)->getObjID(); /* for zsort or unsort */
      break;
    case LIGHT:
      ilight = lights.end() - 1;
      break;
    default:
      break;
    }
  } else {
    switch(type) {
    case SHAPE:
      ishape = std::find_if(shapes.begin(), shapes.end(), 
                            std::bind2nd(std::ptr_fun(&sameID), id));
      if (ishape == shapes.end()) return false;
      break;
    case LIGHT:
      ilight = std::find_if(lights.begin(), lights.end(),
      						std::bind2nd(std::ptr_fun(&sameID), id));
      if (ilight == lights.end()) return false;
      break;
    default:
      return false;
    }
  }

  switch(type) {
  case SHAPE:
    {
      Shape* shape = *ishape;
      shapes.erase(ishape);
      if ( shape->isBlended() )
          zsortShapes.erase(std::find_if(zsortShapes.begin(), zsortShapes.end(),
                                         std::bind2nd(std::ptr_fun(&sameID), id)));
      else
        unsortedShapes.erase(std::find_if(unsortedShapes.begin(), unsortedShapes.end(),
                                       std::bind2nd(std::ptr_fun(&sameID), id)));
      if (destroy)
        delete shape;
      calcDataBBox();
      success = true;
    }  
    break;
  case LIGHT:
    {
      Light* light = *ilight;
      lights.erase(ilight);
      if (destroy)
        delete light;
      nlights--;
      success = true;
    }
    break;
  case BBOXDECO:
    {
      if (bboxDeco) {
        if (destroy)
          delete bboxDeco;
        bboxDeco = NULL;
        success = true;
      }
    }
    break;
  default: // VIEWPOINT,BACKGROUND ignored
    break;
  }

  return success;
}

int Scene::get_id_count(TypeID type)
{
  switch(type) {
  case SHAPE:  return shapes.size();
  case LIGHT:  return lights.size();
  case BBOXDECO: return bboxDeco ? 1 : 0;
  case VIEWPOINT: return viewpoint ? 1 : 0;
  case BACKGROUND: return background ? 1 : 0;

  default:     return 0;
  }
}

void Scene::get_ids(TypeID type, int* ids, char** types)
{
  char buffer[20];
  switch(type) {
  case SHAPE: 
    for (std::vector<Shape*>::iterator i = shapes.begin(); i != shapes.end() ; ++ i ) {
      *ids++ = (*i)->getObjID();
      buffer[19] = 0;
      (*i)->getShapeName(buffer, 20);
      *types = R_alloc(strlen(buffer)+1, 1);
      strcpy(*types, buffer);
      types++;
    }
    return;
  case LIGHT: 
    for (std::vector<Light*>::iterator i = lights.begin(); i != lights.end() ; ++ i ) {
      *ids++ = (*i)->getObjID();
      *types = R_alloc(strlen("light")+1, 1);
      strcpy(*types, "light");
      types++;
    }
    return;
  case BBOXDECO:
    if (bboxDeco) {
      *ids = bboxDeco->getObjID();
      *types = R_alloc(strlen("bboxdeco")+1, 1);
      strcpy(*types, "bboxdeco");
    }
    return;
  case VIEWPOINT:
    if (viewpoint) {
      *ids = viewpoint->getObjID();
      *types = R_alloc(strlen("viewpoint")+1, 1);
      strcpy(*types, "viewpoint");
    }
    return;
  case BACKGROUND:
    if (background) {
      *ids = background->getObjID();
      *types = R_alloc(strlen("background")+1, 1);
      strcpy(*types, "background");
    }
    return;
    
  default:	return;
  }
}  

SceneNode* Scene::get_scenenode(int id, bool recursive) 
{
  Light* light;
  Shape* shape;
  Background *background;
  BBoxDeco* bboxdeco;
  
  if ( (shape = get_shape(id, recursive)) )
    return shape;
  else if ( (light = get_light(id)) ) 
    return light;
  else if ( (background = get_background()) && id == background->getObjID())
    return background;
  else if ( (bboxdeco = get_bboxdeco()) && id == bboxdeco->getObjID())
    return bboxdeco;
  else return NULL;
}

Shape* Scene::get_shape(int id, bool recursive)
{
  return get_shape_from_list(shapes, id, recursive);
}

Light* Scene::get_light(int id)
{
  std::vector<Light*>::iterator ilight;

  if (lights.empty()) 
    return NULL;
  
  ilight = std::find_if(lights.begin(), lights.end(), 
                        std::bind2nd(std::ptr_fun(&sameID), id));
  if (ilight == lights.end()) return NULL;
  else return *ilight;
}

const AABox& Scene::getBoundingBox()
{ 
  if (bboxChanges) 
      calcDataBBox();
  return data_bbox; 
}

void Scene::renderZsort(RenderContext* renderContext)
{  
  std::vector<Shape*>::iterator iter;
  std::multimap<float, ShapeItem*> distanceMap;
  int index = 0;

  for (iter = zsortShapes.begin() ; iter != zsortShapes.end() ; ++iter ) {
    Shape* shape = *iter;
    shape->renderBegin(renderContext);
    for (int j = 0; j < shape->getElementCount(); j++) {
	ShapeItem* item = new ShapeItem(shape, j);
	float distance = renderContext->getDistance( shape->getElementCenter(j) );
      distanceMap.insert( std::pair<const float,ShapeItem*>(-distance, item) );
      index++;
    }
  }

  {
    Shape* prev = NULL;
    std::multimap<float,ShapeItem*>::iterator iter;
    for (iter = distanceMap.begin() ; iter != distanceMap.end() ; ++ iter ) {
      ShapeItem* item = iter->second;
      Shape* shape = item->shape;
      if (shape != prev) {
        if (prev) prev->drawEnd(renderContext);
        shape->drawBegin(renderContext);
        prev = shape;
      }
      shape->drawElement(renderContext, item->itemnum);
    }
    if (prev) prev->drawEnd(renderContext);
  }
}

void Scene::render(RenderContext* renderContext)
{

  renderContext->scene     = this;
  renderContext->viewpoint = viewpoint;


  //
  // CLEAR BUFFERS
  //

  GLbitfield clearFlags = 0;

  SAVEGLERROR;

  // Depth Buffer

  glClearDepth(1.0);
  glDepthFunc(GL_LESS);
  glDepthMask(GL_TRUE);
  // mask and func will be reset by material

  // if ( unsortedShapes.size() )
    clearFlags  |= GL_DEPTH_BUFFER_BIT;

  // Color Buffer (optional - depends on background node)
  
  clearFlags |= background->getClearFlags(renderContext);

  // clear
  glClear(clearFlags);
  // renderContext.clear(viewport);

  // userMatrix and scale might change the length of normals.  If this slows us
  // down, we should test for that instead of just enabling GL_NORMALIZE
  
  glEnable(GL_NORMALIZE);
  

  if (bboxChanges) 
    calcDataBBox();
  
  Sphere total_bsphere;

  if (data_bbox.isValid()) {
    
    // 
    // GET DATA VOLUME SPHERE
    //

    total_bsphere = Sphere( (bboxDeco) ? bboxDeco->getBoundingBox(data_bbox) : data_bbox, viewpoint->scale );
    if (total_bsphere.radius <= 0.0)
      total_bsphere.radius = 1.0;

  } else {
    total_bsphere = Sphere( Vertex(0,0,0), 1 );
  }

  SAVEGLERROR;

  //
  // SETUP LIGHTING MODEL
  //

  setupLightModel(renderContext, total_bsphere);

  //
  // SETUP VIEWPORT TRANSFORMATION
  //

  glViewport(renderContext->rect.x,renderContext->rect.y,renderContext->rect.width, renderContext->rect.height);


  //
  // SETUP BACKGROUND VIEWPOINT PROJECTION
  //
  // FIXME: move to background
  //

  viewpoint->setupFrustum( renderContext, total_bsphere );

  //
  // RENDER BACKGROUND
  //

  // DISABLE Z-BUFFER TEST
  glDisable(GL_DEPTH_TEST);

  // DISABLE Z-BUFFER FOR WRITING
  glDepthMask(GL_FALSE);

  background->render(renderContext);

  SAVEGLERROR;
  
  //
  // RENDER MODEL
  //

  if (data_bbox.isValid() ) {

    //
    // SETUP VIEWPOINT TRANSFORMATION
    //

    viewpoint->setupTransformation( renderContext, total_bsphere);

    // Save matrices for projection/unprojection later
    
    glGetDoublev(GL_MODELVIEW_MATRIX,renderContext->modelview);
    glGetDoublev(GL_PROJECTION_MATRIX,renderContext->projection);
    glGetIntegerv(GL_VIEWPORT, renderContext->viewport);    
    
    //
    // RENDER SOLID SHAPES
    //

    // ENABLE Z-BUFFER TEST 
    glEnable(GL_DEPTH_TEST);

    // ENABLE Z-BUFFER FOR WRITING
    glDepthMask(GL_TRUE);

    // DISABLE BLENDING
    glDisable(GL_BLEND);
    
    //
    // RENDER BBOX DECO
    //

    if (bboxDeco) 
      bboxDeco->render(renderContext);  // This changes the modelview/projection/viewport

    SAVEGLERROR;

    {
      std::vector<Shape*>::iterator iter;

      for (iter = unsortedShapes.begin() ; iter != unsortedShapes.end() ; ++iter ) {
        Shape* shape = *iter;
        shape->render(renderContext);
        SAVEGLERROR;
      }
    }

// #define NO_BLEND

#ifndef NO_BLEND
    //
    // RENDER BLENDED SHAPES
    //
    // render shapes in bounding-box sorted order according to z value
    //

    // DISABLE Z-BUFFER FOR WRITING
    glDepthMask(GL_FALSE);
    
    SAVEGLERROR;
    
    // SETUP BLENDING
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

    SAVEGLERROR;
    
    // ENABLE BLENDING
    glEnable(GL_BLEND);

    SAVEGLERROR;

    //
    // GET THE TRANSFORMATION
    //

    viewpoint->setupTransformation(renderContext, total_bsphere);

    Matrix4x4 M(renderContext->modelview);    
    Matrix4x4 P(renderContext->projection);
    P = P*M;
    
    renderContext->Zrow = P.getRow(2);
    renderContext->Wrow = P.getRow(3);
    
    renderZsort(renderContext);
#endif    
    /* Reset flag(s) now that scene has been rendered */
    renderContext->viewpoint->scaleChanged = false;
    
    SAVEGLERROR;
  }
}


void Scene::setupLightModel(RenderContext* rctx, const Sphere& viewSphere)
{
  Color global_ambient(0.0f,0.0f,0.0f,1.0f);

  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient.data );
  glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, GL_TRUE );
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE );

#ifdef GL_VERSION_1_2
//  glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, GL_SINGLE_COLOR );
#endif

  //
  // global lights
  //

  rctx->viewpoint->setupFrustum(rctx, viewSphere);
  rctx->viewpoint->setupTransformation(rctx, viewSphere);
  SAVEGLERROR;

  std::vector<Light*>::const_iterator iter;

  for(iter = lights.begin(); iter != lights.end() ; ++iter ) {

    Light* light = *iter;

    if (!light->viewpoint)
      light->setup(rctx);
  }

  SAVEGLERROR;

  //
  // viewpoint lights
  //

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  for(iter = lights.begin(); iter != lights.end() ; ++iter ) {

    Light* light = *iter;

    if (light->viewpoint)
      light->setup(rctx);

  }

  SAVEGLERROR;

  //
  // disable unused lights
  //

  for (int i=nlights;i<8;i++)
    glDisable(gl_light_ids[i]);

}

void Scene::calcDataBBox()
{
  data_bbox.invalidate();

  std::vector<Shape*>::const_iterator iter;

  bboxChanges = false;
  for(iter = shapes.begin(); iter != shapes.end(); ++iter) {
    Shape* shape = *iter;

    if (!shape->getIgnoreExtent()) {
      data_bbox += shape->getBoundingBox(this);
      bboxChanges |= shape->getBBoxChanges();
    }
  }
}

// ---------------------------------------------------------------------------
int Scene::getIgnoreExtent(void)
{
  return (int)ignoreExtent;
}
// ---------------------------------------------------------------------------
void Scene::setIgnoreExtent(int in_ignoreExtent)
{
  ignoreExtent = (bool)in_ignoreExtent;
}

// ---------------------------------------------------------------------------
void Scene::invalidateDisplaylists()
{
  std::vector<Shape*>::iterator iter;
  for (iter = shapes.begin(); iter != shapes.end(); ++iter) {
    (*iter)->invalidateDisplaylist();
  }
}

bool sameID(SceneNode* node, int id)
{ 
  return node->getObjID() == id; 
}
