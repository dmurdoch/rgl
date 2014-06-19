#include "subscene.hpp"
#include "gl2ps.h"
#include "R.h"
#include <algorithm>

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Subscene
//

Subscene::Subscene(Subscene* in_parent, Embedding in_viewport, Embedding in_projection, Embedding in_model,
                   bool in_ignoreExtent)
 : SceneNode(SUBSCENE), parent(in_parent), do_viewport(in_viewport), do_projection(in_projection),
   do_model(in_model), viewport(0.,0.,1.,1.),Zrow(), Wrow(), ignoreExtent(in_ignoreExtent)
{
  userviewpoint = NULL;
  modelviewpoint = NULL;
  bboxdeco   = NULL;
  background = NULL;
  bboxChanges = false;
  data_bbox.invalidate();
  
  for (int i=0; i<4; i++) {
    pviewport[i] = i < 2 ? 0 : 1024;
    for (int j=0;j<4;j++) {
      modelMatrix[4*i + j] = i == j;
      projMatrix[4*i + j] = i == j;
    }
  }  
  newEmbedding();
}

Subscene::~Subscene() 
{
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
    delete (*i);
}

bool Subscene::add(SceneNode* node)
{
  bool success = false;
  switch( node->getTypeID() )
  {
    case SHAPE:
      {
        Shape* shape = (Shape*) node;
        addShape(shape);

        success = true;
      }
      break;
    case LIGHT:
      {
	Light* light = (Light*) node;
	  addLight(light);
	  
	  success = true;
      }
      break;
    case USERVIEWPOINT:
      {
        userviewpoint = (UserViewpoint*) node;
        success = true;
      }
      break;
    case MODELVIEWPOINT:
      {
        modelviewpoint = (ModelViewpoint*) node;
        success = true;
      }
      break;
    case SUBSCENE:
      {
	Subscene* subscene = static_cast<Subscene*>(node);
	if (subscene->getSubscene(getObjID()))
	  error("Cannot add a subscene %d to itself or its child.", subscene->getObjID());
	addSubscene(subscene);
	success = true;
      }
      break;
    case BACKGROUND:
      {
        Background* background = static_cast<Background*>(node);
        addBackground(background);
        success = true;
      }
      break;
    case BBOXDECO:
      { 
        BBoxDeco* bboxdeco = static_cast<BBoxDeco*>(node);
        addBBoxDeco(bboxdeco);
        success = true;
      }
      break;
    default:
      break;
  }
  return success;
}

void Subscene::addBackground(Background* newbackground)
{
  background = newbackground;
}

void Subscene::addBBoxDeco(BBoxDeco* newbboxdeco)
{
  bboxdeco = newbboxdeco;
}

void Subscene::addShape(Shape* shape)
{
  if (!shape->getIgnoreExtent()) 
    addBBox(shape->getBoundingBox(), shape->getBBoxChanges());

  shapes.push_back(shape);
  
  if ( shape->isBlended() ) {
    zsortShapes.push_back(shape);
  } else if ( shape->isClipPlane() ) {
    clipPlanes.push_back(static_cast<ClipPlaneSet*>(shape));
  } else
    unsortedShapes.push_back(shape);
}

void Subscene::addBBox(const AABox& bbox, bool changes)
{
  data_bbox += bbox;
  bboxChanges |= changes;
  if (parent && !ignoreExtent) 
    parent->addBBox(bbox, changes);
}
  
void Subscene::addLight(Light* light)
{
  lights.push_back(light);
}

void Subscene::addSubscene(Subscene* subscene)
{
  subscenes.push_back(subscene);
  if (!subscene->getIgnoreExtent()) 
    addBBox(subscene->getBoundingBox(), subscene->bboxChanges);
}

