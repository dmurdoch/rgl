// C++ source
// This file is part of RGL.
//
// $Id$



#ifdef __sun
#include <locale.h>
#else
#include <locale>
#endif
#include <cstdio>
#include "rglview.h"
#include "opengl.h"
#include "lib.h"
#include "rglmath.h"
#include "pixmap.h"
#include "fps.h"
#include "select.h"
#include "gl2ps.h"

#include "R.h"		// for error()

using namespace rgl;

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
  
  for (int i=0; i<3; i++) {
    beginCallback[i] = NULL;
    updateCallback[i] = NULL;
    endCallback[i] = NULL;
    cleanupCallback[i] = NULL;
    for (int j=0; j<3; j++) 
      userData[3*i + j] = NULL;
  }
}

RGLView::~RGLView()
{
  for (int i=0; i<3; i++) 
    if (cleanupCallback[i]) 
      (*cleanupCallback[i])(userData + 3*i);
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

#if defined HAVE_FREETYPE
  renderContext.font = impl->getFont("sans", 1, 1, true);
#else
  renderContext.font = impl->fonts[0];
#endif
}

Scene* RGLView::getScene() {
  return scene;
}

void RGLView::resize(int in_width, int in_height) {

  View::resize(in_width, in_height);

  renderContext.rect.width = in_width;
  renderContext.rect.height = in_height;
  
  update();

  if (drag) captureLost();
}

void RGLView::paint(void) {

  double last = renderContext.time;
  double t    = getTime();

  double dt   = (last != 0.0f) ? last - t : 0.0f;
  
  renderContext.time = t;
  renderContext.deltaTime = dt;
  
  /* This doesn't do any actual plotting, but it calculates matrices etc. */
  scene->update(&renderContext);

  /* This section does the OpenGL plotting */
  if (windowImpl->beginGL()) {
    SAVEGLERROR;  
    scene->render(&renderContext);
    glViewport(0,0, width, height);
    if (selectState == msCHANGING)
      select.render(mousePosition);
    if (flags & FSHOWFPS && selectState == msNONE)
      fps.render(renderContext.time, &renderContext );

    glFinish();
    windowImpl->endGL();
    
    SAVEGLERROR;
  }
}

//////////////////////////////////////////////////////////////////////////////
//
// user input
//

// NB:  This code has to deal with three conflicting descriptions of pixel locations.
//      The calls to buttonPress, buttonRelease, etc. are given in OS window-relative
//      coordinates, which count mouseX from the left, mouseY down from the top.
//      These are translated into the OpenGL convention which counts Y up from the bottom,
//      or subscene-relative coordinates, up from the bottom of the viewport.
//      We use RGLView::translateCoords to go from OS window-relative to OpenGL window-relative,
//      and Subscene::translateCoords to go from OpenGL window-relative to viewport-relative.

void RGLView::keyPress(int key)
{
  switch(key) {
    case GUI_KeyF1:
      flags ^= FSHOWFPS;
      windowImpl->update();
      break;
    case GUI_KeyESC:
      selectState = msABORT;
      break;
  }
}

void RGLView::buttonPress(int button, int mouseX, int mouseY)
{
    ModelViewpoint* modelviewpoint = scene->getCurrentSubscene()->getModelViewpoint();
      if ( modelviewpoint->isInteractive() ) {
	if (!drag) {
	  translateCoords(&mouseX, &mouseY);
	  Subscene* subscene = scene->whichSubscene(mouseX, mouseY);
	  subscene->translateCoords(&mouseX, &mouseY);
	  drag = button;
	  activeSubscene = subscene->getObjID();
	  vwidth = subscene->pviewport.width;
	  vheight = subscene->pviewport.height;
	  windowImpl->captureMouse(this);	  
	  (this->*ButtonBeginFunc[button-1])(mouseX, mouseY);
	}
      }
}


void RGLView::buttonRelease(int button, int mouseX, int mouseY)
{
  	if (drag == button) {
	    windowImpl->releaseMouse();
	    drag = 0;
	    (this->*ButtonEndFunc[button-1])();
	    activeSubscene = 0;
 	}
}

