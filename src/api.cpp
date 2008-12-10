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

#include "lib.hpp"
#include "R.h"

//
// API Success is encoded as integer type:
//
#define RGL_FAIL     0
#define RGL_SUCCESS  1
inline int as_success(int b) { return (b) ; }



//
// data type conversion utilities:
// 
inline bool as_bool(int idata) { return (idata) ? true : false; }

//
//   rgl_init moved to init.cpp
//

extern DeviceManager* deviceManager;

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
  *successptr = as_success( deviceManager && deviceManager->openDevice() );
}


//
// FUNCTION
//   rgl_dev_close
//

void rgl_dev_close(int* successptr)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getCurrentDevice())) {

    device->close();
    success = RGL_SUCCESS;

  }

  *successptr = success;
}

void rgl_dev_bringtotop(int* successptr, int* stay)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getCurrentDevice())) {

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
  if (deviceManager) {
    *idptr = deviceManager->getCurrent();
    *successptr = RGL_SUCCESS;
  } else {
    *successptr = RGL_FAIL;
  }
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
  bool silent = (bool) idata[1];
  *successptr = as_success ( deviceManager && deviceManager->setCurrent(id, silent) );
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
//     [0]  count of types
//     [1], [2], ...  TypeID 1, 2, ...
//
//

void rgl_clear(int* successptr, int *idata)
{
  int success = RGL_SUCCESS;
  Device* device;
  int num = idata[0];

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    for (int i=1; success && i<=num; i++) {
      TypeID stackTypeID = (TypeID) idata[i];

      success = as_success( device->clear( stackTypeID ) ); // viewpoint & material handled in R, background ignored
    }
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
//     [1]  id SceneNode identifier
//
//


void rgl_pop(int* successptr, int* idata)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getCurrentDevice())) {

    TypeID stackTypeID = (TypeID) idata[0];
    int id = idata[1];
 
    success = as_success( device->pop( stackTypeID, id ) );

  }

  *successptr = success;
}

//
// FUNCTION
//   rgl_id_count
//

void rgl_id_count(int* type, int* count)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    
    *count = scene->get_id_count((TypeID) *type);
  } else {
    *count = 0;
  }
}  

//
// FUNCTION
//   rgl_ids
//

void rgl_ids(int* type, int* ids, char** types)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    
    scene->get_ids((TypeID) *type, ids, types);
  }
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

  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {

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

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

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

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    float theta	      = static_cast<float>( ddata[0] );
    float phi	      = static_cast<float>( ddata[1] );
    float fov         = static_cast<float>( ddata[2] );
    float zoom        = static_cast<float>( ddata[3] );
    Vertex scale      = Vertex( ddata[4], ddata[5], ddata[6] );
    
    int   interactive = idata[0];
    int   polar       = idata[1];
    
    if (polar) success = as_success( device->add( new Viewpoint(PolarCoord(theta, phi), fov, zoom, scale, interactive) ) );
    else       success = as_success( device->add( new Viewpoint(ddata + 7, fov, zoom, scale, interactive) ) );

  }

  *successptr = success;
}

