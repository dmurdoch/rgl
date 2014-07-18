#ifndef RGL_OSX_GUI_H
#define RGL_OSX_GUI_H
// ---------------------------------------------------------------------------
#include "../gui.h"
// ---------------------------------------------------------------------------

namespace rgl {

class OSXGUIFactory : public GUIFactory
{
public:
  OSXGUIFactory();
	~OSXGUIFactory();
  WindowImpl* createWindowImpl(Window* w); 
  bool hasEventLoop();
};

} // namespace rgl
// ---------------------------------------------------------------------------
#endif // RGL_OSX_GUI_H

