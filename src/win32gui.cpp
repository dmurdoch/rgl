#include "config.hpp"
#ifdef RGL_W32
// C++ source
// This file is part of RGL.
//
// $Id$

#include "win32gui.hpp"

#include "lib.hpp"
#include "glgui.hpp"

#include <winuser.h>
#ifndef DEBUG
#define NDEBUG
#endif
#include <cassert>
// ---------------------------------------------------------------------------
namespace gui {

extern int     gInitValue;
extern HANDLE  gHandle;
static WNDPROC gDefWindowProc;
static HWND    gMDIClientHandle = 0;
static HWND    gMDIFrameHandle  = 0;

// ---------------------------------------------------------------------------
//
// translate keycode
//
// ---------------------------------------------------------------------------
static int translate_key(int wParam) 
{
  if ( (wParam >= VK_F1) && (wParam <= VK_F12) ) {
    return ( GUI_KeyF1 + (wParam - VK_F1) );
  } else {
    switch(wParam) {
      case VK_UP:
        return GUI_KeyUp;
      case VK_DOWN:
        return GUI_KeyDown;
      case VK_LEFT:
        return GUI_KeyLeft;
      case VK_RIGHT:
        return GUI_KeyRight;
      case VK_INSERT:
        return GUI_KeyInsert;
      default:
        return 0;
    }
  }
}
// ---------------------------------------------------------------------------
class Win32WindowImpl : public WindowImpl
{ 
public:
  Win32WindowImpl(Window* in_window);
  void setTitle(const char* title);
  void setLocation(int x, int y);
  void setSize(int width, int height);
  void show();
  void hide();
  int  isTopmost(HWND handle);
  void bringToTop(int stay);
  void update();
  void destroy();
  void captureMouse(View* pView);
  void releaseMouse();
private:
  LRESULT processMessage(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);
  static bool registerClass();
  static void unregisterClass();
  static LRESULT CALLBACK delegateWindowProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);
  static LRESULT CALLBACK windowProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);
  static ATOM classAtom;
  HWND  windowHandle;
  View* captureView;
  bool  updateMode;             // window is currently updated
  bool  autoUpdate;             // update/refresh automatically
  bool  refreshMenu;		// need to tell Windows to update the menu
  friend class Win32GUIFactory;

public:
  bool beginGL();
  void endGL();
  void swap();
private:
  bool initGL();
  void shutdownGL();
  void initGLBitmapFont(u8 firstGlyph, u8 lastGlyph);
  void destroyGLFont();
  HDC   dcHandle;               // temporary variable setup by lock
  HGLRC glrcHandle;
};
// ----------------------------------------------------------------------------
// constructor
// ----------------------------------------------------------------------------
Win32WindowImpl::Win32WindowImpl(Window* in_window)
: WindowImpl(in_window)
{
  windowHandle = NULL;
  captureView = NULL;

  dcHandle = NULL;
  glrcHandle = NULL;

  updateMode = false;
  autoUpdate = false;
  refreshMenu = false;
}

void Win32WindowImpl::setTitle(const char* title)
{
  SetWindowText(windowHandle, title);
}

void Win32WindowImpl::setLocation(int x, int y)
{
  // FIXME
}

void Win32WindowImpl::setSize(int width, int height)
{
  // FIXME
}

void Win32WindowImpl::show()
{
  if (windowHandle) {
    // ShowWindow is required in SDI to show the window once 
    // (otherwise to update takes place)
    ShowWindow(windowHandle, SW_SHOW);
    SetWindowPos(
      windowHandle
     ,HWND_TOP
     ,0,0,0,0
     ,SWP_SHOWWINDOW|SWP_NOMOVE|SWP_NOACTIVATE|SWP_NOSIZE
    );
    update();
  } else
    lib::printMessage("window not bound");
}

void Win32WindowImpl::hide()
{
  if (windowHandle) {
    ShowWindow(windowHandle, SW_HIDE);
  }
}

int Win32WindowImpl::isTopmost(HWND handle)
{
  return GetWindowLong(handle, GWL_EXSTYLE) & WS_EX_TOPMOST;
}

