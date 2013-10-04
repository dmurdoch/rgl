#ifndef RGL_NULL_GUI_HPP
#define RGL_NULL_GUI_HPP
// ---------------------------------------------------------------------------
// $Id: win32gui.hpp 840 2012-01-06 16:07:37Z murdoch $
// ---------------------------------------------------------------------------
#include "gui.hpp"

namespace rgl {

// ---------------------------------------------------------------------------
class NULLGUIFactory : public GUIFactory
{
public:
  NULLGUIFactory();
  virtual ~NULLGUIFactory();
  WindowImpl* createWindowImpl(Window* window);
};
// ---------------------------------------------------------------------------

} // namespace rgl

#endif // RGL_NULL_GUI_HPP

