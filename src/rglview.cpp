// C++ source
// This file is part of RGL.
//
// $Id$

#include "rglview.h"
#include "opengl.hpp"
#include <stdio.h>
#include "lib.hpp"
#include "math.h"
#include "pixmap.h"
#include "fps.h"
#include "select.h"
#include "gl2ps.h"
#include <locale>

//
// CAMERA config
//

#define ZOOM_MIN  0.0001f
#define ZOOM_MAX  10000.0f


RGLView::RGLView(Scene* in_scene)
 : View(0,0,256,256,0), dragBase(0.0f,0.0f),dragCurrent(0.0f,0.0f), autoUpdate(false)
{
  scene = in_scene;
  drag  = 0;
  flags = 0;
  selectState = msNONE;

  setDefaultMouseFunc();
  renderContext.rect.x = 0;
  renderContext.rect.y = 0; // size is set elsewhere
}

RGLView::~RGLView()
{
}

void RGLView::show()
{
  fps.init( lib::getTime() );
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

  renderContext.rect.width = width;
  renderContext.rect.height = height;
  if (drag) captureLost();
}

void RGLView::paint(void) {

  double last = renderContext.time;
  double t    = lib::getTime();

  double dt   = (last != 0.0f) ? last - t : 0.0f;
  
  renderContext.time = t;
  renderContext.deltaTime = dt;

  if (windowImpl->beginGL()) {
    scene->render(&renderContext);

    glGetDoublev(GL_MODELVIEW_MATRIX,modelMatrix);
    glGetDoublev(GL_PROJECTION_MATRIX,projMatrix);
    glGetIntegerv(GL_VIEWPORT,viewport);

    if (selectState == msCHANGING)
      select.render(mousePosition);
    if (flags & FSHOWFPS && selectState == msNONE)
      fps.render(renderContext.time, &renderContext );

    glFinish();
    windowImpl->endGL();
  }

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
	  (this->*ButtonBeginFunc[button-1])(mouseX,mouseY);
	}
      }
}


void RGLView::buttonRelease(int button, int mouseX, int mouseY)
{
  	if (drag == button) {
	    windowImpl->releaseMouse();
	    drag = 0;
	    (this->*ButtonEndFunc[button-1])();
 	}
}

void RGLView::mouseMove(int mouseX, int mouseY)
{
    if (drag) {
  	mouseX = clamp(mouseX, 0, width-1);
  	mouseY = clamp(mouseY, 0, height-1);

  	(this->*ButtonUpdateFunc[drag-1])(mouseX,mouseY);
    }
}

void RGLView::wheelRotate(int dir)
{
  Viewpoint* viewpoint = scene->getViewpoint();
  
  float zoom = viewpoint->getZoom();

#define ZOOM_STEP  1.05f 
#define ZOOM_PIXELLOGSTEP 0.02f
  
  switch(dir)
  {
    case GUI_WheelForward:
      zoom *= ZOOM_STEP;
      break;
    case GUI_WheelBackward:
      zoom /= ZOOM_STEP;
      break;
  }

  zoom = clamp( zoom , ZOOM_MIN, ZOOM_MAX);
  viewpoint->setZoom(zoom);

  View::update();
}

void RGLView::captureLost()
{
  if (drag) {
    (this->*ButtonEndFunc[drag-1])();
    drag = 0;
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

    math::rad2deg( math::asin( dx/r ) ),
    math::rad2deg( math::asin( dy/r ) )
    
  );

}

static Vertex screenToVector(int width, int height, int mouseX, int mouseY) {

    float radius = (float) getMax(width, height) * 0.5f;

    float cx = ((float)width) * 0.5f;
    float cy = ((float)height) * 0.5f;
    float x  = (((float)mouseX) - cx)/radius;
    float y  = (((float)mouseY) - cy)/radius;

    // Make unit vector

    float len = sqrt(x*x + y*y);
    if (len > 1.0e-6) {
        x = x/len;
        y = y/len;
    }
    // Find length to first edge

    float maxlen = math::sqrt(2.0f);

    // zero length is vertical, max length is horizontal
    float angle = (maxlen - len)/maxlen*math::pi<float>()/2.0f;

    float z = math::sin(angle);

    // renorm to unit length

    len = math::sqrt(1.0f - z*z);
    x = x*len;
    y = y*len;

    return Vertex(x, y, z);
}

void RGLView::trackballBegin(int mouseX, int mouseY)
{
	rotBase = screenToVector(width,height,mouseX,height-mouseY);
}

