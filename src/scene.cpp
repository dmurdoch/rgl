// C++ source
// This file is part of RGL.
//
// $Id$

#include "gl2ps.h"
#include "scene.h"
#include "rglmath.h"
#include "render.h"
#include "geom.hpp"
#include <map>
#include <algorithm>
#include <functional>
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Scene
//

static int gl_light_ids[8] = { GL_LIGHT0, GL_LIGHT1, GL_LIGHT2, GL_LIGHT3, GL_LIGHT4, GL_LIGHT5, GL_LIGHT6, GL_LIGHT7 };

ObjID SceneNode::nextID = BBOXID + 1;

Scene::Scene()
: rootSubscene(NULL, PREPROJ) 
{
  currentSubscene = &rootSubscene;
  nlights    = 0;
 
  rootSubscene.add( new Viewpoint );
  rootSubscene.add( new Background );
  Light* light = new Light; 
  add(light);
  rootSubscene.addLight(light);
}

Scene::~Scene()
{
  clear(SHAPE);
  clear(LIGHT);
  clear(BBOXDECO);

}

Viewpoint* Scene::getViewpoint() 
{
  return currentSubscene->getViewpoint();
}

void Scene::deleteShapes()
{
  std::vector<Shape*>::iterator iter;
  for (iter = shapes.begin(); iter != shapes.end(); ++iter) {
    delete *iter;
  }
  shapes.clear();
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

  rootSubscene.clear(typeID, true);
  switch(typeID) {
    case SHAPE:
      deleteShapes();
      SAVEGLERROR;
      success = true;
      break;
    case LIGHT:
      deleteLights();
      SAVEGLERROR;
      success = true;
      break;
    case BBOXDECO:
      success = true;
      break;
  }
  return success;
}

void Scene::addShape(Shape* shape) {

  shapes.push_back(shape);
  
  currentSubscene->addShape(shape);

}

void Scene::addLight(Light* light) {

  light->id = gl_light_ids[ nlights++ ];

  lights.push_back( light );

  currentSubscene->addLight(light);

}  

bool Scene::add(SceneNode* node)
{
  bool success = false;
  switch( node->getTypeID() )
  {
    case LIGHT:
      {
        addLight((Light*) node);

        success = true;
      }
      break;
    case SHAPE:
      {
        addShape((Shape*) node);

        success = true;
      }
      break;
    case BACKGROUND:
      {
        currentSubscene->addBackground((Background*) node);
        success = true;
      }
      break;
    case BBOXDECO:
      {
        currentSubscene->addBboxdeco((BBoxDeco*) node);
        success = true;
      }
      break;
    case SUBSCENE:
      {
	Subscene* subscene = static_cast<Subscene*>(node);
	currentSubscene->addSubscene(subscene);
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
  std::vector<Subscene*>::iterator isubscene;
  
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
    case LIGHT: {
      if (lights.empty()) return false;
      break;
    }
    case SUBSCENE: rootSubscene.pop(type, id, destroy);
      return true;
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
      rootSubscene.pop(SHAPE, id);
      Shape* shape = *ishape;
      shapes.erase(ishape);
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
      currentSubscene->pop(type, id, true);
      success = true;
    }
    break;
  default: // BACKGROUND ignored
    break;
  }

  return success;
}

int Scene::get_id_count(TypeID type)
{
  switch(type) {
  case SHAPE:  return shapes.size();
  case LIGHT:  return lights.size();
  case SUBSCENE: return rootSubscene.get_id_count(type, true) + 1;

  default:     return rootSubscene.get_id_count(type, true);
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
  case SUBSCENE:
    *ids++ = rootSubscene.getObjID(); 
    *types = R_alloc(strlen("subscene")+1, 1);
    strcpy(*types, "subscene");
    types++;
    rootSubscene.get_ids(type, ids, types);  
    return;
    
  default:
    rootSubscene.get_ids(type, ids, types);  
    return;
  }
}  

SceneNode* Scene::get_scenenode(int id, bool recursive) 
{
  Light* light;
  Shape* shape;
  Background *background;
  BBoxDeco* bboxdeco;
  Subscene* subscene;
  
  if ( (shape = get_shape(id, recursive)) )
    return shape;
  else if ( (light = get_light(id)) ) 
    return light;
  else if ( (background = get_background()) && id == background->getObjID())
    return background;
  else if ( (bboxdeco = get_bboxdeco()) && id == bboxdeco->getObjID())
    return bboxdeco;
  else if ( (subscene = get_subscene(id)) )
    return subscene;
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

Subscene* Scene::get_subscene(int id)
{
  return rootSubscene.get_subscene(id);
}

void Scene::setCurrentSubscene(Subscene* subscene)
{
  currentSubscene = subscene;
}

Subscene* Scene::getCurrentSubscene()
{
  return currentSubscene;
}

  
void Scene::render(RenderContext* renderContext)
{

  renderContext->scene     = this;
  renderContext->viewpoint = rootSubscene.getViewpoint();


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
  // renderContext.clear(subscene);

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

    total_bsphere = Sphere( (bboxDeco) ? bboxDeco->getBoundingBox(data_bbox) : data_bbox, rootSubscene.viewpoint->scale );
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

    rootSubscene.renderUnsorted(renderContext);

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
    if (renderContext->gl2psActive == GL2PS_NONE) 
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    else
      gl2psBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

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
    
    rootSubscene.renderZsort(renderContext);
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

bool rgl::sameID(SceneNode* node, int id)
{ 
  return node->getObjID() == id; 
}
