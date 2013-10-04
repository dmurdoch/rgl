#ifndef RGL_OSX_GUI_HPP
#define RGL_OSX_GUI_HPP
// ---------------------------------------------------------------------------
#include "../gui.hpp"
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
#endif // RGL_OSX_GUI_HPP

