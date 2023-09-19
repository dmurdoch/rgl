// C++ source
// This file is part of RGL.
//

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
#include "gl2ps.h"

#include "R.h"		// for Rf_error()

using namespace rgl;

bool rgl::doUseShaders = false;

RGLView::RGLView(Scene* in_scene)
 : View(0,0,256,256,0), autoUpdate(false), useShaders(false)
{
  scene = in_scene;
  flags = 0;

  renderContext.rect.x = 0;
  renderContext.rect.y = 0; // size is set elsewhere
  
  activeSubscene = 0;
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

  if (activeSubscene) {
    Subscene* subscene = scene->getSubscene(activeSubscene);
    if (subscene && subscene->drag)
      captureLost();
  }
}

void RGLView::paint(void) {
  
  double last = renderContext.time;
  double t    = getTime();
  
  double dt   = (last != 0.0f) ? last - t : 0.0f;
  
  renderContext.time = t;
  renderContext.deltaTime = dt;
  
  doUseShaders = useShaders; /* Make useShaders globally visible during painting */
  
  /* This doesn't do any actual plotting, but it calculates matrices etc.,
  and may call user callbacks */
  int saveRedraw = windowImpl->setSkipRedraw(1);
  scene->update(&renderContext);
  windowImpl->setSkipRedraw(saveRedraw);

#ifndef RGL_NO_OPENGL    
  /* This section does the OpenGL plotting */
  if (windowImpl->beginGL()) {
    SAVEGLERROR;  
    Subscene* subscene = scene->getCurrentSubscene();
    scene->render(&renderContext);
    glViewport(0,0, width, height);
    if (subscene) {
      if (flags & FSHOWFPS && subscene->getSelectState() == msNONE)
        fps.render(renderContext.time, &renderContext );
    }
    glFinish();
    windowImpl->endGL();
    
    SAVEGLERROR;
  }
#endif
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
      Subscene* subscene = scene->getCurrentSubscene();
      if (subscene)
        subscene->setSelectState(msABORT);
      break;
  }
}

void RGLView::buttonPress(int button, int mouseX, int mouseY)
{
  ModelViewpoint* modelviewpoint = scene->getCurrentSubscene()->getModelViewpoint();
  if ( modelviewpoint->isInteractive() ) {
    translateCoords(&mouseX, &mouseY);
    Subscene* subscene = scene->whichSubscene(mouseX, mouseY);
    subscene->translateCoords(&mouseX, &mouseY);
    subscene->drag = button;
    activeSubscene = subscene->getObjID();
    windowImpl->captureMouse(this);	  
    subscene->buttonBegin(button ,mouseX, mouseY);
    View::update();
  }
}

void RGLView::buttonRelease(int button, int mouseX, int mouseY)
{
  Subscene* subscene; 
  if (activeSubscene 
        && (subscene = scene->getSubscene(activeSubscene))) {
    windowImpl->releaseMouse();
    subscene->drag = 0;
    subscene->buttonEnd(button);
    View::update();
  }
  // Rprintf("release happened, activeSubscene=0\n");
  activeSubscene = 0;
}

void RGLView::mouseMove(int mouseX, int mouseY)
{
  if (activeSubscene) {
    translateCoords(&mouseX, &mouseY);
    Subscene* subscene = scene->getSubscene(activeSubscene);
    if (!subscene) { 
      buttonRelease(0, mouseX, mouseY);
      return;
    }
    subscene->translateCoords(&mouseX, &mouseY);
    
    int vwidth = subscene->pviewport.width, 
      vheight = subscene->pviewport.height;    	  
    
    mouseX = clamp(mouseX, 0, vwidth-1);
    mouseY = clamp(mouseY, 0, vheight-1);
    if (windowImpl->beginGL()) {
      subscene->buttonUpdate(subscene->drag, mouseX, mouseY);
      windowImpl->endGL();
      
      View::update();
    }
  } else {
    ModelViewpoint* modelviewpoint = scene->getCurrentSubscene()->getModelViewpoint();
    if ( modelviewpoint->isInteractive() ) {
      translateCoords(&mouseX, &mouseY);
      Subscene* subscene = scene->whichSubscene(mouseX, mouseY);
      if (subscene && subscene->getMouseMode(bnNOBUTTON) != mmNONE) {
        subscene->translateCoords(&mouseX, &mouseY);
        subscene->drag = bnNOBUTTON;
        subscene->buttonUpdate(bnNOBUTTON, mouseX, mouseY);
        View::update();
      }
    }
  }
}

void RGLView::wheelRotate(int dir, int mouseX, int mouseY)
{
  Subscene* subscene = NULL;
  ModelViewpoint* modelviewpoint = scene->getCurrentSubscene()->getModelViewpoint();
  if ( modelviewpoint->isInteractive() ) {
    translateCoords(&mouseX, &mouseY);
    subscene = scene->whichSubscene(mouseX, mouseY);
  }
  if (!subscene)
    subscene = scene->getCurrentSubscene(); 
  subscene->wheelRotate(dir);
  View::update();
}

