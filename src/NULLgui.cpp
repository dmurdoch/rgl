
#include <ctype.h>
#include "config.h"
// C++ source
// This file is part of RGL.
//

#include "NULLgui.h"

#include "lib.h"

#include "assert.h"
#include "R.h"
#include <Rinternals.h>

// ---------------------------------------------------------------------------

namespace rgl {

class NULLWindowImpl : public WindowImpl
{ 
public:
  NULLWindowImpl(Window* in_window);
  ~NULLWindowImpl();
  void setTitle(const char* title) {};
  void setWindowRect(int left, int top, int right, int bottom);
  void getWindowRect(int *left, int *top, int *right, int *bottom);
  void show() {};
  void hide() {};
  void bringToTop(int stay) {};
  void update() { if (window && !window->skipRedraw) window->paint(); };
  void destroy() { delete this; }
  void captureMouse(View* pView) {};
  void releaseMouse() {};
  void watchMouse(bool withoutButton) {};
  int getAntialias() { return 8; }
  int getMaxClipPlanes() { return INT_MAX; }

private:
  int rect[4];
  friend class NULLGUIFactory;

public:
  bool beginGL() { return false; };
  void endGL() {};
  void swap() {};
};

} // namespace rgl

using namespace rgl;
// ----------------------------------------------------------------------------
// constructor
// ----------------------------------------------------------------------------
NULLWindowImpl::NULLWindowImpl(Window* in_window)
: WindowImpl(in_window)
{
  setWindowRect(0, 0, 256, 256);
}

NULLWindowImpl::~NULLWindowImpl()
{
  if (window) 
    window->notifyDestroy(); 
}

void NULLWindowImpl::setWindowRect(int left, int top, int right, int bottom)
{
  rect[0] = left;
  rect[1] = top;
  rect[2] = right;
  rect[3] = bottom;
  window->resize(right-left, bottom-top);
}

void NULLWindowImpl::getWindowRect(int *left, int *top, int *right, int *bottom)
{
    *left = rect[0];
    *top = rect[1];
    *right = rect[2];
    *bottom = rect[3];
}
  
// ---------------------------------------------------------------------------
//
// NULLGUIFactory class
//
// ---------------------------------------------------------------------------


NULLGUIFactory::NULLGUIFactory()
{
}
// ---------------------------------------------------------------------------
NULLGUIFactory::~NULLGUIFactory() {
}
// ---------------------------------------------------------------------------

WindowImpl* NULLGUIFactory::createWindowImpl(Window* in_window, int antialias)
{
  NULLWindowImpl* impl = new NULLWindowImpl(in_window);
  return impl;
}
// ---------------------------------------------------------------------------

#ifdef RGL_NO_OPENGL
#include <sys/time.h>
namespace rgl {
NULLGUIFactory* gpNULLGUIFactory = NULL;
}

void rgl::printMessage( const char* string ) {
  Rf_warning("RGL: %s\n", string);
}

GUIFactory* rgl::getGUIFactory(bool useNULLDevice)
{
  if (useNULLDevice)
    return (GUIFactory*) gpNULLGUIFactory;
  else
    Rf_error("OpenGL is not available in this build");  
}

const char * rgl::GUIFactoryName(bool useNULLDevice)
{
  return "null";
}

bool rgl::init(bool useNULLDevice)
{
  gpNULLGUIFactory = new NULLGUIFactory();
  return true;
}

void rgl::quit()
{
  assert(gpNULLGUIFactory != NULL);
  delete gpNULLGUIFactory;
  gpNULLGUIFactory = NULL;
}

double rgl::getTime() {
  struct ::timeval t;
  gettimeofday(&t,NULL);
  return ( (double) t.tv_sec ) * 1000.0 + ( ( (double) t.tv_usec ) / 1000.0 ); 
}

#endif