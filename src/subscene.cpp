#include "subscene.h"
#include "rglview.h"
#include "select.h"
#include "gl2ps.h"
#include "R.h"
#include <algorithm>
#include <functional>

using namespace rgl;

/* Code for debugging 
 
static void printMatrix(const char* msg, double* m) {
  Rprintf("%s:\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n",
          msg, m[0], m[4], m[8], m[12],
                                  m[1], m[5], m[9], m[13],
                                                     m[2], m[6], m[10], m[14],
                                                                         m[3], m[7], m[11], m[15]);
}

static void printMatrix(const char* msg, Matrix4x4 m) {
  double data[16];
  m.getData(data);
  printMatrix(msg, data);
}

static void printMVMatrix(const char* msg) {
  double m[16] = {0};
#ifndef RGL_NO_OPENGL
  glGetDoublev(GL_MODELVIEW_MATRIX, m);
#endif
  printMatrix(msg, m);
}

static void printPRMatrix(const char* msg) {
  double m[16] = {0};
#ifndef RGL_NO_OPENGL
  glGetDoublev(GL_PROJECTION_MATRIX, m);
#endif
  printMatrix(msg, m);  
}

*/

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Subscene
//

Subscene::Subscene(Embedding in_viewport, Embedding in_projection, Embedding in_model,
                   Embedding in_mouseHandlers,
                   bool in_ignoreExtent)
 : SceneNode(SUBSCENE), parent(NULL), do_viewport(in_viewport), do_projection(in_projection),
   do_model(in_model), do_mouseHandlers(in_mouseHandlers), 
   viewport(0.,0.,1.,1.),Zrow(), Wrow(),
   pviewport(0,0,1024,1024), drag(0), ignoreExtent(in_ignoreExtent),
   selectState(msNONE), 
   dragBase(0.0f,0.0f), dragCurrent(0.0f,0.0f)
{
  userviewpoint = NULL;
  modelviewpoint = NULL;
  bboxdeco   = NULL;
  background = NULL;
  bboxChanges = false;
  data_bbox.invalidate();
  modelMatrix.setIdentity();
  projMatrix.setIdentity(); 
  mouseListeners.push_back(this);
  for (int i=0; i<5; i++) {
    mouseMode[i] = mmNONE;
    beginCallback[i] = NULL;
    updateCallback[i] = NULL;
    endCallback[i] = NULL;
    cleanupCallback[i] = NULL;
    for (int j=0; j<3; j++) 
      userData[3*i + j] = NULL;
  }
  setDefaultMouseMode();
}

Subscene::~Subscene() 
{
  // Don't destroy contained subscenes:  they're
  // still in the scene list
  
  for (int i=0; i<5; i++) 
    if (cleanupCallback[i]) 
      (*cleanupCallback[i])(userData + 3*i);
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
	if (subscene->parent)
	  Rf_error("Subscene %d is already a child of subscene %d.", subscene->getObjID(),
	        subscene->parent->getObjID());
	addSubscene(subscene);
	success = true;
      }
      break;
    case BACKGROUND:
      {
        Background* new_background = static_cast<Background*>(node);
        addBackground(new_background);
        success = true;
      }
      break;
    case BBOXDECO:
      { 
        BBoxDeco* new_bboxdeco = static_cast<BBoxDeco*>(node);
        addBBoxDeco(new_bboxdeco);
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
    newBBox();
  } else
    unsortedShapes.push_back(shape);
}

void Subscene::addBBox(const AABox& bbox, bool changes)
{
  bboxChanges |= changes;
  if (data_bbox.isValid()) {
    /* Update will make it test as valid but not
     * handle other shapes, so we don't
     * update unless it is already valid */
    data_bbox += bbox;
    intersectClipplanes();
    if (parent && !ignoreExtent) {
      parent->bboxChanges |= changes;
      parent->newBBox();
    }
  }
}
  
void Subscene::addLight(Light* light)
{
  lights.push_back(light);
}

void Subscene::addSubscene(Subscene* subscene)
{
  subscenes.push_back(subscene);
  subscene->parent = this;
  subscene->newEmbedding();
  if (!subscene->getIgnoreExtent())
    newBBox();
}

void Subscene::hideShape(int id)
{
  std::vector<Shape*>::iterator ishape 
     = std::find_if(shapes.begin(), shapes.end(), 
       std::bind(&sameID, std::placeholders::_1, id));
  if (ishape == shapes.end()) return;
        
  Shape* shape = *ishape;
  shapes.erase(ishape);
  if ( shape->isBlended() )
    zsortShapes.erase(std::find_if(zsortShapes.begin(), zsortShapes.end(),
                                   std::bind(&sameID, std::placeholders::_1, id)));
  else if ( shape->isClipPlane() )
    clipPlanes.erase(std::find_if(clipPlanes.begin(), clipPlanes.end(),
                     std::bind(&sameID, std::placeholders::_1, id)));
  else
    unsortedShapes.erase(std::find_if(unsortedShapes.begin(), unsortedShapes.end(),
                         std::bind(&sameID, std::placeholders::_1, id)));
      
  newBBox();
}

