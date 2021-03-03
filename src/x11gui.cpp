#include "config.h"
#ifdef RGL_X11
// ---------------------------------------------------------------------------
// C++ source
// This file is part of RGL.
//

// Uncomment for verbose output on stderr:
// #define RGL_X11_DEBUG

// ---------------------------------------------------------------------------
#include <X11/keysym.h>
#include <cstdio>
#include <Rinternals.h>
#include "x11gui.h"
#include "lib.h"
#include "R.h"

namespace rgl {

// ---------------------------------------------------------------------------
extern SEXP    rglNamespace;    
// ---------------------------------------------------------------------------

class X11WindowImpl : public WindowImpl
{
public:
  X11WindowImpl(rgl::Window* in_window
  , X11GUIFactory* in_factory
  , ::Window in_xwindow
  , XVisualInfo* invisualinfo
  );
  virtual ~X11WindowImpl();
  void setTitle(const char* title);
  void setWindowRect(int left, int top, int right, int bottom);
  void getWindowRect(int *left, int *top, int *right, int *bottom);
  void show();
  void hide();
  void bringToTop(int stay);
  void update();
  void destroy();
  bool beginGL();
  void endGL();
  void swap();
  void captureMouse(View* captureview);
  void releaseMouse();
  GLFont* getFont(const char* family, int style, double cex, 
                  bool useFreeType);

private:
  void initGL();
  GLBitmapFont* initGLFont();
  void shutdownGL();
  static int translate_key(KeySym keysym);
  void on_init();
  void on_shutdown();
  void on_paint();
  void processEvent(XEvent& ev); 
  X11GUIFactory* factory;
  ::Window       xwindow;
  ::GLXContext   glxctx;
  friend class X11GUIFactory;
  XVisualInfo* xvisualinfo;
};

} // namespace rgl

using namespace rgl;
// ---------------------------------------------------------------------------
// X11WindowImpl Implementation
// ---------------------------------------------------------------------------
X11WindowImpl::X11WindowImpl(Window* w, X11GUIFactory* f, ::Window in_xwindow, XVisualInfo* invisualinfo)
: WindowImpl(w)
, factory(f)
, xwindow(in_xwindow)
, xvisualinfo(invisualinfo)
{
  on_init();
}
// ---------------------------------------------------------------------------
X11WindowImpl::~X11WindowImpl()
{
  if (xwindow != 0)
    destroy();
  // free XVisualInfo structure
  if (xvisualinfo) {
    XFree(xvisualinfo);
    xvisualinfo = 0;
  }    
}
// ---------------------------------------------------------------------------
void X11WindowImpl::setTitle(const char* title)
{
  XStoreName(factory->xdisplay,xwindow,title);
  factory->flushX();
}
// ---------------------------------------------------------------------------
void X11WindowImpl::setWindowRect(int left, int top, int right, int bottom) 
{
  ::Window root, child, parent, *children;
  int x, y;
  unsigned int nchildren;
  XQueryTree(factory->xdisplay, xwindow, &root, &parent, &children, &nchildren);
  XTranslateCoordinates(factory->xdisplay, xwindow, parent, 0, 0, &x, &y, &child);
  // The weird calculation below (subtracting twice (x,y)) compensates for the diff
  // between coordinates of the rgl window within the parent window.
  // There's probably a smarter way to do this...
  XMoveWindow(factory->xdisplay, xwindow, left-2*x, top-2*y);
  XResizeWindow(factory->xdisplay, xwindow, right-left, bottom-top);
  factory->flushX();
}
// ---------------------------------------------------------------------------
void X11WindowImpl::getWindowRect(int *left, int *top, int *right, int *bottom)
{
  ::Window root, child;
  int x, y;
  unsigned int width, height, border_width, depth;
  do {
    factory->flushX();
    factory->processEvents();
  } while (XEventsQueued(factory->xdisplay, QueuedAfterFlush));
  XGetGeometry(factory->xdisplay, xwindow, &root, &x, &y, &width, &height, &border_width, &depth);
  XTranslateCoordinates(factory->xdisplay, xwindow, root, x, y, left, top, &child);
  XTranslateCoordinates(factory->xdisplay, xwindow, root, x+width, y+height, right, bottom, &child);
}

