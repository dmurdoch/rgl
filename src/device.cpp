// C++ source
// This file is part of RGL.
//
// $Id$
// ---------------------------------------------------------------------------
#include <cstring>
#include "Device.h"
#include "lib.h"

using namespace rgl;

// ---------------------------------------------------------------------------
Device::Device(int id, bool useNULL) : id_(id)
{
  scene   = new Scene();
  rglview = new RGLView(scene);
  window  = new Window( rglview, getGUIFactory(useNULL) );
  if (window && !window->windowImpl) {
    delete window;
    window = NULL;
  }
  if (!window) {
    devtype = "none";
    return;
  } 
  devtype = GUIFactoryName(useNULL);
  window->addDisposeListener(this);
}
// ---------------------------------------------------------------------------
Device::~Device()
{
  delete scene;
}
// ---------------------------------------------------------------------------
int  Device::getID() 
{
  return id_;
}
// ---------------------------------------------------------------------------
void Device::notifyDisposed(Disposable* disposable)
{
  dispose();
}
// ---------------------------------------------------------------------------
void Device::setName(const char* string)
{
  window->setTitle(string);
}
// ---------------------------------------------------------------------------
void Device::update()
{
//  window->update();
}
// ---------------------------------------------------------------------------
bool Device::open(void)
{
  if (window) {
    window->setVisibility(true);
    return true;
  } else 
    return false;
}
// ---------------------------------------------------------------------------
void Device::close(void)
{
  window->on_close(); 
}
// ---------------------------------------------------------------------------

void Device::bringToTop(int stay)
{
  window->bringToTop(stay);
}

void Device::setWindowRect(int left, int top, int right, int bottom)
{
  window->setWindowRect(left, top, right, bottom);
}

void Device::getWindowRect(int *left, int *top, int *right, int *bottom)
{
  window->getWindowRect(left, top, right, bottom);
}

// ---------------------------------------------------------------------------
int Device::getIgnoreExtent(void)
{
  return scene->getIgnoreExtent();
}
// ---------------------------------------------------------------------------
void Device::setIgnoreExtent(int in_ignoreExtent)
{
  scene->setIgnoreExtent(in_ignoreExtent);
}
// ---------------------------------------------------------------------------
int Device::getSkipRedraw(void)
{
  return window->getSkipRedraw();
}
// ---------------------------------------------------------------------------
void Device::setSkipRedraw(int in_skipRedraw)
{
  window->setSkipRedraw(in_skipRedraw);
}
// ---------------------------------------------------------------------------
bool Device::clear(TypeID stackTypeID)
{
  bool success;
  success = scene->clear(stackTypeID);
  rglview->update();
  return success;
}
// ---------------------------------------------------------------------------
int Device::add(SceneNode* node)
{
  bool success;
  success = scene->add(node);
  rglview->update();
  if (success) return node->getObjID();
  else return 0;
}
// ---------------------------------------------------------------------------

bool Device::pop(TypeID stackTypeID, int id)
{
  bool success;
  bool inGL = rglview->windowImpl->beginGL(); // May need to set context for display lists.
  success = scene->pop(stackTypeID, id);
  if (inGL) {
    rglview->windowImpl->endGL();
  }
  rglview->update();
  return success;
}
// ---------------------------------------------------------------------------
bool Device::snapshot(int format, const char* filename)
{
  return rglview->snapshot( (PixmapFileFormatID) format, filename);
}
// ---------------------------------------------------------------------------
bool Device::pixels(int* ll, int* size, int component, double* result)
{
  return rglview->pixels( ll, size, component, result);
}
// ---------------------------------------------------------------------------
RGLView* Device::getRGLView(void)
{
  return rglview;
}
// ---------------------------------------------------------------------------
bool Device::postscript(int format, const char* filename, bool drawText)
{
  return rglview->postscript( format, filename, drawText);
}
// ---------------------------------------------------------------------------
void Device::getFonts(FontArray& outfonts, int nfonts, char** family, int* style, double* cex, 
                      bool useFreeType)
{
  window->getFonts(outfonts, nfonts, family, style, cex, useFreeType);
}
// ---------------------------------------------------------------------------
const char * Device::getDevtype()
{
  return devtype;
}
