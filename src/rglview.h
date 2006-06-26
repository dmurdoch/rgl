#ifndef RGLVIEW_H
#define RGLVIEW_H

// C++ header file
// This file is part of RGL
//
// $Id$


#include "gui.hpp"
#include "scene.h"
#include "fps.h"
#include "select.h"
#include "pixmap.h"

using namespace gui;

enum MouseModeID {mmTRACKBALL = 1, mmXAXIS, mmYAXIS, mmZAXIS, mmPOLAR, mmSELECTING, mmZOOM, mmFOV};
enum MouseSelectionID {msNONE=1, msCHANGING, msDONE};

class RGLView : public View
{
public:
  RGLView(Scene* scene);
  ~RGLView();
  bool snapshot(PixmapFileFormatID formatID, const char* filename);
  bool postscript(int format, const char* filename);
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

  MouseModeID getMouseMode(int button);
  void        setMouseMode(int button, MouseModeID mode);
  MouseSelectionID getSelectState();
  void        setSelectState(MouseSelectionID state);
  double*     getMousePosition();
  void        getUserMatrix(double* dest);
  void        setUserMatrix(double* src);
  
  // These are set after rendering the scene
  GLdouble modelMatrix[16], projMatrix[16];
  GLint viewport[4];

protected:

  void setWindowImpl(WindowImpl* impl);


private:
	typedef void (RGLView::*viewControlPtr)(int mouseX,int mouseY);
	typedef void (RGLView::*viewControlEndPtr)();

	viewControlPtr	ButtonBeginFunc[3], ButtonUpdateFunc[3];
	viewControlEndPtr ButtonEndFunc[3];

	void setDefaultMouseFunc();

//
// DRAG USER-INPUT
//

  int drag;

// o DRAG FEATURE: adjustDirection

  void polarBegin(int mouseX, int mouseY);
  void polarUpdate(int mouseX, int mouseY);
  void polarEnd();

  void trackballBegin(int mouseX, int mouseY);
  void trackballUpdate(int mouseX, int mouseY);
  void trackballEnd();
  
  void oneAxisBegin(int mouseX, int mouseY);
  void oneAxisUpdate(int mouseX, int mouseY);  

  PolarCoord camBase, dragBase, dragCurrent;
  Vertex rotBase, rotCurrent, axis;


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
  void mouseSelectionUpdate(int mouseX,int mouseY);
  void mouseSelectionEnd();

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

  MouseModeID mouseMode[3];
  MouseSelectionID selectState;
  double  mousePosition[4];

};

#endif /* RGLVIEW_H */
