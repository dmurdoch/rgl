// C++ source
// This file is part of RGL.
//
// ---------------------------------------------------------------------------
#include "gui.h"
#include "lib.h"
#include "R.h"

using namespace rgl;

// ---------------------------------------------------------------------------
// WindowImpl common code
// ---------------------------------------------------------------------------
void WindowImpl::getFonts(FontArray& outfonts, int nfonts, char** family, int* style, 
                          double* cex, bool useFreeType)
{
  GLFont* font;
  outfonts.resize(nfonts);
  for (int i = 0; i < nfonts; i++) {
    font = getFont(*(family++), *(style++), *(cex++), useFreeType);
    outfonts[i] = font;
  }  
}

// ---------------------------------------------------------------------------
// View Implementation
// ---------------------------------------------------------------------------
View::View()
: baseX(0)
, baseY(0)
, width(0)
, height(0)
, flags(0)
, windowImpl(0)
{ }
// ---------------------------------------------------------------------------
View::View(int inBaseX, int inBaseY, int inWidth, int inHeight, int inFlags)
: baseX(inBaseX)
, baseY(inBaseY)
, width(inWidth)
, height(inHeight)
, flags(inFlags)
, windowImpl(0)
{
}
// ---------------------------------------------------------------------------
View::~View()
{
  if ((windowImpl) && (flags & WINDOW_IMPL_OWNER)) {
    windowImpl->unbind();
    windowImpl->destroy();
    windowImpl = 0;
  }
}
// ---------------------------------------------------------------------------
void View::setSize(int inWidth, int inHeight)
{
  if ((windowImpl) && (flags & WINDOW_IMPL_OWNER)) {
    int left, top, right, bottom;
    windowImpl->getWindowRect(&left, &top, &right, &bottom);
    windowImpl->setWindowRect(left, top, left+inWidth, top+inHeight);
  } else
    resize(inWidth, inHeight);
}
// ---------------------------------------------------------------------------
void View::setLocation(int inBaseX, int inBaseY)
{
  if ((windowImpl) && (flags & WINDOW_IMPL_OWNER)) {
    int left, top, right, bottom;
    windowImpl->getWindowRect(&left, &top, &right, &bottom);
    windowImpl->setWindowRect(inBaseX, inBaseY, inBaseX + left-right, inBaseY + bottom-top);
  } else
    relocate(inBaseX, inBaseY);
}
// ---------------------------------------------------------------------------
void View::update(void)
{
  if (windowImpl)
    windowImpl->update();
}
// ---------------------------------------------------------------------------
void View::setWindowImpl(WindowImpl* inWindowImpl)
{
  windowImpl = inWindowImpl;
}
// ---------------------------------------------------------------------------
void View::show(void)
{
}
// ---------------------------------------------------------------------------
void View::hide(void)
{
}
// ---------------------------------------------------------------------------
void View::paint(void)
{
}
// ---------------------------------------------------------------------------
void View::resize(int inWidth, int inHeight)
{
  width  = inWidth;
  height = inHeight;
}
// ---------------------------------------------------------------------------
void View::relocate(int inBaseX, int inBaseY)
{
  baseX = inBaseX;
  baseY = inBaseY;
}
// ---------------------------------------------------------------------------
void View::keyPress(int code)
{
}
// ---------------------------------------------------------------------------
void View::keyRelease(int code)
{
}
// ---------------------------------------------------------------------------
void View::buttonPress(int button, int mouseX, int mouseY)
{
}
// ---------------------------------------------------------------------------
void View::buttonRelease(int button, int mouseX, int mouseY)
{
}
// ---------------------------------------------------------------------------
void View::mouseMove(int mouseX, int mouseY)
{
}
// ---------------------------------------------------------------------------
void View::wheelRotate(int direction, int mouseX, int mouseY)
{
}
// ---------------------------------------------------------------------------
void View::captureLost()
{
}
// ---------------------------------------------------------------------------
// Window Implementation
// ---------------------------------------------------------------------------
Window::Window(View* in_child, GUIFactory* factory)
: View(0,0,in_child->width, in_child->height,WINDOW_IMPL_OWNER)
, child(in_child)
, title("untitled")
{
  skipRedraw = false;  
  windowImpl = factory->createWindowImpl(this);
  if (!windowImpl) {
    return;
  } 
  if (child)
    child->setWindowImpl(windowImpl);
}
// ---------------------------------------------------------------------------
Window::~Window()
{
  if (child) {
    delete child;
  }
  fireNotifyDisposed();  
}
// ---------------------------------------------------------------------------
void Window::setWindowImpl(WindowImpl* impl)
{
  View::setWindowImpl(impl);

  if (child)
    child->setWindowImpl(impl);
}
// ---------------------------------------------------------------------------
void Window::setTitle(const char* in_title)
{
  if (windowImpl)
    windowImpl->setTitle(in_title);
}
// ---------------------------------------------------------------------------
void Window::update(void)
{
  windowImpl->update();
}
// ---------------------------------------------------------------------------
void Window::setVisibility(bool state)
{
  if (state)
    windowImpl->show();
  else
    windowImpl->hide();
}
// ---------------------------------------------------------------------------
void Window::bringToTop(int stay)
{
  windowImpl->bringToTop(stay);
}
// ---------------------------------------------------------------------------
void Window::getWindowRect(int *left, int *top, int *width, int *height)
{
  windowImpl->getWindowRect(left, top, width, height);
}
// ---------------------------------------------------------------------------
void Window::setWindowRect(int left, int top, int right, int bottom)
{
  right = getMax(right, left + 1);
  bottom = getMax(bottom, top + 1);
  resize(right-left, bottom-top); // In case message never gets sent, e.g. Xvfb
  windowImpl->setWindowRect(left, top, right, bottom);
}