void RGLView::trackballUpdate(int mouseX, int mouseY)
{
	Viewpoint* viewpoint = scene->getViewpoint();

  	rotCurrent = screenToVector(width,height,mouseX,height-mouseY);

	if (windowImpl->beginGL()) {
	    viewpoint->updateMouseMatrix(rotBase,rotCurrent);
	    windowImpl->endGL();

	    View::update();
	}
}

void RGLView::trackballEnd()
{
	Viewpoint* viewpoint = scene->getViewpoint();
    viewpoint->mergeMouseMatrix();
}

void RGLView::oneAxisBegin(int mouseX, int mouseY)
{
	rotBase = screenToVector(width,height,mouseX,height/2);
}

void RGLView::oneAxisUpdate(int mouseX, int mouseY)
{
	Viewpoint* viewpoint = scene->getViewpoint();

  	rotCurrent = screenToVector(width,height,mouseX,height/2);

	if (windowImpl->beginGL()) {
	    viewpoint->mouseOneAxis(rotBase,rotCurrent,axis[drag-1]);
	    windowImpl->endGL();

	    View::update();
	}
}

void RGLView::polarBegin(int mouseX, int mouseY)
{
	Viewpoint* viewpoint = scene->getViewpoint();

  	camBase = viewpoint->getPosition();

	dragBase = screenToPolar(width,height,mouseX,height-mouseY);

}

void RGLView::polarUpdate(int mouseX, int mouseY)
{
	Viewpoint* viewpoint = scene->getViewpoint();

  dragCurrent = screenToPolar(width,height,mouseX,height-mouseY);

  PolarCoord newpos = camBase - ( dragCurrent - dragBase );

  newpos.phi = clamp( newpos.phi, -90.0f, 90.0f );
  
  viewpoint->setPosition( newpos );
  View::update();
}

void RGLView::polarEnd()
{

 //    Viewpoint* viewpoint = scene->getViewpoint();
 //    viewpoint->mergeMouseMatrix();

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

  float zoom = clamp ( viewpoint->getZoom() * exp(-dy*ZOOM_PIXELLOGSTEP), ZOOM_MIN, ZOOM_MAX);
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

  if ( (formatID < PIXMAP_FILEFORMAT_LAST) && (pixmapFormat[formatID]) 
      && windowImpl->beginGL() ) {

    // alloc pixmap memory

    Pixmap snapshot;
  
    snapshot.init(RGB24, width, height, 8);

    // read front buffer

    glPushAttrib(GL_PIXEL_MODE_BIT);

    glReadBuffer(GL_FRONT);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glReadPixels(0,0,width,height,GL_RGB, GL_UNSIGNED_BYTE, (GLvoid*) snapshot.data);

    glPopAttrib();

    success = snapshot.save( pixmapFormat[formatID], filename );

    windowImpl->endGL();

  }

  return success;
}

void RGLView::setMouseMode(int button, MouseModeID mode)
{
	int index = button-1;
    	mouseMode[index] = mode;
	switch (mode) {
	    case mmTRACKBALL:
	    	ButtonBeginFunc[index] = &RGLView::trackballBegin;
	    	ButtonUpdateFunc[index] = &RGLView::trackballUpdate;
	    	ButtonEndFunc[index] = &RGLView::trackballEnd;
	    	break;
	    case mmXAXIS:
	    case mmYAXIS:
	    case mmZAXIS:
	    	ButtonBeginFunc[index] = &RGLView::oneAxisBegin;
	    	ButtonUpdateFunc[index] = &RGLView::oneAxisUpdate;
	    	ButtonEndFunc[index] = &RGLView::trackballEnd; // No need for separate function
	    	if (mode == mmXAXIS)      axis[index] = Vertex(1,0,0);
	    	else if (mode == mmYAXIS) axis[index] = Vertex(0,1,0);
	    	else                      axis[index] = Vertex(0,0,1);
	    	break;	    	
	    case mmPOLAR:
 	    	ButtonBeginFunc[index] = &RGLView::polarBegin;
	    	ButtonUpdateFunc[index] = &RGLView::polarUpdate;
	    	ButtonEndFunc[index] = &RGLView::polarEnd;
	    	break;
	    case mmSELECTING:
 	    	ButtonBeginFunc[index] = &RGLView::mouseSelectionBegin;
	    	ButtonUpdateFunc[index] = &RGLView::mouseSelectionUpdate;
	    	ButtonEndFunc[index] = &RGLView::mouseSelectionEnd;
	    	break;
	    case mmZOOM:
 	    	ButtonBeginFunc[index] = &RGLView::adjustZoomBegin;
	    	ButtonUpdateFunc[index] = &RGLView::adjustZoomUpdate;
	    	ButtonEndFunc[index] = &RGLView::adjustZoomEnd;
	    	break;
	    case mmFOV:
 	    	ButtonBeginFunc[index] = &RGLView::adjustFOVBegin;
	    	ButtonUpdateFunc[index] = &RGLView::adjustFOVUpdate;
	    	ButtonEndFunc[index] = &RGLView::adjustFOVEnd;
	    	break;
	}
}

