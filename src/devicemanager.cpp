// C++ source
// This file is part of RGL.
//

#include <algorithm>
#include <cstdio>
#include "DeviceManager.h"
#include "types.h"
#include "assert.h"
#include "lib.h"

using namespace rgl;

DeviceManager::DeviceManager(bool in_useNULLDevice) 
 : newID(1), devices(), current( devices.end() ), useNULLDevice(in_useNULLDevice)
{ }

DeviceManager::~DeviceManager()
{
  std::vector<Device*> disposeList;
  {
    for( Container::const_iterator i = devices.begin(), end = devices.end() ;  i!=end ; ++i ) {
      disposeList.push_back(*i);
    }
  }
  // disploseList. devices.begin(), devices.end() );
  for (std::vector<Device*>::iterator i = disposeList.begin(); i != disposeList.end() ; ++ i ) {
    // remove manager from listeners    
    (*i)->removeDisposeListener(this);
    // close device
    (*i)->close();
  }
}

bool DeviceManager::openDevice(bool useNULL) 
{
  Device* pDevice = new Device(newID, useNULL);  
  if ( pDevice->open() ) {
    ++newID;
    pDevice->addDisposeListener(this);
    devices.insert( devices.end(), pDevice );
    setCurrent( pDevice->getID() );
    return true;
  } else {
    delete pDevice;
    return false;
  }
}

Device* DeviceManager::getCurrentDevice()
{
  if ( current != devices.end() )
    return *current;
  else
    return NULL;
}

Device* DeviceManager::getAnyDevice()
{
  Device* pDevice = getCurrentDevice();
  if (pDevice == NULL) {
    if (openDevice(useNULLDevice))
      pDevice = getCurrentDevice();
  }
  return pDevice;
}

Device* DeviceManager::getDevice(int id)
{
  for (Container::iterator i = devices.begin() ; i != devices.end() ; ++i ) {
    if ( (*i)->getID() == id )
      return *i;
  }
  return NULL;
}

bool DeviceManager::setCurrent(int id, bool silent)
{
  char buffer[64];
  
  Container::iterator i;
  for (i = devices.begin() ; i != devices.end() ; ++ i ) {
    if ( (*i)->getID() == id )
      break; 
  }
  if ( i != devices.end() ) {
    if ( !silent && current != devices.end() ) {
      snprintf(buffer, 64, "RGL device %d", (*current)->getID() );    
      (*current)->setName(buffer);
    }
    current = i;
    if ( !silent ) {
      snprintf(buffer, 64, "RGL device %d [Focus]", (*current)->getID() );    
      (*current)->setName(buffer);
    }
    return true;
  } else
    return false;
}

int DeviceManager::getCurrent() {
  if ( current != devices.end() )
    return (*current)->getID();
  else
    return 0;
}

int DeviceManager::getDeviceCount() {
  int result = 0;
  for (Container::iterator i = devices.begin(); i != devices.end() ; ++i, ++result);
  return result;
}

void DeviceManager::getDeviceIds(int *buffer, int bufsize) {
  int count = 0;
  for (Container::iterator i = devices.begin(); i != devices.end() && count < bufsize; ++i, ++count) {
    *(buffer++) = (*i)->getID();
  }
}

/**
 * Device disposed handler
 **/
void DeviceManager::notifyDisposed(Disposable* disposed)
{
  Container::iterator pos = std::find( devices.begin(), devices.end(), static_cast<Device*>( disposed ) );
  assert( pos != devices.end() );  
  if ( pos == current ) {
    if ( devices.size() == 1 )
      current = devices.end();
    else
      nextDevice();
  }  
  devices.erase(pos);  
}

void DeviceManager::nextDevice()
{
  if ( current != devices.end() ) {
    // cycle to next
    Iterator next = ++current;
    if ( next == devices.end() )
      next = devices.begin();
    setCurrent( (*next)->getID() );
  } else {
    // ignore: no devices    
  }
}

void DeviceManager::previousDevice()
{
  if ( current != devices.end() ) {
    // cycle to previous
    Iterator prev = current;
    if (prev == devices.begin() )
      prev = devices.end();
    --prev;
    setCurrent( (*prev)->getID() );
  } else {
    // ignore: no devices
  }
}

bool DeviceManager::createTestWindow()
{
  bool result = false;
  Device* pDevice = new Device(newID, false);  
  if ( pDevice ) {
    if ( pDevice->hasWindow() )
      result = true;
    pDevice->close();
    delete pDevice;
  }
  return result;
}

