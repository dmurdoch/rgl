#ifndef WIN32_GUI_H
#define WIN32_GUI_H

// C++ header file
// This file is part of RGL
//
// $Id: win32gui.h,v 1.2 2004/05/28 08:41:07 dadler Exp $


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

} // namespace gui


#endif /* WIN32_GUI_H */

