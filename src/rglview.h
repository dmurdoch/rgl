#ifndef RGLVIEW_H
#define RGLVIEW_H

// C++ header file
// This file is part of RGL
//
// $Id: rglview.h,v 1.1 2003/03/25 00:13:21 dadler Exp $


#include "gui.h"
#include "scene.h"
#include "fps.h"

using namespace gui;

class RGLView : public View
{
public:
  RGLView(Scene* scene);
  ~RGLView();
  bool snapshot(PixmapFileFormatID formatID, const char* filename);
// event handler:
  void show(void);
  void hide(void);
  void paint(void);
  void resize(int width, int height);
  void buttonPress(int button, int mouseX, int mouseY);
  void buttonRelease(int button, int mouseX, int mouseY);
  void mouseMove(int mouseX, int mouseY);
  void wheelRotate(int dir);
  void captureLost();
  void keyPress(int code);
  Scene* getScene();

protected:

  void setWindowImpl(WindowImpl* impl);


private:

  
//
// DRAG USER-INPUT
//

  int drag;

// o DRAG FEATURE: adjustDirection

  void adjustDirectionBegin(int mouseX, int mouseY);
  void adjustDirectionUpdate(int mouseX, int mouseY);
  void adjustDirectionEnd();

  PolarCoord camBase, dragBase, dragCurrent;

// o DRAG FEATURE: adjustZoom

  void adjustZoomBegin(int mouseX, int mouseY);
  void adjustZoomUpdate(int mouseX, int mouseY);
  void adjustZoomEnd();

  int zoomBaseY;
  float zoomCamBase;

// o DRAG FEATURE: adjustFOV (field of view)

  void adjustFOVBegin(int mouseX, int mouseY);
  void adjustFOVUpdate(int mouseX, int mouseY);
  void adjustFOVEnd();

  int fovBaseY;

  
//
// RENDER SYSTEM
//
  
// o LAYERS
  
  Scene*  scene;
  FPS     fps;

// o CONTEXT
  
  RenderContext renderContext;

  bool autoUpdate;

  enum {
    FSHOWFPS    = 1<<0,
    FAUTOUPDATE = 1<<1
  };

  int  flags;
  
};

#endif /* RGLVIEW_H */
