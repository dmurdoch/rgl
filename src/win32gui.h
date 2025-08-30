#ifndef RGL_W32_GUI_H
#define RGL_W32_GUI_H
// ---------------------------------------------------------------------------
#include "gui.h"
// ---------------------------------------------------------------------------
#include <windows.h>

namespace rgl {

// ---------------------------------------------------------------------------
class Win32GUIFactory : public GUIFactory
{
public:
  Win32GUIFactory();
  virtual ~Win32GUIFactory();
  WindowImpl* createWindowImpl(Window* window, int antialias);
#ifndef WGL_WGLEXT_PROTOTYPES
  PFNWGLCHOOSEPIXELFORMATARBPROC wglChoosePixelFormatARB;
#endif
};
// ---------------------------------------------------------------------------

} // namespace rgl

#endif // RGL_W32_GUI_H

