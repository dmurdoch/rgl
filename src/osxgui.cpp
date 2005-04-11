#include "config.hpp"
#ifdef RGL_OSX
#include "gui.hpp"
class OSXGUIFactory : public gui::GUIFactory
{
public:
  OSXGUIFactory();
};
#endif

