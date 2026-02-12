#ifndef RGL_GUI_H
#define RGL_GUI_H
// ---------------------------------------------------------------------------
// C++ header file
// This file is part of RGL
//
// ---------------------------------------------------------------------------
#include "R.h"
#include "types.h"
#include "glgui.h"
#include "Disposable.h"

namespace rgl {

// ---------------------------------------------------------------------------
enum {
  GUI_ButtonLeft = 1,
  GUI_ButtonRight,
  GUI_ButtonMiddle
};
// ---------------------------------------------------------------------------
enum {
  GUI_WheelForward = 1,
  GUI_WheelBackward
};
// ---------------------------------------------------------------------------
enum {
  GUI_KeyF1  = 128,
  GUI_KeyF2,
  GUI_KeyF3,
  GUI_KeyF4,
  GUI_KeyF5,
  GUI_KeyF6,
  GUI_KeyF7,
  GUI_KeyF8,
  GUI_KeyF9,
  GUI_KeyF10,
  GUI_KeyF11,
  GUI_KeyF12,
  GUI_KeyReturn,
  GUI_KeyUp,
  GUI_KeyDown,
  GUI_KeyLeft,
  GUI_KeyRight,
  GUI_KeyInsert,
  GUI_KeyESC
};
// ---------------------------------------------------------------------------
//
// IMPLEMENTATION INTERFACE
//
// ---------------------------------------------------------------------------
class View;
class Window;
// ---------------------------------------------------------------------------
class WindowImpl
{
public:
  inline WindowImpl(Window* in_window)
  : window(in_window)
  { 
    fonts.resize(1);
  }

  virtual ~WindowImpl() { }

  inline  void unbind() { window = 0; }
  virtual void setTitle(const char* title) = 0;
  virtual void setWindowRect(int left, int top, int right, int bottom) = 0;
  virtual void getWindowRect(int *in_left, int *in_top, int *in_right, int *in_bottom) = 0;
  virtual int  setSkipRedraw(int in_skipRedraw);
  virtual void show(void) = 0;
  virtual void hide(void) = 0;
  virtual void update(void) = 0;

  virtual void bringToTop(int stay) = 0;

  /// @doc notifyDestroy will be called on success
  virtual void destroy(void) = 0;
  virtual bool beginGL(void) = 0;
  virtual void endGL(void) = 0;
  virtual void swap(void) = 0;
  virtual void captureMouse(View* captureView) = 0;
  virtual void releaseMouse(void) = 0;
  virtual void watchMouse(bool withoutButton) = 0;
  virtual GLFont* getFont(const char* family, int style, double cex) = 0;
  void getFonts(FontArray& outfonts, int nfonts, const char** family, int* style, double* cex);
  virtual int getAntialias();
  virtual int getMaxClipPlanes();
  FontArray fonts;
protected:
  Window*      window;
};
// ---------------------------------------------------------------------------
//
// GUIFactory to be used in ABSTRACT GUI TOOLKIT
//
// ---------------------------------------------------------------------------
class GUIFactory
{
public:
  virtual ~GUIFactory() { }    
  virtual WindowImpl* createWindowImpl(Window*, int antialias) = 0;
};
// ---------------------------------------------------------------------------
//
// implementation specific
//
rgl::GUIFactory* getGUIFactory(bool useNULLDevice);
// ---------------------------------------------------------------------------
//
// ABSTRACT GUI TOOLKIT
//
// ---------------------------------------------------------------------------
//
// view flags
//
// ---------------------------------------------------------------------------
#define WINDOW_IMPL_OWNER   (1<<0)
// ---------------------------------------------------------------------------
class View 
{
public:
  View();
  View(int basex, int basey, int width, int height, int flags);
  virtual ~View();

// services:

  virtual void setSize(int width, int height);
  virtual void setLocation(int basex, int basey);
  virtual void update(void);

// event handlers:

  virtual void show(void);
  virtual void hide(void);
  virtual void paint(void);
  virtual void relocate(int baseX, int baseY);
  virtual void resize(int inWidth, int inHeight);
  virtual void keyPress(int code);
  virtual void keyRelease(int code);
  virtual void buttonPress(int button, int mouseX, int mouseY);
  virtual void buttonRelease(int button, int mouseX, int mouseY);
  virtual void wheelRotate(int direction, int mouseX, int mouseY);
  virtual void mouseMove(int mouseX, int mouseY);
  virtual void captureLost();

// protected services:

  virtual void setWindowImpl(WindowImpl* impl);

// data:

  int baseX, baseY;
  int width, height;
  int flags;

  WindowImpl* windowImpl;

  friend class Window;
};
// ---------------------------------------------------------------------------
class Window : public View, public Disposable
{
public:

  Window(View* child=NULL, GUIFactory* factory=rgl::getGUIFactory(0),
         int antialias = RGL_ANTIALIAS);
  ~Window();

// overloaded view methods:
  void setWindowImpl(WindowImpl* windowImpl);

// services:
  void setTitle(const char* title);
  void setVisibility(bool state);
  void update(void);
  int getSkipRedraw(void);
  void setSkipRedraw(int in_skipRedraw, int doUpdate = 1);

/**
 * Close the window. 
 **/
public:
  void close() { if (windowImpl) windowImpl->destroy(); else dispose(); }

// protected:

// event handlers:
  void show();
  void hide();
  void resize(int width, int height);
  void paint();
  void on_close();
  void notifyDestroy();
  void buttonPress(int button, int mouseX, int mouseY);
  void buttonRelease(int button, int mouseX, int mouseY);
  void mouseMove(int mouseX, int mouseY);
  void keyPress(int code);
  void wheelRotate(int dir, int mouseX, int mouseY);

  void bringToTop(int stay);
  void setWindowRect(int left, int top, int right, int bottom);
  void getWindowRect(int *left, int *top, int *right, int *bottom);
  void getFonts(FontArray& outfonts, int nfonts, const char** family, int* style, double* cex);

// data:
  View* child;
  const char* title;
  bool skipRedraw;  
};
// ---------------------------------------------------------------------------

} // namespace rgl

#endif // RGL_GUI_H 

