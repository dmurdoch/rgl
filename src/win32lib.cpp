#include "config.hpp"
#ifdef RGL_W32
// ---------------------------------------------------------------------------
// W32 Library Implementation
// $Id$
// ---------------------------------------------------------------------------
#include "lib.hpp"
#include "win32gui.hpp"
#include "NULLgui.hpp"
#include <windows.h>
#include "assert.hpp"
#include "R.h"

// ---------------------------------------------------------------------------
namespace lib {
// ---------------------------------------------------------------------------
// GUI Factory
// ---------------------------------------------------------------------------
gui::Win32GUIFactory* gpWin32GUIFactory = NULL;
gui::NULLGUIFactory* gpNULLGUIFactory = NULL;
// ---------------------------------------------------------------------------
gui::GUIFactory* getGUIFactory(bool useNULLDevice)
{
  if (useNULLDevice)
    return (gui::GUIFactory*) gpNULLGUIFactory;
  else if (gpWin32GUIFactory)
    return (gui::GUIFactory*) gpWin32GUIFactory;
  else
    error("wgl device not initialized");
}
// ---------------------------------------------------------------------------
const char * GUIFactoryName(bool useNULLDevice)
{
  return useNULLDevice ? "null" : "wgl";
}
// ---------------------------------------------------------------------------
// printMessage
// ---------------------------------------------------------------------------
void printMessage( const char* string ) {
  warning("RGL: %s\n", string);
}
// ---------------------------------------------------------------------------
// getTime
// ---------------------------------------------------------------------------
double getTime() {
  return ( (double) ::GetTickCount() ) * ( 1.0 / 1000.0 );
}
// ---------------------------------------------------------------------------
// init
// ---------------------------------------------------------------------------
bool init(bool useNULLDevice)
{
  if (!useNULLDevice)
    gpWin32GUIFactory = new gui::Win32GUIFactory();  
  gpNULLGUIFactory = new gui::NULLGUIFactory();
  return true;
}
// ---------------------------------------------------------------------------
// quit
// ---------------------------------------------------------------------------
void quit()
{
  assert(gpWin32GUIFactory != NULL && gpNULLGUIFactory != NULL);
  delete gpWin32GUIFactory;
  delete gpNULLGUIFactory;
  gpWin32GUIFactory = NULL;
  gpNULLGUIFactory = NULL;
}
// ---------------------------------------------------------------------------
} // namespace lib
// ---------------------------------------------------------------------------
#endif // RGL_W32

