// C++ source
// This file is part of RGL.
//
// $Id$

#include "lib.hpp"
#include "DeviceManager.hpp"
#include "rglview.h"

#include "lib.hpp"
#include "R.h"
#include "api.h"

using namespace rgl;
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
//   rgl::rgl_init moved to init.cpp
//

namespace rgl {
extern DeviceManager* deviceManager;
}

//
// FUNCTION
//   rgl::rgl_quit
//
// DESCRIPTION
//   Gets called by .onUnload ( R function )
//


void rgl::rgl_quit(int* successptr)
{
  if (deviceManager) {
    delete deviceManager;
    deviceManager = 0;
  }

  quit();

  *successptr = RGL_SUCCESS;
}

//
// FUNCTION
//   rgl::rgl_dev_open
//

void rgl::rgl_dev_open(int* successptr, int* useNULL)
{
  *successptr = as_success( deviceManager && deviceManager->openDevice(*useNULL) );
  CHECKGLERROR;
}


//
// FUNCTION
//   rgl::rgl_dev_close
//

void rgl::rgl_dev_close(int* successptr)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getCurrentDevice())) {

    device->close();
    success = RGL_SUCCESS;
    CHECKGLERROR;

  }

  *successptr = success;
}

void rgl::rgl_dev_bringtotop(int* successptr, int* stay)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getCurrentDevice())) {

    device->bringToTop(*stay);
    success = RGL_SUCCESS;
    CHECKGLERROR;

  }

  *successptr = success;
}

//
// FUNCTION
//   rgl::rgl_dev_getcurrent
//
// RETURNS
//   device id
//

SEXP rgl::rgl_dev_getcurrent(void)
{
  SEXP result;
  if (deviceManager) {
    int id = deviceManager->getCurrent();
    PROTECT(result = ScalarInteger(id));
    if (id) {
      PROTECT(result = namesgets(result, ScalarString(mkChar(deviceManager->getDevice(id)->getDevtype()))));
      CHECKGLERROR;     
      UNPROTECT(1);
    }
    UNPROTECT(1);
    return result;
  }
  return ScalarInteger(0);
}

//
// FUNCTION
//   rgl::rgl_dev_list
//
// RETURNS
//   list of active device ids
//

SEXP rgl::rgl_dev_list(void)
{
  SEXP result, names;
  if (deviceManager) {
    int n = deviceManager->getDeviceCount();
    PROTECT(result = allocVector(INTSXP, n));
    deviceManager->getDeviceIds(INTEGER(result), n);
    PROTECT(names = allocVector(STRSXP, n));
    for (int i = 0; i < n; i++) {
      Device* device = deviceManager->getDevice(INTEGER(result)[i]);
      SET_STRING_ELT(names, i, mkChar(device->getDevtype()));
    }
    PROTECT(result = namesgets(result, names));
    CHECKGLERROR;
    UNPROTECT(3);
    return result;
  }
  return allocVector(INTSXP, 0);
}


//
// FUNCTION
//   rgl::rgl_dev_setcurrent
//
// PARAMETERS
//   idata
//     [0]  device id
//

void rgl::rgl_dev_setcurrent(int* successptr, int* idata)
{
  int id = idata[0];
  bool silent = (bool) idata[1];
  *successptr = as_success ( deviceManager && deviceManager->setCurrent(id, silent) );
  CHECKGLERROR;
}


//
// SCENE MANAGEMENT
//

static Material currentMaterial(Color(1.0f,1.0f,1.0f),Color(1.0f,0.0f,0.0f));

//
// FUNCTION
//   rgl::rgl_clear ( successPtr, idata(type) )
//
// PARAMETERS
//   idata
//     [0]  count of types
//     [1], [2], ...  TypeID 1, 2, ...
//
//

void rgl::rgl_clear(int* successptr, int *idata)
{
  int success = RGL_SUCCESS;
  Device* device;
  int num = idata[0];

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    for (int i=1; success && i<=num; i++) {
      TypeID stackTypeID = (TypeID) idata[i];

      success = as_success( device->clear( stackTypeID ) ); // viewpoint & material handled in R, background ignored
    }
    CHECKGLERROR;
  }

  *successptr = success;
}