// ---------------------------------------------------------------------------
static Bool IsMapNotify(Display* d, XEvent* ev, XPointer arg)
{
  ::Window w = (::Window) arg;
  return ( (ev->xany.window == w) && (ev->type == MapNotify) );
}
void X11WindowImpl::show()
{
  XMapWindow(factory->xdisplay, xwindow);
  XEvent ev;
  XIfEvent(factory->xdisplay, &ev, IsMapNotify, (XPointer) xwindow );
  factory->processEvents();
  factory->flushX();
  update();
}
// ---------------------------------------------------------------------------
void X11WindowImpl::hide()
{
  XUnmapWindow(factory->xdisplay, xwindow);
  factory->flushX();
}
// ---------------------------------------------------------------------------
void X11WindowImpl::bringToTop(int stay)
{
  XRaiseWindow(factory->xdisplay, xwindow);
  factory->processEvents();
  factory->flushX();
}
// ---------------------------------------------------------------------------
void X11WindowImpl::on_paint()
{
  if (window) {
    if (window->skipRedraw) return;
    window->paint();
    SAVEGLERROR;
  }  
  swap();
  SAVEGLERROR;
}
// ---------------------------------------------------------------------------
void X11WindowImpl::update()
{
  on_paint();
  SAVEGLERROR;
}
// ---------------------------------------------------------------------------
void X11WindowImpl::destroy()
{
  if (xwindow != 0) 
  {
    on_shutdown();
    if (factory->xdisplay)
      XDestroyWindow(factory->xdisplay, xwindow);
    factory->flushX();
    factory->notifyDelete(xwindow); /* Why didn't this happen in the lines above, from the DestroyNotify event? */
    xwindow = 0;
    if (window)
        window->notifyDestroy();
    delete this;
  }
}
// ---------------------------------------------------------------------------
bool X11WindowImpl::beginGL()
{
    if ( glXMakeCurrent(factory->xdisplay, xwindow, glxctx) == False ) {
      printMessage("ERROR: can't bind glx context to window");
      return false;
    }
    else return true;

}
// ---------------------------------------------------------------------------
void X11WindowImpl::endGL()
{
}
// ---------------------------------------------------------------------------
void X11WindowImpl::swap()
{
  glXSwapBuffers(factory->xdisplay, xwindow);
}
// ---------------------------------------------------------------------------
void X11WindowImpl::captureMouse(View* captureview)
{
}
// ---------------------------------------------------------------------------
void X11WindowImpl::releaseMouse()
{
}
// ---------------------------------------------------------------------------
void X11WindowImpl::processEvent(XEvent& ev)
{
  char   keybuffer[8];
  KeySym keysym;
  XComposeStatus compose;
  int    keycode;
  ::Window root, child;
  int    rootx, rooty, winx, winy;
  unsigned int  mask;
  
  switch(ev.type) {
    case ButtonPress:
      switch(ev.xbutton.button) {
        case 1:
          if (window)
            window->buttonPress( GUI_ButtonLeft, ev.xbutton.x, ev.xbutton.y );
          break;
        case 2:
          if (window)
            window->buttonPress( GUI_ButtonMiddle, ev.xbutton.x, ev.xbutton.y );
          break;
        case 3:
          if (window)
            window->buttonPress( GUI_ButtonRight, ev.xbutton.x, ev.xbutton.y );
          break;
        case 4:
          if (window)
            window->wheelRotate( GUI_WheelForward, ev.xbutton.x, ev.xbutton.y );
          break;
        case 5:
          if (window)
            window->wheelRotate( GUI_WheelBackward, ev.xbutton.x, ev.xbutton.y  );
          break;
      }
      break;
    case ButtonRelease:
      switch(ev.xbutton.button) {
        case 1:
          if (window)
            window->buttonRelease( GUI_ButtonLeft, ev.xbutton.x, ev.xbutton.y );
          break;
        case 2:
          if (window)
            window->buttonRelease( GUI_ButtonMiddle, ev.xbutton.x, ev.xbutton.y );
          break;
        case 3:
          if (window)
            window->buttonRelease( GUI_ButtonRight, ev.xbutton.x, ev.xbutton.y );
          break;
      }
      break;
    case KeyPress:
      XLookupString(&ev.xkey, keybuffer, sizeof(keybuffer), &keysym, &compose);
      keycode = translate_key(keysym);
      if (keycode)
        if (window)
          window->keyPress(keycode);
      break;
    case KeyRelease:
      XLookupString(&ev.xkey, keybuffer, sizeof(keybuffer), &keysym, &compose);
      keycode = translate_key(keysym);
      if (keycode)
        if (window)
          window->keyRelease(keycode);
      break;
    case MappingNotify:
      XRefreshKeyboardMapping(&ev.xmapping);
      break;
    case MotionNotify:
      if( XQueryPointer(factory->xdisplay, xwindow, &root, &child, &rootx, &rooty, &winx, &winy, &mask) == True )
        if (window)
          window->mouseMove( winx, winy );
      break;
    case Expose:
      if (ev.xexpose.count == 0) {
        if (window) {
          if (window->skipRedraw) break;
          window->paint();
        }  
        swap();
      }
      break;
    case ConfigureNotify:
      if (window)
        window->resize( ev.xconfigure.width, ev.xconfigure.height );
      break;
    case MapNotify:
      if (window)
        window->show();
      break;
    case UnmapNotify:
      if (window)
        window->hide();
      break;
    case ClientMessage:
      if ( ( (::Atom) ev.xclient.data.l[0] ) == factory->atoms[GUI_X11_ATOM_WM_DELETE])
        if (window)
          window->on_close();
      break;
    case DestroyNotify:
      factory->notifyDelete(xwindow);
      xwindow = 0;
      if (window)
        window->notifyDestroy();
      delete this;
      break;
  }
}
// ---------------------------------------------------------------------------
static int error_code; 