MouseModeID RGLView::getMouseMode(int button)
{
    return mouseMode[button-1];
}

MouseSelectionID RGLView::getSelectState()
{
    	return selectState;
}

void RGLView::setSelectState(MouseSelectionID state)
{
    	selectState = state;
}

double* RGLView::getMousePosition()
{
    	return mousePosition;
}

//////////////////////////////////////////////////////////////////////////////
//
// INTERACTIVE FEATURE
//   mouseSelection
//
void RGLView::mouseSelectionBegin(int mouseX,int mouseY)
{
	mousePosition[0] = (float)mouseX/(float)width;
	mousePosition[1] = (float)(height - mouseY)/(float)height;
	mousePosition[2] = mousePosition[0];
	mousePosition[3] = mousePosition[1];
	selectState = msCHANGING;
}

void RGLView::mouseSelectionUpdate(int mouseX,int mouseY)
{
	mousePosition[2] = (float)mouseX/(float)width;
	mousePosition[3] = (float)(height - mouseY)/(float)height;
	View::update();
}

void RGLView::mouseSelectionEnd()
{
	selectState = msDONE;
	View::update();
}

void RGLView::getUserMatrix(double* dest)
{
	Viewpoint* viewpoint = scene->getViewpoint();

	viewpoint->getUserMatrix(dest);
}

void RGLView::setUserMatrix(double* src)
{
	Viewpoint* viewpoint = scene->getViewpoint();

	viewpoint->setUserMatrix(src);

	View::update();
}

void RGLView::getScale(double* dest)
{
	Viewpoint* viewpoint = scene->getViewpoint();
	
	viewpoint->getScale(dest);
}

void RGLView::setScale(double* src)
{
	Viewpoint* viewpoint = scene->getViewpoint();

	viewpoint->setScale(src);

	View::update();
}

void RGLView::getPosition(double* dest)
{    
    Viewpoint* viewpoint = scene->getViewpoint();
    viewpoint->getPosition(dest);
}

void RGLView::setPosition(double* src)
{
	Viewpoint* viewpoint = scene->getViewpoint();

	viewpoint->setPosition(src);
}


void RGLView::setDefaultMouseFunc()
{
    setMouseMode(1, mmPOLAR);
    setMouseMode(2, mmFOV);
    setMouseMode(3, mmZOOM);
}

bool RGLView::postscript(int formatID, const char* filename, bool drawText)
{
  bool success = false;

  FILE *fp = fopen(filename, "wb");  
  char *oldlocale = setlocale(LC_NUMERIC, "C");
  
  GLint buffsize = 0, state = GL2PS_OVERFLOW;
  GLint viewport[4];
  GLint options = GL2PS_SILENT | GL2PS_SIMPLE_LINE_OFFSET | GL2PS_NO_BLENDING |
                  GL2PS_OCCLUSION_CULL | GL2PS_BEST_ROOT;

  if (!drawText) options |= GL2PS_NO_TEXT;
  
  if (windowImpl->beginGL()) {
  
    glGetIntegerv(GL_VIEWPORT, viewport);
 
    while( state == GL2PS_OVERFLOW ){ 
      buffsize += 1024*1024;
      gl2psBeginPage ( filename, "Generated by rgl", viewport,
                   formatID, GL2PS_BSP_SORT, options,
                   GL_RGBA, 0, NULL, 0, 0, 0, buffsize,
                   fp, filename );

    
      if ( drawText ) {
        // signal gl2ps for text
        scene->invalidateDisplaylists();
        if (formatID == GL2PS_PS || formatID == GL2PS_EPS || 
            formatID == GL2PS_TEX || formatID == GL2PS_PGF)
      	  renderContext.gl2psActive = GL2PS_POSITIONAL;  
        else
          renderContext.gl2psActive = GL2PS_LEFT_ONLY;
      }
    
      // redraw:
    
      scene->render(&renderContext);
      glFinish();
 
      if ( drawText ) {
        scene->invalidateDisplaylists();
        renderContext.gl2psActive = GL2PS_NONE;   
      }
      success = true;

      state = gl2psEndPage();
    }
  
    windowImpl->endGL();
  }
  setlocale(LC_NUMERIC, oldlocale);
  
  fclose(fp);

  return success;
}