//
// FUNCTION
//   rgl::rgl_pop  ( successPtr, idata )
//
// PARAMETERS
//   idata
//     [0]  stack TypeID
//     [1]  id SceneNode identifier
//
//


void rgl::rgl_pop(int* successptr, int* idata)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getCurrentDevice())) {

    TypeID stackTypeID = (TypeID) idata[0];
    int id = idata[1];
 
    success = as_success( device->pop( stackTypeID, id ) );
    CHECKGLERROR;

  }

  *successptr = success;
}

//
// FUNCTION
//   rgl::rgl_id_count
//

void rgl::rgl_id_count(int* type, int* count)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    
    *count = 0;
    while (*type) {
      *count += scene->get_id_count((TypeID) *type);
      type++;
    }
    CHECKGLERROR;
  } else {
    *count = 0;
  }
}  

//
// FUNCTION
//   rgl::rgl_ids
//

void rgl::rgl_ids(int* type, int* ids, char** types)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    
    while (*type) {
      int n = scene->get_id_count((TypeID) *type);
      scene->get_ids((TypeID) *type, ids, types);
      ids += n;
      types += n;
      type++;
    }
    CHECKGLERROR;
  }
} 

//
// FUNCTION
//   rgl::rgl_attrib_count
//

void rgl::rgl_attrib_count(int* id, int* attrib, int* count)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    AABox bbox = scene->getBoundingBox();
    SceneNode* scenenode = scene->get_scenenode(*id, true);
    if ( scenenode )
      *count = scenenode->getAttributeCount(bbox, *attrib);
    else
      *count = 0;
  }
} 

//
// FUNCTION
//   rgl::rgl_attrib
//

void rgl::rgl_attrib(int* id, int* attrib, int* first, int* count, double* result)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    AABox bbox = scene->getBoundingBox();
    SceneNode* scenenode = scene->get_scenenode(*id, true);
    if ( scenenode )
      scenenode->getAttribute(bbox, *attrib, *first, *count, result);
  }
} 

//
// FUNCTION
//   rgl::rgl_text_attrib
//

void rgl::rgl_text_attrib(int* id, int* attrib, int* first, int* count, char** result)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    AABox bbox = scene->getBoundingBox();
    SceneNode* scenenode = scene->get_scenenode(*id, true);
    
    if (scenenode)
      for (int i=0; i < *count; i++) {
      	String s = scenenode->getTextAttribute(bbox, *attrib, i + *first);
      	if (s.length) {
      	  *result = R_alloc(s.length + 1, 1);
	  strncpy(*result, s.text, s.length);
	  (*result)[s.length] = '\0';
	}
	result++;
      }
  }
} 

//
// FUNCTION
//   rgl::rgl_bg   ( successPtr, idata )
//
// PARAMETERS
//   idata
//     [0]  bool environment sphere
//     [1]  int  fogtype
//


void rgl::rgl_bg(int* successptr, int* idata)
{
  int success = RGL_FAIL;

  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    bool sphere    = as_bool( idata[0] );
    int  fogtype   = idata[1];

    success = as_success( device->add( new Background(currentMaterial, sphere, fogtype) ) );
    CHECKGLERROR;
  }

  *successptr = success;
}


//
// FUNCTION
//   rgl::rgl_light   ( successPtr, idata, cdata, ddata )
//

void rgl::rgl_light ( int* successptr, int* idata, double* ddata )
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    bool  viewpoint_rel = as_bool( idata[0] );
    bool  finite_pos = as_bool( idata[10] );

    Color ambient;
    Color diffuse;
    Color specular;

    ambient.set3iv ( &idata[1] );
    diffuse.set3iv ( &idata[4] );
    specular.set3iv( &idata[7] );

    float theta         = (float) ddata[0];
    float phi           = (float) ddata[1];
    Vertex finposition   = Vertex( ddata[2], ddata[3], ddata[4] );

    success = as_success( device->add( new Light( PolarCoord(theta, phi), finposition, (bool) viewpoint_rel, (bool) finite_pos, ambient, diffuse, specular ) ) );
    CHECKGLERROR;
  }

  *successptr = success;
}


