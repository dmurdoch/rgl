// C++ source
// This file is part of RGL.
//
// $Id: gui.cpp,v 1.2 2003/06/04 08:52:51 dadler Exp $

#include "gui.h"
#include "lib.h"
#include <string.h>

namespace gui {

//////////////////////////////////////////////////////////////////////////////
//
// CLASS IMPLEMENTATION
//   View
//

View::View()
{
  baseX  = 0;
  baseY  = 0;
  width  = 0;
  height = 0;

  flags  = 0;
  windowImpl = NULL;
}


View::View(int inBaseX, int inBaseY, int inWidth, int inHeight, int inFlags)
{
  baseX  = inBaseX;
  baseY  = inBaseY;
  width  = inWidth;
  height = inHeight;

  flags = inFlags;
  windowImpl = NULL;
}


View::~View()
{
  if ((windowImpl) && (flags & WINDOW_IMPL_OWNER)) {
    windowImpl->unbind();
    windowImpl->destroy();
  }
}


void View::setSize(int inWidth, int inHeight)
{
  if ((windowImpl) && (flags & WINDOW_IMPL_OWNER))
    windowImpl->setSize(inWidth, inHeight);
  else
    resize(inWidth, inHeight);
}


void View::setLocation(int inBaseX, int inBaseY)
{
  if ((windowImpl) && (flags & WINDOW_IMPL_OWNER))
    windowImpl->setLocation(inBaseX, inBaseY);
  else
    relocate(inBaseX, inBaseY);
}

void View::update(void)
{
  if (windowImpl)
    windowImpl->update();
}

void View::setWindowImpl(WindowImpl* inWindowImpl)
{
  windowImpl = inWindowImpl;
}


void View::show(void)
{
}

void View::hide(void)
{
}

void View::paint(void)
{
}


void View::resize(int inWidth, int inHeight)
{
  width  = inWidth;
  height = inHeight;
}


void View::relocate(int inBaseX, int inBaseY)
{
  baseX = inBaseX;
  baseY = inBaseY;
}

void View::keyPress(int code)
{
}
void View::keyRelease(int code)
{
}
void View::buttonPress(int button, int mouseX, int mouseY)
{
}

void View::buttonRelease(int button, int mouseX, int mouseY)
{
}

void View::mouseMove(int mouseX, int mouseY)
{
}

void View::wheelRotate(int direction)
{
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS IMPLEMENTATION
//   Window
//


Window::Window(View* in_child, GUIFactory* factory)
 : View(0,0,in_child->width,in_child->height,WINDOW_IMPL_OWNER)
{
  child          = in_child; 
  title          = "untitled";
  destroyHandler = NULL;

  windowImpl = factory->createWindowImpl(this);

  if (child)
    child->setWindowImpl(windowImpl);
}


Window::~Window()
{
  if (child)
    delete child;


  if (destroyHandler)
    destroyHandler->notifyDestroy(destroyHandler_userdata);
}


void Window::setDestroyHandler(DestroyHandler* inDestroyHandler, void* inUserdata)
{
  destroyHandler = inDestroyHandler;
  destroyHandler_userdata = inUserdata;
}

void Window::setWindowImpl(WindowImpl* impl)
{
  View::setWindowImpl(impl);

  if (child)
    child->setWindowImpl(impl);
}

void Window::setTitle(const char* inTitle)
{
  title = inTitle;
  if (windowImpl)
    windowImpl->setTitle( strdup(title) );
}

void Window::update(void)
{
  windowImpl->update();
}
void Window::setVisibility(bool state)
{
  if (state)
    windowImpl->show();
  else
    windowImpl->hide();
}

//
// EVENTS:
//

void Window::show(void)
{
  if (child)
    child->show();
}
void Window::hide(void)
{
  if (child)
    child->hide();
}
void Window::resize(int width, int height)
{
  if (child)
    child->resize(width,height);
}
void Window::paint(void)
{
  if (child)
    child->paint();
}
void Window::closeRequest(void)
{
  windowImpl->destroy();
}
void Window::notifyDestroy(void)
{
  if (child) {
    delete child;
    child = NULL;
  }
  
  if (destroyHandler)
    destroyHandler->notifyDestroy(destroyHandler_userdata);
}
void Window::buttonPress(int button, int mouseX, int mouseY)
{
  if (child)
    child->buttonPress(button, mouseX, mouseY);
}
void Window::buttonRelease(int button, int mouseX, int mouseY)
{
  if (child)
    child->buttonRelease(button, mouseX, mouseY);
}
void Window::mouseMove(int mouseX, int mouseY)
{
  if (child)
    child->mouseMove(mouseX, mouseY);
}
void Window::keyPress(int code)
{
  if (child)
    child->keyPress(code);
}
void Window::wheelRotate(int dir)
{
  if (child)
    child->wheelRotate(dir);
}

}
