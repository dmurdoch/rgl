// C++ source
// This file is part of RGL.
//
// $Id: win32lib.cpp,v 1.1 2003/03/25 00:13:21 dadler Exp $

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
  delete gpWin32GUIFactory;
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
