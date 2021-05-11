// C++ source
// This file is part of RGL.
//

#include "lib.h"
#include "DeviceManager.h"
#include "rglview.h"

#include "lib.h"
#include "R.h"
#include "api.h"
#include "platform.h"

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
extern void getObserver(double* ddata, Subscene* subscene);
extern void setObserver(bool automatic, double* ddata, RGLView* rglview, Subscene* subscene);
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

void rgl::rgl_id_count(int* type, int* count, int* subsceneID)
{
  Device* device;    
  *count = 0;
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Subscene* subscene;

    if (!*subsceneID) {
      while (*type) {
        *count += scene->get_id_count((TypeID) *type);
        type++;
      }
    } else if ((subscene = scene->getSubscene(*subsceneID))) {
      while (*type) {
        *count += subscene->get_id_count((TypeID) *type, false);
	type++;
      }
    }
    CHECKGLERROR;
  } 
}  

//
// FUNCTION
//   rgl::rgl_ids
//

void rgl::rgl_ids(int* type, int* ids, char** types, int* subsceneID)
{
  Device* device;
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Subscene* subscene;
    if (!*subsceneID) {  
      while (*type) {
        int n = scene->get_id_count((TypeID) *type);
        if (n) {
          scene->get_ids((TypeID) *type, ids, types);
          ids += n;
          types += n;
        }
        type++;
      }
    } else if ((subscene = scene->getSubscene(*subsceneID))) {
      while (*type) {
        int n = subscene->get_id_count((TypeID) *type, false);
        subscene->get_ids((TypeID) *type, ids, types, false);
        ids += n;
        types += n;
        type++;
      }	
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
    Subscene* subscene = scene->whichSubscene(*id);
    AABox bbox = subscene->getBoundingBox();
    SceneNode* scenenode = scene->get_scenenode(*id);
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
    Subscene* subscene = scene->whichSubscene(*id);
    AABox bbox = subscene->getBoundingBox();
    SceneNode* scenenode = scene->get_scenenode(*id);
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
    SceneNode* scenenode = scene->get_scenenode(*id);
    
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


void rgl::rgl_bg(int* successptr, int* idata, double* fogScale)
{
  int success = RGL_FAIL;

  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    bool sphere    = as_bool( idata[0] );
    int  fogtype   = idata[1];
    Background* bg = new Background(currentMaterial, sphere, fogtype, static_cast<float>(fogScale[0]));
    success = as_success( device->add( bg ) );
    SceneNode*  quad = bg->getQuad();
    if (quad) {
      int save_ignore = device->getIgnoreExtent(),
      	  save_redraw = device->getSkipRedraw();
      device->setSkipRedraw(true);
      device->setIgnoreExtent(true);
      device->add( quad );
      device->getScene()->hide(quad->getObjID());
      device->setIgnoreExtent(save_ignore);
      device->setSkipRedraw(save_redraw);
    }
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
    Vertex finposition   = Vertex( static_cast<float>(ddata[2]), 
                                   static_cast<float>(ddata[3]), 
                                   static_cast<float>(ddata[4]) );

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
    Vertex scale      = Vertex( static_cast<float>(ddata[4]), 
                                static_cast<float>(ddata[5]), 
                                static_cast<float>(ddata[6]) );
    
    int   interactive = idata[0];
    int   polar       = idata[1];
    int   user        = idata[2];
    int   model       = idata[3];
    
    if (model) {
      if (polar) success = as_success( device->add( new ModelViewpoint(PolarCoord(theta, phi), scale, interactive) ) );
      else       success = as_success( device->add( new ModelViewpoint(ddata + 7, scale, interactive) ) );
    } else
      success = RGL_SUCCESS;
      
    if (user && success)
      success = as_success( device->add( new UserViewpoint(fov, zoom) ) );

    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_getObserver(int* successptr, double* ddata)
{
  int success = RGL_FAIL;
  
  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
  
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getCurrentSubscene();
    getObserver(ddata, subscene);
    success = RGL_SUCCESS;
  }
  
  *successptr = success;
}

void rgl::rgl_setObserver(int* successptr, double* ddata)
{
  int success = RGL_FAIL;
  
  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
  
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    bool automatic = (bool)*successptr;
    Subscene* subscene = scene->getCurrentSubscene();
    setObserver(automatic, ddata, rglview, subscene);
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

void rgl::rgl_spheres(int* successptr, int* idata, double* vertex, double* radius,
                      int* fastTransparency)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int nvertex = idata[0];
    int nradius = idata[1];

    success = as_success( device->add( new SphereSet(currentMaterial, nvertex, vertex, nradius, radius,
    						     device->getIgnoreExtent(), *fastTransparency != 0) ) );
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
    bool fixedSize = (bool)idata[3];
    int count = 0;
    Shape** shapelist;
    Scene* scene = NULL;
    if (nshapes) {
      shapelist = (Shape**) R_alloc(nshapes, sizeof(Shape*));
      RGLView* rglview = device->getRGLView();
      scene = rglview->getScene();
      while (nshapes) {
        int id = *(shapes++);
        nshapes--;
        Shape* shape = scene->get_shape(id); 
        if (shape) {
          scene->hide(id);
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
    						     device->getIgnoreExtent(), count, shapelist, userMatrix,
    						     fixedSize, scene) ) );
    CHECKGLERROR;
  }

  *successptr = success;
}

void rgl::rgl_newsubscene(int* successptr, int* parentid, int* embedding, int* ignoreExtent)
{
  int success = RGL_FAIL;
  Device* device;
//  Rprintf("rgl_newsubscene with  %d %d %d %d\n",
//          embedding[0], embedding[1], embedding[2], embedding[3]);
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();      
//    Rprintf("getting parent %d\n", parentid[0]);
    Subscene* parent = scene->getSubscene(parentid[0]);
    if (parent) {
      Subscene* current = scene->getCurrentSubscene();
      scene->setCurrentSubscene(parent);
//      Rprintf("Creating subscene\n");
      Subscene* subscene = new Subscene( (Embedding)embedding[0], 
                                         (Embedding)embedding[1], 
                                         (Embedding)embedding[2],
                                         EMBED_REPLACE,
                                         *ignoreExtent != 0);
      if (subscene && scene->add(subscene)) {
        for (int i=0; i<5; i++)
          subscene->setMouseMode(i, parent->getMouseMode(i));
        if (embedding[3] != EMBED_REPLACE)
          subscene->setEmbedding(3, (Embedding)embedding[3]);
        success = as_success( subscene->getObjID() );
      }
      scene->setCurrentSubscene(current);
    }
  }
  *successptr = success;
} 