void RGLView::mouseMove(int mouseX, int mouseY)
{
    if (drag) {
        translateCoords(&mouseX, &mouseY);
    	Subscene* subscene = scene->getSubscene(activeSubscene);
    	if (!subscene) { /* it may have been killed */
    	  buttonRelease(drag, mouseX, mouseY);
    	  return;
    	}
    	subscene->translateCoords(&mouseX, &mouseY);

	vwidth = subscene->pviewport.width; /* These may have changed */
	vheight = subscene->pviewport.height;    	  
    	
  	mouseX = clamp(mouseX, 0, vwidth-1);
  	mouseY = clamp(mouseY, 0, vheight-1);

  	(this->*ButtonUpdateFunc[drag-1])(mouseX,mouseY);
    }
}

void RGLView::wheelRotate(int dir)
{
  (this->*WheelRotateFunc)(dir);
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
//   screen space is the same as in OpenGL, starting 0,0 at left/bottom(!) of viewport
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
    rotBase = screenToVector(vwidth,vheight,mouseX,mouseY);
}

void RGLView::trackballUpdate(int mouseX, int mouseY)
{
    	Subscene* subscene = scene->getSubscene(activeSubscene);
    	if (!subscene) return;

  	rotCurrent = screenToVector(vwidth,vheight,mouseX,mouseY);
	if (windowImpl->beginGL()) {
            for (unsigned int i = 0; i < subscene->mouseListeners.size(); i++) {
                Subscene* sub = scene->getSubscene(subscene->mouseListeners[i]);
                if (sub) {
                    ModelViewpoint* modelviewpoint = sub->getModelViewpoint();
	            modelviewpoint->updateMouseMatrix(rotBase,rotCurrent);
                }
            }
	    windowImpl->endGL();

	    View::update();
	}
}

void RGLView::trackballEnd()
{
    Subscene* subscene = scene->getSubscene(activeSubscene);
    if (!subscene) return;
    for (unsigned int i = 0; i < subscene->mouseListeners.size(); i++) {
        Subscene* sub = scene->getSubscene(subscene->mouseListeners[i]);
        if (sub) {   
            ModelViewpoint* modelviewpoint = sub->getModelViewpoint();
            modelviewpoint->mergeMouseMatrix();
        }
    }
}

void RGLView::oneAxisBegin(int mouseX, int mouseY)
{
	rotBase = screenToVector(vwidth,vheight,mouseX,height/2);
}

void RGLView::oneAxisUpdate(int mouseX, int mouseY)
{
    	Subscene* subscene = scene->getSubscene(activeSubscene);
    	if (!subscene) return;

  	rotCurrent = screenToVector(vwidth,vheight,mouseX,height/2);

	if (windowImpl->beginGL()) {
            for (unsigned int i = 0; i < subscene->mouseListeners.size(); i++) {
                Subscene* sub = scene->getSubscene(subscene->mouseListeners[i]);
                if (sub) {
                    ModelViewpoint* modelviewpoint = sub->getModelViewpoint();
	            modelviewpoint->mouseOneAxis(rotBase,rotCurrent,axis[drag-1]);
                }
            }
	    windowImpl->endGL();

	    View::update();
	}
}

void RGLView::polarBegin(int mouseX, int mouseY)
{
    	Subscene* subscene = scene->getSubscene(activeSubscene);
    	if (!subscene) return;

	ModelViewpoint* modelviewpoint = subscene->getModelViewpoint();

  	camBase = modelviewpoint->getPosition();

	dragBase = screenToPolar(vwidth,vheight,mouseX,mouseY);

}

void RGLView::polarUpdate(int mouseX, int mouseY)
{
  Subscene* subscene = scene->getSubscene(activeSubscene);
  if (!subscene) return;

  dragCurrent = screenToPolar(vwidth,vheight,mouseX,mouseY);

  PolarCoord newpos = camBase - ( dragCurrent - dragBase );

  newpos.phi = clamp( newpos.phi, -90.0f, 90.0f );
  for (unsigned int i = 0; i < subscene->mouseListeners.size(); i++) {
    Subscene* sub = scene->getSubscene(subscene->mouseListeners[i]);
    if (sub) {   
      ModelViewpoint* modelviewpoint = sub->getModelViewpoint();
      modelviewpoint->setPosition( newpos );
    }
  }
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
  Subscene* subscene = scene->getSubscene(activeSubscene);
  if (!subscene) return;

  int dy = mouseY - fovBaseY;

  float py = -((float)dy/(float)vheight) * 180.0f;

  for (unsigned int i = 0; i < subscene->mouseListeners.size(); i++) {
    Subscene* sub = scene->getSubscene(subscene->mouseListeners[i]);
    if (sub) {
      UserViewpoint* userviewpoint = sub->getUserViewpoint();
      userviewpoint->setFOV( userviewpoint->getFOV() + py );
    }
  }

  View::update();

  fovBaseY = mouseY;
}


