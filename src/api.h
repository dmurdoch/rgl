#ifndef RGL_API_H
#define RGL_API_H

#include "ABCLineSet.h"
#include "PlaneSet.h"
#include "SphereSet.h"
#include "SpriteSet.h"
#include "Surface.h"
#include "TextSet.h"
#include "R.h"
#include <Rinternals.h>


namespace rgl {

#ifdef __cplusplus
extern "C" {
#endif

/*
// RGL API IMPLEMENTATION
//
//
// C API FUNCTION DESIGN
//  rgl_<name> ( successptr , ... )
//
// PARAMETERS
//   successptr
//     [0]  function success status
*/

/* library service */

void rgl_quit          (int* successptr);

/* device management */

void rgl_dev_open      (int* successptr, int* useNULL);
void rgl_dev_close      (int* successptr);
SEXP rgl_dev_getcurrent(void);
SEXP rgl_dev_list        (void);
void rgl_dev_setcurrent(int* successptr, int* idata);
void rgl_dev_bringtotop(int* successptr, int* stay);

/* device services */

void rgl_snapshot (int* successptr, int* idata, char** cdata);
void rgl_pixels(int* successptr, int* ll, int* size, int* component, double* result);
void rgl_postscript (int* successptr, int* idata, char** cdata);

/* scene management */

void rgl_clear    (int* successptr, int* idata);
void rgl_pop      (int* successptr, int* idata);
void rgl_id_count (int* type, int* count, int* subsceneID);
void rgl_ids       (int* type, int* ids, char** types, int* subsceneID);
void rgl_attrib_count (int* id, int* attrib, int* count);
void rgl_attrib   (int* id, int* attrib, int* first, int* count, double* result);
void rgl_text_attrib   (int* id, int* attrib, int* first, int* count, char** result);

void rgl_material (int* successptr, int* idata, char** cdata, double* ddata);
void rgl_getcolorcount(int* count);
void rgl_getmaterial (int* successptr, int *id, int* idata, char** cdata, double* ddata);

void rgl_light    (int* successptr, int* idata, double* ddata );

void rgl_viewpoint(int* successptr, int* idata, double* ddata);

void rgl_bg       (int* successptr, int* idata, double* fogScale);
void rgl_bbox     (int* successptr, int* idata, double* ddata, double* xat, char** xtext, double* yat, char** ytext, double* zat, char** ztext);

SEXP rgl_primitive(SEXP idata, SEXP vertex, SEXP normals, SEXP texcoords);
void rgl_texts    (int* successptr, int* idata, double* adj, char** text, double* vertex,
                                 int* nfonts, char** family, int* style, double* cex, int* useFreeType,
                                 int* npos, int* pos);
void rgl_spheres  (int* successptr, int* idata, double* vertex, double* radius, int* fastTransparency);
void rgl_planes   (int* successptr, int* idata, double* normals, double* offsets);
void rgl_clipplanes(int* successptr, int* idata, double* normals, double* offsets);
void rgl_abclines (int* successptr, int* idata, double* bases, double* directions);

void rgl_surface  (int* successptr, int* idata, double* x, double* z, double* y, 
	                         double* normal_x, double* normal_z, double* normal_y,
	                         double* texture_s, double* texture_t,
	                         int* coords, int* orientation, int* flags);
void rgl_sprites  (int* successptr, int* idata, double* vertex, double* radius, 
                   int* shapes, double* userMatrix, double* adj,
                   int* pos, double* offset);
void rgl_newsubscene (int* successptr, int* parentid, int* embedding, int* ignoreExtent);
void rgl_setsubscene (int* id);
void rgl_getsubsceneid (int* id, int* dev); /* On input, 0 for root, 1 for current */
void rgl_getsubsceneparent(int* id);
void rgl_getsubscenechildcount(int* id, int* n);
void rgl_getsubscenechildren(int* id, int* children);
void rgl_addtosubscene (int* successptr, int* count, int* ids);
void rgl_delfromsubscene(int* successptr, int* count, int* ids);
void rgl_gc(int* count, int* protect);

void rgl_locator(int* successptr, double* locations);

void rgl_selectstate(int* dev, int* sub, int* successptr, int* selectstate, double* locations);
void rgl_setselectstate(int* dev, int* sub, int* successptr, int *idata);
void rgl_setEmbeddings(int* successptr, int* embeddings);
void rgl_getEmbeddings(int* successptr, int* embeddings);

SEXP rgl_setMouseCallbacks(SEXP button, SEXP begin, SEXP update, SEXP end, SEXP dev, SEXP sub);
SEXP rgl_setWheelCallback(SEXP rotate, SEXP dev, SEXP sub);
SEXP rgl_getMouseCallbacks(SEXP button, SEXP dev, SEXP sub);
SEXP rgl_getWheelCallback(SEXP dev, SEXP sub);

SEXP rgl_getAxisCallback(SEXP dev, SEXP sub, SEXP axis);
SEXP rgl_setAxisCallback(SEXP draw, SEXP dev, SEXP sub, SEXP axis);

SEXP rgl_par3d(SEXP device, SEXP subscene, SEXP args);

/* These may be removed if observer is set completely by par3d */
void rgl_getObserver(int* successptr, double* ddata);
void rgl_setObserver(int* successptr, double* ddata);
void rgl_incrementID(int* n);

SEXP rgl_earcut(SEXP x, SEXP y);

#ifdef __cplusplus
}
#endif

} // namespace rgl

#endif /* RGL_API_H */

