#ifndef RGL_API_H
#define RGL_API_H

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
void rgl_pixels(int* successptr, int* ll, int* size, int* component, float* result);
void rgl_postscript (int* successptr, int* idata, char** cdata);

/* scene management */

void rgl_clear    (int* successptr, int* idata);
void rgl_pop      (int* successptr, int* idata);
void rgl_id_count (int* type, int* count);
void rgl_ids       (int* type, int* ids, char** types);
void rgl_attrib_count (int* id, int* attrib, int* count);
void rgl_attrib   (int* id, int* attrib, int* first, int* count, double* result);
void rgl_text_attrib   (int* id, int* attrib, int* first, int* count, char** result);

void rgl_material (int* successptr, int* idata, char** cdata, double* ddata);
void rgl_getcolorcount(int* count);
void rgl_getmaterial (int* successptr, int *id, int* idata, char** cdata, double* ddata);

void rgl_light    (int* successptr, int* idata, double* ddata );

void rgl_viewpoint(int* successptr, int* idata, double* ddata);

void rgl_bg       (int* successptr, int* idata);
void rgl_bbox     (int* successptr, int* idata, double* ddata, double* xat, char** xtext, double* yat, char** ytext, double* zat, char** ztext);

void rgl_primitive(int* successptr, int* idata, double* vertex, double* normals, double* texcoords);
void rgl_texts    (int* successptr, int* idata, double* adj, char** text, double* vertex,
                                 int* nfonts, char** family, int* style, double* cex, int* useFreeType);
void rgl_spheres  (int* successptr, int* idata, double* vertex, double* radius);
void rgl_planes   (int* successptr, int* idata, double* normals, double* offsets);
void rgl_clipplanes(int* successptr, int* idata, double* normals, double* offsets);
void rgl_abclines (int* successptr, int* idata, double* bases, double* directions);

void rgl_surface  (int* successptr, int* idata, double* x, double* z, double* y, 
	                         double* normal_x, double* normal_z, double* normal_y,
	                         double* texture_s, double* texture_t,
	                         int* coords, int* orientation, int* flags);
void rgl_sprites  (int* successptr, int* idata, double* vertex, double* radius, int* shapes, double* userMatrix);
void rgl_newsubscene (int* successptr, int* parentid);
void rgl_setsubsceneid (int* successptr, int* viewportid);
void rgl_getsubsceneid (int* successptr);
void rgl_addtosubscene (int* successptr, int* count, int* ids);

void rgl_user2window(int* successptr, int* idata, double* point, double* pixel, double* model, double* proj, int* view);
void rgl_window2user(int* successptr, int* idata, double* point, double* pixel, double* model, double* proj, int* view);
void rgl_locator(int* successptr, double* locations);
void rgl_getMouseMode(int* successptr, int* button, int* mode);
void rgl_setMouseMode(int* successptr, int* button, int* mode);
void rgl_selectstate(int* successptr, int* selectstate, double* locations);
void rgl_setselectstate(int* successptr, int *idata);
void rgl_getUserMatrix(int* successptr, double* userMatrix);
void rgl_setUserMatrix(int* successptr, double* userMatrix);
void rgl_getScale(int* successptr, double* scale);
void rgl_setScale(int* successptr, double* scale);
void rgl_getZoom(int* successptr, double* zoom);
void rgl_setZoom(int* successptr, double* zoom);
void rgl_getFOV(int* successptr, double* fov);
void rgl_setFOV(int* successptr, double* fov);
void rgl_getModelMatrix(int* successptr, double* modelMatrix);
void rgl_getProjMatrix(int* successptr, double* projMatrix);
void rgl_getIgnoreExtent(int* successptr, int* ignoreExtent);
void rgl_setIgnoreExtent(int* successptr, int* ignoreExtent);
void rgl_getSkipRedraw(int* successptr, int* skipRedraw);
void rgl_setSkipRedraw(int* successptr, int* skipRedraw);
void rgl_getViewport(int* successptr, int* viewport);
void rgl_getBoundingbox(int* successptr, double* bboxvec);
void rgl_getWindowRect(int* successptr, int* rect);
void rgl_setWindowRect(int* successptr, int* rect);

SEXP rgl_setMouseCallbacks(SEXP button, SEXP begin, SEXP update, SEXP end);
SEXP rgl_par3d(SEXP args);

/* not for users:  does not maintain consistency */
void rgl_setPosition(double* position);
void rgl_getPosition(double* position);

/* These functions are related to the API, but only accessed internally */

char*   rgl_getFamily();
bool    rgl_setFamily(const char *family);
int     rgl_getFont();
bool    rgl_setFont(int font);
double  rgl_getCex();
bool    rgl_setCex(double cex);
int     rgl_getUseFreeType();
bool    rgl_setUseFreeType(bool useFreeType);
char*	rgl_getFontname();
int	rgl_getAntialias();
int	rgl_getMaxClipPlanes();

#ifdef __cplusplus
}
#endif

} // namespace rgl

#endif /* RGL_API_H */

