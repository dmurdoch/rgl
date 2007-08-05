// C++ source
// This file is part of RGL.
//
// $Id$

#include "DeviceManager.hpp"
#include "types.h"
#include <algorithm>
#include <cstdio>
#include <cassert>
#include "lib.hpp"

DeviceManager::DeviceManager() 
 : newID(1), devices(), current( devices.end() )
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

bool DeviceManager::openDevice() 
{
  Device* pDevice = new Device(newID);  
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
    openDevice();
    pDevice = getCurrentDevice();
  }
  return pDevice;
}

bool DeviceManager::setCurrent(int id)
{
  char buffer[64];
  
  Container::iterator i;
  for (i = devices.begin() ; i != devices.end() ; ++ i ) {
    if ( (*i)->getID() == id )
      break; 
  }
  if ( i != devices.end() ) {
    if ( current != devices.end() ) {
      sprintf(buffer, "RGL device %d", (*current)->getID() );    
      (*current)->setName(buffer);
    }
    current = i;
    sprintf(buffer, "RGL device %d [Focus]", (*current)->getID() );    
    (*current)->setName(buffer);
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


