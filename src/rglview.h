#ifndef RGLVIEW_H
#define RGLVIEW_H

// C++ header file
// This file is part of RGL
//
// $Id: rglview.h,v 1.4 2004/08/27 15:58:57 dadler Exp $


#include "gui.h"
#include "scene.h"
#include "fps.h"
#include "select.h"
#include "pixmap.h"

using namespace gui;

enum MouseModeID {mmNAVIGATING=1, mmSELECTING };
enum MouseSelectionID {msNONE=1, msCHANGING, msDONE};

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

  MouseModeID getMouseMode();
  void        setMouseMode(MouseModeID mode);
  MouseSelectionID getSelectState();
  void        setSelectState(MouseSelectionID state);
  double*     getMousePosition();

  // These are set after rendering the scene
  GLdouble modelMatrix[16], projMatrix[16];
  GLint viewport[4];

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

// o DRAG FEATURE: mouseSelection
  void mouseSelectionBegin(int mouseX,int mouseY);
  void mouseSelectionContinue(int mouseX,int mouseY);
  void mouseSelectionEnd(int mouseX,int mouseY);

//
// RENDER SYSTEM
//
  
// o LAYERS
  
  Scene*  scene;
  FPS     fps;
  SELECT  select;

// o CONTEXT
  
  RenderContext renderContext;

  bool autoUpdate;

  enum {
    FSHOWFPS    = 1<<0,
    FAUTOUPDATE = 1<<1
  };

  int  flags;

  MouseModeID mouseMode;
  MouseSelectionID selectState;
  double  mousePosition[4];

};

#endif /* RGLVIEW_H */