void Subscene::hideShape(int id)
{
  std::vector<Shape*>::iterator ishape 
     = std::find_if(shapes.begin(), shapes.end(), 
       std::bind2nd(std::ptr_fun(&sameID), id));
  if (ishape == shapes.end()) return;
        
  Shape* shape = *ishape;
  shapes.erase(ishape);
  if ( shape->isBlended() )
    zsortShapes.erase(std::find_if(zsortShapes.begin(), zsortShapes.end(),
                                   std::bind2nd(std::ptr_fun(&sameID), id)));
  else if ( shape->isClipPlane() )
    clipPlanes.erase(std::find_if(clipPlanes.begin(), clipPlanes.end(),
                     std::bind2nd(std::ptr_fun(&sameID), id)));
  else
    unsortedShapes.erase(std::find_if(unsortedShapes.begin(), unsortedShapes.end(),
                         std::bind2nd(std::ptr_fun(&sameID), id)));
      
  calcDataBBox();
}

void Subscene::hideLight(int id)
{
  std::vector<Light*>::iterator ilight = std::find_if(lights.begin(), lights.end(),
                            std::bind2nd(std::ptr_fun(&sameID), id));
  if (ilight != lights.end()) {
    lights.erase(ilight);
  }
}

void Subscene::hideBBoxDeco(int id)
{
  if (bboxdeco && sameID(bboxdeco, id))
    bboxdeco = NULL;
}

void Subscene::hideBackground(int id)
{
  if (background && sameID(background, id))
    background = NULL;
}

Subscene* Subscene::hideSubscene(int id, Subscene* current)
{
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ) {
    if (sameID(*i, id)) {
      if ((*i)->getSubscene(current->getObjID()))
        current = (*i)->parent;  
      subscenes.erase(i);
      calcDataBBox();
      return current;
    } 
  }
  return current;
}

Subscene* Subscene::getSubscene(int id)
{
  if (id == getObjID()) return this;
    
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end() ; ++ i ) {
    Subscene* subscene = (*i)->getSubscene(id);
    if (subscene) return subscene;
  }
  
  return NULL;
}

Subscene* Subscene::whichSubscene(int mouseX, int mouseY)
{
  Subscene* result = NULL;
  Subscene* sub;
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end() ; ++ i ) {
    result = (sub = (*i)->whichSubscene(mouseX, mouseY)) ? sub : result;
  }  
  if (!result && pviewport[0] <= mouseX && mouseX < pviewport[0] + pviewport[2] 
              && pviewport[1] <= mouseY && mouseY < pviewport[1] + pviewport[3])
    result = this;
  return result;
}

int Subscene::getAttributeCount(AABox& bbox, AttribID attrib)
{
  switch (attrib) {
    case IDS:	   
    case TYPES:    return shapes.size();
  }
  return SceneNode::getAttributeCount(bbox, attrib);
}

void Subscene::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);
  int ind = 0;

  if (first + count < n) n = first + count;
  if (first < n) {
    switch(attrib) {
      case IDS:
        for (std::vector<Shape*>::iterator i = shapes.begin(); i != shapes.end() ; ++ i ) {
      	  if ( first <= ind  && ind < n )  
            *result++ = (*i)->getObjID();
          ind++;
        }
        return;
    }  
    SceneNode::getAttribute(bbox, attrib, first, count, result);
  }
}

String Subscene::getTextAttribute(AABox& bbox, AttribID attrib, int index)
{
  int n = getAttributeCount(bbox, attrib);
  if (index < n && attrib == TYPES) {
    char* buffer = R_alloc(20, 1);    
    shapes[index]->getTypeName(buffer, 20);
    return String(strlen(buffer), buffer);
  } else
    return SceneNode::getTextAttribute(bbox, attrib, index);
}

void Subscene::renderClipplanes(RenderContext* renderContext)
{
  std::vector<ClipPlaneSet*>::iterator iter;
  
  ClipPlaneSet::num_planes = 0;
	
  for (iter = clipPlanes.begin() ; iter != clipPlanes.end() ; ++iter ) {
    ClipPlaneSet* plane = *iter;
    plane->render(renderContext);
    SAVEGLERROR;
  }
}

void Subscene::disableClipplanes(RenderContext* renderContext)
{
  std::vector<ClipPlaneSet*>::iterator iter;
	
  for (iter = clipPlanes.begin() ; iter != clipPlanes.end() ; ++iter ) {
    ClipPlaneSet* plane = *iter;
    plane->enable(false);
    SAVEGLERROR;
  }
}
 