void rgl::rgl_viewpoint(int* successptr, int* idata, double* ddata)
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

    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_getZoom(int* successptr, double* zoom)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Viewpoint* viewpoint = scene->getViewpoint();
    *zoom = viewpoint->getZoom();
    success = RGL_SUCCESS;
    CHECKGLERROR;
  }
  *successptr = success;
}

void rgl::rgl_setZoom(int* successptr, double* zoom)
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
    CHECKGLERROR;
  }
  *successptr = success;
}

void rgl::rgl_getFOV(int* successptr, double* fov)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Viewpoint* viewpoint = scene->getViewpoint();
    *fov = viewpoint->getFOV();
    success = RGL_SUCCESS;
    CHECKGLERROR;
  }
  *successptr = success;
}

void rgl::rgl_setFOV(int* successptr, double* fov)
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
    CHECKGLERROR;
  }
  *successptr = success;
}

void rgl::rgl_getIgnoreExtent(int* successptr, int* ignoreExtent)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    *ignoreExtent = device->getIgnoreExtent();
    success = RGL_SUCCESS;
    CHECKGLERROR;
  }
  *successptr = success;
}

void rgl::rgl_setIgnoreExtent(int* successptr, int* ignoreExtent)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    device->setIgnoreExtent(*ignoreExtent);
    success = RGL_SUCCESS;
    CHECKGLERROR;
  }
  *successptr = success;
}

void rgl::rgl_getSkipRedraw(int* successptr, int* skipRedraw)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    *skipRedraw = device->getSkipRedraw();
    success = RGL_SUCCESS;
    CHECKGLERROR;
  }
  *successptr = success;
}

void rgl::rgl_setSkipRedraw(int* successptr, int* skipRedraw)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    device->setSkipRedraw(*skipRedraw);
    success = RGL_SUCCESS;
    CHECKGLERROR;
  }
  *successptr = success;
}

void rgl::rgl_primitive(int* successptr, int* idata, double* vertex, double* normals, double* texcoords)
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
    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_surface(int* successptr, int* idata, double* x, double* z, double* y, 
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

    CHECKGLERROR;
  }
  *successptr = success;
}

void rgl::rgl_spheres(int* successptr, int* idata, double* vertex, double* radius)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int nvertex = idata[0];
    int nradius = idata[1];

    success = as_success( device->add( new SphereSet(currentMaterial, nvertex, vertex, nradius, radius,
    						     device->getIgnoreExtent()) ) );
    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_planes(int* successptr, int* idata, double* normals, double* offsets)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int nnormal = idata[0];
    int noffset = idata[1];

    success = as_success( device->add( new PlaneSet(currentMaterial, nnormal, normals, noffset, offsets) ) );
    CHECKGLERROR;

  }
  *successptr = success;
}

void rgl::rgl_clipplanes(int* successptr, int* idata, double* normals, double* offsets)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int nnormal = idata[0];
    int noffset = idata[1];

    success = as_success( device->add( new ClipPlaneSet(currentMaterial, nnormal, normals, noffset, offsets) ) );
    CHECKGLERROR;

  }
  *successptr = success;
}

