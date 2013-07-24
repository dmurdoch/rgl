
#include "lib.hpp"
#include "DeviceManager.hpp"
#include "init.hpp"
//
// FUNCTION
//   rgl_init
//

//
// GLOBAL: deviceManager pointer
//

DeviceManager* deviceManager = NULL;

namespace gui {

int gInitValue;
void* gHandle;

//
// FUNCTION
//   rgl_init
//
// PARAMETERS
//   ioptions - platform-specific options.
//     Windows:
//     [0]  multiple-document-interface console handle (MDI)
//          or 0 (SDI)
//     MacOSX:
//     [0]  indicator of presence (1) or absence (0) of Carbon/Cocoa
//

#ifdef __cplusplus
extern "C" {
#endif

SEXP rgl_init(SEXP initValue, SEXP useNULL)
{
  int success = 0;
  bool useNULLDevice = asLogical(useNULL);

  gInitValue = 0;
  gHandle = NULL;
  
  if ( isNumeric(initValue) ) {
    gInitValue =  asInteger(initValue);
  }
  else if ( TYPEOF(initValue) == EXTPTRSXP ) {
    gHandle = R_ExternalPtrAddr(initValue);
  }
  else if ( !isNull(initValue) )
  {
    return ScalarInteger( 0 );
  }  
  if ( lib::init(useNULLDevice) ) {
    deviceManager = new DeviceManager(useNULLDevice);
    success = 1;
  }

  return(ScalarInteger(success));
}
#ifdef __cplusplus
}
#endif

// ---------------------------------------------------------------------------
} // namespace gui
// ---------------------------------------------------------------------------

