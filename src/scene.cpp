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

ObjID SceneNode::nextID = 1;

Scene::Scene()
: rootSubscene(NULL, EMBED_REPLACE, EMBED_REPLACE, EMBED_REPLACE) 
{
  currentSubscene = &rootSubscene;
 
  rootSubscene.add( new UserViewpoint );
  rootSubscene.add( new ModelViewpoint );
  rootSubscene.add( new Background );
  Light* light = new Light; 
  add(light);
}

Scene::~Scene()
{
  clear(SHAPE);
  clear(LIGHT);
  clear(BBOXDECO);

}

UserViewpoint* Scene::getUserViewpoint() 
{
  return currentSubscene->getUserViewpoint();
}

ModelViewpoint* Scene::getModelViewpoint() 
{
  return currentSubscene->getModelViewpoint();
}

void Scene::deleteShapes()
{
  std::vector<Shape*>::iterator iter;
  for (iter = shapes.begin(); iter != shapes.end(); ++iter) {
    rootSubscene.hideShape((*iter)->getObjID(), true);
    delete *iter;
  }
  shapes.clear();
}

void Scene::deleteLights()
{
  std::vector<Light*>::iterator iter;
  for (iter = lights.begin(); iter != lights.end(); ++iter) {
    rootSubscene.hideLight((*iter)->getObjID(), true);
    delete *iter;
  }
  lights.clear();
}

void Scene::deleteBBoxDecos()
{
  std::vector<BBoxDeco*>::iterator iter;
  for (iter = bboxdecos.begin(); iter != bboxdecos.end(); ++iter) {
    rootSubscene.hideBBoxDeco((*iter)->getObjID(), true);
    delete *iter;
  }
  bboxdecos.clear();
}

bool Scene::clear(TypeID typeID)
{
  bool success = false;

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
    case SUBSCENE:
      rootSubscene.clearSubscenes();
      SAVEGLERROR;
      success = true;
      break;
    case BBOXDECO:
      deleteBBoxDecos();
      SAVEGLERROR;
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

  lights.push_back( light );

  currentSubscene->addLight(light);

}  

void Scene::addBBoxDeco(BBoxDeco* bboxdeco) {

  bboxdecos.push_back( bboxdeco );

  currentSubscene->addBBoxDeco(bboxdeco);

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
    case BBOXDECO:
      {
        addBBoxDeco((BBoxDeco*) node);
        
        success = true;
      }
      break;
    default:
      currentSubscene->add(node);
      success = true;
  }
  return success;
}

bool Scene::pop(TypeID type, int id)
{
  std::vector<Shape*>::iterator ishape;
  std::vector<Light*>::iterator ilight;
  std::vector<Subscene*>::iterator isubscene;
  std::vector<BBoxDeco*>::iterator ibboxdeco;
  
  if (id == 0) {  
    switch(type) {
      case SHAPE: {
        if (shapes.empty()) return false;
        ishape = shapes.end() - 1;
        id = (*ishape)->getObjID(); /* for zsort or unsort */        
	break;
      }
      case LIGHT: {
        if (lights.empty()) return false;
        ilight = lights.end() - 1;
        id = (*ilight)->getObjID();        
	break;
      }
      case BBOXDECO: {
        if (bboxdecos.empty()) return false;
        ibboxdeco = bboxdecos.end() - 1;
	id = (*ibboxdeco)->getObjID();
        break;
      }
      case SUBSCENE: 
        id = currentSubscene->getObjID();
        break;
      default:
	return false;
    }
  } 
  
  ishape = std::find_if(shapes.begin(), shapes.end(), 
			std::bind2nd(std::ptr_fun(&sameID), id));
  if (ishape != shapes.end()) {
    rootSubscene.hideShape(id, true);
    Shape* shape = *ishape;
    shapes.erase(ishape);
    delete shape;
    return true;
  }
  
  ilight = std::find_if(lights.begin(), lights.end(),
			std::bind2nd(std::ptr_fun(&sameID), id));
  if (ilight != lights.end()) {
    rootSubscene.hideLight(id, true);
    Light* light = *ilight;
    lights.erase(ilight);
    delete light;
    return true;      
  }    
      
  ibboxdeco = std::find_if(bboxdecos.begin(), bboxdecos.end(),
			   std::bind2nd(std::ptr_fun(&sameID), id));
  if (ibboxdeco != bboxdecos.end()) {
    rootSubscene.hideBBoxDeco(id, true);
    BBoxDeco* bboxdeco = *ibboxdeco;
    bboxdecos.erase(ibboxdeco);
    delete bboxdeco;
    return true;
  }
  
  SceneNode* node = get_scenenode(id, true);
  if (node && node->getTypeID() == SUBSCENE) {
    currentSubscene = rootSubscene.popSubscene(id, currentSubscene);
    return true;
  }
  
  return false;
}

