// C++ source
// This file is part of RGL.
//
// $Id$


#include "scene.h"
#include "math.h"
#include "render.h"
#include "geom.hpp"
#include <map>

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Scene
//

static int gl_light_ids[8] = { GL_LIGHT0, GL_LIGHT1, GL_LIGHT2, GL_LIGHT3, GL_LIGHT4, GL_LIGHT5, GL_LIGHT6, GL_LIGHT7 };

Scene::Scene()
{
  background = NULL;
  viewpoint  = NULL;
  nlights    = 0;
  bboxDeco   = NULL;
 
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

bool Scene::clear(TypeID typeID)
{
  bool success = false;

  switch(typeID) {
    case SHAPE:
      shapes.deleteItems();
      zsortShapes.clear();
      unsortedShapes.clear();
      data_bbox.invalidate();
      success = true;
      break;
    case LIGHT:
      lights.deleteItems();
      nlights = 0;
      success = true;
      break;
    case BBOXDECO:
      delete bboxDeco;
      bboxDeco = NULL;
      success = true;
      break;
    default:
      break;
  }
  return success;
}

void Scene::addShape(Shape* shape) {
  const AABox& bbox = shape->getBoundingBox();
  data_bbox += bbox;

  shapes.addTail(shape);

  if ( shape->getMaterial().isBlended() ) {
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

        lights.addTail( light );

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


bool Scene::pop(TypeID type)
{
  bool success = false;

  switch(type) {
  case SHAPE:
    {
      Node* tail = shapes.getTail();
      if (tail) {
        Shape* shape = (Shape*) tail;
        if ( shape->getMaterial().isBlended() )
          zsortShapes.pop_back();
        else
          unsortedShapes.pop_back();

        delete shapes.remove(tail);

        calcDataBBox();

        success = true;
      }
    }
    break;
  case LIGHT:
    {
      Node* tail = lights.getTail();
      if (tail) {
        delete lights.remove(tail);
        nlights--;
        success = true;
      }
    }
    break;
  case BBOXDECO:
    {
      if (bboxDeco) {
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

void Scene::render(RenderContext* renderContext)
{

  renderContext->scene     = this;
  renderContext->viewpoint = viewpoint;


  //
  // CLEAR BUFFERS
  //

  GLbitfield clearFlags = 0;

  // Depth Buffer

  glClearDepth(1.0);
  glDepthFunc(GL_LESS);
  glDepthMask(GL_TRUE);

  // if ( unsortedShapes.size() )
    clearFlags  |= GL_DEPTH_BUFFER_BIT;

  // Color Buffer (optional - depends on background node)
  
  clearFlags |= background->getClearFlags(renderContext);

  // clear
  glClear(clearFlags);
  // renderContext.clear(viewport);


  //
  // SETUP LIGHTING MODEL
  //

  setupLightModel(renderContext);


  Sphere total_bsphere;

  if (data_bbox.isValid()) {
    
    // 
    // GET DATA VOLUME SPHERE
    //

    total_bsphere = Sphere( (bboxDeco) ? bboxDeco->getBoundingBox(data_bbox) : data_bbox );

  } else {
    total_bsphere = Sphere( Vertex(0,0,0), 1 );
  }


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

  
  //
  // RENDER MODEL
  //

  if (data_bbox.isValid() ) {

    //
    // SETUP VIEWPOINT TRANSFORMATION
    //

    viewpoint->setupTransformation( renderContext, total_bsphere);

    //
    // RENDER BBOX DECO
    //

    if (bboxDeco)
      bboxDeco->render(renderContext);

    //
    // RENDER SOLID SHAPES
    //

    // ENABLE Z-BUFFER TEST 
    glEnable(GL_DEPTH_TEST);

    // ENABLE Z-BUFFER FOR WRITING
    glDepthMask(GL_TRUE);

    // DISABLE BLENDING
    glDisable(GL_BLEND);

    {
      std::vector<Shape*>::iterator iter;

      for (iter = unsortedShapes.begin() ; iter != unsortedShapes.end() ; ++iter ) {
        Shape* shape = *iter;
        shape->render(renderContext);
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
    
    // SETUP BLENDING
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

    // ENABLE BLENDING
    glEnable(GL_BLEND);

    //
    // GET THE TRANSFORMATION
    //

    viewpoint->setupTransformation(renderContext, total_bsphere);
    
    double data[16];
        
    glGetDoublev(GL_MODELVIEW_MATRIX,data);
    Matrix4x4 M(data);
    
    glGetDoublev(GL_PROJECTION_MATRIX,data);
    Matrix4x4 P(data);
    P = P*M;
    
    renderContext->Zrow = P.getRow(2);
    renderContext->Wrow = P.getRow(3);
    
    {
      std::vector<Shape*>::iterator iter;
      std::multimap<float, int> distanceMap;
      int index = 0;

      for (iter = zsortShapes.begin() ; iter != zsortShapes.end() ; ++iter ) {
        Shape* shape = *iter;
      
        const AABox& aabox = shape->getBoundingBox();

        float distance = renderContext->getDistance( aabox.getCenter() );
        distanceMap.insert( std::pair<float,int>(-distance, index) );
        index++;

      }

      {
        std::multimap<float,int>::iterator iter;
        for (iter = distanceMap.begin() ; iter != distanceMap.end() ; ++ iter ) {
          int index = iter->second;
          Shape* shape = zsortShapes[index];
          shape->renderZSort(renderContext);
        }
      }
    }
#endif
  }
}


void Scene::setupLightModel(RenderContext* rctx)
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

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  rctx->viewpoint->setupOrientation(rctx);

  ListIterator iter(&lights);

  for(iter.first(); !iter.isDone() ; iter.next() ) {

    Light* light = (Light*) iter.getCurrent();

    if (!light->viewpoint)
      light->setup(rctx);
  }

  //
  // viewpoint lights
  //

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  for(iter.first(); !iter.isDone() ; iter.next() ) {

    Light* light = (Light*) iter.getCurrent();

    if (light->viewpoint)
      light->setup(rctx);

  }

  //
  // disable unused lights
  //

  for (int i=nlights;i<8;i++)
    glDisable(gl_light_ids[i]);

}

void Scene::calcDataBBox()
{
  data_bbox.invalidate();

  ListIterator iter(&shapes);

  for(iter.first(); !iter.isDone(); iter.next() ) {
    Shape* shape = (Shape*) iter.getCurrent();

    data_bbox += shape->getBoundingBox();
  }
}



