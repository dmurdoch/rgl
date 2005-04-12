#include "config.hpp"
// ---------------------------------------------------------------------------
#ifdef RGL_OSX
// ---------------------------------------------------------------------------
#include "osxgui.hpp"
// ---------------------------------------------------------------------------
#include <Carbon/Carbon.h>
#include "opengl.hpp"
// ---------------------------------------------------------------------------
namespace gui {
// ---------------------------------------------------------------------------
class OSXWindowImpl : public WindowImpl
{
public:
	OSXWindowImpl(Window* window);
	~OSXWindowImpl();
  void setTitle(const char* title) { }
  void setLocation(int x, int y) { }
  void setSize(int width, int height) { }
  void show();
  void hide() { }
  void update() { }
  void bringToTop(int stay) { }
  void destroy() { }
  void beginGL() { }
  void endGL() { }
  void swap() { }
  void captureMouse(View* captureView) { }
  void releaseMouse(void) { }
private:
	void on_init() { }
	void on_dispose() { }
	OSStatus windowHandler(EventHandlerCallRef next, EventRef e);
	static OSStatus memberDelegate(EventHandlerCallRef next, EventRef e,void* userdata);
  ::WindowRef mWindowRef;
};
// ---------------------------------------------------------------------------
OSXWindowImpl::OSXWindowImpl(Window* window)
  : WindowImpl(window)
{
  OSStatus s;
  WindowClass wc = kDocumentWindowClass;
  WindowAttributes wa = 0
    // |kWindowCompositingAttribute
    // |kWindowStandardDocumentAttributes
    |kWindowStandardHandlerAttribute
  ;
	Rect r;
  r.left = 100;
  r.right = r.left + 256;
  r.top = 100;
  r.bottom = r.top + 256;
  s = CreateNewWindow(wc,wa,&r,&mWindowRef);
  check_noerr(s); 
  EventTypeSpec typeList[] = {
 //   { kEventClassWindow,    kEventWindowClose },
    { kEventClassWindow,    kEventWindowDrawContent },
    { kEventClassWindow,    kEventWindowBoundsChanged },
    { kEventClassKeyboard,  kEventRawKeyDown },
    { kEventClassKeyboard,  kEventRawKeyUp }
  };
  int numTypes = sizeof(typeList)/sizeof(EventTypeSpec);
  EventHandlerUPP handlerUPP = NewEventHandlerUPP(OSXWindowImpl::memberDelegate);
	EventTargetRef theTarget; 
	theTarget = GetWindowEventTarget(mWindowRef);
	InstallEventHandler(
		theTarget, handlerUPP,
    numTypes, typeList,
    this, 
		NULL
	);  	
  on_init();	
}
// ---------------------------------------------------------------------------
OSXWindowImpl::~OSXWindowImpl()
{
	on_dispose();
}
// ---------------------------------------------------------------------------
void OSXWindowImpl::show()
{
	ShowWindow(mWindowRef);
}
// ---------------------------------------------------------------------------
OSStatus OSXWindowImpl::windowHandler(EventHandlerCallRef next, EventRef e) {
  EventKind kind = GetEventKind(e);
  switch( kind ) {
    case kEventWindowDrawContent:
      return noErr;
/*			
    case kEventWindowClose:
      QuitApplicationEventLoop();
      return noErr;
*/
	  case kEventWindowBoundsChanged:
      // aglUpdateContext(ctx);
      break; 
    case kEventRawKeyDown:
      // on_key_down( get_keycode(e) );
      break;
    case kEventRawKeyUp:
      // on_key_up( get_keycode(e) );
      break;
  }
  return CallNextEventHandler(next,e);
}
// ---------------------------------------------------------------------------
OSStatus OSXWindowImpl::memberDelegate(EventHandlerCallRef next, EventRef e, void* userdata)
{
	return static_cast<OSXWindowImpl*>(userdata)->windowHandler(next,e);
}
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
} // namespace gui
// ---------------------------------------------------------------------------
#endif // RGL_OSX