void Subscene::hideLight(int id)
{
  std::vector<Light*>::iterator ilight = std::find_if(lights.begin(), lights.end(),
                            std::bind(&sameID, std::placeholders::_1, id));
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
  if (background && sameID(background, id)) {
    if (parent)
      background = NULL;
    else
      background = new( Background );  /* The root must always have a background */
  }
}

Subscene* Subscene::hideSubscene(int id, Subscene* current)
{
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i) {
    if (sameID(*i, id)) {
      if ((*i)->getSubscene(current->getObjID()))
        current = (*i)->parent;  
      (*i)->parent = NULL;
      subscenes.erase(i);
      newBBox();
      return current;
    } 
  }
  return current;
}

void Subscene::hideViewpoint(int id)
{
  if (userviewpoint && sameID(userviewpoint, id)) {
    if (parent)            /* the root needs a viewpoint */
      userviewpoint = NULL;
  } else if (modelviewpoint && sameID(modelviewpoint, id)) {
    if (parent)            /* the root needs a viewpoint */
      modelviewpoint = NULL;
  } 
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

Subscene* Subscene::whichSubscene(int id)
{
  for (std::vector<Shape*>::iterator i = shapes.begin(); i != shapes.end() ; ++ i ) {
    if ((*i)->getObjID() == id)
      return this;
  }
  for (std::vector<Light*>::iterator i = lights.begin(); i != lights.end() ; ++ i ) {
    if ((*i)->getObjID() == id)
      return this;
  }
  if (bboxdeco && bboxdeco->getObjID() == id)
    return this;
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) {
    if ((*i)->getObjID() == id)
      return this;
  }
  if (userviewpoint && userviewpoint->getObjID() == id)
    return this;
  if (modelviewpoint && modelviewpoint->getObjID() == id)
    return this;
  if (background && background->getObjID() == id)
    return this;
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end() ; ++ i ) {
    Subscene* result = (*i)->whichSubscene(id);
    if (result) 
      return result;
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
  if (!result && pviewport.x <= mouseX && mouseX < pviewport.x + pviewport.width 
              && pviewport.y <= mouseY && mouseY < pviewport.y + pviewport.height)
    result = this;
  return result;
}

int Subscene::getAttributeCount(SceneNode* subscene, AttribID attrib)
{
  switch (attrib) {
    case IDS:	   
    case TYPES:    return (int)shapes.size();
  }
  return SceneNode::getAttributeCount(subscene, attrib);
}

void Subscene::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
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
    SceneNode::getAttribute(subscene, attrib, first, count, result);
  }
}

