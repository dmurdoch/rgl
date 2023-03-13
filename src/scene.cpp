// C++ source
// This file is part of RGL.
//

#include "scene.h"
#include "gl2ps.h"
#include "SpriteSet.h"
#include "rglmath.h"
#include "render.h"
#include "geom.h"
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
: rootSubscene(EMBED_REPLACE, EMBED_REPLACE, EMBED_REPLACE, EMBED_REPLACE, false),
  doIgnoreExtent(false)
{
  nodes.reserve(6);
  nodes.push_back( currentSubscene = &rootSubscene );
 
  add( new UserViewpoint );
  add( new ModelViewpoint );
  add( new Background );
  add( new Light );
}

Scene::~Scene()
{
  clear(SHAPE);
  clear(LIGHT);
  clear(BBOXDECO);
  clear(BACKGROUND);
  clear(MODELVIEWPOINT);
  clear(USERVIEWPOINT);
}

UserViewpoint* Scene::getUserViewpoint() 
{
  return currentSubscene->getUserViewpoint();
}

ModelViewpoint* Scene::getModelViewpoint() 
{
  return currentSubscene->getModelViewpoint();
}

bool Scene::clear(TypeID type)
{
  std::vector<SceneNode*>::iterator iter;
  for (iter = nodes.begin(); iter != nodes.end();) {
    if ((*iter)->getTypeID() == type) {
      SceneNode* node = (*iter);
      int id = node->getObjID();
      if (id == rootSubscene.getObjID()) 
        ++iter;
      else {
        hide(node->getObjID());
      	if (node->owner) {
      	  ++iter;
      	} else {
          delete node;
          iter = nodes.erase(iter);
      	} 
      }
    } else
      ++iter;
  }
  SAVEGLERROR;
  return true;
}

bool Scene::add(SceneNode* node)
{
  nodes.push_back( node );
  return currentSubscene->add(node);
}  

bool Scene::pop(TypeID type, int id)
{
  std::vector<SceneNode*>::iterator iter;
  
  if (id == 0) {  
    for (iter = nodes.end(); iter != nodes.begin();) {
      --iter;
      if ((*iter)->getTypeID() == type) {
        id = (*iter)->getObjID();
        break;
      }
    }
    if (!id) return false;
  }
  iter = std::find_if(nodes.begin(), nodes.end(), 
//		      std::bind(std::ptr_fun(&sameID), placeholders::_1, id));
          std::bind(&sameID, std::placeholders::_1, id));
  if (iter != nodes.end()) {
    SceneNode* node = *iter;  
    if (node == &rootSubscene) 
      return true;
    hide((*iter)->getObjID());
    // Rprintf("removing references to %d\n", id);
    removeReferences(*iter); /* Might be in mouseListeners */
    nodes.erase(iter);
    delete node;

    return true;
  }
  
  return false;
}

void Scene::hide(int id)
{
  std::vector<SceneNode*>::iterator inode;
  SceneNode* node = get_scenenode(id);
  if (node) {
    TypeID type = node->getTypeID();
    for (inode = nodes.begin(); inode != nodes.end(); ++inode) {
      if ((*inode)->getTypeID() == SUBSCENE) {
        Subscene* subscene = static_cast<Subscene*>((*inode));
        switch (type) {
          case SUBSCENE: currentSubscene = subscene->hideSubscene(id, currentSubscene);
            break;
          case SHAPE: subscene->hideShape(id);
            break;
          case LIGHT: subscene->hideLight(id);
            break;
          case BBOXDECO: subscene->hideBBoxDeco(id);
            break;
          case BACKGROUND: subscene->hideBackground(id);
            break;
          case USERVIEWPOINT:
          case MODELVIEWPOINT:
            subscene->hideViewpoint(id);
            break;
          default: error("hiding type %d not implemented", type);
        }
      }
    }
  }
}