void rgl::rgl_setsubscene(int* id)
{
  Device* device;
    
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene(); 
    Subscene* subscene = scene->getSubscene(*id);
    if (subscene) {
      *id = scene->setCurrentSubscene(subscene)->getObjID();
    } else
      *id = 0;
  } else
    *id = 0;
}  

void rgl::rgl_getsubsceneid(int* id, int* dev)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getDevice(*dev))) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    const Subscene* subscene = (*id) == 1 ? scene->getCurrentSubscene() : scene->getRootSubscene();
    *id = subscene->getObjID();
  } else
    *id = 0;
} 

void rgl::rgl_getsubsceneparent(int* id)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(*id);
    if (!subscene) {
      *id = NA_INTEGER;
    } else {
      subscene = subscene->getParent();
      *id = subscene ? subscene->getObjID() : 0;
    }
  } else
    *id = NA_INTEGER;
}    

void rgl::rgl_getsubscenechildcount(int* id, int* n)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(*id);
    *n = subscene ? static_cast<int>(subscene->getChildCount()) : 0;
  } else
    *n = 0;
} 

void rgl::rgl_getsubscenechildren(int* id, int* children)
{
  Device* device;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    const Subscene* subscene = scene->getSubscene(*id);
    if (subscene) {
      for (size_t i = 0; i < subscene->getChildCount(); i++) {
        Subscene* child = subscene->getChild(i);
        children[i] = child ? child->getObjID() : 0;
      }
    }
  }
}

