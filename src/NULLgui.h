#ifndef RGL_NULL_GUI_H
#define RGL_NULL_GUI_H
// ---------------------------------------------------------------------------
#include "gui.h"

namespace rgl {

// ---------------------------------------------------------------------------
class NULLGUIFactory : public GUIFactory
{
public:
  NULLGUIFactory();
  virtual ~NULLGUIFactory();
  WindowImpl* createWindowImpl(Window* window, int antialias);
};
// ---------------------------------------------------------------------------

} // namespace rgl

#endif // RGL_NULL_GUI_H

