// C++ source
// This file is part of RGL.
//
// $Id: devicemanager.cpp,v 1.1 2003/03/25 00:13:21 dadler Exp $

#include "devicemanager.h"
#include "types.h"
#include <stdio.h>

//////////////////////////////////////////////////////////////////////////////
//
// STRUCT
//   DeviceInfo
//


DeviceManager::DeviceInfo::DeviceInfo(Device* inDevice, int inId)
{ 
  device = inDevice;
  id = inId;
}


DeviceManager::DeviceInfo::~DeviceInfo()
{
  if (device)
    delete device;
}


//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   DeviceManager
//

DeviceManager::DeviceManager()
{
  current = NULL;
  idCount = 1;
}


DeviceManager::~DeviceManager()
{

  //
  // unset destroy handler on all open devices
  //

  ListIterator iter(&deviceInfos);

  for(iter.first(); !iter.isDone(); iter.next()) {
    DeviceInfo* info = (DeviceInfo*) iter.getCurrent();
    info->device->setDestroyHandler(NULL,NULL);
  }

  //
  // destroy devices
  //

  deviceInfos.deleteItems();

}


//
// DESTROY HANDLER for class Device
//

void DeviceManager::notifyDestroy(void* userdata)
{
  DeviceInfo* destroyed = (DeviceInfo*) userdata;

  // device already destroyed
  destroyed->device = NULL;

  if (current == destroyed) {

    // current device is destroyed, adjust focus

    RingIterator ringiter(&deviceInfos);

    ringiter.set(current);
    ringiter.next();

    DeviceInfo* newcurrent = (DeviceInfo*) ringiter.getCurrent();

    if (newcurrent == current) {
      // there's only one open device
      deviceInfos.remove(destroyed);
      delete destroyed;
      current = NULL;
      setCurrent(0);
    }
    else {
      // more than one, so focus the new one
      deviceInfos.remove(destroyed);
      delete destroyed;
      current = NULL;
      setCurrent(newcurrent->id);
    }
  } else {

    deviceInfos.remove(destroyed);
    delete destroyed;

  }
}

//
// METHOD openDevice
//

bool DeviceManager::openDevice(void)
{
  bool success = false;
  
  Device* device = new Device();
  if (device) {

    if ( device->open() ) {

      int id;

      id = idCount++;

      DeviceInfo* deviceInfo = new DeviceInfo(device,id);

      deviceInfos.addTail( deviceInfo );
      device->setDestroyHandler( this, (void*) deviceInfo );

      success = setCurrent(id);
    }

  }

  return success;
}


//
// METHOD getCurrent
//

Device* DeviceManager::getCurrentDevice(void)
{
  return (current) ? current->device : NULL;
}

//
// METHOD getAnyDevice
//

Device* DeviceManager::getAnyDevice(void)
{
  if (current == NULL)
    openDevice();

  return getCurrentDevice();

}


//
// METHOD getCurrent
//

int DeviceManager::getCurrent()
{
  return (current) ? current->id : 0;
}


//
// METHOD setCurrent
//

bool DeviceManager::setCurrent(int id)
{
  bool success = false;
  DeviceInfo* found = NULL;

  ListIterator iter(&deviceInfos);

  for( iter.first(); !iter.isDone() ; iter.next() ) {

    DeviceInfo* deviceInfo = (DeviceInfo*) iter.getCurrent();

    if (deviceInfo->id == id) {
      found = deviceInfo;
      break;
    }
  }

  if (found) {

    char buffer[64];

    if (current) {
      sprintf(buffer, "RGL device %d (inactive)", current->id);
      current->device->setName(buffer);
    }
    
    current = found;

    sprintf(buffer, "RGL device %d (active)", current->id);
    current->device->setName(buffer);
    
    success = true;
  }

  return success;
}