void rgl::rgl_abclines(int* successptr, int* idata, double* bases, double* directions)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int nbases = idata[0];
    int ndirs  = idata[1];

    success = as_success( device->add( new ABCLineSet(currentMaterial, nbases, bases, ndirs, directions) ) );
    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_sprites(int* successptr, int* idata, double* vertex, double* radius, int* shapes, double* userMatrix)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int nvertex = idata[0];
    int nradius = idata[1];
    int nshapes = idata[2];
    int count = 0;
    Shape** shapelist;
    if (nshapes) {
      shapelist = (Shape**) R_alloc(nshapes, sizeof(Shape*));
      RGLView* rglview = device->getRGLView();
      Scene* scene = rglview->getScene();
      while (nshapes) {
        int id = *(shapes++);
        nshapes--;
        Shape* shape = scene->get_shape(id); 
        if (shape) {
          scene->rootSubscene.hideShape(id, true);
          shapelist[count++] = shape; 
        }
      }
      if (!count) {
        *successptr = RGL_FAIL;
        return;
      }
    } else 
      shapelist = NULL;
    success = as_success( device->add( new SpriteSet(currentMaterial, nvertex, vertex, nradius, radius,
    						     device->getIgnoreExtent(), count, shapelist, userMatrix) ) );
    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_newsubscene(int* successptr, int* parentid)
{
  int success = RGL_FAIL;
  Device* device;
    
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();      
    Subscene* parent = scene->get_subscene(parentid[0]);
    if (parent) {
      Subscene* subscene = new Subscene( parent, EMBED_INHERIT, EMBED_INHERIT, EMBED_INHERIT );
      if (subscene && scene->add(subscene)) {
	success = as_success( subscene->getObjID() );
      }
    }
  }
  *successptr = success;
} 

void rgl::rgl_setsubsceneid(int* successptr, int* subsceneid)
{
  int success = RGL_FAIL;
  Device* device;
    
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();      
    Subscene* subscene = scene->get_subscene(subsceneid[0]);
    if (subscene) {
      scene->setCurrentSubscene(subscene);
      success = as_success(subsceneid[0]);
    }
  }
  *successptr = success;
}  

void rgl::rgl_getsubsceneid(int* successptr)
{
  int success = RGL_FAIL;
  Device* device;
    
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();      
    Subscene* subscene = scene->getCurrentSubscene();
    if (subscene) {
      success = as_success(subscene->getObjID());
    }
  }
  *successptr = success;
} 

void rgl::rgl_addtosubscene(int* successptr, int* count, int* ids)
{
  int success = RGL_FAIL;
  Device* device;
    
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();      
    Subscene* subscene = scene->getCurrentSubscene();
    if (subscene) {
      for (int i=0; i < count[0]; i++) {
        SceneNode* node = scene->get_scenenode(ids[i], true);
	if (node) 
	  switch (node->getTypeID()) {
	  case SHAPE: 
	    subscene->addShape( static_cast<Shape*>(node) );
	    success++;
	    break;
	  default:
	    warning("id %d is not a shape; cannot add to subscene", ids[i]);
          }
	else 
	  warning("id %d not found in scene", ids[i]);
      }
    }
  }
  *successptr = success;
} 

void rgl::rgl_material(int *successptr, int* idata, char** cdata, double* ddata)
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
  mat.depth_mask = (idata[23]) ? true : false;
  mat.depth_test = idata[24];
  
  int* colors   = &idata[25];

  char*  pixmapfn = cdata[0];

  mat.shininess   = (float) ddata[0];
  mat.size      = (float) ddata[1];
  mat.lwd         = (float) ddata[2];
  double* alpha   = &ddata[3];

  mat.alphablend  = false;
  
  if ( strlen(pixmapfn) > 0 ) {
    mat.texture = new Texture(pixmapfn, textype, mipmap, (unsigned int) minfilter, (unsigned int) magfilter, envmap);
    if ( !mat.texture->isValid() ) {
      mat.texture->unref();
      // delete mat.texture;
      mat.texture = NULL;
    } else
      mat.alphablend = mat.alphablend || mat.texture->hasAlpha();
  } else
    mat.texture = NULL;

  mat.colors.set( ncolor, colors, nalpha, alpha);
  mat.alphablend  = mat.alphablend || mat.colors.hasAlpha();

  CHECKGLERROR;

  *successptr = RGL_SUCCESS;
}

void rgl::rgl_getcolorcount(int* count)
{
  *count = currentMaterial.colors.getLength();
  CHECKGLERROR;
}

