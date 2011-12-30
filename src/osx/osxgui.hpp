#ifndef RGL_OSX_GUI_HPP
#define RGL_OSX_GUI_HPP
// ---------------------------------------------------------------------------
#include "../gui.hpp"
// ---------------------------------------------------------------------------
namespace gui {
// ---------------------------------------------------------------------------
class OSXGUIFactory : public GUIFactory
{
public:
  OSXGUIFactory();
	~OSXGUIFactory();
  WindowImpl* createWindowImpl(Window* w); 
  bool hasEventLoop();
};
// ---------------------------------------------------------------------------
} // namespace gui
// ---------------------------------------------------------------------------
#endif // RGL_OSX_GUI_HPP