void rgl::rgl_addtosubscene(int* successptr, int* count, int* ids)
{
  int success = RGL_FAIL;
  Device* device;
    
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();      
    Subscene* subscene = scene->getSubscene(*successptr);
    if (subscene) {
      for (int i=0; i < count[0]; i++) {
        SceneNode* node = scene->get_scenenode(ids[i]);
	if (node) {
	  subscene->add(node);
	  success = RGL_SUCCESS;
	} else 
	  warning("id %d not found in scene", ids[i]);
      }
      rglview->update();
    }
  }
  *successptr = success;
} 

void rgl::rgl_delfromsubscene(int* successptr, int* count, int* ids)
{
  int success = RGL_FAIL;
  Device* device;
    
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();      
    Subscene* subscene = scene->getSubscene(*successptr);
    if (subscene) {
      for (int i=0; i < count[0]; i++) {
        SceneNode* node = scene->get_scenenode(ids[i]);
	if (node) 
	  switch (node->getTypeID()) {
	  case SHAPE: 
	    subscene->hideShape( ids[i] );
	    success++;
	    break;
	  case LIGHT:
	    subscene->hideLight( ids[i] );
	    success++;
	    break;
	  case BBOXDECO:
	    subscene->hideBBoxDeco( ids[i] );
	    success++;
	    break;
	  case SUBSCENE:
	    scene->setCurrentSubscene( subscene->hideSubscene( ids[i], scene->getCurrentSubscene() ) );
	    success++;
	    break;
	  case BACKGROUND:
	    subscene->hideBackground( ids[i] );
	    success++;
	    break;
	  case USERVIEWPOINT:
	  case MODELVIEWPOINT:
	    subscene->hideViewpoint( ids[i] );
	    success++;
	    break;
	  default:
	    char buffer[20];
	    buffer[19] = 0;
	    node->getTypeName(buffer, 20);
	    warning("id %d is type %s; cannot hide", ids[i], buffer);
          }
	else 
	  warning("id %d not found in scene", ids[i]);
      }
      rglview->update();
    }
  }
  *successptr = success;
}