void rgl::rgl_getmaterial(int *successptr, int *id, int* idata, char** cdata, double* ddata)
{
  Material* mat = &currentMaterial;
  unsigned int i,j;
  
  if (*id > 0) {
    Device* device;
    *successptr = RGL_FAIL;
    if (deviceManager && (device = deviceManager->getCurrentDevice())) {
      RGLView* rglview = device->getRGLView();
      Scene* scene = rglview->getScene();
    
      Shape* shape = scene->get_shape(*id, true);
      if (shape) 
        mat = shape->getMaterial(); /* success! successptr will be set below */
      else {
	BBoxDeco* bboxdeco = scene->get_bboxdeco();
	if (bboxdeco && *id == bboxdeco->getObjID())
	  mat = bboxdeco->getMaterial();
	else {
	  Background* background = scene->get_background();
	  if (background && *id == background->getObjID())
	    mat = background->getMaterial();
	  else
	    return;
        }
      }
    } else
      return;
  }
  
  idata[1] = mat->lit ? 1 : 0;
  idata[2] = mat->smooth ? 1 : 0;
  idata[3] = (int) mat->front;
  idata[4] = (int) mat->back;
  idata[5] = mat->fog ? 1 : 0;
  if (mat->texture) {
    mat->texture->getParameters( (Texture::Type*) (idata + 6),
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
  idata[11] = (int) mat->ambient.getRedub();
  idata[12] = (int) mat->ambient.getGreenub();
  idata[13] = (int) mat->ambient.getBlueub();
  idata[14] = (int) mat->specular.getRedub();
  idata[15] = (int) mat->specular.getGreenub();
  idata[16] = (int) mat->specular.getBlueub();  
  idata[17] = (int) mat->emission.getRedub();
  idata[18] = (int) mat->emission.getGreenub();
  idata[19] = (int) mat->emission.getBlueub();
  idata[21] = mat->point_antialias ? 1 : 0;
  idata[22] = mat->line_antialias ? 1 : 0;
  idata[23] = mat->depth_mask ? 1 : 0;
  idata[24] = mat->depth_test;

  for (i=0, j=25; (i < mat->colors.getLength()) && (i < (unsigned int)idata[0]); i++) {
    idata[j++] = (int) mat->colors.getColor(i).getRedub();
    idata[j++] = (int) mat->colors.getColor(i).getGreenub();
    idata[j++] = (int) mat->colors.getColor(i).getBlueub();
  }
  idata[0] = i;

  ddata[0] = (double) mat->shininess;
  ddata[1] = (double) mat->size;
  ddata[2] = (double) mat->lwd;
  
  if (mat->colors.hasAlpha()) {
    for (i=0, j=3; (i < mat->colors.getLength()) && (i < (unsigned int)idata[10]); i++) 
      ddata[j++] = (double) mat->colors.getColor(i).getAlphaf();
    idata[10] = i;
  } else 
    idata[10] = 0;
  CHECKGLERROR;
  
  *successptr = RGL_SUCCESS;
}

void rgl::rgl_texts(int* successptr, int* idata, double* adj, char** text, double* vertex,
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
    CHECKGLERROR;

  }
  *successptr = success;
}

void rgl::rgl_bbox(int* successptr,
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
    int   front      =        idata[7];

    float xunit      = (float) ddata[0];
    float yunit      = (float) ddata[1];
    float zunit      = (float) ddata[2];
    float marklen    = (float) ddata[3];
    float expand     = (float) ddata[4];    


    AxisInfo xaxis(xticks, xat, xtext, xlen, xunit);
    AxisInfo yaxis(yticks, yat, ytext, ylen, yunit);
    AxisInfo zaxis(zticks, zat, ztext, zlen, zunit);

    success = as_success( device->add( new BBoxDeco(currentMaterial, xaxis, yaxis, zaxis, marklen, (bool) marklen_rel, expand, (bool)front ) ) );
    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_snapshot(int* successptr, int* idata, char** cdata)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getCurrentDevice())) {

    int   format   = idata[0];
    char* filename = cdata[0];

    success = as_success( device->snapshot( format, filename ) );
    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_pixels(int* successptr, int* ll, int* size, int* component, float* result)
{
  int success = RGL_FAIL;
  
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    
    success = as_success( device->pixels( ll, size, *component, result) );
    CHECKGLERROR;
    
  }
  
  *successptr = success;
}

