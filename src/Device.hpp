#ifndef DEVICE_H
#define DEVICE_H

// C++ header file
// This file is part of RGL
//
// $Id: Device.hpp,v 1.1 2004/09/22 10:39:33 dadler Exp $

#include "Disposable.hpp"
#include "types.h"
#include "rglview.h"


//
// class Device
//
// - display device title
// - setup the view matrix container (rows and columns of views)
// - setup the view/scene relation (scene per view -or- shared scene)
// - manages current view
// - dispatches scene services to current view's scene
//


class Device : public Disposable, protected IDisposeListener
{
public: // -- all methods are blocking until action completed

  Device(int id);
  virtual ~Device();
  int  getID();
  void setName(const char* string);
  bool open(void); // -- if failed, instance is invalid and should be deleted
  void close(void); // -- when done, instance is invalid and should be deleted
  bool snapshot(int format, const char* filename);

  bool clear(TypeID stackTypeID);
  bool add(SceneNode* node);
  bool pop(TypeID stackTypeID);

#ifdef _WIN32
  void bringToTop(int stay);
#endif

  RGLView* getRGLView(void);
// event handlers
protected:
  void notifyDisposed(Disposable* disposable);
private:
  void update(void);

  Window* window;
  RGLView* rglview;
  Scene* scene;
  int    id_;
};

#endif /* DEVICE_H */