int Subscene::get_id_count(TypeID type, bool recursive)
{
  int result = 0;
  if (recursive)
    for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
      result += (*i)->get_id_count(type, recursive);
  switch (type) {
    case SHAPE: {
      result += shapes.size();
      break;
    }
    case LIGHT: {
      result += lights.size();
      break;
    }
    case BBOXDECO: {
      result += bboxdeco ? 1 : 0;
      break;
    }
    case SUBSCENE: {
      result += subscenes.size();
      break;
    }
    case USERVIEWPOINT: {    
      result += do_projection > EMBED_INHERIT ? 1 : 0;
      break;
    }
    case MODELVIEWPOINT: {    
      result += do_model > EMBED_INHERIT ? 1 : 0;
      break;
    }
    case BACKGROUND: {
      result += background ? 1 : 0;
      break;
    }
  }
  return result;
}
    
int Subscene::get_ids(TypeID type, int* ids, char** types, bool recursive)
{
  char buffer[20];
  int count = 0;
  switch(type) {
  case SHAPE: 
    for (std::vector<Shape*>::iterator i = shapes.begin(); i != shapes.end() ; ++ i ) {
      *ids++ = (*i)->getObjID();
      buffer[19] = 0;
      (*i)->getTypeName(buffer, 20);
      *types = R_alloc(strlen(buffer)+1, 1);
      strcpy(*types, buffer);
      types++;
      count++;
    }
    break;
  case LIGHT: 
    for (std::vector<Light*>::iterator i = lights.begin(); i != lights.end() ; ++ i ) {
      *ids++ = (*i)->getObjID();
      *types = R_alloc(strlen("light")+1, 1);
      strcpy(*types, "light");
      types++;
      count++;
    }
    break;
  case BBOXDECO: 
    if (bboxdeco) {
      *ids++ = bboxdeco->getObjID();
      *types = R_alloc(strlen("bboxdeco")+1, 1);
      strcpy(*types, "bboxdeco");
      types++;
      count++;
    }
    break;
  case SUBSCENE: 
    for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) {
      *ids++ = (*i)->getObjID();
      *types = R_alloc(strlen("subscene")+1, 1);
      strcpy(*types, "subscene");
      types++;
      count++;
    }
    break;
  case USERVIEWPOINT:
    if (userviewpoint) {
      *ids++ = userviewpoint->getObjID();
      *types = R_alloc(strlen("userviewpoint")+1, 1);
      strcpy(*types, "userviewpoint");
      types++;
      count++;
    }
    break;
  case MODELVIEWPOINT:
    if (modelviewpoint) {
      *ids++ = modelviewpoint->getObjID();
      *types = R_alloc(strlen("modelviewpoint")+1, 1);
      strcpy(*types, "modelviewpoint");
      types++;
      count++;
    }
    break;
  case BACKGROUND:
    if (background) {
      *ids++ = background->getObjID();
      *types = R_alloc(strlen("background")+1, 1);
      strcpy(*types, "background");
      types++;
      count++;
    }
    break;
  }
  if (recursive)
    for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) {
      int newcount = (*i)->get_ids(type, ids, types, true);
      ids += newcount;
      types += newcount;
      count += newcount;
    }
  return count;
}

Background* Subscene::get_background()
{
  if (background) return background;
  else if (parent) return parent->get_background();
  else return NULL;
}

Background* Subscene::get_background(int id)
{
  Background* background = get_background();
  if (background && background->getObjID() == id)
    return background;
  
  std::vector<Subscene*>::const_iterator iter;
  for(iter = subscenes.begin(); iter != subscenes.end(); ++iter) {
    background = (*iter)->get_background(id);
    if (background) return background;
  }
  return NULL;
}  

BBoxDeco* Subscene::get_bboxdeco()
{
  if (bboxdeco) return bboxdeco;
  else if (parent) return parent->get_bboxdeco();
  else return NULL;
}