void Win32WindowImpl::bringToTop(int stay) /* stay=0 for regular, 1 for topmost, 2 for toggle */
{
  if (windowHandle) {
    SetForegroundWindow(windowHandle); /* needed in Rterm */
    BringWindowToTop(windowHandle);    /* needed in Rgui --mdi */

    if (stay == 2) 
      stay = !isTopmost(windowHandle);

    if (stay) 
      SetWindowPos(
        windowHandle
      , HWND_TOPMOST
      , 0, 0, 0, 0
      , SWP_NOMOVE | SWP_NOSIZE
      );
    else 
      SetWindowPos(windowHandle
      , HWND_NOTOPMOST
      , 0, 0, 0, 0
      , SWP_NOMOVE | SWP_NOSIZE
      );
  } else
    lib::printMessage("window not bound");
}

void Win32WindowImpl::update()
{
  InvalidateRect(windowHandle, NULL, false);
  UpdateWindow(windowHandle);
}

void Win32WindowImpl::destroy()
{
  if (gHandle) SendMessage(gMDIClientHandle, WM_MDIDESTROY, (WPARAM) windowHandle, 0);
  else DestroyWindow(windowHandle);
}

bool Win32WindowImpl::beginGL()
{
  dcHandle = GetDC(windowHandle);
  if (wglMakeCurrent( dcHandle, glrcHandle )) return true;
  else return false;
}

void Win32WindowImpl::endGL()
{
  ReleaseDC(windowHandle, dcHandle);
}

void Win32WindowImpl::swap()
{
  dcHandle = GetDC(windowHandle);
  SwapBuffers(dcHandle);
  ReleaseDC(windowHandle, dcHandle);
}

void Win32WindowImpl::captureMouse(View* inCaptureView)
{
  captureView = inCaptureView;
  SetCapture(windowHandle);
}

void Win32WindowImpl::releaseMouse(void)
{
  captureView = NULL;
  ReleaseCapture();
}

bool Win32WindowImpl::initGL () {
  bool success = false;
  // obtain a device context for the window
  dcHandle = GetDC(windowHandle);
  if (dcHandle) {
    // describe requirements
    PIXELFORMATDESCRIPTOR pfd = {
      sizeof(PIXELFORMATDESCRIPTOR),    // size of this pfd
      1,                                // version number
      0
      | PFD_DRAW_TO_WINDOW              // support window
      | PFD_SUPPORT_OPENGL              // support OpenGL
      | PFD_GENERIC_FORMAT              // generic format
      | PFD_DOUBLEBUFFER                // double buffered
      ,
      PFD_TYPE_RGBA,                    // RGBA type
      16,                               // 16-bit color depth
      0, 0, 0, 0, 0, 0,                 // color bits ignored
      1,                                // alpha buffer
      0,                                // shift bit ignored
      0,                                // no accumulation buffer
      0, 0, 0, 0,                       // accum bits ignored
      16,                               // 16-bit z-buffer
      0,                                // no stencil buffer
      0,                                // no auxiliary buffer
      PFD_MAIN_PLANE,                   // main layer
      0,                                // reserved
      0, 0, 0                           // layer masks ignored
    };
    int  iPixelFormat;
    // get the device context's best, available pixel format match
    iPixelFormat = ChoosePixelFormat(dcHandle, &pfd);
    if (iPixelFormat != 0) {
      // make that match the device context's current pixel format
      SetPixelFormat(dcHandle, iPixelFormat, &pfd);
      // create GL context
      if ( ( glrcHandle = wglCreateContext( dcHandle ) ) )
          success = true;
      else
        lib::printMessage("wglCreateContext failed");
    }
    else
      lib::printMessage("iPixelFormat == 0!");
    ReleaseDC(windowHandle,dcHandle);
  }

  return success;
}

void Win32WindowImpl::shutdownGL() 
{
  dcHandle = GetDC(windowHandle);
  wglMakeCurrent(NULL,NULL);
  ReleaseDC(windowHandle, dcHandle);
  wglDeleteContext(glrcHandle);
}

void Win32WindowImpl::initGLBitmapFont(u8 firstGlyph, u8 lastGlyph) 
{
  if (beginGL()) {
    SelectObject (dcHandle, GetStockObject (SYSTEM_FONT) );
    font.nglyph     = lastGlyph-firstGlyph+1;
    font.widths     = new unsigned int [font.nglyph];
    GLuint listBase = glGenLists(font.nglyph);
    font.firstGlyph = firstGlyph;
    font.listBase   = listBase - firstGlyph;
    GetCharWidth32( dcHandle, font.firstGlyph, lastGlyph,  (LPINT) font.widths );
    wglUseFontBitmaps(dcHandle, font.firstGlyph, font.nglyph, listBase);
    endGL();
  }
}

void Win32WindowImpl::destroyGLFont() 
{
  if (beginGL()) {
    glDeleteLists( font.listBase + font.firstGlyph, font.nglyph);
    delete [] font.widths;
    endGL();
  }
}

