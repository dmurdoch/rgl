#include "Subscene.hpp"
#include "R.h"
#include <algorithm>

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Subscene
//

Subscene::Subscene(Subscene* in_parent, int in_where)
 : SceneNode(SUBSCENE), parent(in_parent), where(in_where)
{
  viewpoint = NULL;
  bboxDeco   = NULL;
  background = NULL;
  ignoreExtent = false;
  bboxChanges = false;

}

Subscene::~Subscene() 
{
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
    delete (*i);
  if (viewpoint)
    delete viewpoint;
  if (background)
    delete background;
  if (bboxdeco)
    delete bboxdeco;
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
    case VIEWPOINT:
      {
        if (viewpoint)
          delete viewpoint;
        viewpoint = (Viewpoint*) node;
        success = true;
      }
      break;
    case SUBSCENE:
      {
	Subscene* subscene = static_cast<Subscene*>(node);
	addSubscene(subscene);
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
  if (background)
    delete background;
  background = newbackground;
}

void Subscene::addBboxdeco(BBoxdeco* newbboxdeco)
{
  if (bboxdeco)
    delete bboxdeco;
  bboxdeco = newbboxdeco;
}

void Subscene::addShape(Shape* shape)
{
  if (!shape->getIgnoreExtent()) {
    const AABox& bbox = shape->getBoundingBox();
    data_bbox += bbox;
    bboxChanges |= shape->getBBoxChanges();
  }

  shapes.push_back(shape);
  
  if ( shape->isBlended() ) {
    zsortShapes.push_back(shape);
  } else if ( shape->isClipPlane() ) {
    clipPlanes.push_back(static_cast<ClipPlaneSet*>(shape));
  } else
    unsortedShapes.push_back(shape);
}

void Subscene::addLight(Light* light)
{
  lights.push_back(light);
}

void Subscene::addSubscene(Subscene* subscene)
{
  subscenes.push_back(subscene);
}

void Subscene::pop(TypeID type, int id, bool destroy)
{
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
      (*i)->pop(type, id, destroy);
    
  switch(type) {
    case SHAPE: {    
    
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
      break;
    }
    case SUBSCENE: {
      std::vector<Subscene*>::iterator isubscene
	= std::find_if(subscenes.begin(), subscenes.end(),
	  std::bind2nd(std::ptr_fun(&sameID), id));
      if (isubscene == subscenes.end()) return;
      Subscene* subscene = *isubscene;
      subscenes.erase(isubscene);
      if (destroy)
	delete subscene;
      break;
    }
    default: // VIEWPOINT ignored
    break;
  }
}

Subscene* Subscene::get_subscene(int id)
{
  if (id == getObjID()) return this;
    
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end() ; ++ i ) {
    Subscene* subscene = (*i)->get_subscene(id);
    if (subscene) return subscene;
  }
  
  return NULL;
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
    shapes[index]->getShapeName(buffer, 20);
    return String(strlen(buffer), buffer);
  } else
    return SceneNode::getTextAttribute(bbox, attrib, index);
}

bool Subscene::clear(TypeID typeID, bool recursive)
{
  bool success = false;
    
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
      (*i)->clear(typeID);

  switch(typeID) {
    case SHAPE:
      zsortShapes.clear();
      SAVEGLERROR;
      unsortedShapes.clear();
      SAVEGLERROR;
      clipPlanes.clear();
      SAVEGLERROR;
      bboxChanges = false;      
      success = true;
      break;
    case SUBSCENE:
      subscenes.clear();
      break;
  }
  return success;
}