void rgl_getZoom(int* successptr, double* zoom)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Viewpoint* viewpoint = scene->getViewpoint();
    *zoom = viewpoint->getZoom();
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_setZoom(int* successptr, double* zoom)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Viewpoint* viewpoint = scene->getViewpoint();
    viewpoint->setZoom( *zoom );
    rglview->update();
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_getFOV(int* successptr, double* fov)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

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
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Viewpoint* viewpoint = scene->getViewpoint();
    viewpoint->setFOV(*fov);
    rglview->update();
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_getIgnoreExtent(int* successptr, int* ignoreExtent)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    *ignoreExtent = device->getIgnoreExtent();
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_setIgnoreExtent(int* successptr, int* ignoreExtent)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    device->setIgnoreExtent(*ignoreExtent);
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_getSkipRedraw(int* successptr, int* skipRedraw)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    *skipRedraw = device->getSkipRedraw();
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_setSkipRedraw(int* successptr, int* skipRedraw)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    device->setSkipRedraw(*skipRedraw);
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_primitive(int* successptr, int* idata, double* vertex, double* normals, double* texcoords)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int   type    = idata[0];
    int   nvertex = idata[1];
    int   ignoreExtent = device->getIgnoreExtent();
    int   useNormals = idata[2];
    int   useTexcoords = idata[3];
    
    SceneNode* node;

    switch(type) {
    case 1: // RGL_POINTS:
      node = new PointSet( currentMaterial, nvertex, vertex, ignoreExtent);
      break;
    case 2: // RGL_LINES:
      node = new LineSet( currentMaterial, nvertex, vertex, ignoreExtent);
      break;
    case 3: // RGL_TRIANGLES:
      node = new TriangleSet( currentMaterial, nvertex, vertex, normals, texcoords, 
                              ignoreExtent, useNormals, useTexcoords);
      break;
    case 4: // RGL_QUADS:
      node = new QuadSet( currentMaterial, nvertex, vertex, normals, texcoords, 
                              ignoreExtent, useNormals, useTexcoords);
      break;
    case 5: // RGL_LINE_STRIP:
      node = new LineStripSet( currentMaterial, nvertex, vertex, ignoreExtent);
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

void rgl_surface(int* successptr, int* idata, double* x, double* z, double* y, 
	         double* normal_x, double* normal_z, double* normal_y,
	         double* texture_s, double* texture_t,
	         int* coords, int* orientation, int* flags)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int nx         = idata[0];
    int nz         = idata[1];

    success = as_success( device->add( new Surface(currentMaterial, nx, nz, x, z, y, 
                                                   normal_x, normal_z, normal_y,
                                                   texture_s, texture_t,
                                                   coords, *orientation, flags,
    						   device->getIgnoreExtent()) ) );

  }

  *successptr = success;
}

void rgl_spheres(int* successptr, int* idata, double* vertex, double* radius)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int nvertex = idata[0];
    int nradius = idata[1];

    success = as_success( device->add( new SphereSet(currentMaterial, nvertex, vertex, nradius, radius,
    						     device->getIgnoreExtent()) ) );
  }

  *successptr = success;
}

void rgl_sprites(int* successptr, int* idata, double* vertex, double* radius)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int nvertex = idata[0];
    int nradius = idata[1];

    success = as_success( device->add( new SpriteSet(currentMaterial, nvertex, vertex, nradius, radius,
    						     device->getIgnoreExtent()) ) );
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
  mat.point_antialias = (idata[21]) ? true : false;
  mat.line_antialias = (idata[22]) ? true : false;
  int* colors   = &idata[23];

  char*  pixmapfn = cdata[0];

  mat.shininess   = (float) ddata[0];
  mat.size      = (float) ddata[1];
  mat.lwd         = (float) ddata[2];
  double* alpha   = &ddata[3];

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

void rgl_getcolorcount(int* count)
{
  *count = currentMaterial.colors.getLength();
}

void rgl_getmaterial(int *successptr, int* idata, char** cdata, double* ddata)
{
  Material& mat = currentMaterial;
  unsigned int i,j;
  
  idata[1] = mat.lit ? 1 : 0;
  idata[2] = mat.smooth ? 1 : 0;
  idata[3] = (int) mat.front;
  idata[4] = (int) mat.back;
  idata[5] = mat.fog ? 1 : 0;
  if (mat.texture) {
    mat.texture->getParameters( (Texture::Type*) (idata + 6),
                               (bool*) (idata + 7),
                               (unsigned int*) (idata + 8),
                               (unsigned int*) (idata + 9),
                               (bool*) (idata + 20),
                               strlen(cdata[0]),
                               cdata[0] );
  } else {
    idata[6] = 4; /* mat.texture.type; */
    idata[7] = 0; /* mat.texture.mipmap ? 1 : 0; */
    idata[8] = 1; /* mat.texture.minfilter; */
    idata[9] = 1; /* mat.texture.magfilter; */
    idata[20] = 0; /* mat.texture.envmap ? 1 : 0; */
    cdata[0][0] = '\0';
  }
  idata[11] = (int) mat.ambient.getRedub();
  idata[12] = (int) mat.ambient.getGreenub();
  idata[13] = (int) mat.ambient.getBlueub();
  idata[14] = (int) mat.specular.getRedub();
  idata[15] = (int) mat.specular.getGreenub();
  idata[16] = (int) mat.specular.getBlueub();  
  idata[17] = (int) mat.emission.getRedub();
  idata[18] = (int) mat.emission.getGreenub();
  idata[19] = (int) mat.emission.getBlueub();
  idata[21] = mat.point_antialias ? 1 : 0;
  idata[22] = mat.line_antialias ? 1 : 0;

  for (i=0, j=23; (i < mat.colors.getLength()) && (i < (unsigned int)idata[0]); i++) {
    idata[j++] = (int) mat.colors.getColor(i).getRedub();
    idata[j++] = (int) mat.colors.getColor(i).getGreenub();
    idata[j++] = (int) mat.colors.getColor(i).getBlueub();
  }
  idata[0] = i;

  ddata[0] = (double) mat.shininess;
  ddata[1] = (double) mat.size;
  ddata[2] = (double) mat.lwd;
  
  if (mat.colors.hasAlpha()) {
    for (i=0, j=3; (i < mat.colors.getLength()) && (i < (unsigned int)idata[10]); i++) 
      ddata[j++] = (double) mat.colors.getColor(i).getAlphaf();
    idata[10] = i;
  } else 
    idata[10] = 0;
  
  *successptr = RGL_SUCCESS;
}

