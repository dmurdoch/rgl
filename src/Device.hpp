#ifndef RGL_DEVICE_HPP
#define RGL_DEVICE_HPP

// C++ header file
// This file is part of RGL
//
// $Id$

#include "Disposable.hpp"
#include "types.h"
#include "rglview.h"

namespace rgl {

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

  Device(int id, bool useNULL);
  virtual ~Device();
  int  getID();
  void setName(const char* string);
  bool open(void); // -- if failed, instance is invalid and should be deleted
  void close(void); // -- when done, instance is invalid and should be deleted
  bool snapshot(int format, const char* filename);
  bool pixels(int* ll, int* size, int component, float* result);
  bool postscript(int format, const char* filename, bool drawText);

  bool clear(TypeID stackTypeID);
  int add(SceneNode* node); // -- return a unique id if successful, or zero if not
  bool pop(TypeID stackTypeID, int id);

  // accessor method for Scene, modeled after getBoundingBox()
  // from scene.h
  Scene* getScene() const { return scene; }

  void bringToTop(int stay);

  RGLView* getRGLView(void);
  
  int getIgnoreExtent(void);
  void setIgnoreExtent(int in_ignoreExtent);  
  int getSkipRedraw(void);
  void setSkipRedraw(int in_skipRedraw);
  
  void setWindowRect(int left, int top, int right, int bottom);
  void getWindowRect(int *left, int *top, int *right, int *bottom);
  
  void getFonts(FontArray& outfonts, int nfonts, char** family, int* style, double* cex, 
                bool useFreeType);
  const char* getDevtype(void);

// event handlers
protected:
  void notifyDisposed(Disposable* disposable);
private:
  void update(void);

  Window* window;
  RGLView* rglview;
  Scene* scene;
  const char* devtype;
  int    id_;
};

} // namespace rgl

#endif // RGL_DEVICE_HPP