void Subscene::renderClipplanes(RenderContext* renderContext)
{
  std::vector<ClipPlaneSet*>::iterator iter;
	
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

void Subscene::renderUnsorted(RenderContext* renderContext)
{
  GLdouble mat[16];
  GLenum oldplanes = ClipPlaneSet::num_planes;
  /* We render the subscenes in 3 passes, depending on 
     where they fall in the rendering sequence.  Assumes matrix mode is MODELVIEW */
     
  glPushMatrix();  /* Save parent matrix */
 
  E.getData(mat);
  glMultMatrixd(mat);
  
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
    if ((*i)->where == PREPROJ)
      (*i)->renderUnsorted(renderContext);
      
  P.getData(mat);
  glMultMatrixd(mat);
  
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
    if ((*i)->where == PROJ)
      (*i)->renderUnsorted(renderContext);
  
  M.getData(mat);
  glMultMatrixd(mat);
  
  renderClipplanes(renderContext);

  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
    if ((*i)->where == MODEL)
      (*i)->renderUnsorted(renderContext);
    
  std::vector<Shape*>::iterator iter;

  for (iter = unsortedShapes.begin() ; iter != unsortedShapes.end() ; ++iter ) {
    Shape* shape = *iter;
    shape->render(renderContext);
    SAVEGLERROR;
  }
  
  disableClipplanes(renderContext);
  ClipPlaneSet::num_planes = oldplanes;
  
  glPopMatrix();

}  
   
void Subscene::renderZsort(RenderContext* renderContext)
{  
  GLdouble mat[16];
  GLenum oldplanes = ClipPlaneSet::num_planes;
  
  glPushMatrix();  /* Save parent matrix */
 
  E.getData(mat);
  glMultMatrixd(mat);
  
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
    if ((*i)->where == PREPROJ)
      (*i)->renderZsort(renderContext);
      
  P.getData(mat);
  glMultMatrixd(mat);
  
  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
    if ((*i)->where == PROJ)
      (*i)->renderZsort(renderContext);
  
  M.getData(mat);
  glMultMatrixd(mat);
  
  renderClipplanes(renderContext);

  for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
    if ((*i)->where == MODEL)
      (*i)->renderZsort(renderContext);
    
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
  
  disableClipplanes(renderContext);
  ClipPlaneSet::num_planes = oldplanes;
  
  glPopMatrix();
}

int Subscene::get_id_count(TypeID type, bool recursive)
{
  int result = 0;
  if (recursive)
    for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) 
      result += (*i)->get_id_count(type);
  switch (TYPE) {
    case SUBSCENE: {
      result += 1;
      break;
    }
    case VIEWPOINT: {    
      result += viewpoint ? 1 : 0;
      break;
    }
    case BACKGROUND: {
      result += background ? 1 : 0;
      break;
    }
    case BBOXDECO: {
      result += bboxdeco ? 1 : 0;
      break;
    }
  }
  return result;
}
    
void Subscene::get_ids(TypeID type, int* ids, char** types, bool recursive)
{
  switch(type) {
  case SUBSCENE: 
    for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) {
      *ids++ = (*i)->getObjID();
      *types = R_alloc(strlen("subscene")+1, 1);
      strcpy(*types, "subscene");
      types++;
    }
    break;
  case VIEWPOINT:
    if (viewpoint) {
      *ids = viewpoint->getObjID();
      *types = R_alloc(strlen("viewpoint")+1, 1);
      strcpy(*types, "viewpoint");
      types++;
    }
    break;
  }
  case BBOXDECO:
    if (bboxDeco) {
      *ids = bboxDeco->getObjID();
      *types = R_alloc(strlen("bboxdeco")+1, 1);
      strcpy(*types, "bboxdeco");
      types++;
    }
    break;
  case BACKGROUND:
    if (background) {
      *ids = background->getObjID();
      *types = R_alloc(strlen("background")+1, 1);
      strcpy(*types, "background");
      types++;
    }
    break;
  if (recursive)
    for (std::vector<Subscene*>::iterator i = subscenes.begin(); i != subscenes.end(); ++ i ) {
      (*i)->get_ids(type, ids, types);	
      ids += (*i)->get_id_count(type);
      types += (*i)->get_id_count(type);
    }
  }
}

void Subscene::setMatrix(int which, const Matrix4x4& src)
{
  switch (which) {
    case 1:  M = Matrix4x4(src); break;
    case 2:  P = Matrix4x4(src); break;
    case 3:  E = Matrix4x4(src); break;
  }
}

Background* Subscene::get_background()
{
  if (background) return background;
  else if (parent) return parent->get_background();
  else return NULL;
}

BBoxDeco* Subscene::get_bboxdeco()
{
  if (bboxdeco) return bboxdeco;
  else if (parent) return parent->get_bboxdeco();
  else return NULL;
}