void rgl_texts(int* successptr, int* idata, double* adj, char** text, double* vertex,
               int* nfonts, char** family, int* style, double* cex, 
               int* useFreeType)
{
  int success = RGL_FAIL;

  Device* device;
  
#ifndef HAVE_FREETYPE
  if (*useFreeType) error("FreeType not supported in this build");
#endif

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int ntext   = idata[0];
    
    FontArray fonts;
    device->getFonts(fonts, *nfonts, family, style, cex, (bool) *useFreeType);
    success = as_success( device->add( new TextSet(currentMaterial, ntext, text, vertex, 
                                                   adj[0], adj[1],
    						   device->getIgnoreExtent(), fonts) ) );
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

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

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
    float expand     = (float) ddata[4];    


    AxisInfo xaxis(xticks, xat, xtext, xlen, xunit);
    AxisInfo yaxis(yticks, yat, ytext, ylen, yunit);
    AxisInfo zaxis(zticks, zat, ztext, zlen, zunit);

    success = as_success( device->add( new BBoxDeco(currentMaterial, xaxis, yaxis, zaxis, marklen, (bool) marklen_rel, expand ) ) );
  }

  *successptr = success;
}

void rgl_snapshot(int* successptr, int* idata, char** cdata)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getCurrentDevice())) {

    int   format   = idata[0];
    char* filename = cdata[0];

    success = as_success( device->snapshot( format, filename ) );
  }

  *successptr = success;
}

void rgl_pixels(int* successptr, int* ll, int* size, int* component, float* result)
{
  int success = RGL_FAIL;
  
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    
    success = as_success( device->pixels( ll, size, *component, result) );
    
  }
  
  *successptr = success;
}