BBoxDeco* Subscene::get_bboxdeco(int id)
{
  BBoxDeco* bboxdeco = get_bboxdeco();
  if (bboxdeco && bboxdeco->getObjID() == id)
    return bboxdeco;
  
  std::vector<Subscene*>::const_iterator iter;
  for(iter = subscenes.begin(); iter != subscenes.end(); ++iter) {
    bboxdeco = (*iter)->get_bboxdeco(id);
    if (bboxdeco) return bboxdeco;
  }
  return NULL;
}  


UserViewpoint* Subscene::getUserViewpoint()
{
  if (userviewpoint && do_projection > EMBED_INHERIT)
    return userviewpoint;
  else if (parent) return parent->getUserViewpoint();
  else error("must have a user viewpoint");
}

ModelViewpoint* Subscene::getModelViewpoint()
{
  if (modelviewpoint && do_model > EMBED_INHERIT)
    return modelviewpoint;
  else if (parent) return parent->getModelViewpoint();
  else error("must have a model viewpoint");
}

void Subscene::render(RenderContext* renderContext)
{
  GLdouble saveprojection[16];
  GLint saveviewport[4] = {0,0,0,0};
  
  /* FIXME:  the viewpoint object affects both the projection matrix and the
             model matrix.  We need ugly code to use the right one when 
             one is inherited and the other is not */

  renderContext->subscene = this;
  
  if (do_viewport > EMBED_INHERIT) {
  
    //
    // SETUP VIEWPORT TRANSFORMATION
    //
    if (parent)  
      for (int i=0; i<4; i++) saveviewport[i] = parent->pviewport[i];
    setupViewport(renderContext);

  }
  glGetIntegerv(GL_VIEWPORT, pviewport);  
  SAVEGLERROR;
  
  if (background) {
    GLbitfield clearFlags = background->getClearFlags(renderContext);

    // clear
    glDepthMask(GL_TRUE);
    glClear(clearFlags);
  }

  if (bboxChanges) 
    calcDataBBox();
  
  Sphere total_bsphere;

  if (data_bbox.isValid()) {
    
    // 
    // GET DATA VOLUME SPHERE
    //

    total_bsphere = Sphere( (bboxdeco) ? bboxdeco->getBoundingBox(data_bbox) : data_bbox, getModelViewpoint()->scale );
    if (total_bsphere.radius <= 0.0)
      total_bsphere.radius = 1.0;

  } else {
    total_bsphere = Sphere( Vertex(0,0,0), 1 );
  }

  SAVEGLERROR;
  
  // Now render the current scene.  First we use the projection matrix.  If we're inheriting,
  // just use the parent.
  
  if (do_projection > EMBED_INHERIT) {
    
    for (int i=0; i<16; i++) saveprojection[i] = projMatrix[i];
    setupProjMatrix(renderContext, total_bsphere);
  
  }
  glGetDoublev(GL_PROJECTION_MATRIX, projMatrix);
  
  // Now the model matrix.  Since this depends on both the viewpoint and the model
  // transformations, we don't bother using the parent one, we reconstruct in
  // every subscene.
  
  setupModelViewMatrix(total_bsphere.center);
  glGetDoublev(GL_MODELVIEW_MATRIX, modelMatrix);
  
  setupLights(renderContext);
  
  if (background) {
    //
    // RENDER BACKGROUND
    //

    // DISABLE Z-BUFFER TEST
    glDisable(GL_DEPTH_TEST);

    // DISABLE Z-BUFFER FOR WRITING
    glDepthMask(GL_FALSE);
  
    background->render(renderContext);
    SAVEGLERROR;
  }
  
  //
  // RENDER MODEL
  //

  if (data_bbox.isValid() ) {

    //
    // RENDER SOLID SHAPES
    //

    // ENABLE Z-BUFFER TEST 
    glEnable(GL_DEPTH_TEST);

    // ENABLE Z-BUFFER FOR WRITING
    glDepthMask(GL_TRUE);

    // DISABLE BLENDING
    glDisable(GL_BLEND);
    
    // CLIP PLANES
    renderClipplanes(renderContext);
    
    //
    // RENDER BBOX DECO
    //

    if (bboxdeco) 
      bboxdeco->render(renderContext);  // This changes the modelview/projection/viewport

    SAVEGLERROR;

    renderUnsorted(renderContext);

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

    Matrix4x4 M(modelMatrix);    
    Matrix4x4 P(projMatrix);
    P = P*M;
    
    Zrow = P.getRow(2);
    Wrow = P.getRow(3);
    
    renderZsort(renderContext);
#endif    

    /* Reset flag(s) now that scene has been rendered */
    getModelViewpoint()->scaleChanged = false;

    /* Reset clipplanes */
    disableClipplanes(renderContext);
    SAVEGLERROR;
  }
  
  // Render subscenes
    
  std::vector<Subscene*>::const_iterator iter;
  for(iter = subscenes.begin(); iter != subscenes.end(); ++iter) 
    (*iter)->render(renderContext);
    
  if (do_projection > EMBED_INHERIT) {
    glMatrixMode(GL_PROJECTION);
    glLoadMatrixd(saveprojection);
  }
  
  if (do_viewport > EMBED_INHERIT) 
    glViewport(saveviewport[0], saveviewport[1], saveviewport[2], saveviewport[3]);
  
}

