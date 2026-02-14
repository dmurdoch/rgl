#include <fcntl.h>
#include <unistd.h>
#include "lib.h"
#include "DeviceManager.h"

/* libfreetype 2.6 defines a conflicting TYPEOF macro */

#ifdef TYPEOF
# undef TYPEOF
#endif

#include <R_ext/Visibility.h>
#include <R_ext/Rdynload.h>
#include "R.h"
#include "init.h"
#include "api.h"

using namespace rgl;

//
// FUNCTION
//   rgl_init
//

//
// GLOBAL: deviceManager pointer
//

namespace rgl{

DeviceManager* deviceManager = NULL;

int gInitValue;
void* gHandle;
SEXP rglNamespace;
bool rglDebug;
std::string rglHome;

//
// FUNCTION
//   rgl_init
//

#ifdef __cplusplus
extern "C" {
#endif
  
extern rasterText_measure_text_func       measure_text;
extern rasterText_get_buffer_stride_func  get_buffer_stride;  
extern rasterText_draw_text_to_buffer_func draw_text_to_buffer;
extern rasterText_pack_text_func          pack_text;

SEXP rgl_init(SEXP initValue, SEXP useNULL, SEXP in_namespace,
              SEXP debug, SEXP home)
{
  int success = 0;
  bool useNULLDevice = Rf_asLogical(useNULL);

  gInitValue = 0;
  gHandle = NULL;
  rglNamespace = in_namespace;
  rglDebug = Rf_asLogical(debug);
  rglHome = std::string(CHAR(STRING_ELT(home, 0)));
  
  if ( Rf_isNumeric(initValue) ) {
    gInitValue =  Rf_asInteger(initValue);
  }
  else if ( TYPEOF(initValue) == EXTPTRSXP ) {
    gHandle = R_ExternalPtrAddr(initValue);
  }
  else if ( !Rf_isNull(initValue) )
  {
    return Rf_ScalarInteger( 0 );
  }  

  /* Get access to the rasterText functions.
   * NB:  need to make sure rasterText is loaded before
   * this will work! */
  
  rasterText_version_func ver = (rasterText_version_func)
    R_GetCCallable("rasterText", "API_version");
  if (ver() != 6) {
    Rprintf("This version of rgl was written for rasterText API version 6, not %d\n", ver());
    return Rf_ScalarInteger( 0 );
  }
  measure_text = (rasterText_measure_text_func)
    R_GetCCallable("rasterText", "measure_text");
  pack_text = (rasterText_pack_text_func)
    R_GetCCallable("rasterText", "pack_text");
  get_buffer_stride = (rasterText_get_buffer_stride_func) 
    R_GetCCallable("rasterText", "get_buffer_stride");
  draw_text_to_buffer = (rasterText_draw_text_to_buffer_func)
    R_GetCCallable("rasterText", "draw_text_to_buffer");
  if (!measure_text || !pack_text || !get_buffer_stride || !draw_text_to_buffer) {
    Rprintf("Text drawing functions not loaded.\n");
    return Rf_ScalarInteger( 0 );
  }
  
  /* Some systems write useless messages to stderr.  We'll
   * hide those
   */
  int stderr_copy = STDERR_FILENO, /* suppress "maybe undefined" warning */
      devNull = -1;
  if (!rglDebug) {
#if defined(_WIN32) || defined(windows) || defined(RGL_W32) 
     devNull = open("nul", O_WRONLY);
#endif
     if (devNull == -1) 
       devNull = open("/dev/null", O_WRONLY);

     if (devNull != -1) {
       R_FlushConsole();
       stderr_copy = dup(STDERR_FILENO);
       dup2(devNull, STDERR_FILENO);
     }
  }
  if ( init(useNULLDevice) ) {
    deviceManager = new DeviceManager(useNULLDevice);
  }
  if ( deviceManager && (useNULLDevice || deviceManager->createTestWindow()))
       success = 1;
  
  /* Restore STDERR */
  if (devNull != -1) {
    dup2(stderr_copy, STDERR_FILENO);
    close(stderr_copy);
  }
  
  return(Rf_ScalarInteger(success));
}

#define FUNDEF(name, n)  {#name, (DL_FUNC) &name, n}

#undef CHECK_ARGS

#ifdef CHECK_ARGS
  R_NativePrimitiveArgType aI[1] = {INTSXP};  
  R_NativePrimitiveArgType aL[1] = {LGLSXP}; 
  R_NativePrimitiveArgType aII[2] = {INTSXP, INTSXP}; 
  R_NativePrimitiveArgType aLI[2] = {LGLSXP, INTSXP}; 
  R_NativePrimitiveArgType aLL[2] = {LGLSXP, LGLSXP}; 
  R_NativePrimitiveArgType aIII[3] = {INTSXP, INTSXP, INTSXP};  
  R_NativePrimitiveArgType aIIS[3] = {INTSXP, INTSXP, STRSXP}; 
  R_NativePrimitiveArgType aIID[3] = {INTSXP, INTSXP, REALSXP};
  R_NativePrimitiveArgType aLII[3] = {LGLSXP, INTSXP, INTSXP}; 
  R_NativePrimitiveArgType aLIS[3] = {LGLSXP, INTSXP, STRSXP}; 
  R_NativePrimitiveArgType aLID[3] = {LGLSXP, INTSXP, REALSXP};
  R_NativePrimitiveArgType aLLI[3] = {LGLSXP, LGLSXP, INTSXP};
  R_NativePrimitiveArgType aIIDD[4] = {INTSXP, INTSXP, REALSXP, REALSXP}; 
  R_NativePrimitiveArgType aLISD[4] = {LGLSXP, INTSXP, STRSXP, REALSXP}; 
  R_NativePrimitiveArgType aIISI[4] = {INTSXP, INTSXP, STRSXP, INTSXP};
  R_NativePrimitiveArgType aLIDD[4] = {LGLSXP, INTSXP, REALSXP, REALSXP}; 
  R_NativePrimitiveArgType aLIIL[4] = {LGLSXP, INTSXP, INTSXP, LGLSXP};
  R_NativePrimitiveArgType aIIIID[5] = {INTSXP, INTSXP, INTSXP, INTSXP, REALSXP}; 
  R_NativePrimitiveArgType aIIIIS[5] = {INTSXP, INTSXP, INTSXP, INTSXP, STRSXP}; 
  R_NativePrimitiveArgType aLIIIS[5] = {LGLSXP, INTSXP, INTSXP, INTSXP, STRSXP}; 
  R_NativePrimitiveArgType aLIIID[5] = {LGLSXP, INTSXP, INTSXP, INTSXP, REALSXP}; 
  R_NativePrimitiveArgType aLIISD[5] = {LGLSXP, INTSXP, INTSXP, STRSXP, REALSXP};
  R_NativePrimitiveArgType aLIIDS[5] = {LGLSXP, INTSXP, INTSXP, REALSXP, STRSXP};
  R_NativePrimitiveArgType aLIIIF[5] = {LGLSXP, INTSXP, INTSXP, INTSXP, SINGLESXP}; 
  R_NativePrimitiveArgType aLIDDD[5] = {LGLSXP, INTSXP, REALSXP, REALSXP, REALSXP};
  R_NativePrimitiveArgType aIIDDD[5] = {INTSXP, INTSXP, REALSXP, REALSXP, REALSXP};
  R_NativePrimitiveArgType aIIDDID[6] = {INTSXP, INTSXP, REALSXP, REALSXP, INTSXP, REALSXP};
  R_NativePrimitiveArgType aLIDDDDI[7] = {LGLSXP, INTSXP, REALSXP, REALSXP, REALSXP, REALSXP, INTSXP};
  
  R_NativePrimitiveArgType aLIDDSDSDS[9] = {LGLSXP, INTSXP, REALSXP, REALSXP, STRSXP, REALSXP,
                                             STRSXP, REALSXP, STRSXP}; 
  R_NativePrimitiveArgType aIIDSDISIDI[10] = {INTSXP, INTSXP, REALSXP, STRSXP, REALSXP, INTSXP,
                                             STRSXP, INTSXP, REALSXP, INTSXP}; 
  R_NativePrimitiveArgType aIIDDDDDDDDIII[13] = {INTSXP, INTSXP, REALSXP, REALSXP, REALSXP, REALSXP,
                                             REALSXP, REALSXP, REALSXP, REALSXP, INTSXP, INTSXP, INTSXP}; 

 static const R_CMethodDef CEntries[] = { 
   {"rgl_dev_open", 		(DL_FUNC) &rgl_dev_open, 3, aLLI},
   {"rgl_dev_close", 		(DL_FUNC) &rgl_dev_close, 1, aL},
   {"rgl_dev_setcurrent", 	(DL_FUNC) &rgl_dev_setcurrent, 2, aLI},
   {"rgl_snapshot", 		(DL_FUNC) &rgl_snapshot, 3, aLIS},
   {"rgl_postscript", 		(DL_FUNC) &rgl_postscript, 3, aLIS},
   {"rgl_material", 		(DL_FUNC) &rgl_material, 4, aLISD},
   {"rgl_getmaterial", 		(DL_FUNC) &rgl_getmaterial, 5, aLIISD},
   {"rgl_getcolorcount", 	(DL_FUNC) &rgl_getcolorcount, 1, aI},
   {"rgl_dev_bringtotop", 	(DL_FUNC) &rgl_dev_bringtotop, 2, aLL},
   {"rgl_clear", 		(DL_FUNC) &rgl_clear, 2, aLI},  
   {"rgl_pop", 			(DL_FUNC) &rgl_pop, 2, aLI},  
   {"rgl_id_count", 		(DL_FUNC) &rgl_id_count, 3, aIII},  
   {"rgl_ids", 			(DL_FUNC) &rgl_ids, 4, aIISI},  
   {"rgl_viewpoint", 		(DL_FUNC) &rgl_viewpoint, 3, aLID},    
   {"rgl_getObserver", 	        (DL_FUNC) &rgl_getObserver, 2, aID},
   {"rgl_setObserver", 	        (DL_FUNC) &rgl_setObserver, 2, aID},
   {"rgl_attrib_count", 	(DL_FUNC) &rgl_attrib_count, 3, aIII}, 
   {"rgl_attrib", 		(DL_FUNC) &rgl_attrib, 5, aIIIID}, 
   {"rgl_text_attrib", 		(DL_FUNC) &rgl_text_attrib, 5, aIIIIS}, 
   {"rgl_bg", 			(DL_FUNC) &rgl_bg, 3, aLID},
   {"rgl_bbox", 		(DL_FUNC) &rgl_bbox, 9, aLIDDSDSDS}, 
   {"rgl_light",		(DL_FUNC) &rgl_light, 3, aIID},
   {"rgl_pixels",		(DL_FUNC) &rgl_pixels, 5, aLIIIF},
   {"rgl_planes",		(DL_FUNC) &rgl_planes, 4, aIIDD},
   {"rgl_clipplanes", 		(DL_FUNC) &rgl_planes, 4, aIIDD},
   {"rgl_abclines",		(DL_FUNC) &rgl_abclines, 4, aIIDD},
   {"rgl_surface", 		(DL_FUNC) &rgl_surface, 13, aIIDDDDDDDDIII},
   {"rgl_spheres",		(DL_FUNC) &rgl_spheres, 5, aIIDDI},
   {"rgl_texts",		(DL_FUNC) &rgl_texts, 12, aIIDSDISIDSII},
   {"rgl_sprites",  		(DL_FUNC) &rgl_sprites, 9, aIIDDIDDID},
   {"rgl_newsubscene",		(DL_FUNC) &rgl_newsubscene, 4, aIIII},
   {"rgl_setsubscene",		(DL_FUNC) &rgl_setsubscene, 1, aI},
   {"rgl_getsubsceneid",	(DL_FUNC) &rgl_getsubsceneid, 2, aII},
   {"rgl_getsubsceneparent",    (DL_FUNC) &rgl_getsubsceneparent, 1, aI},
   {"rgl_getsubscenechildcount",(DL_FUNC) &rgl_getsubscenechildcount, 2, aII},
   {"rgl_getsubscenechildren",  (DL_FUNC) &rgl_getsubscenechildren, 2, aII},
   {"rgl_gc", 			(DL_FUNC) &rgl_gc, 2, aII},
   {"rgl_setEmbeddings",        (DL_FUNC) &rgl_setEmbeddings, 2, aII},
   {"rgl_getEmbeddings",        (DL_FUNC) &rgl_getEmbeddings, 2, aII},
   {"rgl_addtosubscene", 	(DL_FUNC) &rgl_addtosubscene, 3, aIII},
   {"rgl_delfromsubscene",	(DL_FUNC) &rgl_delfromsubscene, 3, aIII},
   {"rgl_selectstate", 		(DL_FUNC) &rgl_selectstate, 5, aIILID},
   {"rgl_setselectstate",	(DL_FUNC) &rgl_setselectstate, 4, aIILI},
   {"rgl_quit",			(DL_FUNC) &rgl_quit, 1, aL},
   {"rgl_getShaderFlags", (DL_FUNC) &rgl_getShaderFlags, 4, aLIIL},
   {"rgl_getShaderDefines", (DL_FUNC) &rgl_getShaderDefines, 5, aIIIIS}
   {"rgl_incrementID", (DL_FUNC) &rgl_incrementID, 1, aI},
   {NULL, NULL, 0}
 };

#else  // don't CHECK_ARGS

 static const R_CMethodDef CEntries[] = { 
   FUNDEF(rgl_dev_open, 3),
   FUNDEF(rgl_dev_close, 1),
   FUNDEF(rgl_dev_setcurrent, 2),
   FUNDEF(rgl_snapshot, 3),
   FUNDEF(rgl_postscript, 3),
   FUNDEF(rgl_material, 4),
   FUNDEF(rgl_getmaterial, 5),
   FUNDEF(rgl_getcolorcount, 1),
   FUNDEF(rgl_dev_bringtotop, 2),
   FUNDEF(rgl_clear, 2), 
   FUNDEF(rgl_pop, 2), 
   FUNDEF(rgl_id_count, 3), 
   FUNDEF(rgl_ids, 4), 
   FUNDEF(rgl_viewpoint, 3), 
   FUNDEF(rgl_getObserver, 2),
   FUNDEF(rgl_setObserver, 2),
   FUNDEF(rgl_attrib_count, 3), 
   FUNDEF(rgl_attrib, 5), 
   FUNDEF(rgl_text_attrib, 5), 
   FUNDEF(rgl_bg, 3),
   FUNDEF(rgl_bbox, 9), 
   FUNDEF(rgl_light, 3),
   FUNDEF(rgl_pixels, 5),
   FUNDEF(rgl_planes, 4),
   FUNDEF(rgl_clipplanes, 4),
   FUNDEF(rgl_abclines, 4),
   FUNDEF(rgl_surface, 13),
   FUNDEF(rgl_spheres, 5),
   FUNDEF(rgl_texts, 12),
   FUNDEF(rgl_sprites, 9),
   FUNDEF(rgl_newsubscene, 4),
   FUNDEF(rgl_setsubscene, 1),
   FUNDEF(rgl_getsubsceneid, 2),
   FUNDEF(rgl_getsubsceneparent, 1),
   FUNDEF(rgl_getsubscenechildcount, 2),
   FUNDEF(rgl_getsubscenechildren, 2),
   FUNDEF(rgl_gc, 2),
   FUNDEF(rgl_setEmbeddings, 2),
   FUNDEF(rgl_getEmbeddings, 2),
   FUNDEF(rgl_addtosubscene, 3),
   FUNDEF(rgl_delfromsubscene, 3),
   FUNDEF(rgl_selectstate, 5),
   FUNDEF(rgl_setselectstate, 4),
   FUNDEF(rgl_quit, 1),
   FUNDEF(rgl_getShaderFlags, 4),
   FUNDEF(rgl_getShaderDefines, 5),
   FUNDEF(rgl_incrementID, 1),
   
   {NULL, NULL, 0}
 };
 
 #endif // CHECK_ARGS

 static const R_CallMethodDef CallEntries[]  = {
   FUNDEF(rgl_init, 5),
   FUNDEF(rgl_dev_getcurrent, 0),
   FUNDEF(rgl_dev_list, 0),
   FUNDEF(rgl_earcut, 2),
   FUNDEF(rgl_par3d, 3),
   FUNDEF(rgl_setMouseCallbacks, 6),
   FUNDEF(rgl_setWheelCallback, 3),
   FUNDEF(rgl_setAxisCallback, 4),
   FUNDEF(rgl_getMouseCallbacks, 3),
   FUNDEF(rgl_getWheelCallback, 2),
   FUNDEF(rgl_getAxisCallback, 3),
   FUNDEF(rgl_primitive, 4),
   FUNDEF(rgl_texture_from_array, 1),
   FUNDEF(rgl_textureRaster, 1),

   {NULL, NULL, 0}
 };

 static const R_ExternalMethodDef ExtEntries[] = {
   {NULL, NULL, 0}
 };
 
void attribute_visible R_init_rgl(DllInfo *dll) 
{
  R_registerRoutines(dll, CEntries, CallEntries, NULL, ExtEntries);
  R_useDynamicSymbols(dll, FALSE);
  R_forceSymbols(dll, TRUE);
}

#ifdef __cplusplus
}
#endif

// ---------------------------------------------------------------------------
} // namespace rgl
// ---------------------------------------------------------------------------