void rgl_user2window(int* successptr, int* idata, double* point, double* pixel, double* model, double* proj, int* view)
{
  int success = RGL_FAIL;
  GLdouble* vertex = pixel;
  int columns = idata[0];
  GLint viewport[4];

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {
  
  	for (int i=0; i<4; i++) viewport[i] = view[i];
  	for (int i=0; i<columns; i++) {
		gluProject(point[0],point[1],point[2],model,proj,viewport,
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
  GLint viewport[4];

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {
  
    	for (int i=0; i<4; i++) viewport[i] = view[i];
  	for (int i=0; i<columns; i++) {
	        pixel[0] *= view[2];
	        pixel[1] *= view[3];
		gluUnProject(pixel[0],pixel[1],pixel[2],model,proj,viewport,
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
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {
  
 	RGLView* rglview = device->getRGLView();
  	*mode = static_cast<int>( rglview->getMouseMode(*button) );
    	success = RGL_SUCCESS;
  }

  *successptr = success;
}

void rgl_setMouseMode(int* successptr, int* button, int* mode)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {
  
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

	if (deviceManager && (device = deviceManager->getAnyDevice())) {

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
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

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
  	Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

		RGLView* rglview = device->getRGLView();
		rglview->getUserMatrix(userMatrix);

    	success = RGL_SUCCESS;

  	}

  *successptr = success;
}

void rgl_setUserMatrix(int* successptr, double* userMatrix)
{

	int success = RGL_FAIL;
  	Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

		RGLView* rglview = device->getRGLView();
		rglview->setUserMatrix(userMatrix);

		success = RGL_SUCCESS;

  	}

  *successptr = success;

}

void rgl_getPosition(double* position)
{
   Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

		RGLView* rglview = device->getRGLView();
		rglview->getPosition(position);

  	}
}

void rgl_setPosition(double* position)
{
  	Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

		RGLView* rglview = device->getRGLView();
		rglview->setPosition(position);

  	}
}

void rgl_getScale(int* successptr, double* scale)
{
	int success = RGL_FAIL;
  	Device* device = deviceManager->getAnyDevice();

  	if (device) {

		RGLView* rglview = device->getRGLView();
		rglview->getScale(scale);

    	success = RGL_SUCCESS;

  	}

  *successptr = success;
}

void rgl_setScale(int* successptr, double* scale)
{

	int success = RGL_FAIL;
  	Device* device = deviceManager->getAnyDevice();

  	if (device) {

		RGLView* rglview = device->getRGLView();
		rglview->setScale(scale);

		success = RGL_SUCCESS;

  	}

  *successptr = success;

}

void rgl_getModelMatrix(int* successptr, double* modelMatrix)
{
	int success = RGL_FAIL;
  	Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

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
  	Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

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
  	Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

		RGLView* rglview = device->getRGLView();
		for (int i=0; i<4; i++) {
	    		viewport[i] = rglview->viewport[i];
		}
    		success = RGL_SUCCESS;
  	}

  *successptr = success;
}

void rgl_getWindowRect(int* successptr, int* rect)
{
  int success = RGL_FAIL;
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
   
     device->getWindowRect(rect, rect+1, rect+2, rect+3);
     success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_setWindowRect(int* successptr, int* rect)
{
  int success = RGL_FAIL;
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
  
    device->setWindowRect(rect[0], rect[1], rect[2], rect[3]);
    success = RGL_SUCCESS;
  }
  *successptr = success;
}

void rgl_postscript(int* successptr, int* idata, char** cdata)
{
  int success = RGL_FAIL;
 
  Device* device;

  if (deviceManager && (device = deviceManager->getCurrentDevice())) {

    int   format   = idata[0];
    bool  drawText = (bool)idata[1];
    char* filename = cdata[0];

    success = as_success( device->postscript( format, filename, drawText ) );
  }

  *successptr = success;
}


void rgl_getBoundingbox(int* successptr, double* bboxvec)
{
	int success = RGL_FAIL;
  	Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

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

/* font access functions.  These are only used from par3d */

char* getFamily()
{
  Device* device;
  const char* f;
  char* result = NULL;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    f = device->getRGLView()->getFontFamily();
    result = R_alloc(strlen(f)+1, 1);
    strcpy(result, f);
  } 
  return result;
}

bool setFamily(const char *family)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    device->getRGLView()->setFontFamily(family);
    return true;
  } else
    return false;
}

int getFont()
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    return device->getRGLView()->getFontStyle();
  } else
    return -1;
}

bool setFont(int font)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    device->getRGLView()->setFontStyle(font);
    return true;
  } else
    return false;
}

double getCex()
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    return  device->getRGLView()->getFontCex();
  } else
    return -1;
}

bool setCex(double cex)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    device->getRGLView()->setFontCex(cex);
    return true;
  } else
    return false;
}

int getUseFreeType()
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    return  (int) device->getRGLView()->getFontUseFreeType();
  } else
    return -1;
}

bool setUseFreeType(bool useFreeType)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    device->getRGLView()->setFontUseFreeType(useFreeType);
    return true;
  } else
    return false;
}

char* getFontname()
{
  Device* device;
  const char* f;
  char* result = NULL;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    f = device->getRGLView()->getFontname();
    result = R_alloc(strlen(f)+1, 1);
    strcpy(result, f);
  } 
  return result;
}
