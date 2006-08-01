#ifndef RGL_GUI_HPP
#define RGL_GUI_HPP
// ---------------------------------------------------------------------------
// C++ header file
// This file is part of RGL
//
// $Id$
// ---------------------------------------------------------------------------
#include <string.h>
#include "types.h"
#include "glgui.hpp"
#include "Disposable.hpp"
// ---------------------------------------------------------------------------
namespace gui {
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
  GUI_KeyInsert
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
  }
  inline  void unbind() { window = 0; }
  virtual void setTitle(const char* title) = 0;
  virtual void setLocation(int x, int y) = 0;
  virtual void setSize(int width, int height) = 0;
  virtual void show(void) = 0;
  virtual void hide(void) = 0;
  virtual void update(void) = 0;

  virtual void bringToTop(int stay) = 0;

  /// @doc notifyDestroy will be called on success
  virtual void destroy(void) = 0;
  virtual void beginGL(void) = 0;
  virtual void endGL(void) = 0;
  virtual void swap(void) = 0;
  virtual void captureMouse(View* captureView) = 0;
  virtual void releaseMouse(void) = 0;
  // OpenGL support (FIXME: remove)
  GLBitmapFont font;
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
  virtual WindowImpl* createWindowImpl(Window*) = 0;
};
// ---------------------------------------------------------------------------
} // namespace gui
// ---------------------------------------------------------------------------
//
// implementation specific
//
namespace lib {
gui::GUIFactory* getGUIFactory();
}
// ---------------------------------------------------------------------------
namespace gui {
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
  virtual void wheelRotate(int direction);
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

  Window(View* child=NULL, GUIFactory* factory=lib::getGUIFactory() );
  ~Window();

// overloaded view methods:
  void setWindowImpl(WindowImpl* windowImpl);

// services:
  void setTitle(const char* title);
  void setVisibility(bool state);
  void update(void);
  int getSkipRedraw(void);
  void setSkipRedraw(int in_skipRedraw);

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
  void wheelRotate(int dir);

  void bringToTop(int stay);

// data:
  View* child;
  const char* title;
  bool skipRedraw;  
};
// ---------------------------------------------------------------------------
} // namespace gui
// ---------------------------------------------------------------------------
#endif // RGL_GUI_HPP 

