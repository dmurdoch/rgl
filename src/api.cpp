// C++ source
// This file is part of RGL.
//
// $Id$

#include "lib.hpp"

extern "C" {

#include "api.h"

} // extern C

#include "DeviceManager.hpp"
#include "rglview.h"

//
// GLOBAL: deviceManager pointer
//

DeviceManager* deviceManager = NULL;

#include "lib.hpp"

//
// API Success is encoded as integer type:
//
#define RGL_FAIL     0
#define RGL_SUCCESS  1
inline int as_success(bool b) { return (b) ? RGL_SUCCESS : RGL_FAIL; }

//
// data type conversion utilities:
// 
inline bool as_bool(int idata) { return (idata) ? true : false; }

//
// FUNCTION
//   rgl_init
//

void rgl_init(int* successptr)
{
  int success = RGL_FAIL;

  if ( lib::init() ) {
    deviceManager = new DeviceManager();
    success = RGL_SUCCESS;
  }

  *successptr = success;
}

//
// FUNCTION
//   rgl_quit
//
// DESCRIPTION
//   Gets called by .Last.lib ( R function )
//

void rgl_quit(int* successptr)
{
  if (deviceManager) {
    delete deviceManager;
    deviceManager = 0;
  }

  lib::quit();

  *successptr = RGL_SUCCESS;
}

//
// FUNCTION
//   rgl_dev_open
//

void rgl_dev_open(int* successptr)
{
  *successptr = as_success( deviceManager->openDevice() );
}


//
// FUNCTION
//   rgl_dev_close
//

void rgl_dev_close(int* successptr)
{
  int success = RGL_FAIL;

  Device* device;

  device = deviceManager->getCurrentDevice();

  if (device) {

    device->close();
    success = RGL_SUCCESS;

  }

  *successptr = success;
}

void rgl_dev_bringtotop(int* successptr, int* stay)
{
  int success = RGL_FAIL;

  Device* device;

  device = deviceManager->getCurrentDevice();

  if (device) {

    device->bringToTop(*stay);
    success = RGL_SUCCESS;

  }

  *successptr = success;
}

//
// FUNCTION
//   rgl_dev_getcurrent
//
// RETURNS
//   device id
//

void rgl_dev_getcurrent(int* successptr, int* idptr)
{
  *idptr = deviceManager->getCurrent();
  *successptr = RGL_SUCCESS;
}

//
// FUNCTION
//   rgl_dev_setcurrent
//
// PARAMETERS
//   idata
//     [0]  device id
//

void rgl_dev_setcurrent(int* successptr, int* idata)
{
  int id = idata[0];
  *successptr = as_success ( deviceManager->setCurrent(id) );
}


//
// SCENE MANAGEMENT
//

static Material currentMaterial(Color(1.0f,1.0f,1.0f),Color(1.0f,0.0f,0.0f));

//
// FUNCTION
//   rgl_clear ( successPtr, idata(type) )
//
// PARAMETERS
//   idata
//     [0]  TypeID
//
//

void rgl_clear(int* successptr, int *idata)
{
  int success = RGL_FAIL;
  Device* device = deviceManager->getAnyDevice();

  if (device) {

    TypeID stackTypeID = (TypeID) idata[0];

    success = as_success( device->clear( stackTypeID ) );
  }

  *successptr = success;
}


//
// FUNCTION
//   rgl_pop  ( successPtr, idata )
//
// PARAMETERS
//   idata
//     [0]  stack TypeID
//
//


void rgl_pop(int* successptr, int* idata)
{
  int success = RGL_FAIL;
  Device* device = deviceManager->getCurrentDevice();

  if (device) {

    TypeID stackTypeID = (TypeID) idata[0];
 
    success = as_success( device->pop( stackTypeID ) );

  }

  *successptr = success;
}


//
// FUNCTION
//   rgl_bg   ( successPtr, idata )
//
// PARAMETERS
//   idata
//     [0]  bool environment sphere
//     [1]  int  fogtype
//


void rgl_bg(int* successptr, int* idata)
{
  int success = RGL_FAIL;

  Device* device = deviceManager->getAnyDevice();
  if (device) {
    bool sphere    = as_bool( idata[0] );
    int  fogtype   = idata[1];

    success = as_success( device->add( new Background(currentMaterial, sphere, fogtype) ) );
  }

  *successptr = success;
}


//
// FUNCTION
//   rgl_light   ( successPtr, idata, cdata, ddata )
//

