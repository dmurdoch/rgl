#ifndef X11_GUI_H
#define X11_GUI_H
// ---------------------------------------------------------------------------
// C++ header file
// This file is part of RGL
//
// ---------------------------------------------------------------------------
#include <X11/Xlib.h>
#include <GL/glx.h>
#include <map>
#include "gui.h"

namespace rgl {

// ---------------------------------------------------------------------------
class X11WindowImpl;
enum {
  GUI_X11_ATOM_WM_DELETE = 0,
  GUI_X11_ATOM_LAST
};
// ---------------------------------------------------------------------------
class X11GUIFactory : public GUIFactory
{
public:
  X11GUIFactory (const char* displayname);
  virtual ~X11GUIFactory ();
  WindowImpl* createWindowImpl(Window* window);
  inline bool isConnected() { return (xdisplay) ? true : false; }
  inline int  getFD()     { return ConnectionNumber(xdisplay); }
  
  void notifyDelete(::Window xwindowid);
  
  // implementation services:
  
  void processEvents();
  void flushX();
  
  // display specific:
  
  Display* xdisplay;
  
  ::Atom atoms[GUI_X11_ATOM_LAST];
  
  // GLX specific
  int errorBase, eventBase;
  
  // Font specific
  XFontStruct* xfont;
  
  void throw_error(const char* string);
private:

  void connect(const char* displayname);
  void disconnect();

  // administrative data:

  typedef std::map< XID , X11WindowImpl*> WindowMap;
  
  WindowMap windowMap;
  ::Window group_leader;
};
// ---------------------------------------------------------------------------

} // namespace rgl

#endif // X11_GUI_H