static int X11SaveErr(Display *dsp, XErrorEvent *event)
{
  error_code = event->error_code;
  return 0;
}
// ---------------------------------------------------------------------------
void X11WindowImpl::initGL()
{  
  glxctx = glXCreateContext(factory->xdisplay, xvisualinfo, NULL, True);
}
// ---------------------------------------------------------------------------
void X11WindowImpl::shutdownGL()
{
  // destroy GL context
  
  if (glxctx) {
    glXMakeCurrent(factory->xdisplay, None, NULL);
    glXDestroyContext(factory->xdisplay, glxctx);
    glxctx = NULL;
  }
}
// ---------------------------------------------------------------------------
GLFont* X11WindowImpl::getFont(const char* family, int style, double cex, 
                                 bool useFreeType)
{
  for (unsigned int i=0; i < fonts.size(); i++) {
    if (fonts[i] && fonts[i]->cex == cex && fonts[i]->style == style && !strcmp(fonts[i]->family, family)
     && fonts[i]->useFreeType == useFreeType)
      return fonts[i];
  }
  
  if (useFreeType) {
#ifdef HAVE_FREETYPE
    SEXP Rfontname = VECTOR_ELT(PROTECT(eval(PROTECT(lang2(PROTECT(install("rglFonts")), 
                                          PROTECT(ScalarString(mkChar(family))))), rglNamespace)),
                                          0);
    if (isString(Rfontname) && length(Rfontname) >= style) {
      const char* fontname = CHAR(STRING_ELT(Rfontname, style-1)); 
      GLFTFont* font=new GLFTFont(family, style, cex, fontname);
      if (font->font) {
        fonts.push_back(font);
        UNPROTECT(4);
        return font;
      } else {
        warning(font->errmsg);
        delete font;
      }
    }
    UNPROTECT(4);
#else
    warning("FreeType not available");
#endif
  }
  if (strcmp(family, fonts.back()->family)) warning("font family \"%s\" not found, using \"%s\"", 
                                         family, fonts.back()->family);
  else if (style != fonts.back()->style) warning("\"%s\" family only supports font %d", 
                                        fonts.back()->family, fonts.back()->style);
  else if (cex != fonts.back()->cex) warning("\"%s\" family only supports cex = %g",
  					fonts.back()->family, fonts.back()->cex);
  else if (useFreeType) warning("FreeType font not available");
  return fonts.back();
}

GLBitmapFont* X11WindowImpl::initGLFont()
{
  GLBitmapFont* font = NULL; 
  if (beginGL()) {
    font = new GLBitmapFont("bitmap", 1, 1, "fixed");  
    font->nglyph     = GL_BITMAP_FONT_COUNT;
    font->firstGlyph = GL_BITMAP_FONT_FIRST_GLYPH;
    GLuint listBase = glGenLists(font->nglyph);
    font->listBase   = listBase - font->firstGlyph;
    glXUseXFont(factory->xfont->fid, font->firstGlyph, font->nglyph, listBase);

    font->widths = new unsigned int[font->nglyph];

    for(unsigned int i=0;i<font->nglyph;i++)
      font->widths[i] = 9;
    font->ascent = factory->xfont->ascent;
    endGL();  // Should this be added?
  }
  return font;
}
// ---------------------------------------------------------------------------
void X11WindowImpl::on_init()
{
  initGL();
  if (glxctx)
    fonts[0] = initGLFont();
}