void RGLView::captureLost()
{
  if (activeSubscene) {
    Subscene* subscene = scene->getSubscene(activeSubscene);
    if (subscene) {
      subscene->buttonEnd(subscene->drag);
      subscene->drag = 0;
    }
  }
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
   
    if (snapshot.init(RGB24, width, height, 8)) {
#ifndef RGL_NO_OPENGL      
      paint();
      if ( windowImpl->beginGL() ) {
        // read back buffer

        glPushAttrib(GL_PIXEL_MODE_BIT);

        glReadBuffer(GL_BACK);
        glPixelStorei(GL_PACK_ALIGNMENT, 1);
        glReadPixels(0,0,width,height,GL_RGB, GL_UNSIGNED_BYTE, (GLvoid*) snapshot.data);

        glPopAttrib();
  
        windowImpl->endGL();
      } else
#else
      Rf_warning("this build of rgl does not support snapshots");
#endif
        snapshot.clear();
      
      success = snapshot.save( pixmapFormat[formatID], filename );
      
    } else Rf_error("unable to create pixmap");
    	
  } else Rf_error("pixmap save format not supported in this build");
  return success;
}

bool RGLView::pixels( int* ll, int* size, int component, double* result )
{
  bool success = false;
#ifndef RGL_NO_OPENGL
  GLenum format[] = {GL_RED, GL_GREEN, GL_BLUE, GL_ALPHA, 
                      GL_DEPTH_COMPONENT, GL_LUMINANCE}; 
  paint();
  if ( windowImpl->beginGL() ) {
    /*
     * Some OSX systems appear to have a glReadPixels 
     * bug causing segfaults when reading the depth component.  
     * Read those column by column.
     */
    bool bycolumn = format[component] == GL_DEPTH_COMPONENT;
    int n = bycolumn ? size[1] : size[0]*size[1];
    GLfloat* buffer = (GLfloat*) R_alloc(n, sizeof(GLfloat));
  	
    glEnable(GL_DEPTH_TEST);
    glDepthMask(GL_TRUE);
  
    // read front buffer

    glPushAttrib(GL_PIXEL_MODE_BIT);
 
    glReadBuffer(GL_BACK);
    glPixelStorei(GL_PACK_ALIGNMENT, 1);
    
    if (bycolumn) {
      for(int ix=0; ix<size[0]; ++ix){
        glReadPixels(ix+ll[0],ll[1],1,size[1],format[component], GL_FLOAT, (GLvoid*) buffer);
        for(int iy=0; iy<size[1]; ++iy) {
          result[ix + iy*size[0]] = buffer[iy];
        }
      }	
    } else {	
      glReadPixels(ll[0],ll[1],size[0],size[1],format[component], GL_FLOAT, (GLvoid*) buffer);
      for (int i=0; i<n; i++)
        result[i] = buffer[i];
    }
    glPopAttrib();
    success = true;

    windowImpl->endGL();
  }
#endif
  return success;
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
	Rf_error("font not available");
    renderContext.font = font;
}
  
const char* RGLView::getFontFamily() const 
{
  if (!renderContext.font)
    Rf_error("font not available");
      
  return renderContext.font->family;
}

void RGLView::setFontFamily(const char *family)
{
  setDefaultFont(family, getFontStyle(), getFontCex(), getFontUseFreeType());
}

int RGLView::getFontStyle() const 
{
  if (!renderContext.font)
    Rf_error("font not available");
  return renderContext.font->style;
}

void RGLView::setFontStyle(int style)
{
  setDefaultFont(getFontFamily(), style, getFontCex(), getFontUseFreeType());
}

double RGLView::getFontCex() const 
{
  if (!renderContext.font)
    Rf_error("font not available");
  return renderContext.font->cex;
}

void RGLView::setFontCex(double cex)
{
  setDefaultFont(getFontFamily(), getFontStyle(), cex, getFontUseFreeType());
}

const char* RGLView::getFontname() const 
{
  if (!renderContext.font)
    Rf_error("font not available");
  return renderContext.font->fontname;
}

bool RGLView::getFontUseFreeType() const
{
  if (!renderContext.font)
    Rf_error("font not available");
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

bool RGLView::postscript(int formatID, const char* filename, bool drawText)
{
  bool success = false;
  std::FILE *fp = fopen(filename, "wb"); 
#ifndef RGL_NO_OPENGL
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
#else
  Rf_warning("this build of rgl does not support postscript");
#endif  
  fclose(fp);
  return success;
}

void RGLView::setMouseListeners(Subscene* sub, unsigned int n, int* ids)
{
  sub->clearMouseListeners();
  for (unsigned int i=0; i<n; i++) {
    Subscene* subscene = scene->getSubscene(ids[i]);
    if (subscene)
      sub->addMouseListener(subscene);
  }
}

bool RGLView::setUseShaders(bool in_useShaders)
{
#ifndef RGL_NO_OPENGL
	if (in_useShaders && !GLAD_GL_VERSION_2_1) {
		useShaders = false;
		return false;
	}
#endif
	useShaders = in_useShaders;
	return true;
}