// ---------------------------------------------------------------------------

int Window::getSkipRedraw(void)
{
  return (int)skipRedraw;
}
// ---------------------------------------------------------------------------
void Window::setSkipRedraw(int in_skipRedraw)
{
  skipRedraw = (bool)in_skipRedraw;
  if (!skipRedraw) update();
}
// ---------------------------------------------------------------------------
void Window::show(void)
{
  if (child)
    child->show();
}
// ---------------------------------------------------------------------------
void Window::hide(void)
{
  if (child)
    child->hide();
}
// ---------------------------------------------------------------------------
void Window::resize(int in_width, int in_height)
{
  if (child)
    child->resize(in_width,in_height);
}
// ---------------------------------------------------------------------------
void Window::paint(void)
{
  if (child)
    child->paint();
}
// ---------------------------------------------------------------------------
void Window::notifyDestroy(void)
{
  if (child) {
    delete child;
    child = NULL;
  }
  fireNotifyDisposed();
}
// ---------------------------------------------------------------------------
void Window::buttonPress(int button, int mouseX, int mouseY)
{
  if (child)
    child->buttonPress(button, mouseX, mouseY);
}
// ---------------------------------------------------------------------------
void Window::buttonRelease(int button, int mouseX, int mouseY)
{
  if (child)
    child->buttonRelease(button, mouseX, mouseY);
}
// ---------------------------------------------------------------------------
void Window::mouseMove(int mouseX, int mouseY)
{
  if (child)
    child->mouseMove(mouseX, mouseY);
}
// ---------------------------------------------------------------------------
void Window::keyPress(int code)
{
  if (child)
    child->keyPress(code);
}
// ---------------------------------------------------------------------------
void Window::wheelRotate(int dir, int mouseX, int mouseY)
{
  if (child)
    child->wheelRotate(dir, mouseX, mouseY);
}
// ---------------------------------------------------------------------------
void Window::on_close()
{
  windowImpl->destroy();
}
// ---------------------------------------------------------------------------
void Window::getFonts(FontArray& outfonts, int nfonts, char** family, int* style, 
                      double* cex, bool useFreeType)
{
  windowImpl->getFonts(outfonts, nfonts, family, style, cex, useFreeType);
}
// ---------------------------------------------------------------------------

int WindowImpl::getAntialias()
{
  if (beginGL()) {
    int result;      
    glGetIntegerv(GL_SAMPLES, &result);
    endGL();
    CHECKGLERROR;
    return result;
  }
  return 1;
}

int WindowImpl::getMaxClipPlanes()
{
  int result;
  glGetError();
  glGetIntegerv(GL_MAX_CLIP_PLANES, &result);
  if (glGetError() == GL_NO_ERROR)
    return result;
  else
    return 6;
}
