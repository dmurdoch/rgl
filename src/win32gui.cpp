// C++ source
// This file is part of RGL.
//
// $Id: win32gui.cpp,v 1.1 2003/03/25 00:13:21 dadler Exp $

#include "win32gui.h"

#include "lib.h"

#include <winuser.h>

namespace gui {

  //
  // translate keycode
  //
  
  static int translate_key(int wParam) {
  
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
  
  class Win32WindowImpl : public WindowImpl
  {
  
  public:

    static ATOM classAtom;
  
    void setTitle(const char* title)
    {
      SetWindowText(windowHandle, title);
    }
  
    void setLocation(int x, int y)
    {
      // FIXME
    }
  
    void setSize(int width, int height)
    {
      // FIXME
    }
  
    void show(void)
    {
      if (windowHandle) {
        ShowWindow(windowHandle, SW_SHOW);
        UpdateWindow(windowHandle);
      } else
        printMessage("window not bound");
    }
    
    void hide(void)
    {
      if (windowHandle) {
        ShowWindow(windowHandle, SW_HIDE);
      }
    }
  
    void update(void)
    {
      InvalidateRect(windowHandle, NULL, false);
      UpdateWindow(windowHandle);
    }
  
    void destroy(void)
    {
      DestroyWindow(windowHandle);
    }
  
    void beginGL(void)
    { 
      dcHandle = GetDC(windowHandle);
      wglMakeCurrent( dcHandle, glrcHandle );
    }
  
    void endGL(void)
    {
      ReleaseDC(windowHandle, dcHandle);
    }
  
    void swap(void)
    {
      dcHandle = GetDC(windowHandle);
      SwapBuffers(dcHandle);
      ReleaseDC(windowHandle, dcHandle);
    }
  
    void captureMouse(View* inCaptureView)
    {
      captureView = inCaptureView;
      SetCapture(windowHandle);
    }
  
    void releaseMouse(void)
    {
      captureView = NULL;
      ReleaseCapture();
    }
  
  protected:
  
    Win32WindowImpl(Window* in_window) : WindowImpl(in_window)
    {
      windowHandle = NULL;
      captureView = NULL;
  
      dcHandle = NULL;
      glrcHandle = NULL;
  
      updateMode = false;
      autoUpdate = false;
    }
  
    //
    // FEATURE
    //   GL Context
    //
  
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
            printMessage("wglCreateContext failed");
  
        }
        else
          printMessage("iPixelFormat == 0!");
  
        ReleaseDC(windowHandle,dcHandle);
      }
  
