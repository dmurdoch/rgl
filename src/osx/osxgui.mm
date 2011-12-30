#include "../config.hpp"
// ---------------------------------------------------------------------------
#ifdef RGL_COCOA
/**
 * TODO
- get font width
 **/
#ifndef HAVE_FREETYPE
#error Cocoa backend reguires FreeType font reneder
#endif
// ---------------------------------------------------------------------------
#include "osxgui.hpp"
#include "../lib.hpp"
// ---------------------------------------------------------------------------
#include <AppKit/AppKit.h>
#include "../opengl.hpp"
#include "../assert.hpp"
#include "../R.h"
#include <Rinternals.h>
// ---------------------------------------------------------------------------
// configuration
// ---------------------------------------------------------------------------
#define EMULATE_RIGHT_KEYMOD  NSControlKeyMask
#define EMULATE_MIDDLE_KEYMOD NSAlternateKeyMask
// ---------------------------------------------------------------------------
namespace gui {
// ---------------------------------------------------------------------------
class OSXWindowImpl : public WindowImpl
{
public:
  OSXWindowImpl(Window* window);
  ~OSXWindowImpl();
  void setTitle(const char* title);
  void setWindowRect(int left, int top, int right, int bottom);
  void getWindowRect(int *left, int *top, int *right, int *bottom);
  void show();
  void hide() { }
  void update();
  void bringToTop(int stay);
  void destroy();
  bool beginGL();
  void endGL();
  void swap();
  void captureMouse(View* captureView) { }
  void releaseMouse(void) { }
  GLFont* getFont(const char* family, int style, double cex,
                  bool useFreeType);

  // events received from GL Cocoa class
  void on_dealloc();
  void on_paint();
  void on_resize(int width, int height);
  void on_buttonPress(int button, int x, int y);
  void on_buttonRelease(int button, int x, int y);
  void on_mouseMove(int x, int y);
  void on_wheelRotate(int wheel);
private:
  NSWindow *osxWindow;
};
// ---------------------------------------------------------------------------
}
// ---------------------------------------------------------------------------
// interfaces
// ---------------------------------------------------------------------------
@interface GLView : NSOpenGLView {
  gui::OSXWindowImpl *impl;
  NSUInteger lastModifierFlags;
}

- (id)initWithFrame:(NSRect)frame
        pixelFormat:(NSOpenGLPixelFormat *)pixelFormat
               impl:(gui::OSXWindowImpl *)impl;