void Scene::removeReferences(SceneNode* node) {
  int id = node->getObjID(), type = node->getTypeID();
  // Rprintf("node id = %d type = %u\n", id, node);
  for (std::vector<SceneNode*>::iterator iter = nodes.begin(); iter != nodes.end(); ++iter) {
    int itertype = (*iter)->getTypeID();
    // Rprintf("itertype = %u\n", itertype);
    if (itertype == SUBSCENE) {
      Subscene* subscene = (Subscene*)*iter;
      switch (type) {
      case SUBSCENE:
        subscene->deleteMouseListener((Subscene*)node);
        setCurrentSubscene(subscene->hideSubscene(id, getCurrentSubscene() ) );
        break;
      case SHAPE:
        subscene->hideShape(id);
        break;
      case LIGHT:
        subscene->hideLight(id);
        break;
      case BACKGROUND:
        subscene->hideBackground(id);
        break;
      case USERVIEWPOINT:
      case MODELVIEWPOINT:
        subscene->hideViewpoint(id);
        break;
      }
    } else if (itertype == SHAPE) {
      char buffer[20];
      buffer[19] = 0;
      (*iter)->getTypeName(buffer, 20);
      if (!strcmp(buffer, "sprites")) {
        // Rprintf("removing from sprites\n");
        SpriteSet* sprite = (SpriteSet*)*iter;
        sprite->remove_shape(id);
      }
    }
  }
}

int Scene::get_id_count(TypeID type)
{
  int count = 0;
  for (std::vector<SceneNode*>::iterator iter = nodes.begin();
       iter != nodes.end(); ++iter) 
    if (type == (*iter)->getTypeID())
      count++;
   
  return count;
}

void Scene::get_ids(TypeID type, int* ids, char** types)
{
  char buffer[20];
  for (std::vector<SceneNode*>::iterator iter = nodes.begin(); iter != nodes.end(); ++ iter) {
    if (type == (*iter)->getTypeID()) {
      *ids++ = (*iter)->getObjID();
      buffer[19] = 0;
      (*iter)->getTypeName(buffer, 20); 
      *types = R_alloc(strlen(buffer)+1, 1);
      strcpy(*types, buffer);        
      types++;
    }
  }
}  

SceneNode* Scene::get_scenenode(int id) 
{
  for (std::vector<SceneNode*>::iterator iter = nodes.begin(); iter != nodes.end(); ++iter) 
    if (id == (*iter)->getObjID())
      return *iter;
  return NULL;
}

SceneNode* Scene::get_scenenode(TypeID type, int id)
{
  SceneNode* node = get_scenenode(id);
  if (node && node->getTypeID() == type)
    return node;
  else
    return NULL;
}
Shape* Scene::get_shape(int id)
{
  return (Shape*)get_scenenode(SHAPE, id);
}

Background* Scene::get_background(int id)
{
  return (Background*)get_scenenode(BACKGROUND, id);
}

BBoxDeco* Scene::get_bboxdeco(int id)
{
  return (BBoxDeco*)get_scenenode(BBOXDECO, id);
}
  
Subscene* Scene::getSubscene(int id)
{
  return (Subscene*)get_scenenode(SUBSCENE, id);
}

Subscene* Scene::whichSubscene(int id)
{
  Subscene* result = rootSubscene.whichSubscene(id);
  if (!result) result = &rootSubscene;
  return result;
}

Subscene* Scene::whichSubscene(int mouseX, int mouseY)
{
  Subscene* result = rootSubscene.whichSubscene(mouseX, mouseY);
  if (!result) result = &rootSubscene;
  return result;
}

Subscene* Scene::setCurrentSubscene(Subscene* subscene)
{
  Subscene* prev = currentSubscene;
  currentSubscene = subscene;
  return prev;
}

void Scene::setupLightModel()
{
#ifndef RGL_NO_OPENGL
  Color global_ambient(0.0f,0.0f,0.0f,1.0f);

  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, global_ambient.data );
  glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, GL_TRUE );
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE );
  SAVEGLERROR;  
#endif
}
  
void Scene::update(RenderContext* renderContext)
{
  rootSubscene.update(renderContext);
}

void Scene::render(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
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

  rootSubscene.render(renderContext, true);  // All opaque stuff
  rootSubscene.render(renderContext, false); // non-opaque stuff
#endif
}


// ---------------------------------------------------------------------------
void Scene::invalidateDisplaylists()
{
  std::vector<SceneNode*>::iterator iter;
  for (iter = nodes.begin(); iter != nodes.end(); ++iter) {
    if ((*iter)->getTypeID() == SHAPE)
      ((Shape*)(*iter))->invalidateDisplaylist();
  }
}

bool rgl::sameID(SceneNode* node, int id)
{ 
  return node->getObjID() == id; 
}