      return success;
    }
  
  
    void Win32WindowImpl::shutdownGL(void) {
    
      dcHandle = GetDC(windowHandle);
      wglMakeCurrent(NULL,NULL);
      ReleaseDC(windowHandle, dcHandle);
      wglDeleteContext(glrcHandle);
  
    }
  
    //
    // FEATURE
    //   GL Bitmap Fonts
    //
  
    void Win32WindowImpl::initGLBitmapFont(u8 firstGlyph, u8 lastGlyph) {
  
      beginGL();
  
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
  
    void Win32WindowImpl::destroyGLFont(void) {
      beginGL();
      glDeleteLists( font.listBase + font.firstGlyph, font.nglyph);
      delete [] font.widths;
      endGL();
    }
  
  
  private:
  
  
    HWND  windowHandle;
  
    View* captureView;
  
    HGLRC glrcHandle;
    HDC   dcHandle;               // temporary variable setup by lock
  
    bool  updateMode;             // window is currently updated
    bool  autoUpdate;             // update/refresh automatically
  
    static void printMessage(const char* string) {
      MessageBox(NULL, string, "RGL GUI/Win32 port", MB_OK|MB_ICONINFORMATION);
    }
  
  
    LRESULT processMessage(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
      LRESULT returnValue = 0;
      switch(message) {
        case WM_CREATE:
          windowHandle = hwnd;
          initGL();
          initGLBitmapFont(GL_BITMAP_FONT_FIRST_GLYPH, GL_BITMAP_FONT_LAST_GLYPH);
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
  
          window->paint();
          swap();
          ValidateRect(hwnd, NULL);
  /*
          if (autoUpdate)
            SetTimer(hwnd, 1, 100, NULL);
   */
          break;
  
        case WM_TIMER:
  /*
          if (wParam == 1)
            UpdateWindow(hwnd);
            InvalidateRect(hwnd, NULL, false);
  */
          break;
  
        case WM_SIZE:
          window->resize(LOWORD(lParam), HIWORD(lParam));
          break;
  
        case WM_CLOSE:
          window->closeRequest();
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
          ( (captureView) ? captureView : window ) -> buttonPress(GUI_ButtonLeft, LOWORD(lParam), HIWORD(lParam));
          break;
  
        case WM_LBUTTONUP:
          ( (captureView) ? captureView : window ) -> buttonRelease(GUI_ButtonLeft, LOWORD(lParam), HIWORD(lParam));
          break;
  
        case WM_RBUTTONDOWN:
          ( (captureView) ? captureView : window ) -> buttonPress(GUI_ButtonRight, LOWORD(lParam), HIWORD(lParam));
          break;
  
        case WM_RBUTTONUP:
          ( (captureView) ? captureView : window ) -> buttonRelease(GUI_ButtonRight, LOWORD(lParam), HIWORD(lParam));
          break;
  
        case WM_MBUTTONDOWN:
          ( (captureView) ? captureView : window ) -> buttonPress(GUI_ButtonMiddle, LOWORD(lParam), HIWORD(lParam));
          break;
  
        case WM_MBUTTONUP:
          ( (captureView) ? captureView : window ) -> buttonRelease(GUI_ButtonMiddle, LOWORD(lParam), HIWORD(lParam));
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
          ( (captureView) ? captureView : window ) -> mouseMove(LOWORD(lParam), HIWORD(lParam));
          break;
        case WM_CAPTURECHANGED:
          if (captureView) {
            captureView->captureLost();
            captureView = NULL;
          }
          break;

        case WM_DESTROY:
          destroyGLFont();
          shutdownGL();
          SetWindowLong(hwnd, GWL_USERDATA, (LONG) NULL );
          if (window)
            window->notifyDestroy();
          delete this;
          break;
        
        default:
          returnValue = DefWindowProc(hwnd,message,wParam,lParam);
      }
      return returnValue;
    }
  
    static LRESULT CALLBACK windowProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
  
      Win32WindowImpl* windowImpl;
  
      if (message == WM_CREATE) {
  
        // save instance pointer in userdata field on init
  
        windowImpl = (Win32WindowImpl*) ((LPCREATESTRUCT)lParam)->lpCreateParams;
        SetWindowLong(hwnd, GWL_USERDATA, (long)windowImpl );      
  
      } else {
  
        // get instance pointer from userdata field
  
        windowImpl = (Win32WindowImpl*) GetWindowLong(hwnd, GWL_USERDATA);
  
      }
  
      // delegate to class method
    
      if (windowImpl) 
        return windowImpl->processMessage(hwnd, message, wParam, lParam);
      else
        return DefWindowProc(hwnd,message,wParam,lParam);
  
    }
  
  protected:
  
    static HINSTANCE moduleHandle;
  
    static bool registerClass(HINSTANCE inModuleHandle) {
  
      WNDCLASSEX wcex;
  
      moduleHandle = inModuleHandle;
      
  	  wcex.cbSize = sizeof(WNDCLASSEX);
  
  	  wcex.style          = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
      wcex.lpfnWndProc    = (WNDPROC) windowProc;
  	  wcex.cbClsExtra     = 0;
  	  wcex.cbWndExtra     = 0;
  	  wcex.hInstance      = moduleHandle;
  	  wcex.hIcon          = LoadIcon(NULL, IDI_APPLICATION);
  	  wcex.hCursor        = LoadCursor(NULL, IDC_ARROW);
  	  wcex.hbrBackground  = NULL;
  	  wcex.lpszMenuName   = NULL;
  	  wcex.lpszClassName  = "RGLDevice";
  	  wcex.hIconSm        = NULL;
  
  	  classAtom = RegisterClassEx(&wcex);
  
      return (classAtom) ? true : false;
  
    }
  
    static void unregisterClass(void) {
      if (classAtom)
        UnregisterClass(MAKEINTATOM(classAtom), (HINSTANCE) moduleHandle );
    }
  
    friend class Win32GUIFactory;
  
  };
  
  ATOM Win32WindowImpl::classAtom = (ATOM) NULL;
  HINSTANCE Win32WindowImpl::moduleHandle = NULL;
  
  //
  // GUIFactory implementation
  //
  
  Win32GUIFactory::Win32GUIFactory(HINSTANCE inModuleHandle)
  {
    if (inModuleHandle==NULL)
      inModuleHandle = GetModuleHandle(NULL);
  
    if ( !Win32WindowImpl::registerClass(inModuleHandle) )
      Win32WindowImpl::printMessage("error: window class registration failed");
  }
  
  Win32GUIFactory::~Win32GUIFactory() {
    Win32WindowImpl::unregisterClass();
  }
  
  WindowImpl* Win32GUIFactory::createWindowImpl(Window* in_window) 
  { 
    WindowImpl* impl = new Win32WindowImpl(in_window);
    
    RECT size;
  
    size.left = 0;
    size.right = in_window->width-1;
    size.top  = 0;
    size.bottom = in_window->height-1;
  
    // no menu
  
    AdjustWindowRect(&size, WS_CAPTION|WS_SYSMENU|WS_THICKFRAME|WS_MINIMIZEBOX|WS_MAXIMIZEBOX, false);
  
    HWND success = CreateWindow(
      MAKEINTATOM(Win32WindowImpl::classAtom), in_window->title,
      WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, 0,
      size.right- size.left+1, size.bottom - size.top+1,
      NULL, NULL, 
      (HINSTANCE) Win32WindowImpl::moduleHandle, (LPVOID) impl
    );
    
    if (!success) {
      printMessage("gui/win32: unable to create window failed");
      return NULL;
    }
    
    return impl;
  }

};