void RGLView::adjustFOVEnd()
{
}

void RGLView::wheelRotatePull(int dir)
{
  Subscene* subscene = NULL;
  if (activeSubscene) 
    subscene = scene->getSubscene(activeSubscene);
  if (!subscene)
    subscene = scene->getCurrentSubscene();
  for (unsigned int i = 0; i < subscene->mouseListeners.size(); i++) {
    Subscene* sub = scene->getSubscene(subscene->mouseListeners[i]);
    if (sub) {
      UserViewpoint* userviewpoint = sub->getUserViewpoint();
      float zoom = userviewpoint->getZoom();

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
      userviewpoint->setZoom(zoom);
    }
  }
  View::update();
}

void RGLView::wheelRotatePush(int dir)
{
  switch (dir)
  {
    case GUI_WheelForward:
      wheelRotatePull(GUI_WheelBackward);
      break;
    case GUI_WheelBackward:
      wheelRotatePull(GUI_WheelForward);
      break;
  }
}

//////////////////////////////////////////////////////////////////////////////
//
// INTERACTIVE FEATURE
//   user callback
//


void RGLView::userBegin(int mouseX, int mouseY)
{
  int ind = drag - 1;
  activeButton = drag;
  if (beginCallback[ind]) {
    busy = true;
    (*beginCallback[ind])(userData[3*ind+0], mouseX, vheight-mouseY);
    busy = false;
  }
}


void RGLView::userUpdate(int mouseX, int mouseY)
{
  int ind = activeButton - 1;
  if (!busy && updateCallback[ind]) {
    busy = true;
    (*updateCallback[ind])(userData[3*ind+1], mouseX, vheight-mouseY);
    busy = false;
  }
}

void RGLView::userEnd()
{
  int ind = activeButton - 1;
  if (endCallback[ind])
    (*endCallback[ind])(userData[3*ind+2]);
}

void RGLView::userWheel(int dir)
{
  if (wheelCallback)
    (*wheelCallback)(wheelData, dir);
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
  Subscene* subscene = scene->getSubscene(activeSubscene);
  if (!subscene) return;

  int dy = mouseY - zoomBaseY;
  
  for (unsigned int i = 0; i < subscene->mouseListeners.size(); i++) {
    Subscene* sub = scene->getSubscene(subscene->mouseListeners[i]);
    if (sub) {
      UserViewpoint* userviewpoint = sub->getUserViewpoint();

      float zoom = clamp ( userviewpoint->getZoom() * exp(dy*ZOOM_PIXELLOGSTEP), ZOOM_MIN, ZOOM_MAX);
      userviewpoint->setZoom(zoom);
    }
  }
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

  if ( (formatID < PIXMAP_FILEFORMAT_LAST) && (pixmapFormat[formatID])) { 
    // alloc pixmap memory
    Pixmap snapshot;
   
    snapshot.init(RGB24, width, height, 8);    
    if ( windowImpl->beginGL() ) {
        // read front buffer

      glPushAttrib(GL_PIXEL_MODE_BIT);

      glReadBuffer(GL_FRONT);
      glPixelStorei(GL_PACK_ALIGNMENT, 1);
      glReadPixels(0,0,width,height,GL_RGB, GL_UNSIGNED_BYTE, (GLvoid*) snapshot.data);

      glPopAttrib();
  
      windowImpl->endGL();
    } else
      snapshot.clear();
    
    success = snapshot.save( pixmapFormat[formatID], filename );

  } else error("pixmap save format not supported in this build");

  return success;
}

