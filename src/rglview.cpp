// C++ source
// This file is part of RGL.
//
// $Id: rglview.cpp,v 1.2 2003/11/21 15:16:11 dadler Exp $

#include "rglview.h"
#include "opengl.h"
#include <stdio.h>
#include "lib.h"
#include "math.h"
#include "pixmap.h"
#include "fps.h"

//
// GUI config
//

#define BUTTON_DRAGDIRECTION   GUI_ButtonLeft
#define BUTTON_DRAGZOOM        GUI_ButtonRight
#define BUTTON_DRAGFOV         GUI_ButtonMiddle

//
// CAMERA config
//

#define ZOOM_MIN  0.0f
#define ZOOM_MAX  1.0f


RGLView::RGLView(Scene* in_scene)
 : View(0,0,256,256,0), camBase(0.0f,0.0f), dragBase(0.0f,0.0f),dragCurrent(0.0f,0.0f), autoUpdate(false)
{
  scene = in_scene;   
  drag  = 0;
  flags = 0;
}

RGLView::~RGLView()
{
}

void RGLView::show()
{
  fps.init( getTime() );
}

void RGLView::hide()
{
  autoUpdate=false;
}


void RGLView::setWindowImpl(WindowImpl* impl) {
  View::setWindowImpl(impl);
  renderContext.font = &impl->font;
}

Scene* RGLView::getScene() {
  return scene;
}

void RGLView::resize(int width, int height) {

  View::resize(width, height);

  renderContext.size.width = width;
  renderContext.size.height = height;

}

void RGLView::paint(void) {

  double last = renderContext.time;
  double t    = getTime();

  double dt   = (last != 0.0f) ? last - t : 0.0f;

  renderContext.time = t;
  renderContext.deltaTime = dt;

  windowImpl->beginGL();
  scene->render(&renderContext);
  if (flags & FSHOWFPS)
    fps.render(renderContext.time, &renderContext );
  glFinish();
  windowImpl->endGL();

//  if (flags & FAUTOUPDATE)
//    windowImpl->update();
}

//////////////////////////////////////////////////////////////////////////////
//
// user input
//


void RGLView::keyPress(int key)
{
  switch(key) {
    case GUI_KeyF1:
      flags ^= FSHOWFPS;
      windowImpl->update();
      break;
  }
}

void RGLView::buttonPress(int button, int mouseX, int mouseY)
{
  Viewpoint* viewpoint = scene->getViewpoint();
  if ( viewpoint->isInteractive() ) {
    if (!drag) {
      drag = button;
      windowImpl->captureMouse(this);
      switch(button) {
        case BUTTON_DRAGDIRECTION:
          adjustDirectionBegin(mouseX,mouseY);
          break;
        case BUTTON_DRAGZOOM:
          adjustZoomBegin(mouseX,mouseY);
          break;
        case BUTTON_DRAGFOV:
          adjustFOVBegin(mouseX,mouseY);
          break;
      }
    }
  }
}


void RGLView::buttonRelease(int button, int mouseX, int mouseY)
{
  if (drag == button) {
    windowImpl->releaseMouse();
    drag = 0;
    switch(button) {
      case BUTTON_DRAGDIRECTION:
        adjustDirectionEnd();
        break;
      case BUTTON_DRAGZOOM:
        adjustZoomEnd();
        break;
      case BUTTON_DRAGFOV:
        adjustFOVEnd();
        break;
    }
  }
}


void RGLView::mouseMove(int mouseX, int mouseY)
{
  mouseX = clamp(mouseX, 0, width-1);
  mouseY = clamp(mouseY, 0, height-1);
  switch(drag) {
    case BUTTON_DRAGDIRECTION:
      adjustDirectionUpdate(mouseX,mouseY);
      break;
    case BUTTON_DRAGZOOM:
      adjustZoomUpdate(mouseX,mouseY);
      break;
    case BUTTON_DRAGFOV:
      adjustFOVUpdate(mouseX,mouseY);
      break;
  }
}

void RGLView::wheelRotate(int dir)
{
  Viewpoint* viewpoint = scene->getViewpoint();
  
  float zoom = viewpoint->getZoom();

#define ZOOM_STEP   ((ZOOM_MAX - ZOOM_MIN) / 10)
  
  switch(dir)
  {
    case GUI_WheelForward:
      zoom += ZOOM_STEP;
      break;
    case GUI_WheelBackward:
      zoom -= ZOOM_STEP;
      break;
  }

  zoom = clamp( zoom , ZOOM_MIN, ZOOM_MAX);
  viewpoint->setZoom(zoom);

  View::update();
}

