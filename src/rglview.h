#ifndef RGLVIEW_H
#define RGLVIEW_H

// C++ header file
// This file is part of RGL
//
// $Id$


#include "scene.h"
#include "gui.h"
#include "fps.h"
#include "select.h"
#include "pixmap.h"

namespace rgl {

class RGLView : public View
{
public:
  RGLView(Scene* scene);
  ~RGLView();
  bool snapshot(PixmapFileFormatID formatID, const char* filename);
  bool pixels(int* ll, int* size, int component, double* result);
  bool postscript(int format, const char* filename, bool drawText);
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

  void        getUserMatrix(double* dest);
  void        setUserMatrix(double* src);
  void        getScale(double* dest);
  void        setScale(double* src);
  const char* getFontFamily() const;
  void        setFontFamily(const char *family);
  int         getFontStyle() const;
  void        setFontStyle(int style);
  double      getFontCex() const;
  void        setFontCex(double cex);
  bool        getFontUseFreeType() const;
  void        setFontUseFreeType(bool useFreeType);
  void	      setDefaultFont(const char *family, int style, double cex, bool useFreeType);
  const char* getFontname() const;
  int         getActiveSubscene() {return activeSubscene;}
  
  /* NB:  these functions do not maintain consistency with userMatrix */
  
  void        getPosition(double* dest);
  void 	      setPosition(double* src);

  void setMouseListeners(Subscene* sub, unsigned int n, int* ids);
  
protected:

  void setWindowImpl(WindowImpl* impl);


private:

//
// DRAG USER-INPUT
//

  int activeSubscene;

// Translate from OS window-relative coordinates (relative to top left corner) to
// OpenGL window relative (relative to bottom left corner)
  void translateCoords(int* mouseX, int* mouseY) const { *mouseY = height - *mouseY; }


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
};

} // namespace rgl

#endif /* RGLVIEW_H */
