#ifndef DEVICE_MANAGER_H
#define DEVICE_MANAGER_H

// C++ header file
// This file is part of RGL
//
// $Id: devicemanager.h,v 1.1 2003/03/25 00:13:21 dadler Exp $

#include "types.h"
#include "device.h"

//
// CLASS
//   DeviceManager
//
// RESPONSIBILITIES
//   o Open device
//   o Current device focus management, providing device access to API implementation
//   o Device id and name accounting (appears in the window title of the device)
//   o Notify device shutdown (by user closing the window)
//   o Shutdown all devices (destruction of device manager)
//
// COLLABORATORS
//   o Device class
//   o R API implementation
//

class DeviceManager : public DestroyHandler {

public:

// lib services:

  DeviceManager();
  virtual ~DeviceManager();

// device services:

  bool    openDevice(void);
  Device* getCurrentDevice(void);
  Device* getAnyDevice(void);
  bool    setCurrent(int id);
  int     getCurrent();

// device destroy handler:

  void    notifyDestroy(void* userdata);

private:

  class DeviceInfo : public Node
  {
  public:
    DeviceInfo(Device* device, int id);
    ~DeviceInfo();
    Device* device;
    int id;
  };

  DeviceInfo* current;
  List        deviceInfos;
  int         idCount;

};

#endif /* DEVICE_MANAGER_H */