LRESULT Win32WindowImpl::processMessage(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
  LRESULT returnValue = 0;
  switch(message) {
    case WM_CREATE:
      windowHandle = hwnd;
      initGL();
      initGLBitmapFont(GL_BITMAP_FONT_FIRST_GLYPH, GL_BITMAP_FONT_LAST_GLYPH);
      if (gHandle) {
        refreshMenu = true;
      }
      break;
    case WM_SHOWWINDOW:
      if ( ( (BOOL) wParam ) == TRUE ) {
        window->show();
        autoUpdate = true;
      }
      else {
        window->hide();
        autoUpdate = false;
      }
      break;
    case WM_PAINT:
      if (refreshMenu) {
        SendMessage(gMDIClientHandle, WM_MDIREFRESHMENU, 0, 0);    
        DrawMenuBar(gMDIFrameHandle);
        refreshMenu = false;
      }        
      if (!window->skipRedraw) {
        window->paint();
        swap();
      }  
      ValidateRect(hwnd, NULL);
      break;
    case WM_SIZE:
      window->resize(LOWORD(lParam), HIWORD(lParam));
      if (gHandle)
        return gDefWindowProc(hwnd,message,wParam,lParam);
      else
        break;
    case WM_CLOSE:
      window->on_close();
      break;
    case WM_KEYDOWN:
      if (int keycode = translate_key(wParam) ) {
        window->keyPress(keycode);
      } else
        return -1;
    case WM_CHAR:
      window->keyPress( (int) ( (char) wParam ) );
      break;
    case WM_LBUTTONDOWN:
      ( (captureView) ? captureView : window ) -> buttonPress(GUI_ButtonLeft, (short) LOWORD(lParam), (short) HIWORD(lParam) );
      break;
    case WM_LBUTTONUP:
      ( (captureView) ? captureView : window ) -> buttonRelease(GUI_ButtonLeft, (short) LOWORD(lParam), (short) HIWORD(lParam));
      break;
    case WM_RBUTTONDOWN:
      ( (captureView) ? captureView : window ) -> buttonPress(GUI_ButtonRight,(short) LOWORD(lParam), (short) HIWORD(lParam) );
      break;
    case WM_RBUTTONUP:
      ( (captureView) ? captureView : window ) -> buttonRelease(GUI_ButtonRight,(short) LOWORD(lParam), (short) HIWORD(lParam) );
      break;
    case WM_MBUTTONDOWN:
      ( (captureView) ? captureView : window )
       -> buttonPress(GUI_ButtonMiddle, (short) LOWORD(lParam), (short) HIWORD(lParam) );
      break;
    case WM_MBUTTONUP:
      ( (captureView) ? captureView : window ) -> buttonRelease(GUI_ButtonMiddle, (short) LOWORD(lParam), (short) HIWORD(lParam) );
      break;
#if (_WIN32_WINNT >= 0x0400) || (_WIN32_WINDOWS > 0x0400)
    case WM_MOUSEWHEEL:
      {
        int dir = ( (short) HIWORD(wParam)  > 0 ) ?  GUI_WheelForward : GUI_WheelBackward;
        ( (captureView) ? captureView : window ) -> wheelRotate(dir);
        break;
      }
#endif
    case WM_MOUSEMOVE:
      ( (captureView) ? captureView : window ) -> mouseMove( ( (short) LOWORD(lParam) ), ( (short) HIWORD(lParam) ) );
      break;
    case WM_CAPTURECHANGED:
      if (captureView) {
        captureView->captureLost();
        captureView = NULL;
      }
      break;
    case WM_DESTROY:
      delete [] font.widths; // Can't call destroyGLFont because we don't have a valid DC now
      shutdownGL();
      SetWindowLong(hwnd, GWL_USERDATA, (LONG) NULL );
      if (window)
        window->notifyDestroy();
      delete this;
      break;
    default:
      return gDefWindowProc(hwnd,message,wParam,lParam);
  }
  return returnValue;
}
    
// static 
LRESULT CALLBACK Win32WindowImpl::delegateWindowProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
  Win32WindowImpl* windowImpl = (Win32WindowImpl*) GetWindowLong(hwnd, GWL_USERDATA);
  return windowImpl->processMessage(hwnd, message, wParam, lParam);
}

