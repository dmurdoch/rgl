// C++ source
// This file is part of RGL.
//
// $Id$

#include "Device.hpp"
#include "lib.hpp"

Device::Device(int id) : id_(id)
{
  scene   = new Scene();
  rglview = new RGLView(scene);
  window  = new Window( rglview, lib::getGUIFactory() );
  window->addDisposeListener(this);
}

Device::~Device()
{
  fireNotifyDisposed();
  delete scene;
}

int  Device::getID() {
  return id_;
}

void Device::notifyDisposed(Disposable* disposable)
{
  delete this;
}

void Device::setName(const char* string)
{
  window->setTitle(string);
}

void Device::update()
{
//  window->update();
}

bool Device::open(void)
{
  window->setVisibility(true);
  return true;
}

void Device::close(void)
{
  window->dispose();
}

#ifdef _WIN32
void Device::bringToTop(int stay)
{
  window->bringToTop(stay);
}
#endif

//
// scene management:
//

bool Device::clear(TypeID stackTypeID)
{
  bool success;
  if ( success = scene->clear(stackTypeID) )
    rglview->update();
  return success;
}

bool Device::add(SceneNode* node)
{
  bool success;
  if ( success = scene->add(node) )
    rglview->update();
  return success;
}

bool Device::pop(TypeID stackTypeID)
{
  bool success;
  if ( success = scene->pop(stackTypeID) )
    rglview->update();
  return success;
}

//
// export
//

bool Device::snapshot(int format, const char* filename)
{
  return rglview->snapshot( (PixmapFileFormatID) format, filename);
}


RGLView* Device::getRGLView(void)
{
	return rglview;
}