@end
// ---------------------------------------------------------------------------
namespace gui {
// ---------------------------------------------------------------------------
OSXWindowImpl::OSXWindowImpl(Window* window)
  : WindowImpl(window)
{
  NSOpenGLPixelFormatAttribute attributes[] = {
    NSOpenGLPFAWindow,
    NSOpenGLPFADoubleBuffer,
    NSOpenGLPFAColorSize, 32,
    NSOpenGLPFADepthSize, 32,
    0, 0, 0, 0, 0, 0
  };

  // Setup antialiasing based on "gl.aa" option
  int aa = asInteger(GetOption1(install("gl.aa")));
  if(aa > 0) {
    attributes[6] = NSOpenGLPFAMultisample;
    attributes[7] = NSOpenGLPFASampleBuffers;
    attributes[8] = (NSOpenGLPixelFormatAttribute)1;
    attributes[9] = NSOpenGLPFASamples;
    attributes[10] = (NSOpenGLPixelFormatAttribute)aa;
  }

  NSRect frame  = NSMakeRect(100, 100, 256, 256);
  NSRect bounds = NSMakeRect(0, 0, 256, 256);
  NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
  GLView *view = [[GLView alloc] initWithFrame:bounds pixelFormat:pixelFormat impl:this];
  [pixelFormat release];
  osxWindow = [[NSWindow alloc] initWithContentRect:frame
                                          styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask
                                            backing:NSBackingStoreBuffered
                                              defer:NO];
  [osxWindow setContentView:view];
  [osxWindow makeFirstResponder:view];
  [osxWindow setReleasedWhenClosed:YES];
  [view release];
#ifdef HAVE_FREETYPE
  // Determine path to system font
  NSFont *font = [NSFont systemFontOfSize:12.0];
  CTFontDescriptorRef fontRef = CTFontDescriptorCreateWithNameAndSize((CFStringRef)[font fontName], [font pointSize]);
  CFURLRef url = (CFURLRef)CTFontDescriptorCopyAttribute(fontRef, kCTFontURLAttribute);
  fonts[0] = new GLFTFont("Lucida Grande", 0, 12, [[(NSURL *)url path] UTF8String]);
  CFRelease(fontRef);
  CFRelease(url);
#endif
}
// ---------------------------------------------------------------------------
OSXWindowImpl::~OSXWindowImpl()
{
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::setTitle(const char *text)
{
  NSString *title = [[NSString alloc] initWithUTF8String:text];
  [osxWindow setTitle:title];
  [title release];
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::setWindowRect(int left, int top, int right, int bottom)
{
  NSRect frame = NSMakeRect(left, top, right - left, bottom - top);
  [osxWindow setFrame:frame display:YES];
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::getWindowRect(int *left, int *top, int *right, int *bottom)
{
  NSRect frame = [osxWindow frame];
  if(left)   *left   = frame.origin.x;
  if(top)    *top    = frame.origin.y;
  if(right)  *right  = frame.origin.x + frame.size.width;
  if(bottom) *bottom = frame.origin.y + frame.size.height;
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::destroy()
{
}
// ---------------------------------------------------------------------------
GLFont* OSXWindowImpl::getFont(const char* family, int style, double cex,
                                 bool useFreeType)
{
  for (unsigned int i=0; i < fonts.size(); i++) {
    if (fonts[i]->cex == cex && fonts[i]->style == style && !strcmp(fonts[i]->family, family)
     && fonts[i]->useFreeType == useFreeType)
      return fonts[i];
  }

  if (useFreeType) {
#ifdef HAVE_FREETYPE
    int len=0;
    SEXP Rfontname = VECTOR_ELT(PROTECT(eval(lang2(install("rglFonts"),
                                          ScalarString(mkChar(family))), R_GlobalEnv)),
                                          0);
    if (isString(Rfontname) && length(Rfontname) >= style) {
      const char* fontname = CHAR(STRING_ELT(Rfontname, style-1));
      GLFTFont* font=new GLFTFont(family, style, cex, fontname);
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
  return NULL;
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::swap()
{
  [[(NSOpenGLView *)[osxWindow contentView] openGLContext] flushBuffer];
}
// ---------------------------------------------------------------------------
bool OSXWindowImpl::beginGL()
{
  return true;
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::endGL()
{
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::update()
{
#if 1
  // Draw rect should be called directly here if we want immediate result
  [[osxWindow contentView] drawRect:NSZeroRect];
#else
  [[osxWindow contentView] setNeedsDisplay:YES];
#endif
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::show()
{
  [osxWindow makeKeyAndOrderFront:nil];
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::bringToTop(int stay)
{
  [osxWindow makeKeyAndOrderFront:nil];
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::on_dealloc()
{
  if (window) window->notifyDestroy();
  delete this;
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::on_paint()
{
  if (window && !window->skipRedraw) window->paint();
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::on_resize(int width, int height)
{
  if (window) window->resize(width, height);
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::on_buttonPress(int button, int x, int y)
{
  if (window) window->buttonPress(button, x, y);
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::on_buttonRelease(int button, int x, int y)
{
  if (window) window->buttonRelease(button, x, y);
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::on_mouseMove(int x, int y)
{
  if (window) window->mouseMove(x, y);
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::on_wheelRotate(int wheel)
{
  if (window) window->wheelRotate(wheel);
}
// ---------------------------------------------------------------------------
// GUI Factory
// ---------------------------------------------------------------------------
OSXGUIFactory::OSXGUIFactory()
{
}
// ---------------------------------------------------------------------------
OSXGUIFactory::~OSXGUIFactory()
{
}
// ---------------------------------------------------------------------------
WindowImpl* OSXGUIFactory::createWindowImpl(Window* window)
{
  return new OSXWindowImpl(window);
}
// ---------------------------------------------------------------------------
extern int gInitValue;
bool OSXGUIFactory::hasEventLoop()
{
  return gInitValue != 0;
}
// ---------------------------------------------------------------------------
} // namespace gui
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// implementation
// ---------------------------------------------------------------------------
@implementation GLView

- (id)initWithFrame:(NSRect)frame
        pixelFormat:(NSOpenGLPixelFormat *)pixelFormat
               impl:(gui::OSXWindowImpl *)windowImpl
{
  if ((self = [super initWithFrame:frame pixelFormat:pixelFormat])) {
    impl = windowImpl;
  }
  return self;
}

- (void)dealloc
{
  if (impl) impl->on_dealloc();
  [super dealloc];
}

- (void)drawRect:(NSRect)theRect
{
  [[self openGLContext] makeCurrentContext];
  if (impl) impl->on_paint();
  [[self openGLContext] flushBuffer];
}

- (void)update
{
  [super update];
  if (impl) {
    NSRect frame = [self frame];
    impl->on_resize(frame.size.width, frame.size.height);
  }
}

- (void)reshape
{
  [super reshape];
  if (impl) {
    NSRect frame = [self frame];
    impl->on_resize(frame.size.width, frame.size.height);
  }
}

- (NSPoint)pointForEvent:(NSEvent *)event
{
  NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
  NSRect bounds = [self bounds];
  // OpenGL y axis is reversed here
  point.y = bounds.size.height - point.y;
  return point;
}

- (int)buttonFromModifierFlags:(NSUInteger)modifierFlags
{
  if((modifierFlags & EMULATE_RIGHT_KEYMOD) != 0) {
    return gui::GUI_ButtonRight;
  } else if((modifierFlags & EMULATE_MIDDLE_KEYMOD) != 0) {
    return gui::GUI_ButtonMiddle;
  }
  return gui::GUI_ButtonLeft;
}

- (void)scrollWheel:(NSEvent *)event
{
  if (impl) {
    CGFloat delta = [event deltaY];
    if(delta != 0.0) impl->on_wheelRotate(delta > 0.0 ? gui::GUI_WheelForward : gui::GUI_WheelBackward);
  }
}

- (void)mouseDown:(NSEvent *)event
{
  if (impl) {
    NSPoint point = [self pointForEvent:event];
    lastModifierFlags = [event modifierFlags];
    impl->on_buttonPress([self buttonFromModifierFlags:lastModifierFlags], point.x, point.y);
  }
}

- (void)mouseUp:(NSEvent *)event
{
  if (impl) {
    NSPoint point = [self pointForEvent:event];
    impl->on_buttonRelease([self buttonFromModifierFlags:lastModifierFlags], point.x, point.y);
  }
}

- (void)mouseDragged:(NSEvent *)event
{
  if (impl) {
    NSPoint point = [self pointForEvent:event];
    impl->on_mouseMove(point.x, point.y);
  }
}

- (void)rightMouseDown:(NSEvent *)event
{
  if (impl) {
    NSPoint point = [self pointForEvent:event];
    impl->on_buttonPress(gui::GUI_ButtonRight, point.x, point.y);
  }
}

- (void)rightMouseUp:(NSEvent *)event
{
  if (impl) {
    NSPoint point = [self pointForEvent:event];
    impl->on_buttonRelease(gui::GUI_ButtonRight, point.x, point.y);
  }
}

- (void)rightMouseDragged:(NSEvent *)event
{
  if (impl) {
    NSPoint point = [self pointForEvent:event];
    impl->on_mouseMove(point.x, point.y);
  }
}

- (void)otherMouseDown:(NSEvent *)event
{
  if (impl) {
    NSPoint point = [self pointForEvent:event];
    impl->on_buttonPress(gui::GUI_ButtonMiddle, point.x, point.y);
  }
}

- (void)otherMouseUp:(NSEvent *)event
{
  if (impl) {
    NSPoint point = [self pointForEvent:event];
    impl->on_buttonRelease(gui::GUI_ButtonMiddle, point.x, point.y);
  }
}

- (void)otherMouseDragged:(NSEvent *)event
{
  if (impl) {
    NSPoint point = [self pointForEvent:event];
    impl->on_mouseMove(point.x, point.y);
  }
}

@end

#endif // RGL_COCOA