std::string Subscene::getTextAttribute(SceneNode* subscene, AttribID attrib, int index)
{
  int n = getAttributeCount(subscene, attrib);
  if (index < n && attrib == TYPES) {
    return shapes[index]->getTypeName();
  } else
    return SceneNode::getTextAttribute(subscene, attrib, index);
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
  int count = 0;
  switch(type) {
  case SHAPE: 
    for (std::vector<Shape*>::iterator i = shapes.begin(); i != shapes.end() ; ++ i ) {
      *ids++ = (*i)->getObjID();
      *types = copyStringToR((*i)->getTypeName());
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
  Background* this_background = get_background();
  if (this_background && this_background->getObjID() == id)
    return this_background;
  
  std::vector<Subscene*>::const_iterator iter;
  for(iter = subscenes.begin(); iter != subscenes.end(); ++iter) {
    this_background = (*iter)->get_background(id);
    if (this_background) return this_background;
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
  BBoxDeco* this_bboxdeco = get_bboxdeco();
  if (this_bboxdeco && this_bboxdeco->getObjID() == id)
    return this_bboxdeco;
  
  std::vector<Subscene*>::const_iterator iter;
  for(iter = subscenes.begin(); iter != subscenes.end(); ++iter) {
    this_bboxdeco = (*iter)->get_bboxdeco(id);
    if (this_bboxdeco) return this_bboxdeco;
  }
  return NULL;
}  


UserViewpoint* Subscene::getUserViewpoint()
{
  if (userviewpoint && do_projection > EMBED_INHERIT)
    return userviewpoint;
  else if (parent) return parent->getUserViewpoint();
  else Rf_error("must have a user viewpoint");
}

ModelViewpoint* Subscene::getModelViewpoint()
{
  if (modelviewpoint && do_model > EMBED_INHERIT)
    return modelviewpoint;
  else if (parent) return parent->getModelViewpoint();
  else Rf_error("must have a model viewpoint");
}

void Subscene::update(RenderContext* renderContext)
{
  GLdouble saveprojection[16];
  

  renderContext->subscene = this;
  
  setupViewport(renderContext);
  
  // Make sure bounding box is up to date.
  
  getBoundingBox();
  
  // Now get the matrices.  First we compute the projection matrix.  If we're inheriting,
  // just use the parent.
  
  if (do_projection > EMBED_INHERIT) {
    projMatrix.getData(saveprojection);
    setupProjMatrix(renderContext);
  } else
    projMatrix = parent->projMatrix;
  
  // Now the model matrix.  Since this depends on both the viewpoint and the model
  // transformations, we don't bother using the parent one, we reconstruct in
  // every subscene.
  
  if (do_projection > EMBED_INHERIT || do_model > EMBED_INHERIT)
    setupModelViewMatrix(renderContext);
  else
    modelMatrix = parent->modelMatrix;
    
  // update subscenes
    
  std::vector<Subscene*>::const_iterator iter;
  for(iter = subscenes.begin(); iter != subscenes.end(); ++iter) 
    (*iter)->update(renderContext);
    
}

void Subscene::loadMatrices()
{
#ifndef RGL_NO_OPENGL  
  double mat[16];
  projMatrix.getData(mat);
  glMatrixMode(GL_PROJECTION);
  glLoadMatrixd(mat);  
  SAVEGLERROR; 
  
  modelMatrix.getData(mat);
  glMatrixMode(GL_MODELVIEW);  
  glLoadMatrixd(mat);
  SAVEGLERROR;
#endif
}

void Subscene::render(RenderContext* renderContext, bool opaquePass)
{
#ifndef RGL_NO_OPENGL  
  renderContext->subscene = this;
  
  glViewport(pviewport.x, pviewport.y, pviewport.width, pviewport.height);
  glScissor(pviewport.x, pviewport.y, pviewport.width, pviewport.height);
  SAVEGLERROR;
  
  if (background && opaquePass) {
    GLbitfield clearFlags = background->getClearFlags(renderContext);

    // clear
    glDepthMask(GL_TRUE);
    glClear(clearFlags);
  }
  SAVEGLERROR;
  
  // Make sure bounding boxes are up to date.
  
  getBoundingBox();
  
  // Now render the current scene.  First we load the projection matrix, then the modelview matrix.
  
  loadMatrices();
  
  setupLights(renderContext);
  
  if (opaquePass) {
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

    if (bboxdeco) 
      bboxdeco->render(renderContext);  // This changes the modelview/projection/viewport

    SAVEGLERROR;
  }
  // CLIP PLANES
  renderClipplanes(renderContext);
  
  if (opaquePass) {
    renderUnsorted(renderContext);

// #define NO_BLEND
  } else {
#ifndef NO_BLEND
    //
    // RENDER BLENDED SHAPES
    //
    // render shapes in bounding-box sorted order according to z value
    //

    // DISABLE Z-BUFFER FOR WRITING
    glDepthMask(GL_FALSE);
    
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
  }
  /* Reset flag(s) now that scene has been rendered */
  getModelViewpoint()->scaleChanged = false;

  /* Reset clipplanes */
  disableClipplanes(renderContext);
  SAVEGLERROR;
  
  // Render subscenes
    
  std::vector<Subscene*>::const_iterator iter;
  for(iter = subscenes.begin(); iter != subscenes.end(); ++iter) 
    (*iter)->render(renderContext, opaquePass);
  
  if (selectState == msCHANGING) {
    SELECT select;
    select.render(mousePosition);
  }
#endif
}

// static void printbbox(AABox bbox) {
//   Rprintf("%.3g %.3g %.3g %.3g %.3g %.3g\n",
//           bbox.vmin.x, bbox.vmax.x,
//           bbox.vmin.y, bbox.vmax.y,
//           bbox.vmin.z, bbox.vmax.z);  
// }

void Subscene::calcDataBBox()
{
  data_bbox.invalidate();
  
  std::vector<Subscene*>::const_iterator subiter;
  bboxChanges = false;
  for(subiter = subscenes.begin(); subiter != subscenes.end(); ++subiter) {
    Subscene* subscene = *subiter;
    if (!subscene->getIgnoreExtent()) {
      AABox sub_bbox = subscene->getBoundingBox();
      
      if (!sub_bbox.isEmpty()) {
        Matrix4x4 M;
        if (subscene->getEmbedding(EM_MODEL) > EMBED_INHERIT) {
          double matrix[16];
          subscene->getUserMatrix(matrix);
          M.loadData(matrix);
        } else
          M.setIdentity();
        if (subscene->getEmbedding(EM_PROJECTION) > EMBED_INHERIT) {
          double scale[3];
          subscene->getScale(scale);
          M = Matrix4x4::scaleMatrix(scale[0], scale[1], scale[2])*M;
        }
        sub_bbox = sub_bbox.transform(M);
        data_bbox += sub_bbox;
      }
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
  intersectClipplanes(); 
  if (!data_bbox.isValid())
    data_bbox.setEmpty();
}

void Subscene::intersectClipplanes(void) 
{
  std::vector<ClipPlaneSet*>::iterator iter;
  for (iter = clipPlanes.begin() ; iter != clipPlanes.end() ; ++iter ) {
      ClipPlaneSet* plane = *iter;
      plane->intersectBBox(data_bbox);
      SAVEGLERROR;
  }
}

/* Call this when the bbox changes */
void Subscene::newBBox(void)
{
  data_bbox.invalidate();
  if (parent && !ignoreExtent) 
    parent->newBBox();
}

// ---------------------------------------------------------------------------
void Subscene::setIgnoreExtent(int in_ignoreExtent)
{
  if (ignoreExtent != (bool)in_ignoreExtent) {
    ignoreExtent = (bool)in_ignoreExtent;
    if (parent)
      parent->newBBox();
  }
}

void Subscene::setupViewport(RenderContext* rctx)
{
  Rect2 rect(0,0,0,0);
  if (do_viewport == EMBED_REPLACE) {
    rect.x = static_cast<int>(rctx->rect.x + viewport.x*rctx->rect.width);
    rect.y = static_cast<int>(rctx->rect.y + viewport.y*rctx->rect.height);
    rect.width = static_cast<int>(rctx->rect.width*viewport.width);
    rect.height = static_cast<int>(rctx->rect.height*viewport.height);
  } else {
    rect.x = static_cast<int>(parent->pviewport.x + viewport.x*parent->pviewport.width);
    rect.y = static_cast<int>(parent->pviewport.y + viewport.y*parent->pviewport.height);
    rect.width = static_cast<int>(parent->pviewport.width*viewport.width);
    rect.height = static_cast<int>(parent->pviewport.height*viewport.height);
  }
  pviewport = rect;
}

void Subscene::setupProjMatrix(RenderContext* rctx)
{
  if (do_projection == EMBED_REPLACE) 
    projMatrix.setIdentity();

  getUserViewpoint()->setupProjMatrix(rctx, getViewSphere());   
}

// The ModelView matrix has components of the user view (the translation at the start)
// and also the model transformations.  The former comes from the userViewpoint,
// the latter from the modelViewpoint, possibly after applying the same from the parents.
// We always reconstruct from scratch rather than trying to use the matrix in place.

void Subscene::setupModelViewMatrix(RenderContext* rctx)
{
  modelMatrix.setIdentity();
  getUserViewpoint()->setupViewer(rctx);
  setupModelMatrix(rctx);
}

void Subscene::setupModelMatrix(RenderContext* rctx)
{
  /* This sets the active subscene
     modelMatrix, not the local one (though often
     they're the same one). */
     
  if (do_model < EMBED_REPLACE && parent) 
    parent->setupModelMatrix(rctx);
    
  if (do_model > EMBED_INHERIT)
    getModelViewpoint()->setupTransformation(rctx);
  
  if (do_model == EMBED_REPLACE) {
    Vertex center = getViewSphere().center;

    rctx->subscene->modelMatrix = 
      rctx->subscene->modelMatrix * 
      Matrix4x4::translationMatrix(-center.x, -center.y, -center.z);
  }
}

// 
// GET DATA VOLUME SPHERE
//

Sphere Subscene::getViewSphere() 
{
  Sphere total_bsphere;
  if (data_bbox.isValid()) {
    total_bsphere = Sphere( (bboxdeco) ? bboxdeco->getBoundingBox(data_bbox) : data_bbox, getModelViewpoint()->scale );
    if (total_bsphere.radius <= 0.0)
      total_bsphere.radius = 1.0;
    } else
    total_bsphere = Sphere( Vertex(0,0,0), 1 );
  return total_bsphere;
}

void Subscene::disableLights(RenderContext* rctx)
{
    
  //
  // disable lights; setup will enable them
  //
#ifndef RGL_NO_OPENGL
  for (int i=0;i<8;i++)
    glDisable(GL_LIGHT0 + i);  
#endif
}  

void Subscene::setupLights(RenderContext* rctx) 
{  
#ifndef RGL_NO_OPENGL
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
  
  if (nlights == 0 && parent)
    parent->setupLights(rctx);

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
#endif
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
    for (int j = 0; j < shape->getPrimitiveCount(); j++) {
      ShapeItem* item = new ShapeItem(shape, j);
      float distance = getDistance( shape->getPrimitiveCenter(j) );
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
      shape->drawPrimitive(renderContext, item->itemnum);
      delete item;
    }
    if (prev) prev->drawEnd(renderContext);
  }
}

const AABox& Subscene::getBoundingBox()
{ 
  if (bboxChanges || !data_bbox.isValid()) {
    // Rprintf("recalc bbox for %d\n", getObjID());
    calcDataBBox();
    // Rprintf("%d: ", getObjID());
    // if (data_bbox.isEmpty())
    //   Rprintf("empty\n");
    // else if (data_bbox.isValid())
    //   Rprintf("%.1f %.1f\n", data_bbox.vmin.x, data_bbox.vmax.x);
    // else
    //   Rprintf("invalid\n", data_bbox.vmin.x, data_bbox.vmax.x);
  }
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
    case 2: do_model = value; break;
    case 3: do_mouseHandlers = value; break;
  }
  newEmbedding();
}

// #include <unistd.h>
Embedding Subscene::getEmbedding(Embedded which)
{
//  Rprintf("getEmbedding %d, subscene %d\n", which, getObjID());
//  usleep(1000000);
  switch(which) {
    case EM_VIEWPORT:      return do_viewport;
    case EM_PROJECTION:    return do_projection;
    case EM_MODEL:         return do_model;
    case EM_MOUSEHANDLERS: return do_mouseHandlers;
    default: Rf_error("Bad embedding requested");
  }
}

Subscene* Subscene::getMaster(Embedded which) 
{
  if (getEmbedding(which) == EMBED_INHERIT)
    return getParent()->getMaster(which);
  else
    return this;
}

void Subscene::getUserMatrix(double* dest)
{
  ModelViewpoint* this_modelviewpoint = getModelViewpoint();
  this_modelviewpoint->getUserMatrix(dest);
}

void Subscene::setUserMatrix(double* src)
{
  ModelViewpoint* this_modelviewpoint = getModelViewpoint();
  this_modelviewpoint->setUserMatrix(src);
  newBBox();
}

void Subscene::getUserProjection(double* dest)
{
  UserViewpoint* this_userviewpoint = getUserViewpoint();
  this_userviewpoint->getUserProjection(dest);
}

void Subscene::setUserProjection(double* src)
{
  UserViewpoint* this_userviewpoint = getUserViewpoint();
  this_userviewpoint->setUserProjection(src);
}

void Subscene::getScale(double* dest)
{
  ModelViewpoint* this_modelviewpoint = getModelViewpoint();
  this_modelviewpoint->getScale(dest);
}

void Subscene::setScale(double* src)
{
  ModelViewpoint* this_modelviewpoint = getModelViewpoint();
  this_modelviewpoint->setScale(src);
}

void Subscene::getPosition(double* dest)
{
  ModelViewpoint* this_modelviewpoint = getModelViewpoint();
  this_modelviewpoint->getPosition(dest);
}

void Subscene::setPosition(double* src)
{
  ModelViewpoint* this_modelviewpoint = getModelViewpoint();
  this_modelviewpoint->setPosition(src);
}

void Subscene::setViewport(double x, double y, double width, double height)
{
  viewport.x = x;
  viewport.y = y;
  viewport.width = width;
  viewport.height = height;
}

void Subscene::clearMouseListeners()
{
  mouseListeners.clear();
}

void Subscene::addMouseListener(Subscene* sub)
{
  mouseListeners.push_back(sub);
}

void Subscene::deleteMouseListener(Subscene* sub)
{
  for (unsigned int i=0; i < mouseListeners.size(); i++) {
    if (sub == mouseListeners[i]) {
      mouseListeners.erase(mouseListeners.begin() + i);
      return;
    }
  }
}

void Subscene::getMouseListeners(size_t max, int* ids)
{
  max = max > mouseListeners.size() ? mouseListeners.size() : max;  
  for (unsigned int i = 0; i < max; i++)
    ids[i] = mouseListeners[i]->getObjID();
}

float Subscene::getDistance(const Vertex& v) const
{
  Vertex4 vec = Vertex4(v, 1.0f);

  return (Zrow*vec) / (Wrow*vec);
}

viewControlPtr Subscene::getButtonBeginFunc(int button) {
  return getMaster(EM_MOUSEHANDLERS)->ButtonBeginFunc[button];
}

void Subscene::buttonBegin(int button, int mouseX, int mouseY)
{
  (this->*getButtonBeginFunc(button))(mouseX, mouseY);
}

viewControlPtr Subscene::getButtonUpdateFunc(int button) 
{  
  return getMaster(EM_MOUSEHANDLERS)->ButtonUpdateFunc[button];
}

void Subscene::buttonUpdate(int button, int mouseX, int mouseY)
{
  if (button == bnNOBUTTON && needsBegin != mmNONE) {
    buttonBegin(button, mouseX, mouseY);
    needsBegin = mmNONE;
  }
  (this->*getButtonUpdateFunc(button))(mouseX, mouseY);
}

viewControlEndPtr Subscene::getButtonEndFunc(int button)
{
  return getMaster(EM_MOUSEHANDLERS)->ButtonEndFunc[button];  
}

void Subscene::buttonEnd(int button)
{
  (this->*getButtonEndFunc(button))();
}

void Subscene::setDefaultMouseMode()
{
  setMouseMode(bnNOBUTTON,mmNONE);
  setMouseMode(bnLEFT,    mmTRACKBALL);
  setMouseMode(bnRIGHT,   mmZOOM);
  setMouseMode(bnMIDDLE,  mmFOV);
  setMouseMode(bnWHEEL,   wmPULL);

  needsBegin = mmNONE;
  busy = false;
}

bool Subscene::mouseNeedsWatching() {
  if (mouseMode[bnNOBUTTON] != mmNONE)
    return true;
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
    if ((*i)->mouseNeedsWatching())
      return true;
  return false;
}

void Subscene::setMouseMode(int button, MouseModeID mode)
{
  if (getEmbedding(EM_MOUSEHANDLERS) == EMBED_INHERIT)
    getParent()->setMouseMode(button, mode);
  else {
    mouseMode[button] = mode;
    if (button == bnNOBUTTON)
      needsBegin = mode;
    switch (mode) {
      case mmNONE:
        ButtonBeginFunc[button] = &Subscene::noneBegin;
        ButtonUpdateFunc[button] = &Subscene::noneUpdate;
        ButtonEndFunc[button] = &Subscene::noneEnd;
        break;
      case mmTRACKBALL:
        ButtonBeginFunc[button] = &Subscene::trackballBegin;
        ButtonUpdateFunc[button] = &Subscene::trackballUpdate;
        ButtonEndFunc[button] = &Subscene::trackballEnd;
        break;
      case mmXAXIS:
      case mmYAXIS:
      case mmZAXIS:
        ButtonBeginFunc[button] = &Subscene::oneAxisBegin;
        ButtonUpdateFunc[button] = &Subscene::oneAxisUpdate;
        ButtonEndFunc[button] = &Subscene::trackballEnd; // No need for separate function
        if (mode == mmXAXIS)      axis[button] = Vertex(1,0,0);
        else if (mode == mmYAXIS) axis[button] = Vertex(0,1,0);
        else                      axis[button] = Vertex(0,0,1);
        break;	    	
      case mmPOLAR:
        ButtonBeginFunc[button] = &Subscene::polarBegin;
        ButtonUpdateFunc[button] = &Subscene::polarUpdate;
        ButtonEndFunc[button] = &Subscene::polarEnd;
        break;
      case mmSELECTING:
        ButtonBeginFunc[button] = &Subscene::mouseSelectionBegin;
        ButtonUpdateFunc[button] = &Subscene::mouseSelectionUpdate;
        ButtonEndFunc[button] = &Subscene::mouseSelectionEnd;
        break;
      case mmZOOM:
        ButtonBeginFunc[button] = &Subscene::adjustZoomBegin;
        ButtonUpdateFunc[button] = &Subscene::adjustZoomUpdate;
        ButtonEndFunc[button] = &Subscene::adjustZoomEnd;
        break;
      case mmFOV:
        ButtonBeginFunc[button] = &Subscene::adjustFOVBegin;
        ButtonUpdateFunc[button] = &Subscene::adjustFOVUpdate;
        ButtonEndFunc[button] = &Subscene::adjustFOVEnd;
        break;
      case mmUSER:
        ButtonBeginFunc[button] = &Subscene::userBegin;
        ButtonUpdateFunc[button] = &Subscene::userUpdate;
        ButtonEndFunc[button] = &Subscene::userEnd;
        break;
      case wmPULL:
        if (button == bnWHEEL)
          WheelRotateFunc = &Subscene::wheelRotatePull;
        break;
      case wmPUSH:
        if (button == bnWHEEL)
          WheelRotateFunc = &Subscene::wheelRotatePush;
        break;
      case wmUSER2:
        if (button == bnWHEEL)
          WheelRotateFunc = &Subscene::userWheel;
        break;
    }
  }
}

void Subscene::setMouseCallbacks(int button, userControlPtr begin, userControlPtr update, 
                                 userControlEndPtr end, userCleanupPtr cleanup, void** user)
{
  if (getEmbedding(EM_MOUSEHANDLERS) == EMBED_INHERIT)
    getParent()->setMouseCallbacks(button, begin, update, end, cleanup, user);  
  else {
    if (cleanupCallback[button])
      (*cleanupCallback[button])(userData + 3*button);
    beginCallback[button] = begin;
    updateCallback[button] = update;
    endCallback[button] = end;
    cleanupCallback[button] = cleanup;
    userData[3*button + 0] = *(user++);
    userData[3*button + 1] = *(user++);
    userData[3*button + 2] = *user;
    setMouseMode(button, mmUSER);
  }
}

void Subscene::getMouseCallbacks(int button, userControlPtr *begin, userControlPtr *update, 
                                 userControlEndPtr *end, userCleanupPtr *cleanup, void** user)
{
  if (getEmbedding(EM_MOUSEHANDLERS) == EMBED_INHERIT)
    getParent()->getMouseCallbacks(button, begin, update, end, cleanup, user); 
  else {
    *begin = beginCallback[button];
    *update = updateCallback[button];
    *end = endCallback[button];
    *cleanup = cleanupCallback[button];
    *(user++) = userData[3*button + 0];
    *(user++) = userData[3*button + 1];
    *(user++) = userData[3*button + 2];
  }
} 

MouseModeID Subscene::getMouseMode(int button)
{
  return getMaster(EM_MOUSEHANDLERS)->mouseMode[button];
}

void Subscene::setWheelCallback(userWheelPtr wheel, void* user)
{
  if (getEmbedding(EM_MOUSEHANDLERS) == EMBED_INHERIT)
    getParent()->setWheelCallback(wheel, user);
  else {
    wheelCallback = wheel;
    wheelData = user;
    setMouseMode(bnWHEEL, wmUSER2); 
  }
}

void Subscene::getWheelCallback(userWheelPtr *wheel, void** user)
{
  if (getEmbedding(EM_MOUSEHANDLERS) == EMBED_INHERIT)
    getParent()->getWheelCallback(wheel, user);   
  *wheel = wheelCallback;
  *user = wheelData;
}


//
// FUNCTION
//   screenToPolar
//
// DESCRIPTION
//   screen space is the same as in OpenGL, starting 0,0 at left/bottom(!) of viewport
//

static PolarCoord screenToPolar(int width, int height, int mouseX, int mouseY) {
  
  float cubelen, cx,cy,dx,dy,r;
  
  cubelen = (float) getMin(width,height);
  r   = cubelen * 0.5f;
  
  cx  = ((float)width)  * 0.5f;
  cy  = ((float)height) * 0.5f;
  dx  = ((float)mouseX) - cx;
  dy  = ((float)mouseY) - cy;
  
  //
  // dx,dy = distance to center in pixels
  //
  
  dx = clamp(dx, -r,r);
  dy = clamp(dy, -r,r);
  
  //
  // sin theta = dx / r
  // sin phi   = dy / r
  //
  // phi   = arc sin ( sin theta )
  // theta = arc sin ( sin phi   )
  //
  
  return PolarCoord(
    
    math::rad2deg( math::asin( dx/r ) ),
    math::rad2deg( math::asin( dy/r ) )
    
  );
  
}

static Vertex screenToVector(int width, int height, int mouseX, int mouseY) {
  
  float radius = (float) getMax(width, height) * 0.5f;
  
  float cx = ((float)width) * 0.5f;
  float cy = ((float)height) * 0.5f;
  float x  = (((float)mouseX) - cx)/radius;
  float y  = (((float)mouseY) - cy)/radius;
  
  // Make unit vector
  
  float len = sqrt(x*x + y*y);
  if (len > 1.0e-6) {
    x = x/len;
    y = y/len;
  }
  // Find length to first edge
  
  float maxlen = math::sqrt(2.0f);
  
  // zero length is vertical, max length is horizontal
  float angle = (maxlen - len)/maxlen*math::pi<float>()/2.0f;
  
  float z = math::sin(angle);
  
  // renorm to unit length
  
  len = math::sqrt(1.0f - z*z);
  x = x*len;
  y = y*len;
  
  return Vertex(x, y, z);
}

void Subscene::trackballBegin(int mouseX, int mouseY)
{
  rotBase = screenToVector(pviewport.width,pviewport.height,mouseX,mouseY);
}

void Subscene::trackballUpdate(int mouseX, int mouseY)
{
  rotCurrent = screenToVector(pviewport.width,pviewport.height,mouseX,mouseY);
  for (unsigned int i = 0; i < mouseListeners.size(); i++) {
    Subscene* sub = mouseListeners[i];
    if (sub) {
      ModelViewpoint* this_modelviewpoint = sub->getModelViewpoint();
      this_modelviewpoint->updateMouseMatrix(rotBase,rotCurrent);
    }
  }
}

void Subscene::trackballEnd()
{
  for (unsigned int i = 0; i < mouseListeners.size(); i++) {
    Subscene* sub = mouseListeners[i];
    if (sub) {   
      ModelViewpoint* this_modelviewpoint = sub->getModelViewpoint();
      this_modelviewpoint->mergeMouseMatrix();
    }
  }
}

void Subscene::oneAxisBegin(int mouseX, int mouseY)
{
  rotBase = screenToVector(pviewport.width,pviewport.height,mouseX,pviewport.height/2);
}

void Subscene::oneAxisUpdate(int mouseX, int mouseY)
{
  rotCurrent = screenToVector(pviewport.width,pviewport.height,mouseX,pviewport.height/2);
  for (unsigned int i = 0; i < mouseListeners.size(); i++) {
    Subscene* sub = mouseListeners[i];
    if (sub) {
      ModelViewpoint* this_modelviewpoint = sub->getModelViewpoint();
      this_modelviewpoint->mouseOneAxis(rotBase,rotCurrent,axis[drag-1]);
    }
    
  }
}

void Subscene::polarBegin(int mouseX, int mouseY)
{
  ModelViewpoint* this_modelviewpoint = getModelViewpoint();
  
  camBase = this_modelviewpoint->getPosition();
  
  dragBase = screenToPolar(pviewport.width,pviewport.height,mouseX,mouseY);
  
}

void Subscene::polarUpdate(int mouseX, int mouseY)
{
  dragCurrent = screenToPolar(pviewport.width,pviewport.height,mouseX,mouseY);
  
  PolarCoord newpos = camBase - ( dragCurrent - dragBase );
  
  newpos.phi = clamp( newpos.phi, -90.0f, 90.0f );
  for (unsigned int i = 0; i < mouseListeners.size(); i++) {
    Subscene* sub = mouseListeners[i];
    if (sub) {   
      ModelViewpoint* this_modelviewpoint = sub->getModelViewpoint();
      this_modelviewpoint->setPosition( newpos );
    }
  }
}

void Subscene::polarEnd()
{
  
  //    Viewpoint* viewpoint = scene->getViewpoint();
  //    viewpoint->mergeMouseMatrix();
  
}

void Subscene::adjustFOVBegin(int mouseX, int mouseY)
{
  fovBaseY = mouseY;
}


void Subscene::adjustFOVUpdate(int mouseX, int mouseY)
{
  int dy = mouseY - fovBaseY;
  
  float py = -((float)dy/(float)pviewport.height) * 180.0f;
  
  for (unsigned int i = 0; i < mouseListeners.size(); i++) {
    Subscene* sub = mouseListeners[i];
    if (sub) {
      UserViewpoint* this_userviewpoint = sub->getUserViewpoint();
      this_userviewpoint->setFOV( this_userviewpoint->getFOV() + py );
    }
  }
  
  fovBaseY = mouseY;
}


void Subscene::adjustFOVEnd()
{
}

void Subscene::wheelRotatePull(int dir)
{
  for (unsigned int i = 0; i < mouseListeners.size(); i++) {
    Subscene* sub = mouseListeners[i];
    if (sub) {
      UserViewpoint* this_userviewpoint = sub->getUserViewpoint();
      float zoom = this_userviewpoint->getZoom();
      
#define ZOOM_STEP  1.05f 
#define ZOOM_PIXELLOGSTEP 0.02f
#define ZOOM_MIN  0.0001f
#define ZOOM_MAX  10000.0f      
      switch(dir)
      {
      case GUI_WheelForward:
        zoom *= ZOOM_STEP;
        break;
      case GUI_WheelBackward:
        zoom /= ZOOM_STEP;
        break;
      }
      
      zoom = clamp( zoom , ZOOM_MIN, ZOOM_MAX);
      this_userviewpoint->setZoom(zoom);
    }
  }
}

void Subscene::wheelRotatePush(int dir)
{
  switch (dir)
  {
  case GUI_WheelForward:
    wheelRotatePull(GUI_WheelBackward);
    break;
  case GUI_WheelBackward:
    wheelRotatePull(GUI_WheelForward);
    break;
  }
}

void Subscene::wheelRotate(int dir)
{
  int mode = getMouseMode(bnWHEEL);
  if (mode >= wmPULL)
    (this->*WheelRotateFunc)(dir);
  else {
    // Need to fake a click and release dir = 1 rotates away, dir = 2 rotates towards
    buttonBegin(bnWHEEL, pviewport.width / 2, pviewport.height / 2);
    buttonUpdate(bnWHEEL, pviewport.width / 2, pviewport.height / 2 + 10*(dir == 1 ? 1 : -1));
    buttonEnd(bnWHEEL);
  }
}

void Subscene::userBegin(int mouseX, int mouseY)
{
  Subscene* master = getMaster(EM_MOUSEHANDLERS);
  beginCallback[drag] = master->beginCallback[drag];
  void* this_userData = master->userData[3*drag+0];
  activeButton = drag;
  if (beginCallback[drag]) {
    busy = true;
    (*beginCallback[drag])(this_userData, mouseX, pviewport.height-mouseY);
    busy = false;
  }
}


void Subscene::userUpdate(int mouseX, int mouseY)
{
  Subscene* master = getMaster(EM_MOUSEHANDLERS);
  updateCallback[activeButton] = master->updateCallback[activeButton];
  void* this_userData = master->userData[3*activeButton+1];
  if (!busy && updateCallback[activeButton]) {
    busy = true;
    (*updateCallback[activeButton])(this_userData, mouseX, pviewport.height-mouseY);
    busy = false;
  }
}

void Subscene::userEnd()
{
  Subscene* master = getMaster(EM_MOUSEHANDLERS);
  endCallback[activeButton] = master->endCallback[activeButton];
  void* this_userData = master->userData[3*activeButton+2];
  if (endCallback[activeButton])
    (*endCallback[activeButton])(this_userData);
}

void Subscene::userWheel(int dir)
{
  wheelCallback = getMaster(EM_MOUSEHANDLERS)->wheelCallback;
  if (wheelCallback)
    (*wheelCallback)(wheelData, dir);
}

void Subscene::adjustZoomBegin(int mouseX, int mouseY)
{
  zoomBaseY = mouseY;
}


void Subscene::adjustZoomUpdate(int mouseX, int mouseY)
{
  int dy = mouseY - zoomBaseY;
  for (unsigned int i = 0; i < mouseListeners.size(); i++) {
    Subscene* sub = mouseListeners[i];
    if (sub) {
      UserViewpoint* this_userviewpoint = sub->getUserViewpoint();
      
      float zoom = clamp ( this_userviewpoint->getZoom() * exp(dy*ZOOM_PIXELLOGSTEP), ZOOM_MIN, ZOOM_MAX);
      // Rprintf("zoom = %f for subscene %d\n", zoom, sub->getObjID());
      this_userviewpoint->setZoom(zoom);
    }
  }
  
  zoomBaseY = mouseY;
}


void Subscene::adjustZoomEnd()
{
}

double* Subscene::getMousePosition()
{
  return mousePosition;
}

MouseSelectionID Subscene::getSelectState() 
{
  return selectState;
}

void Subscene::setSelectState(MouseSelectionID state)
{
  selectState = state;
}

void Subscene::mouseSelectionBegin(int mouseX,int mouseY)
{
  if (selectState == msABORT) return;
  
  mousePosition[0] = (float)mouseX/(float)pviewport.width;
  mousePosition[1] = (float)mouseY/(float)pviewport.height;
  mousePosition[2] = mousePosition[0];
  mousePosition[3] = mousePosition[1];
  selectState = msCHANGING;
}

void Subscene::mouseSelectionUpdate(int mouseX,int mouseY)
{
  mousePosition[2] = (float)mouseX/(float)pviewport.width;
  mousePosition[3] = (float)mouseY/(float)pviewport.height;
}

void Subscene::mouseSelectionEnd()
{
  if (selectState == msABORT) return;
  
  selectState = msDONE;
}

Subscene* Subscene::getRootSubscene()
{
  return parent ? parent->getRootSubscene() : this;
}

