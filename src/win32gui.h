#ifndef WIN32_GUI_H
#define WIN32_GUI_H

// C++ header file
// This file is part of RGL
//
// $Id: win32gui.h,v 1.1 2003/03/25 00:13:21 dadler Exp $


#include "gui.h"

#include <windows.h>

namespace gui {

  class Win32GUIFactory : public GUIFactory
  {
  
  public:
  
    Win32GUIFactory(HINSTANCE inModuleHandle);
    ~Win32GUIFactory();
  
    WindowImpl* createWindowImpl(Window* window);
      
  };

};


#endif /* WIN32_GUI_H */

