// C++ source
// This file is part of RGL.
//
// $Id$

#include "lib.h"


//
// ===[ GUI IMPLEMENTATION ]=================================================
//

#include "win32gui.h"

gui::Win32GUIFactory* gpWin32GUIFactory = NULL;

gui::GUIFactory* getGUIFactory()
{
  return (gui::GUIFactory*) gpWin32GUIFactory;
}

//
// ===[ R INTEGRATION ]=======================================================
//

bool lib_init()
{
  gpWin32GUIFactory = new gui::Win32GUIFactory(NULL);  
  return true;
}

void lib_quit()
{
  if (gpWin32GUIFactory) {
    delete gpWin32GUIFactory;
    gpWin32GUIFactory = NULL;
  }
}

#include <windows.h>

#define EXPORT_SYMBOL   __declspec(dllexport)

extern "C" {
void rgl_quit(int* successptr);
EXPORT_SYMBOL BOOL APIENTRY DllMain( HINSTANCE moduleHandle, DWORD reason, LPVOID lpReserved );
}

BOOL APIENTRY DllMain( HINSTANCE moduleHandle, DWORD reason, LPVOID lpReserved )
{
  bool success = FALSE;

  switch(reason) {
    case DLL_PROCESS_ATTACH:
      success = TRUE;
      break;
    case DLL_PROCESS_DETACH:
      // shutdown sub-systems
      {
        int success;
        rgl_quit(&success);
      }
      break;
  }
  return success;
}


//////////////////////////////////////////////////////////////////////////////
//
// UTILS
//

//
// STATIC METHOD printMessage
//
// DESCRIPTION
//   prints message to the user
//

void printMessage( const char* string ) {
  MessageBox(NULL, string, "RGL library", MB_OK|MB_ICONINFORMATION);
}

double getTime() {
  return ( (double) GetTickCount() ) * ( 1.0 / 1000.0 );
}