void Subscene::calcDataBBox()
{
  data_bbox.invalidate();
  
  std::vector<Subscene*>::const_iterator subiter;
  bboxChanges = false;
  
  for(subiter = subscenes.begin(); subiter != subscenes.end(); ++subiter) {
    Subscene* subscene = *subiter;
    if (!subscene->getIgnoreExtent()) {
      subscene->calcDataBBox();
      data_bbox += subscene->getBoundingBox();
      bboxChanges |= subscene->bboxChanges;
    }
  }
      
  std::vector<Shape*>::const_iterator iter;
  for(iter = shapes.begin(); iter != shapes.end(); ++iter) {
    Shape* shape = *iter;

    if (!shape->getIgnoreExtent()) {
      data_bbox += shape->getBoundingBox(this);
      bboxChanges |= shape->getBBoxChanges();
    }
  }
}

// ---------------------------------------------------------------------------
void Subscene::setIgnoreExtent(int in_ignoreExtent)
{
  ignoreExtent = (bool)in_ignoreExtent;
}

void Subscene::setupViewport(RenderContext* rctx)
{
  Rect2 rect(0,0,0,0);
  if (do_viewport == EMBED_REPLACE) {
    rect.x = rctx->rect.x + viewport.x*rctx->rect.width;
    rect.y = rctx->rect.y + viewport.y*rctx->rect.height;
    rect.width = rctx->rect.width*viewport.width;
    rect.height = rctx->rect.height*viewport.height;
  } else {
    rect.x = parent->pviewport[0] + viewport.x*parent->pviewport[2];
    rect.y = parent->pviewport[1] + viewport.y*parent->pviewport[3];
    rect.width = parent->pviewport[2]*viewport.width;
    rect.height = parent->pviewport[3]*viewport.height;
  }
  
  glViewport(rect.x, rect.y, rect.width, rect.height);
  glScissor(rect.x, rect.y, rect.width, rect.height);
}

void Subscene::setupProjMatrix(RenderContext* rctx, const Sphere& viewSphere)
{
  glMatrixMode(GL_PROJECTION);
  if (do_projection == EMBED_REPLACE)
    glLoadIdentity();
    
  getUserViewpoint()->setupFrustum(rctx, viewSphere);
    
  SAVEGLERROR;    
}

// The ModelView matrix has components of the user view (the translation at the start)
// and also the model transformations.  The former comes from the userViewpoint,
// the latter from the modelViewpoint, possibly after applying the same from the parents.
// We always reconstruct from scratch rather than trying to use the matrix in place.

void Subscene::setupModelViewMatrix(Vertex center)
{
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  getUserViewpoint()->setupViewer();
  setupModelMatrix(center);
  
  SAVEGLERROR;
}