void rgl::rgl_user2window(int* successptr, int* idata, double* point, double* pixel, double* model, double* proj, int* view)
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
    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_window2user(int* successptr, int* idata, double* point, double* pixel, double* model, double* proj, int* view)
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
    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_getMouseMode(int* successptr, int *button, int* mode)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {
  
    RGLView* rglview = device->getRGLView();
    *mode = static_cast<int>( rglview->getMouseMode(*button) );
    success = RGL_SUCCESS;
    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_setMouseMode(int* successptr, int* button, int* mode)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {
  
    RGLView* rglview = device->getRGLView();
    rglview->setMouseMode(*button, (MouseModeID)(*mode));

    success = RGL_SUCCESS;
    CHECKGLERROR;
  }

  *successptr = success;
}


void rgl::rgl_selectstate(int* successptr, int* selectstate, double* locations)
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
	CHECKGLERROR;
    }
    *successptr = success;

}

void rgl::rgl_setselectstate(int* successptr, int *idata)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    MouseSelectionID selectState = (MouseSelectionID) idata[0];
    RGLView* rglview = device->getRGLView();
    rglview->setSelectState(selectState);

    success = RGL_SUCCESS;
    CHECKGLERROR;

  }

  *successptr = success;
}

void rgl::rgl_getUserMatrix(int* successptr, double* userMatrix)
{
    int success = RGL_FAIL;
    Device* device;

    if (deviceManager && (device = deviceManager->getAnyDevice())) {

	RGLView* rglview = device->getRGLView();
	rglview->getUserMatrix(userMatrix);

    	success = RGL_SUCCESS;
	CHECKGLERROR;

  }

  *successptr = success;
}

void rgl::rgl_setUserMatrix(int* successptr, double* userMatrix)
{

    int success = RGL_FAIL;
    Device* device;

    if (deviceManager && (device = deviceManager->getAnyDevice())) {

	RGLView* rglview = device->getRGLView();
	rglview->setUserMatrix(userMatrix);

	success = RGL_SUCCESS;

        CHECKGLERROR;
    }

    *successptr = success;

}

void rgl::rgl_getPosition(double* position)
{
   Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    RGLView* rglview = device->getRGLView();
    rglview->getPosition(position);
    CHECKGLERROR;

  }
 	
}

void rgl::rgl_setPosition(double* position)
{
  	Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    RGLView* rglview = device->getRGLView();
    rglview->setPosition(position);

    CHECKGLERROR;
  }

}

void rgl::rgl_getScale(int* successptr, double* scale)
{
    int success = RGL_FAIL;
    Device* device = deviceManager->getAnyDevice();

    if (device) {

	RGLView* rglview = device->getRGLView();
	rglview->getScale(scale);

	success = RGL_SUCCESS;
	CHECKGLERROR;

    }

    *successptr = success;
}

void rgl::rgl_setScale(int* successptr, double* scale)
{

    int success = RGL_FAIL;
    Device* device = deviceManager->getAnyDevice();

    if (device) {

	RGLView* rglview = device->getRGLView();
	rglview->setScale(scale);

	success = RGL_SUCCESS;

        CHECKGLERROR;
    }

    *successptr = success;

}

void rgl::rgl_getModelMatrix(int* successptr, double* modelMatrix)
{
    int success = RGL_FAIL;
    Device* device;

    if (deviceManager && (device = deviceManager->getAnyDevice())) {

	RGLView* rglview = device->getRGLView();
	for (int i=0; i<16; i++) {
		modelMatrix[i] = rglview->modelMatrix[i];
	}
	success = RGL_SUCCESS;
        CHECKGLERROR;  	
    }

    *successptr = success;
}

void rgl::rgl_getProjMatrix(int* successptr, double* projMatrix)
{
    int success = RGL_FAIL;
    Device* device;

    if (deviceManager && (device = deviceManager->getAnyDevice())) {

	RGLView* rglview = device->getRGLView();
	for (int i=0; i<16; i++) {
		projMatrix[i] = rglview->projMatrix[i];
	}
	success = RGL_SUCCESS;
        CHECKGLERROR;
    }

    *successptr = success;
}

