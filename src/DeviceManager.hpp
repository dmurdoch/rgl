#ifndef RGL_DEVICE_MANAGER_HPP
#define RGL_DEVICE_MANAGER_HPP

// C++ header file
// This file is part of RGL
//
// $Id: DeviceManager.hpp,v 1.1 2004/09/22 10:39:34 dadler Exp $

#include "Device.hpp"

#include <list>

/**
 * Manager component that is used as a front-end for multiple devices access
 * using an 'id' to set the current device.
 **/
class DeviceManager : protected IDisposeListener {

public:
  DeviceManager();
  ~DeviceManager();
  bool    openDevice(void);
  Device* getCurrentDevice(void);
  Device* getAnyDevice(void);
  bool    setCurrent(int id);
  int     getCurrent();
protected:
  /**
   * Dispose Listener implementation
   **/
  void notifyDisposed(Disposable*);
private:
  void    nextDevice();
  void    previousDevice();
  typedef std::list<Device*> Container;
  typedef Container::iterator Iterator;

  int       newID;
  Container devices;
  Iterator  current; 
};

#endif // DEVICE_MANAGER_HPP