// static 
LRESULT CALLBACK Win32WindowImpl::windowProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
  if (message == WM_CREATE) {
    Win32WindowImpl* windowImpl;
    LPCREATESTRUCT pCreateStruct = reinterpret_cast<LPCREATESTRUCT>(lParam);        
    if (gHandle) {
      LPMDICREATESTRUCT pMDICreateStruct = reinterpret_cast<LPMDICREATESTRUCT>(pCreateStruct->lpCreateParams);
      windowImpl = reinterpret_cast<Win32WindowImpl*>( pMDICreateStruct->lParam );
    } else {
      windowImpl = reinterpret_cast<Win32WindowImpl*>( pCreateStruct->lpCreateParams );
    }
    SetWindowLong(hwnd, GWL_USERDATA, (long) windowImpl );
    SetWindowLong(hwnd, GWL_WNDPROC, (long) delegateWindowProc );
    return windowImpl->processMessage(hwnd, message, wParam, lParam);
  } 
  return gDefWindowProc(hwnd, message, wParam, lParam); 
}

// static 
bool Win32WindowImpl::registerClass() {
  WNDCLASSEX wcex;
  ZeroMemory( &wcex, sizeof(WNDCLASSEX) );
  wcex.cbSize = sizeof(WNDCLASSEX);
  wcex.style          = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
  wcex.lpfnWndProc    = (WNDPROC) windowProc;
  wcex.hIcon          = LoadIcon(NULL, IDI_APPLICATION);
  wcex.hCursor        = LoadCursor(NULL, IDC_ARROW);
  wcex.lpszClassName  = "RGLDevice";
  classAtom = RegisterClassEx(&wcex);
  return (classAtom) ? true : false;
}

// static 
void Win32WindowImpl::unregisterClass(void) {
  if (classAtom)
    UnregisterClass(MAKEINTATOM(classAtom), NULL );
}

// static 
ATOM Win32WindowImpl::classAtom = (ATOM) NULL;

// ---------------------------------------------------------------------------
//
// Win32GUIFactory class
//
// ---------------------------------------------------------------------------


Win32GUIFactory::Win32GUIFactory()
{
  if (gInitValue) {
    // we must be running in pre-2.6.0 R
    gHandle = reinterpret_cast<HANDLE>(gInitValue);
  }
  if (gHandle) {
    // the handle is given for the console window, so that
    // client and frame windows can be derived
    HWND consoleHandle = reinterpret_cast<HWND>(gHandle);
    gMDIClientHandle = GetParent(consoleHandle);
    gMDIFrameHandle  = GetParent(gMDIClientHandle);
    gDefWindowProc   = &DefMDIChildProc;
  } else
    gDefWindowProc   = &DefWindowProc;
  if ( !Win32WindowImpl::registerClass() )
    lib::printMessage("error: window class registration failed");
}
// ---------------------------------------------------------------------------
Win32GUIFactory::~Win32GUIFactory() {
  Win32WindowImpl::unregisterClass();
}
// ---------------------------------------------------------------------------

WindowImpl* Win32GUIFactory::createWindowImpl(Window* in_window)
{
  WindowImpl* impl = new Win32WindowImpl(in_window);

  RECT size;

  size.left = 0;
  size.right = in_window->width-1;
  size.top  = 0;
  size.bottom = in_window->height-1;

  AdjustWindowRect(
    &size
  , WS_OVERLAPPEDWINDOW // WS_CAPTION|WS_SYSMENU|WS_THICKFRAME|WS_MINIMIZEBOX|WS_MAXIMIZEBOX
  , false // no menu
  );

  HWND success = 0;
  
  if (gHandle) {
    success = CreateMDIWindow(
      MAKEINTATOM(Win32WindowImpl::classAtom)
    , in_window->title
    , MDIS_ALLCHILDSTYLES|WS_OVERLAPPEDWINDOW
    , CW_USEDEFAULT, 0
    , size.right- size.left+1, size.bottom - size.top+1
    , gMDIClientHandle, NULL // GetModuleHandle(NULL)
    , reinterpret_cast<LPARAM>(impl)
    );
  } else {
    success = CreateWindow(
      MAKEINTATOM(Win32WindowImpl::classAtom)
    , in_window->title
    , WS_OVERLAPPEDWINDOW
    , CW_USEDEFAULT, 0
    , size.right- size.left+1, size.bottom - size.top+1
    , NULL, NULL, NULL
    , reinterpret_cast<LPVOID>(impl)
    );
  }
  assert(success);
  return impl;
}
// ---------------------------------------------------------------------------
} // namespace gui
// ---------------------------------------------------------------------------
#endif // RGL_W32