void rgl_light ( int* successptr, int* idata, double* ddata )
{
  int success = RGL_FAIL;

  Device* device = deviceManager->getAnyDevice();

  if ( device ) {

    bool  viewpoint_rel = as_bool( idata[0] );

    Color ambient;
    Color diffuse;
    Color specular;

    ambient.set3iv ( &idata[1] );
    diffuse.set3iv ( &idata[4] );
    specular.set3iv( &idata[7] );

    float theta         = (float) ddata[0];
    float phi           = (float) ddata[1];

    success = as_success( device->add( new Light( PolarCoord(theta, phi), (bool) viewpoint_rel, ambient, diffuse, specular ) ) );

  }

  *successptr = success;
}


void rgl_viewpoint(int* successptr, int* idata, double* ddata)
{
  int success = RGL_FAIL;

  Device* device = deviceManager->getAnyDevice();

  if (device) {

    float theta	      = static_cast<float>( ddata[0] );
    float phi	      = static_cast<float>( ddata[1] );
    float fov         = static_cast<float>( ddata[2] );
    float zoom        = static_cast<float>( ddata[3] - 1.0 )/static_cast<float>(VIEWPOINT_MAX_ZOOM-1);

    int   interactive = idata[0];
    int   polar       = idata[1];
    
    if (polar) success = as_success( device->add( new Viewpoint(PolarCoord(theta, phi), fov, zoom, interactive) ) );
    else       success = as_success( device->add( new Viewpoint(ddata + 4, fov, zoom, interactive) ) );

  }

  *successptr = success;
}

