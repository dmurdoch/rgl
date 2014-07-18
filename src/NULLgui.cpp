
#include <ctype.h>
#include <Rinternals.h>
#include "config.h"
// C++ source
// This file is part of RGL.
//
// $Id: win32gui.cpp 923 2013-01-27 10:41:11Z murdoch $

#include "NULLgui.h"

#include "lib.h"
#include "glgui.h"

#include "assert.h"
#include "R.h"

// ---------------------------------------------------------------------------

namespace rgl {

class NULLWindowImpl : public WindowImpl
{ 
public:
  NULLWindowImpl(Window* in_window);
  ~NULLWindowImpl() {};
  void setTitle(const char* title) {};
  void setWindowRect(int left, int top, int right, int bottom);
  void getWindowRect(int *left, int *top, int *right, int *bottom);
  void show() {};
  void hide() {};
  void bringToTop(int stay) {};
  void update() {};
  void destroy() {};
  void captureMouse(View* pView) {};
  void releaseMouse() {};
  GLFont* getFont(const char* family, int style, double cex, 
                  bool useFreeType);

private:
  int rect[4];
  friend class NULLGUIFactory;

public:
  bool beginGL() { return 0; };
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
  fonts[0] = new NULLFont("sans", 1, 1.0);
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

GLFont* NULLWindowImpl::getFont(const char* family, int style, double cex, 
                                 bool useFreeType)
{
  for (unsigned int i=0; i < fonts.size(); i++) {
    if (fonts[i]->cex == cex && fonts[i]->style == style && !strcmp(fonts[i]->family, family)
     && fonts[i]->useFreeType == useFreeType)
      return fonts[i];
  }
  GLFont* font = new NULLFont(family, style, cex);
  fonts.push_back(font);
  return font;
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

WindowImpl* NULLGUIFactory::createWindowImpl(Window* in_window)
{
  NULLWindowImpl* impl = new NULLWindowImpl(in_window);
  return impl;
}
// ---------------------------------------------------------------------------

