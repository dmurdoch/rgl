// C++ source
// This file is part of RGL.
//
// $Id: x11gui.cpp,v 1.2 2003/06/03 07:51:56 dadler Exp $

#include "x11gui.h"
#include "lib.h"

#include <X11/keysym.h>

#include <cstdio>

//
// X11 Window Implementation
//

namespace gui {

//
// X11 Atoms
//

static char* atom_names[GUI_X11_ATOM_LAST] = {
  "WM_DELETE_WINDOW"
};

//
// FUNCTION
//   translate_key
//
// translates X11 KeySym keycode to GUI_Key code
//

int translate_key(KeySym keysym)
{
  if ( (keysym >= XK_space) && (keysym <= XK_asciitilde) )
    return (int) keysym;
  else if ((keysym >= XK_F1) && (keysym <= XK_F12))
    return GUI_KeyF1 + keysym - XK_F1;
  else {
    switch(keysym)
    {
      case XK_Return:
        return GUI_KeyReturn;
      default:
        return 0;
    }
  }
    
}

class X11WindowImpl : public WindowImpl
{
public:
  X11WindowImpl(Window* in_window, X11GUIFactory* in_factory, ::Window in_xwindow)
    : WindowImpl(in_window), factory(in_factory), xwindow(in_xwindow)
  { 
  
    // init font

    beginGL();
    font.nglyph   = GL_BITMAP_FONT_COUNT;
    font.firstGlyph = GL_BITMAP_FONT_FIRST_GLYPH;
    GLuint listBase = glGenLists(font.nglyph);
    font.listBase   = listBase - font.firstGlyph;
    glXUseXFont(factory->xfont, font.firstGlyph, font.nglyph, listBase);

    font.widths = new unsigned int[font.nglyph];

    for(unsigned int i=0;i<font.nglyph;i++)
      font.widths[i] = 9;
    
    endGL();
  
  }
  virtual ~X11WindowImpl()
  { }
  void setTitle(const char* title)
  {
    XStoreName(factory->xdisplay,xwindow,title);
    factory->flushX();
  }
  void setLocation(int x, int y)
  {
    // FIXME
  }
  void setSize(int width, int height)
  {
    // FIXME
  }
  void show()
  {
    XMapWindow(factory->xdisplay, xwindow);
    factory->flushX();
  }
  void hide()
  {
    XUnmapWindow(factory->xdisplay, xwindow);
    factory->flushX();
  }
  void update()
  {
    window->paint();
    swap();
  }
  void destroy()
  {
    XDestroyWindow(factory->xdisplay, xwindow);
    factory->flushX();
  }
  void beginGL()
  {
    if ( glXMakeCurrent(factory->xdisplay, xwindow, factory->glxctx) == False )
      printMessage("ERROR: can't bind glx context to window");
  }
  void endGL()
  {
  }
  void swap()
  {
    glXSwapBuffers(factory->xdisplay, xwindow);
  }
  void captureMouse(gui::View* captureView)
  {
  }
  void releaseMouse()
  {
  }
  //
  // dispatch event 
  //
  void processEvent(XEvent& ev)
  {
    char   keybuffer[8];
    KeySym keysym;
    XComposeStatus compose;
    int    count, keycode;
    ::Window root, child;
    int    rootx, rooty, winx, winy;
    unsigned int  mask;
    
    switch(ev.type) {
      case ButtonPress:
        switch(ev.xbutton.button) {
          case 1:
            window->buttonPress( GUI_ButtonLeft, ev.xbutton.x, ev.xbutton.y );
            break;
          case 2:
            window->buttonPress( GUI_ButtonMiddle, ev.xbutton.x, ev.xbutton.y );
            break;
          case 3:
            window->buttonPress( GUI_ButtonRight, ev.xbutton.x, ev.xbutton.y );
            break;
          case 4:
            window->wheelRotate( GUI_WheelForward );
            break;
          case 5:
            window->wheelRotate( GUI_WheelBackward );
            break;
        }
        break;
      case ButtonRelease:
        switch(ev.xbutton.button) {
          case 1:
            window->buttonRelease( GUI_ButtonLeft, ev.xbutton.x, ev.xbutton.y );
            break;
          case 2:
            window->buttonRelease( GUI_ButtonMiddle, ev.xbutton.x, ev.xbutton.y );
            break;
          case 3:
            window->buttonRelease( GUI_ButtonRight, ev.xbutton.x, ev.xbutton.y );
            break;
        }
        break;
      case KeyPress:
        count = XLookupString(&ev.xkey, keybuffer, sizeof(keybuffer), &keysym, &compose);
        keycode = translate_key(keysym);
        if (keycode)
          window->keyPress(keycode);
        break;
      case KeyRelease:
        count = XLookupString(&ev.xkey, keybuffer, sizeof(keybuffer), &keysym, &compose);
        keycode = translate_key(keysym);
        if (keycode)
          window->keyRelease(keycode);
        break;
      case MappingNotify:
        XRefreshKeyboardMapping(&ev.xmapping);
        break;
      case MotionNotify:
        if( XQueryPointer(factory->xdisplay, xwindow, &root, &child, &rootx, &rooty, &winx, &winy, &mask) == True )
          window->mouseMove( winx, winy );
        break;
      case Expose:
        if (ev.xexpose.count == 0) { 
          window->paint();
          swap();
        }
        break;
      case ConfigureNotify:
        window->resize( ev.xconfigure.width, ev.xconfigure.height );
        break;
      case MapNotify:
        window->show();
        break;
      case UnmapNotify:
        window->hide();
        break;
      case ClientMessage:
        if ( ( (::Atom) ev.xclient.data.l[0] ) == factory->atoms[GUI_X11_ATOM_WM_DELETE])
          window->closeRequest();
        break;
      case DestroyNotify:
        factory->notifyDelete(xwindow);
        window->notifyDestroy();
        delete this;
        break;
    }
  }
  
private:
  X11GUIFactory* factory;
  ::Window       xwindow;
};

//
// throw error
//

void X11GUIFactory::throw_error(const char* string)
{
  printMessage(string);
  disconnect();
}


//
// connect
//

void X11GUIFactory::connect(const char* displayname)
{
  // open one display connection for all RGL X11 devices
  
  xdisplay = XOpenDisplay(displayname);
  
  if (xdisplay == NULL) {
    throw_error("unable to open display"); return;
  }
  
  // load font
  
  xfont = XLoadFont(xdisplay,"fixed");

  // obtain display atoms

  Status s = XInternAtoms(xdisplay, atom_names, sizeof(atom_names)/sizeof(char*), True, atoms);

  if (!s)
    printMessage("some atoms not available");

  // query glx extension
   
  if ( glXQueryExtension(xdisplay, &errorBase, &eventBase) == False )
    throw_error("GLX extension missing on server");
  
  static int attribList[] =
  {
    GLX_RGBA,
    GLX_DOUBLEBUFFER,
    GLX_RED_SIZE, 5,
    GLX_GREEN_SIZE, 5,
    GLX_BLUE_SIZE, 5,
    GLX_ALPHA_SIZE, 0,
    GLX_DEPTH_SIZE, 0,
    None
  };

  //
  // choose GL visual
  //
  
  xvisualinfo = glXChooseVisual( xdisplay, DefaultScreen(xdisplay), attribList );

  if (xvisualinfo == NULL) {
    throw_error("no suitable visual available"); return;
  }
    
  // create opengl context
    
  glxctx = glXCreateContext(xdisplay, xvisualinfo, NULL, True);
  if (!glxctx)
    printMessage("ERROR: can't create glx context");

}


//
// disconnect
//

void X11GUIFactory::disconnect()
{
  // FIXME: shutdown all windows

  // destroy GL context
  
  if (glxctx) {
    glXMakeCurrent(xdisplay, None, NULL);
    glXDestroyContext(xdisplay, glxctx);
    glxctx = NULL;
  }

  // free XVisualInfo structure
  
  if (xvisualinfo) {
    XFree(xvisualinfo);
    xvisualinfo = NULL;
  }

  // free xfont

  if (xfont) {
    XUnloadFont(xdisplay, xfont);
  }
  
  // disconnect from X server
  
  if (xdisplay) {
    XCloseDisplay(xdisplay);
    xdisplay = NULL;
  }
}


//
// flush X requests
//

void X11GUIFactory::flushX()
{
  XFlush(xdisplay);
}


//
// X event dispatcher
//

void X11GUIFactory::processEvents()
{
  int nevents = XEventsQueued(xdisplay, QueuedAfterReading);

  while(nevents--) {
    
    XEvent ev;
    XNextEvent(xdisplay,&ev);

    X11WindowImpl* impl = windowMap[ev.xany.window];

    if (impl)
      impl->processEvent(ev);
    else
      fprintf(stderr,"unknown window id %lx\n", (long)ev.xany.window);
    
  }
}


//
// CONSTRUCTOR
//

X11GUIFactory::X11GUIFactory(const char* displayname)
{
  xdisplay    = NULL;
  xfont       = 0;
  xvisualinfo = NULL;
  glxctx      = NULL;

  connect(displayname); 
}


//
// DESTRUCTOR
//

X11GUIFactory::~X11GUIFactory()
{
  disconnect();
}


//
// FACTORY METHOD
//   createWindowImpl
//

WindowImpl* X11GUIFactory::createWindowImpl(Window* window)
{
  X11WindowImpl* impl = NULL;
    
  // create X11 window
  
  unsigned long valuemask=CWEventMask|CWColormap;
    
  XSetWindowAttributes attrib;
  
  attrib.event_mask = 
      ButtonMotionMask 
    | PointerMotionHintMask
    | VisibilityChangeMask 
    | ExposureMask
    | StructureNotifyMask 
    | ButtonPressMask 
    | KeyPressMask
    | KeyReleaseMask
    | ButtonReleaseMask;

  attrib.colormap = XCreateColormap(xdisplay, DefaultRootWindow(xdisplay), xvisualinfo->visual, AllocNone);
    
  ::Window xwindow = XCreateWindow(
    xdisplay, RootWindow(xdisplay, DefaultScreen(xdisplay)),
    0, 0, 256, 256, 0, 
    xvisualinfo->depth,
    InputOutput,
    xvisualinfo->visual, 
    valuemask,
    &attrib
  );

  if (!xwindow)
    return NULL;

  // set window manager protocols

  int n = 0;

  ::Atom proto_atoms[GUI_X11_ATOM_LAST];
  
  if (atoms[GUI_X11_ATOM_WM_DELETE]) {
    proto_atoms[n] = atoms[GUI_X11_ATOM_WM_DELETE];
    n++;
  }
  else
    printMessage("NO WM_DELETE\n");
  
  if (n)
    XSetWMProtocols(xdisplay,xwindow,proto_atoms,n);

  // create window implementation instance
    
  impl = new X11WindowImpl(window, this, xwindow);
  

  // register instance
    
  windowMap[xwindow] = impl;
  

  // flush X requests
    
  flushX();
    
  return (WindowImpl*) impl;
}

void X11GUIFactory::notifyDelete(::Window xwindowid)
{
  windowMap[xwindowid] = NULL;
}

};