void rgl_getZoom(int* successptr, double* zoom)
{
  int success = RGL_FAIL;
  Device* device = deviceManager->getAnyDevice();

  if ( device ) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Viewpoint* viewpoint = scene->getViewpoint();
    *zoom = viewpoint->getZoom();
    *zoom = 1.0f+(*zoom)* ((float)(VIEWPOINT_MAX_ZOOM-1)) ;
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_setZoom(int* successptr, double* zoom)
{
  int success = RGL_FAIL;
  Device* device = deviceManager->getAnyDevice();

  if ( device ) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Viewpoint* viewpoint = scene->getViewpoint();
    viewpoint->setZoom((*zoom - 1.0f)/((float)(VIEWPOINT_MAX_ZOOM-1)));
    rglview->update();
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_getFOV(int* successptr, double* fov)
{
  int success = RGL_FAIL;
  Device* device = deviceManager->getAnyDevice();

  if ( device ) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Viewpoint* viewpoint = scene->getViewpoint();
    *fov = viewpoint->getFOV();
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_setFOV(int* successptr, double* fov)
{
  int success = RGL_FAIL;
  Device* device = deviceManager->getAnyDevice();

  if ( device ) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Viewpoint* viewpoint = scene->getViewpoint();
    viewpoint->setFOV(*fov);
    rglview->update();
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_primitive(int* successptr, int* idata, double* vertex)
{
  int success = RGL_FAIL;
  Device* device = deviceManager->getAnyDevice();

  if ( device ) {

    int   type    = idata[0];
    int   nvertex = idata[1];

    SceneNode* node;

    switch(type) {
    case 1: // RGL_POINTS:
      node = new PointSet( currentMaterial, nvertex, vertex);
      break;
    case 2: // RGL_LINES:
      node = new LineSet( currentMaterial, nvertex, vertex);
      break;
    case 3: // RGL_TRIANGLES:
      node = new TriangleSet( currentMaterial, nvertex, vertex);
      break;
    case 4: // RGL_QUADS:
      node = new QuadSet( currentMaterial, nvertex, vertex);
      break;
    case 5: // RGL_LINE_STRIP:
      node = new LineStripSet( currentMaterial, nvertex, vertex);
      break;
    default:
      node = NULL;
    }

    if (node) {
      success = as_success( device->add( node ) );
    
      if (!success)
        delete node;
    }
  }

  *successptr = success;
}

void rgl_surface(int* successptr, int* idata, double* x, double* z, double* y, int* coords)
{
  int success = RGL_FAIL;

  Device* device = deviceManager->getAnyDevice();

  if (device) {
    int nx         = idata[0];
    int nz         = idata[1];

    success = as_success( device->add( new Surface(currentMaterial, nx, nz, x, z, y, coords) ) );

  }

  *successptr = success;
}

void rgl_spheres(int* successptr, int* idata, double* vertex, double* radius)
{
  int success = RGL_FAIL;

  Device* device = deviceManager->getAnyDevice();

  if (device) {
    int nvertex = idata[0];
    int nradius = idata[1];

    success = as_success( device->add( new SphereSet(currentMaterial, nvertex, vertex, nradius, radius) ) );
  }

  *successptr = success;
}

void rgl_sprites(int* successptr, int* idata, double* vertex, double* radius)
{
  int success = RGL_FAIL;

  Device* device = deviceManager->getAnyDevice();

  if (device) {
    int nvertex = idata[0];
    int nradius = idata[1];

    success = as_success( device->add( new SpriteSet(currentMaterial, nvertex, vertex, nradius, radius) ) );
  }

  *successptr = success;
}

void rgl_material(int *successptr, int* idata, char** cdata, double* ddata)
{
  Material& mat = currentMaterial;

  int ncolor    = idata[0];
  mat.lit       = (idata[1]) ? true : false;
  mat.smooth    = (idata[2]) ? true : false;
  mat.front     = (Material::PolygonMode) idata[3];
  mat.back      = (Material::PolygonMode) idata[4];
  mat.fog       = (idata[5]) ? true : false;
  Texture::Type textype = (Texture::Type) idata[6];
  bool mipmap = (idata[7]) ? true : false;
  int  minfilter = idata[8];
  int  magfilter = idata[9];
  int    nalpha = idata[10];
  mat.ambient.set3iv( &idata[11] );
  mat.specular.set3iv( &idata[14] );
  mat.emission.set3iv( &idata[17] );
  bool envmap = (idata[20]) ? true : false;
  int* colors   = &idata[21];

  char*  pixmapfn = cdata[0];

  mat.shininess   = (float) ddata[0];
  mat.size        = (float) ddata[1];
  double* alpha   = &ddata[2];

  if ( strlen(pixmapfn) > 0 ) {
    mat.texture = new Texture(pixmapfn, textype, mipmap, (unsigned int) minfilter, (unsigned int) magfilter, envmap);
    if ( !mat.texture->isValid() ) {
      mat.texture->unref();
      // delete mat.texture;
      mat.texture = NULL;
    }
  } else
    mat.texture = NULL;

  mat.colors.set( ncolor, colors, nalpha, alpha);
  mat.alphablend  = mat.colors.hasAlpha();

  mat.setup(); 

  *successptr = RGL_SUCCESS;
}

void rgl_texts(int* successptr, int* idata, double* adj, char** text, double* vertex)
{
  int success = RGL_FAIL;

  Device* device = deviceManager->getAnyDevice();

  if (device) {
    int ntext   = idata[0];

    success = as_success( device->add( new TextSet(currentMaterial, ntext, text, vertex, *adj) ) );
  }

  *successptr = success;
}

void rgl_bbox(int* successptr,
              int* idata,
              double* ddata,
              double* xat, char** xtext,
              double* yat, char** ytext,
              double* zat, char** ztext)
{
  int success = RGL_FAIL;

  Device* device = deviceManager->getAnyDevice();

  if (device) {

    int   xticks     =        idata[0];
    int   yticks     =        idata[1];
    int   zticks     =        idata[2];
    int   xlen       =        idata[3];
    int   ylen       =        idata[4];
    int   zlen       =        idata[5];
    int   marklen_rel =       idata[6];

    float xunit      = (float) ddata[0];
    float yunit      = (float) ddata[1];
    float zunit      = (float) ddata[2];
    float marklen    = (float) ddata[3];

    AxisInfo xaxis(xticks, xat, xtext, xlen, xunit);
    AxisInfo yaxis(yticks, yat, ytext, ylen, yunit);
    AxisInfo zaxis(zticks, zat, ztext, zlen, zunit);

    success = as_success( device->add( new BBoxDeco(currentMaterial, xaxis, yaxis, zaxis, marklen, (bool) marklen_rel ) ) );
  }

  *successptr = success;
}

void rgl_snapshot(int* successptr, int* idata, char** cdata)
{
  int success = RGL_FAIL;

  Device* device = deviceManager->getCurrentDevice();

  if (device) {

    int   format   = idata[0];
    char* filename = cdata[0];

    success = as_success( device->snapshot( format, filename ) );
  }

  *successptr = success;
}


void rgl_user2window(int* successptr, int* idata, double* point, double* pixel, double* model, double* proj, int* view)
{
  int success = RGL_FAIL;
  GLdouble* vertex = pixel;
  int columns = idata[0];

  Device* device = deviceManager->getAnyDevice();

  if ( device ) {
  	for (int i=0; i<columns; i++) {
		gluProject(point[0],point[1],point[2],model,proj,view,
		vertex,vertex+1,vertex+2);
		vertex[0] /= view[2];
		vertex[1] /= view[3];
		point += 3;
		vertex += 3;
	}
	success = RGL_SUCCESS;
  }

  *successptr = success;
}

void rgl_window2user(int* successptr, int* idata, double* point, double* pixel, double* model, double* proj, int* view)
{
  int success = RGL_FAIL;
  GLdouble* vertex = point;
  int columns = idata[0];

  Device* device = deviceManager->getAnyDevice();

  if ( device ) {
  	for (int i=0; i<columns; i++) {
	        pixel[0] *= view[2];
	        pixel[1] *= view[3];
		gluUnProject(pixel[0],pixel[1],pixel[2],model,proj,view,
		vertex,vertex+1,vertex+2);
		pixel += 3;
		vertex += 3;
	}
	success = RGL_SUCCESS;
  }

  *successptr = success;
}

void rgl_getMouseMode(int* successptr, int *button, int* mode)
{
  int success = RGL_FAIL;
  Device* device = deviceManager->getAnyDevice();

  if (device) {
 	RGLView* rglview = device->getRGLView();
  	*mode = static_cast<int>( rglview->getMouseMode(*button) );
    	success = RGL_SUCCESS;
  }

  *successptr = success;
}

void rgl_setMouseMode(int* successptr, int* button, int* mode)
{
  int success = RGL_FAIL;
  Device* device = deviceManager->getAnyDevice();

  if (device) {
 	RGLView* rglview = device->getRGLView();
	rglview->setMouseMode(*button, (MouseModeID)(*mode));

    	success = RGL_SUCCESS;
  }

  *successptr = success;
}


void rgl_selectstate(int* successptr, int* selectstate, double* locations)
{
	int success = RGL_FAIL;
	Device* device;

	device = deviceManager->getAnyDevice();

  	if (device){

		RGLView* rglview = device->getRGLView();
		
    selectstate[0] = (int)rglview->getSelectState();
		double* mousePosition = rglview->getMousePosition();

		locations[0] = *mousePosition;
		locations[1] = *(mousePosition+1);
		locations[2] = *(mousePosition+2);
		locations[3] = *(mousePosition+3);

		success = RGL_SUCCESS;
	}

	*successptr = success;

}

void rgl_setselectstate(int* successptr, int *idata)
{
  int success = RGL_FAIL;
  Device* device = deviceManager->getAnyDevice();

  if (device) {

    MouseSelectionID selectState = (MouseSelectionID) idata[0];
	RGLView* rglview = device->getRGLView();
	rglview->setSelectState(selectState);

    success = RGL_SUCCESS;

  }

  *successptr = success;
}

void rgl_getUserMatrix(int* successptr, double* userMatrix)
{
	int success = RGL_FAIL;
  	Device* device = deviceManager->getAnyDevice();

  	if (device) {

		RGLView* rglview = device->getRGLView();
		rglview->getUserMatrix(userMatrix);

    	success = RGL_SUCCESS;

  	}

  *successptr = success;
}

void rgl_setUserMatrix(int* successptr, double* userMatrix)
{

	int success = RGL_FAIL;
  	Device* device = deviceManager->getAnyDevice();

  	if (device) {

		RGLView* rglview = device->getRGLView();
		rglview->setUserMatrix(userMatrix);

		success = RGL_SUCCESS;

  	}

  *successptr = success;

}

void rgl_getModelMatrix(int* successptr, double* modelMatrix)
{
	int success = RGL_FAIL;
  	Device* device = deviceManager->getAnyDevice();

	if (device){

		RGLView* rglview = device->getRGLView();
		for (int i=0; i<16; i++) {
	    		modelMatrix[i] = rglview->modelMatrix[i];
		}
    		success = RGL_SUCCESS;
  	}

  *successptr = success;
}

void rgl_getProjMatrix(int* successptr, double* projMatrix)
{
	int success = RGL_FAIL;
  	Device* device = deviceManager->getAnyDevice();

	if (device){

		RGLView* rglview = device->getRGLView();
		for (int i=0; i<16; i++) {
	    		projMatrix[i] = rglview->projMatrix[i];
		}
    		success = RGL_SUCCESS;
  	}

  *successptr = success;
}

void rgl_getViewport(int* successptr, int* viewport)
{
	int success = RGL_FAIL;
  	Device* device = deviceManager->getAnyDevice();

	if (device){

		RGLView* rglview = device->getRGLView();
		for (int i=0; i<4; i++) {
	    		viewport[i] = rglview->viewport[i];
		}
    		success = RGL_SUCCESS;
  	}

  *successptr = success;
}

void rgl_postscript(int* successptr, int* idata, char** cdata)
{
  int success = RGL_FAIL;
 
  Device* device = deviceManager->getCurrentDevice();

  if (device) {

    int   format   = idata[0];
    char* filename = cdata[0];

    success = as_success( device->postscript( format, filename ) );
  }

  *successptr = success;
}


void rgl_getBoundingbox(int* successptr, double* bboxvec)
{
	int success = RGL_FAIL;
  	Device* device = deviceManager->getAnyDevice();

	if (device){

	  const AABox& bbox = device->getScene()->getBoundingBox();
	  bboxvec[0] = bbox.vmin.x;
	  bboxvec[1] = bbox.vmax.x;
	  bboxvec[2] = bbox.vmin.y;
	  bboxvec[3] = bbox.vmax.y;
	  bboxvec[4] = bbox.vmin.z;
	  bboxvec[5] = bbox.vmax.z;

	  success = RGL_SUCCESS;
	}
	
	*successptr = success;
}