void X11WindowImpl::on_shutdown()
{
  if (glxctx)
    for (unsigned int i=0; i < fonts.size(); i++) {
      if (fonts[i]) {
        delete fonts[i];
        fonts[i] = NULL;
      }
    }
  shutdownGL();
}
// ---------------------------------------------------------------------------
//
// FUNCTION
//   translate_key
//
// translates X11 KeySym keycode to GUI_Key code
//
// ---------------------------------------------------------------------------
int X11WindowImpl::translate_key(KeySym keysym)
{
  if ( (keysym >= XK_space) && (keysym <= XK_asciitilde) )
    return (int) keysym;
  else if ((keysym >= XK_F1) && (keysym <= XK_F12))
    return static_cast<int>(GUI_KeyF1 + keysym - XK_F1);
  else {
    switch(keysym)
    {
      case XK_Return:
        return GUI_KeyReturn;
      case XK_Escape:
        return GUI_KeyESC;
      default:
        return 0;
    }
  }
    
}

// ---------------------------------------------------------------------------
// X11GUIFactory Implementation
// ---------------------------------------------------------------------------
// throw error
// ---------------------------------------------------------------------------
void X11GUIFactory::throw_error(const char* string)
{
  printMessage(string);
  disconnect();
}
// ---------------------------------------------------------------------------
X11GUIFactory::X11GUIFactory(const char* displayname)
: xdisplay(0)
, xfont(0)
{
  // Open one display connection for all RGL X11 devices
  xdisplay = XOpenDisplay(displayname);
  if (xdisplay == 0) {
    throw_error("unable to open X11 display"); return;
  }
/*  XSynchronize(xdisplay, True); */

  // Load System font
  xfont = XLoadQueryFont(xdisplay,"fixed");
 
  // Obtain display atoms
  static char* atom_names[GUI_X11_ATOM_LAST] = {
    const_cast<char*>("WM_DELETE_WINDOW")
  };
  Status s = XInternAtoms(xdisplay, atom_names, sizeof(atom_names)/sizeof(char*), True, atoms);

  if (!s)
    printMessage("some atoms not available");
 
  // Query glx extension
   
  if ( glXQueryExtension(xdisplay, &errorBase, &eventBase) == False ) {
    throw_error("GLX extension missing on server"); return;
  }
  
}
// ---------------------------------------------------------------------------
X11GUIFactory::~X11GUIFactory()
{
  disconnect();
}
// ---------------------------------------------------------------------------
void X11GUIFactory::disconnect()
{
  // process pending XDestroyNotify events
  if (xdisplay) {
    XSync(xdisplay, False);
    processEvents();

    // free xfont
    if (xfont) {
      XUnloadFont(xdisplay, xfont->fid);
      xfont = 0;
    }
  
    // disconnect from X server
    XCloseDisplay(xdisplay);
    xdisplay = 0;
  }
}
// ---------------------------------------------------------------------------
void X11GUIFactory::flushX()
{
  if (xdisplay)
    XSync(xdisplay, False);
  glXWaitX();
}
// ---------------------------------------------------------------------------
void X11GUIFactory::processEvents()
{
  for(;;) {
    int nevents = XEventsQueued(xdisplay, QueuedAfterReading);

    if (nevents == 0)
      return;
    
    while(nevents--) {
      
      XEvent ev;
      XNextEvent(xdisplay,&ev);

      X11WindowImpl* impl = windowMap[ev.xany.window];

      if (impl)
        impl->processEvent(ev);
#ifdef RGL_X11_DEBUG
      else
        fprintf(stderr,"unknown window id %lx(code %lx)\n"
        , static_cast<long>(ev.xany.window)
        , static_cast<long>(ev.type) 
        );
#endif        
    }
  } 
}
// ---------------------------------------------------------------------------
WindowImpl* X11GUIFactory::createWindowImpl(Window* window)
{
  X11WindowImpl* impl = NULL;
  XVisualInfo* xvisualinfo;

  // Choose GLX visual
  
  static int attribList[] =
  {
    GLX_RGBA,
    GLX_DOUBLEBUFFER,
    GLX_RED_SIZE, 1,
    GLX_GREEN_SIZE, 1,
    GLX_BLUE_SIZE, 1,
    GLX_ALPHA_SIZE, 0,
    GLX_DEPTH_SIZE, 1,
    None, None, // Space for optional AA settings
    None, None,
    None
  };

#ifdef GLX_SAMPLE_BUFFERS
  // Setup antialiasing based on "rgl.antialias" option
  int aa;
  SEXP rgl_aa = GetOption(install("rgl.antialias"),R_BaseEnv);
  if (isNull(rgl_aa)) aa = RGL_ANTIALIAS;
  else aa = asInteger(rgl_aa);
  
  if(aa > 0) {
    attribList[12] = GLX_SAMPLE_BUFFERS;
    attribList[13] = 1;
    attribList[14] = GLX_SAMPLES;
    attribList[15] = aa;
  }
#endif
  
/* These codes are only used in debugging, they are never displayed. */
#define RGL_ERROR_CODE (LastExtensionError + 1000)

  /* clear old errors */
  while ((error_code = glGetError())) { Rprintf("cleared error %d\n", error_code); };

  /* Work around problems with Xvfb on MacOSX and disabled IGLX:  
   temporarily catch protocol errors and convert
   to R errors */
  error_code = 0;
  XErrorHandler old_handler = XSetErrorHandler(X11SaveErr);
  
  xvisualinfo = glXChooseVisual( xdisplay, DefaultScreen(xdisplay), attribList );
#ifdef GLX_SAMPLE_BUFFERS
  // Try to set up visual without MSAA if it failed
  if (xvisualinfo == 0 && aa > 0 && !error_code) {
    attribList[12] = None;
    xvisualinfo = glXChooseVisual( xdisplay, DefaultScreen(xdisplay), attribList );
  }
#endif
  if (xvisualinfo == 0) {
    error_code = RGL_ERROR_CODE + 1;
  }
    
  // create X11 window

  // We don't want a border, but MacOSX Xvfb requires one.  
  unsigned long valuemask=CWEventMask|CWColormap|CWBorderPixel;
    
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


  ::Window xparent = 0;
  if (!error_code) {
    xparent = RootWindow(xdisplay, DefaultScreen(xdisplay));
    if (!error_code & !xparent)
      error_code = RGL_ERROR_CODE + 2;
  }
  
  if (!error_code) {
    attrib.colormap = XCreateColormap(xdisplay, xparent, xvisualinfo->visual, AllocNone);
    if (!error_code && !attrib.colormap)
      error_code = RGL_ERROR_CODE + 3;
  }
  attrib.border_pixel = 0;
  
  
  ::Window xwindow = 0;
  if (!error_code) {
    if (window)
      window->resize(256, 256);  // This may be changed by window manager
    xwindow = XCreateWindow(
      xdisplay, xparent,
      0, 0, 256, 256, 0, 
      xvisualinfo->depth,
      InputOutput,
      xvisualinfo->visual, 
      valuemask,
      &attrib
    );
    if (!error_code && !xwindow)
      error_code = RGL_ERROR_CODE + 4;
  }
  
  if (!error_code)
    XSync(xdisplay, False);

  /* set WM_CLASS on window */
  if (!error_code) {
    XClassHint *classHint = XAllocClassHint();
    if (!error_code) {
      if (classHint) {
        classHint->res_name = const_cast<char*>("rgl");
        classHint->res_class = const_cast<char*>("R_x11");
        XSetClassHint(xdisplay, xwindow, classHint);
        XFree(classHint);
      } else
        error_code = RGL_ERROR_CODE + 5;
    }
  }

  // set window manager protocols

  int n = 0;

  ::Atom proto_atoms[GUI_X11_ATOM_LAST];
  
  if (atoms[GUI_X11_ATOM_WM_DELETE]) {
    proto_atoms[n] = atoms[GUI_X11_ATOM_WM_DELETE];
    n++;
  }
  
  if (xwindow && n && !error_code)
    XSetWMProtocols(xdisplay,xwindow,proto_atoms,n);

  // create window implementation instance
  
  if (xwindow && !error_code) {
    impl = new X11WindowImpl(window, this, xwindow, xvisualinfo);
    if (!error_code && !impl)
      error_code = RGL_ERROR_CODE + 6;
  } else {
    impl = NULL;
  }
  
  // flush X requests
  
  flushX();
  
  XSetErrorHandler(old_handler);

  if (error_code) impl = NULL;
  
  // register instance
  if (xwindow)
    windowMap[xwindow] = impl;
  
  return (WindowImpl*) impl;
}
// ---------------------------------------------------------------------------
void X11GUIFactory::notifyDelete(::Window xwindowid)
{
#ifdef RGL_X11_DEBUG
  fprintf(stderr,"notifyDelete %lx\n", xwindowid);
#endif
  // remove window from map
  windowMap.erase(xwindowid);
}
// ---------------------------------------------------------------------------
#endif // RGL_X11_H

