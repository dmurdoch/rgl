#ifndef RGL_API_H
#define RGL_API_H

#ifdef __cplusplus
extern "C" {
#endif

/*
// RGL API EXPORT MACRO
*/

#ifdef _WIN32
#define EXPORT_SYMBOL   __declspec(dllexport)
#else
#define EXPORT_SYMBOL   extern
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

EXPORT_SYMBOL void rgl_init          (int* successptr);
EXPORT_SYMBOL void rgl_quit          (int* successptr);

/* device management */

EXPORT_SYMBOL void rgl_dev_open      (int* successptr);
EXPORT_SYMBOL void rgl_dev_close     (int* successptr);
EXPORT_SYMBOL void rgl_dev_getcurrent(int* successptr, int* idptr);
EXPORT_SYMBOL void rgl_dev_setcurrent(int* successptr, int* idata);
#ifdef _WIN32
EXPORT_SYMBOL void rgl_dev_bringtotop(int* successptr, int* stay);
#endif

/* device services */

EXPORT_SYMBOL void rgl_snapshot (int* successptr, int* idata, char** cdata);

/* scene management */

EXPORT_SYMBOL void rgl_clear    (int* successptr, int* idata);
EXPORT_SYMBOL void rgl_pop      (int* successptr, int* idata);

EXPORT_SYMBOL void rgl_material (int* successptr, int* idata, char** cdata, double* ddata);

EXPORT_SYMBOL void rgl_light    (int* successptr, int* idata, double* ddata );

EXPORT_SYMBOL void rgl_viewpoint(int* successptr, int* idata, double* ddata);

EXPORT_SYMBOL void rgl_bg       (int* successptr, int* idata);
EXPORT_SYMBOL void rgl_bbox     (int* successptr, int* idata, double* ddata, double* xat, char** xtext, double* yat, char** ytext, double* zat, char** ztext);

EXPORT_SYMBOL void rgl_primitive(int* successptr, int* idata, double* vertex);
EXPORT_SYMBOL void rgl_texts    (int* successptr, int* idata, double* adj, char** text, double* vertex);
EXPORT_SYMBOL void rgl_spheres  (int* successptr, int* idata, double* vertex, double* radius);
EXPORT_SYMBOL void rgl_surface  (int* successptr, int* idata, double* x, double* z, double* y);
EXPORT_SYMBOL void rgl_sprites  (int* successptr, int* idata, double* vertex, double* radius);

EXPORT_SYMBOL void rgl_user2window(int* successptr, int* idata, double* point, double* pixel, double* model, double* proj, int* view);
EXPORT_SYMBOL void rgl_window2user(int* successptr, int* idata, double* point, double* pixel, double* model, double* proj, int* view);
EXPORT_SYMBOL void rgl_locator(int* successptr, double* locations);
EXPORT_SYMBOL void rgl_getMouseMode(int* successptr, int* button, int* mode);
EXPORT_SYMBOL void rgl_setMouseMode(int* successptr, int* button, int* mode);
EXPORT_SYMBOL void rgl_selectstate(int* successptr, int* selectstate, double* locations);
EXPORT_SYMBOL void rgl_setselectstate(int* successptr, int *idata);
EXPORT_SYMBOL void rgl_projection(int* successptr, double* model, double* proj, double* view);
EXPORT_SYMBOL void rgl_getUserMatrix(int* successptr, double* userMatrix);
EXPORT_SYMBOL void rgl_setUserMatrix(int* successptr, double* userMatrix);
EXPORT_SYMBOL void rgl_getZoom(int* successptr, double* zoom);
EXPORT_SYMBOL void rgl_getFOV(int* successptr, double* fov);
EXPORT_SYMBOL void rgl_getModelMatrix(int* successptr, double* modelMatrix);
EXPORT_SYMBOL void rgl_getProjMatrix(int* successptr, double* projMatrix);
EXPORT_SYMBOL void rgl_getViewport(int* successptr, double* viewport);

#ifdef __cplusplus
}
#endif

#endif /* RGL_API_H */