bool RGLView::pixels( int* ll, int* size, int component, float* result )
{
  bool success = false;
  GLenum format[] = {GL_RED, GL_GREEN, GL_BLUE, GL_ALPHA, 
                      GL_DEPTH_COMPONENT, GL_LUMINANCE};   
  if ( windowImpl->beginGL() ) {

    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
  
    // read front buffer

    glPushAttrib(GL_PIXEL_MODE_BIT);
 
    glReadBuffer(GL_FRONT);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    glReadPixels(ll[0],ll[1],size[0],size[1],format[component], GL_FLOAT, (GLvoid*) result);

    glPopAttrib();

    success = true;

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
	    case mmUSER:
 	    	ButtonBeginFunc[index] = &RGLView::userBegin;
	    	ButtonUpdateFunc[index] = &RGLView::userUpdate;
	    	ButtonEndFunc[index] = &RGLView::userEnd;
	    	break;	    	
	}
}

void RGLView::setMouseCallbacks(int button, userControlPtr begin, userControlPtr update, 
                                userControlEndPtr end, userCleanupPtr cleanup, void** user)
{
  if (drag) captureLost();
  int ind = button - 1;
  if (cleanupCallback[ind])
    (*cleanupCallback[ind])(userData + 3*ind);
  beginCallback[ind] = begin;
  updateCallback[ind] = update;
  endCallback[ind] = end;
  cleanupCallback[ind] = cleanup;
  userData[3*ind + 0] = *(user++);
  userData[3*ind + 1] = *(user++);
  userData[3*ind + 2] = *user;
  setMouseMode(button, mmUSER);
}

void RGLView::getMouseCallbacks(int button, userControlPtr *begin, userControlPtr *update, 
                                            userControlEndPtr *end, userCleanupPtr *cleanup, void** user)
{
  int ind = button - 1;
  *begin = beginCallback[ind];
  *update = updateCallback[ind];
  *end = endCallback[ind];
  *cleanup = cleanupCallback[ind];
  *(user++) = userData[3*ind + 0];
  *(user++) = userData[3*ind + 1];
  *(user++) = userData[3*ind + 2];
} 

MouseModeID RGLView::getMouseMode(int button)
{
    return mouseMode[button-1];
}

void RGLView::setWheelMode(WheelModeID mode)
{
  wheelMode = mode;
  switch (mode) {
    case wmPULL:
      WheelRotateFunc = &RGLView::wheelRotatePull;
      break;
    case wmPUSH:
      WheelRotateFunc = &RGLView::wheelRotatePush;
      break;
    case wmUSER:
      WheelRotateFunc = &RGLView::userWheel;
      break;
  }
}

WheelModeID RGLView::getWheelMode()
{
  return wheelMode;
}

void RGLView::setWheelCallback(userWheelPtr wheel, void* user)
{
  wheelCallback = wheel;
  wheelData = user;
  setWheelMode(wmUSER);  
}

void RGLView::getWheelCallback(userWheelPtr *wheel, void** user)
{
  *wheel = wheelCallback;
  *user = wheelData;
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
	if (selectState == msABORT) return;
	
	mousePosition[0] = (float)mouseX/(float)vwidth;
	mousePosition[1] = (float)mouseY/(float)vheight;
	mousePosition[2] = mousePosition[0];
	mousePosition[3] = mousePosition[1];
	selectState = msCHANGING;
}

void RGLView::mouseSelectionUpdate(int mouseX,int mouseY)
{
	mousePosition[2] = (float)mouseX/(float)vwidth;
	mousePosition[3] = (float)mouseY/(float)vheight;
	View::update();
}

void RGLView::mouseSelectionEnd()
{
	if (selectState == msABORT) return;
	
	selectState = msDONE;
	View::update();
}

void RGLView::getUserMatrix(double* dest)
{
  Subscene* subscene = NULL;
  if (activeSubscene) 
    subscene = scene->getSubscene(activeSubscene);
  if (!subscene)
    subscene = scene->getCurrentSubscene();

  ModelViewpoint* modelviewpoint = subscene->getModelViewpoint();

  modelviewpoint->getUserMatrix(dest);
}

void RGLView::setUserMatrix(double* src)
{
  Subscene* subscene = NULL;
  if (activeSubscene) 
    subscene = scene->getSubscene(activeSubscene);
  if (!subscene)
    subscene = scene->getCurrentSubscene();
  subscene->setUserMatrix(src);  	   
  View::update();
}

