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

EXPORT_SYMBOL void rgl_quit          (int* successptr);

/* device management */

EXPORT_SYMBOL void rgl_dev_open      (int* successptr);
EXPORT_SYMBOL void rgl_dev_close     (int* successptr);
EXPORT_SYMBOL void rgl_dev_getcurrent(int* successptr, int* idptr);
EXPORT_SYMBOL void rgl_dev_setcurrent(int* successptr, int* idata);
EXPORT_SYMBOL void rgl_dev_bringtotop(int* successptr, int* stay);

/* device services */

EXPORT_SYMBOL void rgl_snapshot (int* successptr, int* idata, char** cdata);
EXPORT_SYMBOL void rgl_pixels(int* successptr, int* ll, int* size, int* component, float* result);
EXPORT_SYMBOL void rgl_postscript (int* successptr, int* idata, char** cdata);

/* scene management */

EXPORT_SYMBOL void rgl_clear    (int* successptr, int* idata);
EXPORT_SYMBOL void rgl_pop      (int* successptr, int* idata);
EXPORT_SYMBOL void rgl_id_count (int* type, int* count);
EXPORT_SYMBOL void rgl_ids       (int* type, int* ids, char** types);

EXPORT_SYMBOL void rgl_material (int* successptr, int* idata, char** cdata, double* ddata);
EXPORT_SYMBOL void rgl_getcolorcount(int* count);
EXPORT_SYMBOL void rgl_getmaterial (int* successptr, int* idata, char** cdata, double* ddata);

EXPORT_SYMBOL void rgl_light    (int* successptr, int* idata, double* ddata );

EXPORT_SYMBOL void rgl_viewpoint(int* successptr, int* idata, double* ddata);

EXPORT_SYMBOL void rgl_bg       (int* successptr, int* idata);
EXPORT_SYMBOL void rgl_bbox     (int* successptr, int* idata, double* ddata, double* xat, char** xtext, double* yat, char** ytext, double* zat, char** ztext);

EXPORT_SYMBOL void rgl_primitive(int* successptr, int* idata, double* vertex, double* normals, double* texcoords);
EXPORT_SYMBOL void rgl_texts    (int* successptr, int* idata, double* adj, char** text, double* vertex,
                                 int* nfonts, char** family, int* style, double* cex, int* useFreeType);
EXPORT_SYMBOL void rgl_spheres  (int* successptr, int* idata, double* vertex, double* radius);
EXPORT_SYMBOL void rgl_planes   (int* successptr, int* idata, double* normals, double* offsets);
EXPORT_SYMBOL void rgl_abclines (int* successptr, int* idata, double* bases, double* directions);

EXPORT_SYMBOL void rgl_surface  (int* successptr, int* idata, double* x, double* z, double* y, 
	                         double* normal_x, double* normal_z, double* normal_y,
	                         double* texture_s, double* texture_t,
	                         int* coords, int* orientation, int* flags);
EXPORT_SYMBOL void rgl_sprites  (int* successptr, int* idata, double* vertex, double* radius);

EXPORT_SYMBOL void rgl_user2window(int* successptr, int* idata, double* point, double* pixel, double* model, double* proj, int* view);
EXPORT_SYMBOL void rgl_window2user(int* successptr, int* idata, double* point, double* pixel, double* model, double* proj, int* view);
EXPORT_SYMBOL void rgl_locator(int* successptr, double* locations);
EXPORT_SYMBOL void rgl_getMouseMode(int* successptr, int* button, int* mode);
EXPORT_SYMBOL void rgl_setMouseMode(int* successptr, int* button, int* mode);
EXPORT_SYMBOL void rgl_selectstate(int* successptr, int* selectstate, double* locations);
EXPORT_SYMBOL void rgl_setselectstate(int* successptr, int *idata);
EXPORT_SYMBOL void rgl_getUserMatrix(int* successptr, double* userMatrix);
EXPORT_SYMBOL void rgl_setUserMatrix(int* successptr, double* userMatrix);
EXPORT_SYMBOL void rgl_getScale(int* successptr, double* scale);
EXPORT_SYMBOL void rgl_setScale(int* successptr, double* scale);
EXPORT_SYMBOL void rgl_getZoom(int* successptr, double* zoom);
EXPORT_SYMBOL void rgl_setZoom(int* successptr, double* zoom);
EXPORT_SYMBOL void rgl_getFOV(int* successptr, double* fov);
EXPORT_SYMBOL void rgl_setFOV(int* successptr, double* fov);
EXPORT_SYMBOL void rgl_getModelMatrix(int* successptr, double* modelMatrix);
EXPORT_SYMBOL void rgl_getProjMatrix(int* successptr, double* projMatrix);
EXPORT_SYMBOL void rgl_getIgnoreExtent(int* successptr, int* ignoreExtent);
EXPORT_SYMBOL void rgl_setIgnoreExtent(int* successptr, int* ignoreExtent);
EXPORT_SYMBOL void rgl_getSkipRedraw(int* successptr, int* skipRedraw);
EXPORT_SYMBOL void rgl_setSkipRedraw(int* successptr, int* skipRedraw);
EXPORT_SYMBOL void rgl_getViewport(int* successptr, int* viewport);
EXPORT_SYMBOL void rgl_getBoundingbox(int* successptr, double* bboxvec);
EXPORT_SYMBOL void rgl_getWindowRect(int* successptr, int* rect);
EXPORT_SYMBOL void rgl_setWindowRect(int* successptr, int* rect);

/* not for users:  does not maintain consistency */
EXPORT_SYMBOL void rgl_setPosition(double* position);
EXPORT_SYMBOL void rgl_getPosition(double* position);

/* These functions are related to the API, but only accessed internally */

char*   getFamily();
bool    setFamily(const char *family);
int     getFont();
bool    setFont(int font);
double  getCex();
bool    setCex(double cex);
int     getUseFreeType();
bool    setUseFreeType(bool useFreeType);
char*	getFontname();
int	getAntialias();

#ifdef __cplusplus
}
#endif

#endif /* RGL_API_H */