void RGLView::captureLost()
{
  if (drag) {
    switch(drag) {
      case BUTTON_DRAGDIRECTION:
        adjustDirectionEnd();
        drag = 0;
        break;
      case BUTTON_DRAGZOOM:
        adjustZoomEnd();
        drag = 0;
        break;
      case BUTTON_DRAGFOV:
        adjustFOVEnd();
        drag = 0;
        break;
    }
  }
}


//////////////////////////////////////////////////////////////////////////////
//
// INTERACTIVE FEATURE
//   adjustDirection
//

//
// FUNCTION
//   screenToPolar
//
// DESCRIPTION
//   screen space is the same as in OpenGL, starting 0,0 at left/bottom(!)
//

static PolarCoord screenToPolar(int width, int height, int mouseX, int mouseY) {

  float cubelen, cx,cy,dx,dy,r;

  cubelen = (float) getMin(width,height);
  r   = cubelen * 0.5f;

  cx  = ((float)width)  * 0.5f;
  cy  = ((float)height) * 0.5f;
  dx  = ((float)mouseX) - cx;
  dy  = ((float)mouseY) - cy;

  //
  // dx,dy = distance to center in pixels
  //

  dx = clamp(dx, -r,r);
  dy = clamp(dy, -r,r);

  //
  // sin theta = dx / r
  // sin phi   = dy / r
  //
  // phi   = arc sin ( sin theta )
  // theta = arc sin ( sin phi   )
  //

  return PolarCoord(

    rad2degf( asinf( dx/r ) ),
    rad2degf( asinf( dy/r ) )
    
  );

}


void RGLView::adjustDirectionBegin(int mouseX, int mouseY)
{
  Viewpoint* viewpoint = scene->getViewpoint();

  camBase = viewpoint->getPosition();

  dragBase = screenToPolar(width,height,mouseX,height-mouseY);
}


void RGLView::adjustDirectionUpdate(int mouseX, int mouseY)
{
  Viewpoint* viewpoint = scene->getViewpoint();

  // float phiDragNow, thetaDragNow;

  dragCurrent = screenToPolar(width,height,mouseX,height-mouseY);

  PolarCoord newpos = camBase - ( dragCurrent - dragBase );

  newpos.phi = clamp( newpos.phi, -90.0f, 90.0f );
  
  viewpoint->setPosition( newpos );
  View::update();
}


void RGLView::adjustDirectionEnd()
{
}

//////////////////////////////////////////////////////////////////////////////
//
// INTERACTIVE FEATURE
//   adjustFOV
//


void RGLView::adjustFOVBegin(int mouseX, int mouseY)
{
  fovBaseY = mouseY;
}


void RGLView::adjustFOVUpdate(int mouseX, int mouseY)
{
  Viewpoint* viewpoint = scene->getViewpoint();

  int dy = mouseY - fovBaseY;

  float py = ((float)dy/(float)height) * 180.0f;

  viewpoint->setFOV( viewpoint->getFOV() + py );

  View::update();

  fovBaseY = mouseY;
}


void RGLView::adjustFOVEnd()
{
}


//////////////////////////////////////////////////////////////////////////////
//
// INTERACTIVE FEATURE
//   adjustZoom
//


void RGLView::adjustZoomBegin(int mouseX, int mouseY)
{
  zoomBaseY = mouseY;
}


void RGLView::adjustZoomUpdate(int mouseX, int mouseY)
{
  Viewpoint* viewpoint = scene->getViewpoint();

  int dy = mouseY - zoomBaseY;

  float py = (float)dy/(float)height;

  float zoom = clamp ( viewpoint->getZoom() + ( -py * ZOOM_MAX ), ZOOM_MIN, ZOOM_MAX);
  viewpoint->setZoom(zoom);

  View::update();

  zoomBaseY = mouseY;
}


void RGLView::adjustZoomEnd()
{
}

//
// snapshot
//

bool RGLView::snapshot(PixmapFileFormatID formatID, const char* filename)
{
  bool success = false;

  if ( (formatID < PIXMAP_FILEFORMAT_LAST) && (pixmapFormat[formatID]) ) {

    windowImpl->beginGL();

    // alloc pixmap memory

    Pixmap snapshot;
  
    snapshot.init(RGB24, width, height, 8);

    // read front buffer

    glPushAttrib(GL_PIXEL_MODE_BIT);

    glReadBuffer(GL_BACK);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glReadPixels(0,0,width,height,GL_RGB, GL_UNSIGNED_BYTE, (GLvoid*) snapshot.data);

    glPopAttrib();

    snapshot.save( pixmapFormat[formatID], filename );

    windowImpl->endGL();

    success = true;

  }

  return success;
}
