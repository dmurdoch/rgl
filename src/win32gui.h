#ifndef WIN32_GUI_H
#define WIN32_GUI_H

// C++ header file
// This file is part of RGL
//
// $Id$


#include "gui.hpp"

#include <windows.h>

namespace gui {

  class Win32GUIFactory : public GUIFactory
  {
  
  public:
  
    Win32GUIFactory(HINSTANCE inModuleHandle);
    virtual ~Win32GUIFactory();
  
    WindowImpl* createWindowImpl(Window* window);
      
  };

} // namespace gui


#endif /* WIN32_GUI_H */