void Subscene::setupModelMatrix(Vertex center)
{
  if (do_model < EMBED_REPLACE && parent)
    parent->setupModelMatrix(center);
    
  if (do_model > EMBED_INHERIT)
    getModelViewpoint()->setupTransformation(center);
  
  SAVEGLERROR;
}

void Subscene::getModelMatrix(double* modelMatrix, Vertex center)
{
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();
  setupModelMatrix(center);
  glGetDoublev(GL_MODELVIEW_MATRIX, (GLdouble*) modelMatrix);
  glPopMatrix();
}
  
void Subscene::disableLights(RenderContext* rctx)
{
    
  //
  // disable lights; setup will enable them
  //

  for (int i=0;i<8;i++)
    glDisable(GL_LIGHT0 + i);  
}  

void Subscene::setupLights(RenderContext* rctx) 
{  
  int nlights = 0;
  bool anyviewpoint = false;
  std::vector<Light*>::const_iterator iter;
  
  disableLights(rctx);

  for(iter = lights.begin(); iter != lights.end() ; ++iter ) {

    Light* light = *iter;
    light->id = GL_LIGHT0 + (nlights++);
    if (!light->viewpoint)
      light->setup(rctx);
    else
      anyviewpoint = true;
  }

  SAVEGLERROR;

  if (anyviewpoint) {
    //
    // viewpoint lights
    //

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

    for(iter = lights.begin(); iter != lights.end() ; ++iter ) {

      Light* light = *iter;

      if (light->viewpoint)
        light->setup(rctx);
    }
    glPopMatrix();
  }
  SAVEGLERROR;

}

void Subscene::renderUnsorted(RenderContext* renderContext)
{
  std::vector<Shape*>::iterator iter;

  for (iter = unsortedShapes.begin() ; iter != unsortedShapes.end() ; ++iter ) {
    Shape* shape = *iter;
    shape->render(renderContext);
    SAVEGLERROR;
  }
}
    
void Subscene::renderZsort(RenderContext* renderContext)
{  
  std::vector<Shape*>::iterator iter;
  std::multimap<float, ShapeItem*> distanceMap;
  int index = 0;

  for (iter = zsortShapes.begin() ; iter != zsortShapes.end() ; ++iter ) {
    Shape* shape = *iter;
    shape->renderBegin(renderContext);
    for (int j = 0; j < shape->getElementCount(); j++) {
	ShapeItem* item = new ShapeItem(shape, j);
	float distance = getDistance( shape->getElementCenter(j) );
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

const AABox& Subscene::getBoundingBox()
{ 
  if (bboxChanges) 
      calcDataBBox();
  return data_bbox; 
}

void Subscene::newEmbedding()
{
  if (parent) {
    if (do_projection == EMBED_REPLACE && !userviewpoint)
      add(new UserViewpoint(*(parent->getUserViewpoint())));
    else if (do_projection == EMBED_MODIFY && !userviewpoint)
      add(new UserViewpoint(0.0, 1.0)); /* should be like an identity */
    
    if (do_model == EMBED_REPLACE && !modelviewpoint)
      add(new ModelViewpoint(*(parent->getModelViewpoint())));
    else if (do_model == EMBED_MODIFY && !modelviewpoint)
      add(new ModelViewpoint(PolarCoord(0.0, 0.0), Vec3(1.0, 1.0, 1.0), 
                             parent->getModelViewpoint()->isInteractive()));
  }
}

void Subscene::setEmbedding(int which, Embedding value)
{
  switch(which) {
    case 0: do_viewport = value; break;
    case 1: do_projection = value; break;
    case 2: do_model = value; 
  }
  newEmbedding();
}

Embedding Subscene::getEmbedding(int which)
{
  switch(which) {
    case 0: return do_viewport;
    case 1: return do_projection;
    default: return do_model;
  }
}

void Subscene::setViewport(double x, double y, double width, double height)
{
  viewport.x = x;
  viewport.y = y;
  viewport.width = width;
  viewport.height = height;
}

float Subscene::getDistance(const Vertex& v) const
{
  Vertex4 vec = Vertex4(v, 1.0f);

  return (Zrow*vec) / (Wrow*vec);
}
