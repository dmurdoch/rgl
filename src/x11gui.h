#ifndef X11_GUI_H
#define X11_GUI_H

// C++ header file
// This file is part of RGL
//
// $Id: x11gui.h,v 1.1 2003/03/25 00:13:21 dadler Exp $


#include "gui.h"

#include <X11/Xlib.h>
#include <GL/glx.h>

#include <map>

namespace gui {

  enum {
    GUI_X11_ATOM_WM_DELETE = 0,
    GUI_X11_ATOM_LAST
  };

  class X11WindowImpl;

  class X11GUIFactory : public GUIFactory
  {
  public:
    X11GUIFactory (const char* displayname);
    virtual ~X11GUIFactory ();
    WindowImpl* createWindowImpl(Window* window);
    inline int getFD() { return ConnectionNumber(xdisplay); }
    
    void notifyDelete(::Window xwindowid);
    
    // implementation services:
    
    void processEvents();
    void flushX();
    
    // display specific:
    
    Display* xdisplay;
    XVisualInfo* xvisualinfo;
    int errorBase, eventBase;
    GLXContext glxctx;

    ::Font xfont;
    ::Atom atoms[GUI_X11_ATOM_LAST];

  private:

    void connect();
    void disconnect();
    void throw_error(const char* string);

    // administrative data:

    typedef std::map< XID , X11WindowImpl*> WindowMap;
    
    WindowMap windowMap;
  };
};

#endif /* X11_GUI_H */