void RGLView::getScale(double* dest)
{
  Subscene* subscene = NULL;
  if (activeSubscene) 
    subscene = scene->getSubscene(activeSubscene);
  if (!subscene)
    subscene = scene->getCurrentSubscene();
    
  ModelViewpoint* modelviewpoint = subscene->getModelViewpoint();
	
  modelviewpoint->getScale(dest);
}

void RGLView::setScale(double* src)
{
  Subscene* subscene = NULL;
  if (activeSubscene) 
    subscene = scene->getSubscene(activeSubscene);
  if (!subscene)
    subscene = scene->getCurrentSubscene();
    
  subscene->setScale(src);

  View::update();
}

void RGLView::setDefaultFont(const char* family, int style, double cex, bool useFreeType)
{
    GLFont* font = View::windowImpl->getFont(family, style, cex, useFreeType);
    if (!font)
	error("font not available");
    renderContext.font = font;
}
  
const char* RGLView::getFontFamily() const 
{
  if (!renderContext.font)
    error("font not available");
      
  return renderContext.font->family;
}

void RGLView::setFontFamily(const char *family)
{
  setDefaultFont(family, getFontStyle(), getFontCex(), getFontUseFreeType());
}

int RGLView::getFontStyle() const 
{
  if (!renderContext.font)
    error("font not available");
  return renderContext.font->style;
}

void RGLView::setFontStyle(int style)
{
  setDefaultFont(getFontFamily(), style, getFontCex(), getFontUseFreeType());
}

double RGLView::getFontCex() const 
{
  if (!renderContext.font)
    error("font not available");
  return renderContext.font->cex;
}

void RGLView::setFontCex(double cex)
{
  setDefaultFont(getFontFamily(), getFontStyle(), cex, getFontUseFreeType());
}

const char* RGLView::getFontname() const 
{
  if (!renderContext.font)
    error("font not available");
  return renderContext.font->fontname;
}

bool RGLView::getFontUseFreeType() const
{
  if (!renderContext.font)
    error("font not available");
  return renderContext.font->useFreeType;
}

void RGLView::setFontUseFreeType(bool useFreeType)
{
  setDefaultFont(getFontFamily(), getFontStyle(), getFontCex(), useFreeType);
}

void RGLView::getPosition(double* dest)
{    
  Subscene* subscene = NULL;
  if (activeSubscene) 
    subscene = scene->getSubscene(activeSubscene);
  if (!subscene)
    subscene = scene->getCurrentSubscene();
    
  ModelViewpoint* modelviewpoint = subscene->getModelViewpoint();
  modelviewpoint->getPosition(dest);
}

void RGLView::setPosition(double* src)
{
  Subscene* subscene = NULL;
  if (activeSubscene) 
    subscene = scene->getSubscene(activeSubscene);
  if (!subscene)
    subscene = scene->getCurrentSubscene();
    
  ModelViewpoint* modelviewpoint = subscene->getModelViewpoint();

  modelviewpoint->setPosition(src);
}


void RGLView::setDefaultMouseFunc()
{
    setMouseMode(1, mmPOLAR);
    setMouseMode(2, mmFOV);
    setMouseMode(3, mmZOOM);
    setWheelMode(wmPULL);
}

bool RGLView::postscript(int formatID, const char* filename, bool drawText)
{
  bool success = false;

  std::FILE *fp = fopen(filename, "wb");  
  char *oldlocale = setlocale(LC_NUMERIC, "C");
  
  GLint buffsize = 0, state = GL2PS_OVERFLOW;
  GLint vp[4];
  GLint options = GL2PS_SILENT | GL2PS_SIMPLE_LINE_OFFSET | GL2PS_NO_BLENDING |
                  GL2PS_OCCLUSION_CULL | GL2PS_BEST_ROOT;

  if (!drawText) options |= GL2PS_NO_TEXT;
  
  if (windowImpl->beginGL()) {
  
    glGetIntegerv(GL_VIEWPORT, vp);
 
    while( state == GL2PS_OVERFLOW ){ 
      buffsize += 1024*1024;
      gl2psBeginPage ( filename, "Generated by rgl", vp,
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