int Scene::get_id_count(TypeID type)
{
  switch(type) {
  case SHAPE:  return shapes.size();
  case LIGHT:  return lights.size();
  case SUBSCENE: return rootSubscene.get_id_count(type, true)+1;
  case BBOXDECO: return bboxdecos.size();

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
  case BBOXDECO: 
    for (std::vector<BBoxDeco*>::iterator i = bboxdecos.begin(); i != bboxdecos.end() ; ++ i ) {
      *ids++ = (*i)->getObjID();
      *types = R_alloc(strlen("bboxdeco")+1, 1);
      strcpy(*types, "bboxdeco");
      types++;
    }
    return;
  case SUBSCENE:
    *ids++ = rootSubscene.getObjID(); 
    *types = R_alloc(strlen("subscene")+1, 1);
    strcpy(*types, "subscene");
    types++;
    rootSubscene.get_ids(type, ids, types, true);  
    return;
    
  default:
    rootSubscene.get_ids(type, ids, types, true);  
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
  else if ( (subscene = getSubscene(id)) )
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

Subscene* Scene::getSubscene(int id)
{
  return rootSubscene.getSubscene(id);
}

Subscene* Scene::whichSubscene(int mouseX, int mouseY)
{
  Subscene* result = rootSubscene.whichSubscene(mouseX, mouseY);
  if (!result) result = &rootSubscene;
  return result;
}

void Scene::setCurrentSubscene(Subscene* subscene)
{
  currentSubscene = subscene;
}

void Scene::setupLightModel()
{
  Color global_ambient(0.0f,0.0f,0.0f,1.0f);

  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient.data );
  glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, GL_TRUE );
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE );
  SAVEGLERROR;  
}
  
void Scene::render(RenderContext* renderContext)
{

  renderContext->subscene  = &rootSubscene;

  //
  // CLEAR BUFFERS
  //

  GLbitfield clearFlags = GL_COLOR_BUFFER_BIT;
  rootSubscene.get_background()->material.colors.getColor(0).useClearColor();  

  SAVEGLERROR;

  // Depth Buffer

  glClearDepth(1.0);
  glDepthFunc(GL_LESS);
  glDepthMask(GL_TRUE);
  // mask and func will be reset by material

  // if ( unsortedShapes.size() )
    clearFlags  |= GL_DEPTH_BUFFER_BIT;

  // The subscenes use the scissor test to limit where they draw, but we want to clear everything here
  // clear
  glDisable(GL_SCISSOR_TEST);																																																																																																																																																																															
  glClear(clearFlags);  
  glEnable(GL_SCISSOR_TEST);

  // userMatrix and scale might change the length of normals.  If this slows us
  // down, we should test for that instead of just enabling GL_NORMALIZE
  
  glEnable(GL_NORMALIZE);

  setupLightModel();
  
  SAVEGLERROR;

  //
  // RENDER MODEL
  //

  rootSubscene.render(renderContext);
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
