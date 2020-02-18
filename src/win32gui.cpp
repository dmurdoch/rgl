#include "config.h"
#ifdef RGL_W32
// C++ source
// This file is part of RGL.
//

#include "win32gui.h"

#include "lib.h"
#include "glgui.h"

#include <winuser.h>
#include <shlobj.h>
#include "assert.h"
#include "R.h"
#include <Rinternals.h>

#include <ctype.h>

namespace rgl {

extern int     gInitValue;
extern HANDLE  gHandle;
extern SEXP    rglNamespace;
static WNDPROC gDefWindowProc;
static HWND    gMDIClientHandle = 0;
static HWND    gMDIFrameHandle  = 0;

// describe requirements
static const PIXELFORMATDESCRIPTOR pfd = {
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
      case VK_ESCAPE:
      	return GUI_KeyESC;
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
  ~Win32WindowImpl();
  void setTitle(const char* title);
  void setWindowRect(int left, int top, int right, int bottom);
  void getWindowRect(int *left, int *top, int *right, int *bottom);
  void show();
  void hide();
  int  isTopmost(HWND handle);
  void bringToTop(int stay);
  void update();
  void destroy();
  void captureMouse(View* pView);
  void releaseMouse();
  GLFont* getFont(const char* family, int style, double cex, 
                  bool useFreeType);

private:
  LRESULT processMessage(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);
  static bool registerClass();
  static void unregisterClass();
  static LRESULT CALLBACK delegateWindowProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);
  static LRESULT CALLBACK windowProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam);
  static ATOM classAtom;
  HWND  windowHandle;
  View* captureView;
  bool  painting;               // window is currently busy painting
  bool  autoUpdate;             // update/refresh automatically
  bool  refreshMenu;		// need to tell Windows to update the menu
#if defined(WGL_ARB_pixel_format) && !defined(WGL_WGLEXT_PROTOTYPES)
  PFNWGLCHOOSEPIXELFORMATARBPROC wglChoosePixelFormatARB;
#endif
  friend class Win32GUIFactory;

public:
  bool beginGL();
  void endGL();
  void swap();
private:
  bool initGL();
  void shutdownGL();
  GLBitmapFont* initGLBitmapFont(u8 firstGlyph, u8 lastGlyph);
  HDC   dcHandle;               // temporary variable setup by lock
  HGLRC glrcHandle;
};

} // namespace rgl

using namespace rgl;
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

  painting = false;
  autoUpdate = false;
  refreshMenu = false;
}

Win32WindowImpl::~Win32WindowImpl()
{
  beginGL();
  for (unsigned int i=0; i < fonts.size(); i++) {
    delete fonts[i];
  }
  endGL();
}

void Win32WindowImpl::setTitle(const char* title)
{
  SetWindowText(windowHandle, title);
}

void Win32WindowImpl::setWindowRect(int left, int top, int right, int bottom)
{
  if (windowHandle) {
    RECT rect;
    
    rect.left = left;
    rect.top = top;
    rect.right = right;
    rect.bottom = bottom;
    
    // Specification gives the desired client coordinates; expand to include the frame
    AdjustWindowRectEx(&rect, GetWindowLong(windowHandle, GWL_STYLE), FALSE,
                              GetWindowLong(windowHandle, GWL_EXSTYLE)); 
    MoveWindow(windowHandle, rect.left, rect.top, rect.right-rect.left, rect.bottom-rect.top, TRUE);
  }
}

void Win32WindowImpl::getWindowRect(int *left, int *top, int *right, int *bottom)
{
  if (windowHandle) {
    RECT rect;
    GetClientRect(windowHandle, &rect);
    ClientToScreen(windowHandle, (LPPOINT)&rect.left);
    ClientToScreen(windowHandle, (LPPOINT)&rect.right);
    // Rect is now in screen coordinates; convert to parent client area coordinates 
    // for MDI
    HWND parent = GetParent(windowHandle);
    if (parent) {
      ScreenToClient(parent, (LPPOINT)&rect.left);
      ScreenToClient(parent, (LPPOINT)&rect.right);
    }
    *left = rect.left;
    *top = rect.top;
    *right = rect.right;
    *bottom = rect.bottom;
  }
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
    printMessage("window not bound");
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
    printMessage("window not bound");
}