void rgl::rgl_getViewport(int* successptr, int* viewport)
{
    int success = RGL_FAIL;
    Device* device;

    if (deviceManager && (device = deviceManager->getAnyDevice())) {

	RGLView* rglview = device->getRGLView();
	for (int i=0; i<4; i++) {
		viewport[i] = rglview->viewport[i];
	}
	success = RGL_SUCCESS;
        CHECKGLERROR;
    }

    *successptr = success;
}

void rgl::rgl_getWindowRect(int* successptr, int* rect)
{
  int success = RGL_FAIL;
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
   
     device->getWindowRect(rect, rect+1, rect+2, rect+3);
     success = RGL_SUCCESS;
     CHECKGLERROR;
  }
  *successptr = success;
}

void rgl::rgl_setWindowRect(int* successptr, int* rect)
{
  int success = RGL_FAIL;
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
  
    device->setWindowRect(rect[0], rect[1], rect[2], rect[3]);
    success = RGL_SUCCESS;
    CHECKGLERROR;
  }
  *successptr = success;
}

void rgl::rgl_postscript(int* successptr, int* idata, char** cdata)
{
  int success = RGL_FAIL;
 
  Device* device;

  if (deviceManager && (device = deviceManager->getCurrentDevice())) {

    int   format   = idata[0];
    bool  drawText = (bool)idata[1];
    char* filename = cdata[0];

    success = as_success( device->postscript( format, filename, drawText ) );
    CHECKGLERROR;
  }

  *successptr = success;
}


void rgl::rgl_getBoundingbox(int* successptr, double* bboxvec)
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
      CHECKGLERROR;
  }
	
  *successptr = success;
}

/* font access functions.  These are only used from par3d */

char* rgl::rgl_getFamily()
{
  Device* device;
  const char* f;
  char* result = NULL;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    f = device->getRGLView()->getFontFamily();
    result = R_alloc(strlen(f)+1, 1);
    strcpy(result, f);
    CHECKGLERROR;
  } 
  
  return result;
}

bool rgl::rgl_setFamily(const char *family)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    device->getRGLView()->setFontFamily(family);
    CHECKGLERROR;
    return true;
  } else
    return false;
}

int rgl::rgl_getFont()
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    int result = device->getRGLView()->getFontStyle();
    CHECKGLERROR;
    return result;
  } else
    return -1;
}

bool rgl::rgl_setFont(int font)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    device->getRGLView()->setFontStyle(font);
    CHECKGLERROR;
    return true;
  } else
    return false;
}

double rgl::rgl_getCex()
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    double result = device->getRGLView()->getFontCex();
    CHECKGLERROR;  
    return result;
  } else
    return -1;
}

bool rgl::rgl_setCex(double cex)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    device->getRGLView()->setFontCex(cex);
    CHECKGLERROR;
    return true;
  } else
    return false;
}

int rgl::rgl_getUseFreeType()
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    int result = (int) device->getRGLView()->getFontUseFreeType();
    CHECKGLERROR;  
    return result;
  } else
    return -1;
}

bool rgl::rgl_setUseFreeType(bool useFreeType)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    device->getRGLView()->setFontUseFreeType(useFreeType);
    CHECKGLERROR;
    return true;
  } else
    return false;
}

char* rgl::rgl_getFontname()
{
  Device* device;
  const char* f;
  char* result = NULL;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    f = device->getRGLView()->getFontname();
    result = R_alloc(strlen(f)+1, 1);
    strcpy(result, f);
    CHECKGLERROR;
  } 
  return result;
}

int rgl::rgl_getAntialias()
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    WindowImpl* windowImpl = device->getRGLView()->windowImpl;
    if (windowImpl->beginGL()) {
      int result;      
      glGetIntegerv(GL_SAMPLES, &result);
      windowImpl->endGL();
      CHECKGLERROR;
      return result;
    }
  }
  return 1;
}

int rgl::rgl_getMaxClipPlanes()
{
  int result;
  glGetError();
  glGetIntegerv(GL_MAX_CLIP_PLANES, &result);
  if (glGetError() == GL_NO_ERROR)
    return result;
  else
    return 6;
}  