void rgl::rgl_gc(int* count, int* protect)
{
  Device* device;
  int nprotect = *count;
  *count = 0;
  
  if (deviceManager && (device = deviceManager->getAnyDevice())) {
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    if (scene) {
      Subscene* root = (Subscene *)scene->getRootSubscene(); // need to discard const
      int rootid = root->getObjID();
      for (TypeID i = 1; i < MAX_TYPE; i++) {
        int n = scene->get_id_count(i);
        if (n) {
          std::vector<int> ids(n);
          std::vector<char*> types(n);
          scene->get_ids(i, &ids[0], &types[0]);
          // First, remove the protected ones by setting them to zero.
          bool anyunprot = false;
          for (int j = 0; j < n; j++) {
            bool prot = (rootid == ids[j]);
            for (int k = 0; k < nprotect && !prot; k++) 
              prot = (ids[j] == protect[k]);
            if (prot)
              ids[j] = 0;
            else
              anyunprot = true;
          }
          if (!anyunprot) 
            continue;
          // Now look for the others in subscenes
          int m = root->get_id_count(i, true);
          if (m) {
            std::vector<int> ids2(m);
            std::vector<char*> types2(m);
            root->get_ids(i, &ids2[0], &types2[0], true);
            for (int j = 0; j < n; j++) {
              for (int k = 0; k < m && ids[j] != 0; k++) { 
                if (ids[j] == ids2[k])
                  ids[j] = 0;
              }
            }
          }
          for (int j = 0; j < n; j++) {
            if (ids[j] != 0) {
              scene->pop(i, ids[j]);
              (*count)++;
            }
          }
        }
      }
    }
  }
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
  mat.textype   = (Texture::Type) idata[6];
  mat.mipmap    = (idata[7]) ? true : false;
  mat.minfilter = idata[8];
  mat.magfilter = idata[9];
  int    nalpha = idata[10];
  mat.ambient.set3iv( &idata[11] );
  mat.specular.set3iv( &idata[14] );
  mat.emission.set3iv( &idata[17] );
  mat.envmap    = (idata[20]) ? true : false;
  mat.point_antialias = (idata[21]) ? true : false;
  mat.line_antialias = (idata[22]) ? true : false;
  mat.depth_mask = (idata[23]) ? true : false;
  mat.depth_test = idata[24];
  
  int* colors   = &idata[25];

  char*  pixmapfn = cdata[0];

  mat.shininess   = (float) ddata[0];
  mat.size      = (float) ddata[1];
  mat.lwd         = (float) ddata[2];
  mat.polygon_offset_factor = (float) ddata[3];
  mat.polygon_offset_units = (float) ddata[4];
  mat.polygon_offset = ddata[3] != 0.0 || ddata[4] != 0.0;
  
  double* alpha   = &ddata[5];

  mat.alphablend  = false;
  
  if ( strlen(pixmapfn) > 0 ) {
    mat.texture = new Texture(pixmapfn, mat.textype, mat.mipmap, mat.minfilter, mat.magfilter, mat.envmap);
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
    
      Shape* shape = scene->get_shape(*id);
      if (shape) 
        mat = shape->getMaterial(); /* success! successptr will be set below */
      else {
	BBoxDeco* bboxdeco = scene->get_bboxdeco(*id);
	if (bboxdeco)
	  mat = bboxdeco->getMaterial();
	else {
	  Background* background = scene->get_background(*id);
	  if (background)
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
                               static_cast<int>(strlen(cdata[0])),
                               cdata[0] );
  } else {
    idata[6] = (int)mat->textype;
    idata[7] = mat->mipmap ? 1 : 0; 
    idata[8] = mat->minfilter; 
    idata[9] = mat->magfilter; 
    idata[20] = mat->envmap ? 1 : 0; 
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
  idata[25] = mat->isTransparent();

  for (i=0, j=26; (i < mat->colors.getLength()) && (i < (unsigned int)idata[0]); i++) {
    idata[j++] = (int) mat->colors.getColor(i).getRedub();
    idata[j++] = (int) mat->colors.getColor(i).getGreenub();
    idata[j++] = (int) mat->colors.getColor(i).getBlueub();
  }
  idata[0] = i;

  ddata[0] = (double) mat->shininess;
  ddata[1] = (double) mat->size;
  ddata[2] = (double) mat->lwd;
  ddata[3] = (double) mat->polygon_offset_factor;
  ddata[4] = (double) mat->polygon_offset_units;
  
  if (mat->colors.hasAlpha()) {
    for (i=0, j=5; (i < mat->colors.getLength()) && (i < (unsigned int)idata[10]); i++) 
      ddata[j++] = (double) mat->colors.getColor(i).getAlphaf();
    idata[10] = i;
  } else 
    idata[10] = 0;
  CHECKGLERROR;
  
  *successptr = RGL_SUCCESS;
}

void rgl::rgl_texts(int* successptr, int* idata, double* adj, char** text, double* vertex,
               int* nfonts, char** family, int* style, double* cex, 
               int* useFreeType, int* npos, int* pos)
{
  int success = RGL_FAIL;

  Device* device;

  if (deviceManager && (device = deviceManager->getAnyDevice())) {

    int ntext   = idata[0];
    
    FontArray fonts;
    device->getFonts(fonts, *nfonts, family, style, cex, (bool) *useFreeType);
    success = as_success( device->add( new TextSet(currentMaterial, ntext, text, vertex, 
                                                   adj[0], adj[1],
    						   device->getIgnoreExtent(), fonts, *npos, pos) ) );
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

    int   xticks     =        idata[0]; /* these are length of xat etc. */
    int   yticks     =        idata[1];
    int   zticks     =        idata[2];
    int   xlen       =        idata[3]; /* these are suggested tick counts */
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

void rgl::rgl_pixels(int* successptr, int* ll, int* size, int* component, double* result)
{
  int success = RGL_FAIL;
  
  Device* device;
  
  if (deviceManager && (device = deviceManager->getCurrentDevice())) {
    
    success = as_success( device->pixels( ll, size, *component, result) );
    CHECKGLERROR;
    
  }
  
  *successptr = success;
}

void rgl::rgl_selectstate(int* dev, int* sub, int* successptr, int* selectstate, double* locations)
{
  int success = RGL_FAIL;
  Device* device;
  
  if (deviceManager && (device = deviceManager->getDevice(*dev))) {
    
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(*sub);
    
    selectstate[0] = (int)subscene->getSelectState();
    double* mousePosition = subscene->getMousePosition();
    
    locations[0] = *mousePosition;
    locations[1] = *(mousePosition+1);
    locations[2] = *(mousePosition+2);
    locations[3] = *(mousePosition+3);
    
    success = RGL_SUCCESS;
    CHECKGLERROR;
  }
  *successptr = success;
  
}

void rgl::rgl_setselectstate(int* dev, int* sub, int* successptr, int *idata)
{
  int success = RGL_FAIL;
  Device* device;

  if (deviceManager && (device = deviceManager->getDevice(*dev))) {

    MouseSelectionID selectState = (MouseSelectionID) idata[0];
    RGLView* rglview = device->getRGLView();
    Scene* scene = rglview->getScene();
    Subscene* subscene = scene->getSubscene(*sub);
    
    subscene->setSelectState(selectState);

    success = RGL_SUCCESS;
    CHECKGLERROR;

  }

  *successptr = success;
}

void rgl::rgl_getEmbeddings(int* id, int* embeddings)
{
    Device* device;
    
    if (deviceManager && (device = deviceManager->getAnyDevice())) {
      RGLView* rglview = device->getRGLView();
      Scene* scene = rglview->getScene();
      Subscene* subscene = scene->getSubscene(*id);
      if (subscene) {
        embeddings[0] = subscene->getEmbedding(EM_VIEWPORT);
        embeddings[1] = subscene->getEmbedding(EM_PROJECTION);
        embeddings[2] = subscene->getEmbedding(EM_MODEL);
        embeddings[3] = subscene->getEmbedding(EM_MOUSEHANDLERS);
      }
    }
}

void rgl::rgl_setEmbeddings(int* id, int* embeddings)
{
    Device* device;
    
    if (deviceManager && (device = deviceManager->getAnyDevice())) {
      RGLView* rglview = device->getRGLView();
      Scene* scene = rglview->getScene();
      Subscene* subscene = scene->getSubscene(*id);
      *id = RGL_FAIL;
      if (subscene) {
        if (!subscene->getParent() &&        // can't change the root
            (embeddings[0] != EMBED_REPLACE
            || embeddings[1] != EMBED_REPLACE
            || embeddings[2] != EMBED_REPLACE
            || embeddings[3] != EMBED_REPLACE))
          return;  
        subscene->setEmbedding(0, (Embedding)embeddings[0]);
        subscene->setEmbedding(1, (Embedding)embeddings[1]);
        subscene->setEmbedding(2, (Embedding)embeddings[2]);
        subscene->setEmbedding(3, (Embedding)embeddings[3]);
        rglview->update();
        *id = RGL_SUCCESS;
      }
    }
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