void Win32WindowImpl::update()
{
  InvalidateRect(windowHandle, NULL, false);
  SAVEGLERROR;
  UpdateWindow(windowHandle);
  SAVEGLERROR;
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
    int  iPixelFormat;
#ifdef WGL_ARB_pixel_format
    // Setup antialiasing based on "rgl.antialias" option
    int aa;
    SEXP rgl_aa = GetOption(install("rgl.antialias"),R_BaseEnv);
    if (isNull(rgl_aa)) aa = RGL_ANTIALIAS;
    else aa = asInteger(rgl_aa);
    
    if (aa > 0) {
      float fAttributes[] = { 0, 0 };
      int iAttributes[] = {
        WGL_DRAW_TO_WINDOW_ARB, GL_TRUE,
        WGL_SUPPORT_OPENGL_ARB, GL_TRUE,
        WGL_ACCELERATION_ARB,   WGL_FULL_ACCELERATION_ARB,
        WGL_COLOR_BITS_ARB,     24,
        WGL_ALPHA_BITS_ARB,     8,
        WGL_DEPTH_BITS_ARB,     16,
        WGL_STENCIL_BITS_ARB,   0,
        WGL_DOUBLE_BUFFER_ARB,  GL_TRUE,
        WGL_SAMPLE_BUFFERS_ARB, GL_TRUE,
        WGL_SAMPLES_ARB,        aa,
        0, 0 };
      UINT numFormats = 0;
      if (!wglChoosePixelFormatARB || !wglChoosePixelFormatARB(dcHandle, iAttributes, fAttributes, 1, &iPixelFormat, &numFormats) || numFormats < 1) {
        iPixelFormat = ChoosePixelFormat(dcHandle, &pfd);
      }
    } else
#endif
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

void Win32WindowImpl::shutdownGL() 
{
  dcHandle = GetDC(windowHandle);
  wglMakeCurrent(NULL,NULL);
  ReleaseDC(windowHandle, dcHandle);
  wglDeleteContext(glrcHandle);
}

GLFont* Win32WindowImpl::getFont(const char* family, int style, double cex, 
                                 bool useFreeType)
{
  for (unsigned int i=0; i < fonts.size(); i++) {
    if (fonts[i]->cex == cex && fonts[i]->style == style && !strcmp(fonts[i]->family, family)
     && fonts[i]->useFreeType == useFreeType)
      return fonts[i];
  }
  
  if (!useFreeType) {
    // Not found, so create it.  This is based on code from graphapp gdraw.c
    if (strcmp(family, "NA") && beginGL()) {  // User passes NA_character_ for default, looks like "NA" here
      
      SEXP Rfontname = VECTOR_ELT(PROTECT(eval(lang2(install("windowsFonts"), 
                                          ScalarString(mkChar(family))), rglNamespace)),
                                          0);
      if (isString(Rfontname)) {
        const char* fontname = CHAR(STRING_ELT(Rfontname, 0)); 
        GLBitmapFont* font = new GLBitmapFont(family, style, cex, fontname);
        HFONT hf;
        LOGFONT lf;
    
        double size = 12*cex + 0.5;
    
        lf.lfHeight = -MulDiv(size, GetDeviceCaps(dcHandle, LOGPIXELSY), 72);
  
        lf.lfWidth = 0 ;
        lf.lfEscapement = lf.lfOrientation = 0;
        lf.lfWeight = FW_NORMAL;
        lf.lfItalic = lf.lfUnderline = lf.lfStrikeOut = 0;
        if ((! strcmp(fontname, "Symbol")) || (! strcmp(fontname, "Wingdings")))
          lf.lfCharSet = SYMBOL_CHARSET;
        else
          lf.lfCharSet = DEFAULT_CHARSET;
        lf.lfClipPrecision = CLIP_DEFAULT_PRECIS;
        lf.lfQuality = DEFAULT_QUALITY;
        lf.lfPitchAndFamily = DEFAULT_PITCH | FF_DONTCARE;
        if ((strlen(fontname) > 1) && (fontname[0] == 'T') && (fontname[1] == 'T')) {
          const char *pf;
          lf.lfOutPrecision = OUT_TT_ONLY_PRECIS;
          for (pf = &fontname[2]; isspace(*pf) ; pf++);
          strncpy(lf.lfFaceName, pf, LF_FACESIZE-1);
        }
        else {
          lf.lfOutPrecision = OUT_DEFAULT_PRECIS;
          strncpy(lf.lfFaceName, fontname, LF_FACESIZE-1);
        }
        if (style == 2 || style == 4) lf.lfWeight = FW_BOLD;
        if (style == 3 || style == 4) lf.lfItalic = 1;
      
        if ((hf = CreateFontIndirect(&lf))) {
          SelectObject (dcHandle, hf );
          font->nglyph     = GL_BITMAP_FONT_LAST_GLYPH - GL_BITMAP_FONT_FIRST_GLYPH + 1;
          font->widths     = new unsigned int [font->nglyph];
          GLuint listBase = glGenLists(font->nglyph);
          font->firstGlyph = GL_BITMAP_FONT_FIRST_GLYPH;
          font->listBase   = listBase - font->firstGlyph;
          GetCharWidth32( dcHandle, font->firstGlyph, GL_BITMAP_FONT_LAST_GLYPH,  (LPINT) font->widths );
          {
            TEXTMETRIC tm;
            GetTextMetrics( dcHandle, &tm);
            font->ascent = tm.tmAscent;
          }
          wglUseFontBitmaps(dcHandle, font->firstGlyph, font->nglyph, listBase);
          DeleteObject( hf );
          endGL();  
          fonts.push_back(font);
          UNPROTECT(1);
          return font;
        } 
        delete font;
        endGL();
      }
      UNPROTECT(1);
    }
  } else { // useFreeType
#ifdef HAVE_FREETYPE
    char fontname_absolute[MAX_PATH+1] = "";
    int len=0;
    SEXP Rfontname = VECTOR_ELT(PROTECT(eval(lang2(install("rglFonts"), 
                                          ScalarString(mkChar(family))), rglNamespace)),
                                          0);
    if (isString(Rfontname) && length(Rfontname) >= style) {
      const char* fontname = CHAR(STRING_ELT(Rfontname, style-1)); 
      if (!IS_ABSOLUTE_PATH(fontname)) {
        LPITEMIDLIST pidlFonts;
        assert(SUCCEEDED(SHGetSpecialFolderLocation(0, CSIDL_FONTS, &pidlFonts))
            && SUCCEEDED(SHGetPathFromIDList(pidlFonts, fontname_absolute)) );
        len = strlen(fontname_absolute);
        if (len && fontname_absolute[len-1] != '\\') {
          strcat(fontname_absolute, "\\");
          len++;
        }
      }
      assert(len + strlen(fontname) <= MAX_PATH);
      strcat(fontname_absolute, fontname);  
      GLFTFont* font=new GLFTFont(family, style, cex, fontname_absolute);
      if (font->font) {
        fonts.push_back(font);
        UNPROTECT(1);
        return font;
      } else {
        warning(font->errmsg);
        delete font;
      }
    }
    UNPROTECT(1);
#endif
  }
  if (strcmp(family, fonts[0]->family)) warning("font family \"%s\" not found, using \"%s\"", 
                                         family, fonts[0]->family);
  else if (style != fonts[0]->style) warning("\"%s\" family only supports font %d", 
                                        fonts[0]->family, fonts[0]->style);
  else if (cex != fonts[0]->cex) warning("\"%s\" family only supports cex = %g",
  					fonts[0]->family, fonts[0]->cex);
  else if (useFreeType) warning("FreeType font not available");
  return fonts[0];
}

GLBitmapFont* Win32WindowImpl::initGLBitmapFont(u8 firstGlyph, u8 lastGlyph) 
{
  GLBitmapFont* font = NULL; 
  if (beginGL()) {
    font = new GLBitmapFont("bitmap", 1, 1, "System");
    SelectObject (dcHandle, GetStockObject (SYSTEM_FONT) );
    font->nglyph     = lastGlyph-firstGlyph+1;
    font->widths     = new unsigned int [font->nglyph];
    GLuint listBase = glGenLists(font->nglyph);
    font->firstGlyph = firstGlyph;
    font->listBase   = listBase - firstGlyph;
    GetCharWidth32( dcHandle, font->firstGlyph, lastGlyph,  (LPINT) font->widths );
    {  
      TEXTMETRIC tm;
      GetTextMetrics( dcHandle, &tm);
      font->ascent = tm.tmAscent;
    }    
    wglUseFontBitmaps(dcHandle, font->firstGlyph, font->nglyph, listBase);
    endGL();
  }
  return font;
}

LRESULT Win32WindowImpl::processMessage(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
  LRESULT returnValue = 0;
  switch(message) {
    case WM_CREATE:
      windowHandle = hwnd;
      initGL();
      fonts[0] = initGLBitmapFont(GL_BITMAP_FONT_FIRST_GLYPH, GL_BITMAP_FONT_LAST_GLYPH);
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
    case WM_PAINT: // Warning:  don't put Rprintf calls in paint/render/draw methods, or you get a permanent loop!
      if (!painting) {
        painting = true;
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
        painting = false;
      }
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
        ( (captureView) ? captureView : window ) -> wheelRotate(dir, (short) LOWORD(lParam), (short) HIWORD(lParam) );
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
      shutdownGL();
#if defined (WIN64) || defined(_MSC_VER) 
	  SetWindowLongPtr(hwnd, GWLP_USERDATA, (long)NULL);
#else
      SetWindowLong(hwnd, GWL_USERDATA, (LONG) NULL );
#endif
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
#if defined (WIN64) || defined(_MSC_VER) 
  Win32WindowImpl* windowImpl = (Win32WindowImpl*) GetWindowLongPtr(hwnd, GWLP_USERDATA);
#else
  Win32WindowImpl* windowImpl = (Win32WindowImpl*) GetWindowLong(hwnd, GWL_USERDATA);
#endif
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
    if (windowImpl) {
#if defined (WIN64) || defined(_MSC_VER) 
      SetWindowLongPtr(hwnd, GWLP_USERDATA, (LONG_PTR)windowImpl );
      SetWindowLongPtr(hwnd, GWLP_WNDPROC, (LONG_PTR) delegateWindowProc );
#else
      SetWindowLong(hwnd, GWL_USERDATA, (long) windowImpl );
      SetWindowLong(hwnd, GWL_WNDPROC, (long) delegateWindowProc );
#endif
      return windowImpl->processMessage(hwnd, message, wParam, lParam);
    }
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
#if defined(WGL_ARB_pixel_format) && !defined(WGL_WGLEXT_PROTOTYPES)
: wglChoosePixelFormatARB(NULL)
#endif
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
    error("window class registration failed");

#if defined(WGL_ARB_pixel_format) && !defined(WGL_WGLEXT_PROTOTYPES)
  HANDLE saveHandle = gHandle;
  gHandle = NULL; /* call below fails for MDI windows */
  // wglGetProcAddress needs to be called within valid GL context, we need to create dummy window here
  HWND windowHandle = CreateWindow(MAKEINTATOM(Win32WindowImpl::classAtom), "", WS_POPUP | WS_DISABLED, 0, 0, 10, 10, NULL, NULL, NULL, NULL);
  if (windowHandle) {
    HDC dcHandle = GetDC(windowHandle);
    if (dcHandle) {
      int iPixelFormat = ChoosePixelFormat(dcHandle, &pfd);
      if (iPixelFormat != 0) {
        SetPixelFormat(dcHandle, iPixelFormat, &pfd);
        HGLRC glrcHandle = wglCreateContext(dcHandle);
        if (glrcHandle) {
          wglMakeCurrent(dcHandle, glrcHandle);
          wglChoosePixelFormatARB = (PFNWGLCHOOSEPIXELFORMATARBPROC)wglGetProcAddress("wglChoosePixelFormatARB");
          wglMakeCurrent(NULL, NULL);
          wglDeleteContext(glrcHandle);
        }
      }
      ReleaseDC(windowHandle, dcHandle);
    }
    DestroyWindow(windowHandle);
  }
  gHandle = saveHandle;
#endif
}
// ---------------------------------------------------------------------------
Win32GUIFactory::~Win32GUIFactory() {
  Win32WindowImpl::unregisterClass();
}
// ---------------------------------------------------------------------------

WindowImpl* Win32GUIFactory::createWindowImpl(Window* in_window)
{
  Win32WindowImpl* impl = new Win32WindowImpl(in_window);
#if defined(WGL_ARB_pixel_format) && !defined(WGL_WGLEXT_PROTOTYPES)
  impl->wglChoosePixelFormatARB = wglChoosePixelFormatARB;
#endif  

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
  if (!success)
    error("window creation failed");

  return impl;
}
// ---------------------------------------------------------------------------
#endif // RGL_W32

