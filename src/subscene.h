#ifndef SUBSCENE_H
#define SUBSCENE_H

#include "Shape.h"
#include "ClipPlane.h"
#include "Viewpoint.h"
#include "Background.h"
#include "BBoxDeco.h"
#include "Light.h"
#include <map>


namespace rgl {

enum Embedding { EMBED_INHERIT=1, EMBED_MODIFY, EMBED_REPLACE };
enum Embedded  { EM_VIEWPORT = 0, EM_PROJECTION, EM_MODEL, EM_MOUSEHANDLERS};

enum MouseModeID {mmNONE = 0, mmTRACKBALL, mmXAXIS, mmYAXIS, mmZAXIS, mmPOLAR, 
                  mmSELECTING, mmZOOM, mmFOV, mmUSER};

enum MouseSelectionID {msNONE=1, msCHANGING, msDONE, msABORT};

enum WheelModeID {wmNONE = 0, wmPUSH, wmPULL, wmUSER};

typedef void (*userControlPtr)(void *userData, int mouseX, int mouseY);
typedef void (*userControlEndPtr)(void *userData);
typedef void (*userCleanupPtr)(void **userData);
typedef void (*userWheelPtr)(void *userData, int dir);

typedef void (Subscene::*viewControlPtr)(int mouseX,int mouseY);
typedef void (Subscene::*viewControlEndPtr)();
typedef void (Subscene::*viewWheelPtr)(int dir);

class Subscene : public SceneNode {
  /* Subscenes do their own projection.  They can inherit, modify or replace the
     viewport, projection and model matrices.  The root viewport always replaces them,
     since it doesn't have anything to inherit.
  */
private:

  void setupViewport(RenderContext* rctx);
  void setupProjMatrix(RenderContext* rctx, const Sphere& viewSphere);
  void setupModelMatrix(RenderContext* rctx, Vertex center);
  void setupModelViewMatrix(RenderContext* rctx, Vertex center);
  void setDefaultMouseMode();
  
  void disableLights(RenderContext* rctx);
  void setupLights(RenderContext* rctx);
  
  void newEmbedding();

  /* These lists contain pointers to lights and shapes, but don't actually manage them:  the Scene does that. */
  std::vector<Light*> lights;
  std::vector<Shape*> shapes;
  std::vector<Shape*> unsortedShapes;
  std::vector<Shape*> zsortShapes;
  std::vector<ClipPlaneSet*> clipPlanes;  

  /* Subscenes form a tree; this is the parent subscene.  The root has a NULL parent. */
  Subscene* parent;
  /* Here are the children */
  std::vector<Subscene*> subscenes;
  
  UserViewpoint* userviewpoint;
  ModelViewpoint* modelviewpoint;
  /**
   * bounded background
   **/
  Background* background;
  /**
   * bounded decorator
   **/
  BBoxDeco*  bboxdeco;  
  
  /** 
   * How is this subscene embedded in its parent?
   **/
  Embedding do_viewport, do_projection, do_model, do_mouseHandlers;
  
  /**
   * This viewport on the (0,0) to (1,1) scale
   **/
  Rect2d viewport;
public:
  Subscene(Embedding in_viewport, Embedding in_projection, Embedding in_model,
           Embedding in_mouseHandlers, bool in_ignoreExtent);
  virtual ~Subscene( );

  bool add(SceneNode* node);
  void addBackground(Background* newbackground);
  void addBBoxDeco(BBoxDeco* bboxdeco);
  void addShape(Shape* shape);
  void addLight(Light* light);
  void addSubscene(Subscene* subscene);
  void addBBox(const AABox& bbox, bool changes);
  void intersectClipplanes(void);
  
  /**
   * hide shape or light or bboxdeco
   **/
   
  void hideShape(int id);
  void hideLight(int id);
  void hideBBoxDeco(int id);
  void hideBackground(int id);
  Subscene* hideSubscene(int id, Subscene* current);
  void hideViewpoint(int id);

  /**
   * recursive search for subscene; could return self, or NULL if not found
   **/
  Subscene* getSubscene(int id);
  Subscene* whichSubscene(int id); /* which subscene holds this */
  Subscene* whichSubscene(int mouseX, int mouseY); /* coordinates are pixels within the window */
  
  /**
   * get parent, or NULL for the root
   **/  
  Subscene* getParent() const { return parent; }

  /**
   * get children
   **/
  int getChildCount() const { return subscenes.size(); }
  Subscene* getChild(int which) const { return subscenes[which]; }
  
  /**
   * obtain bounding box
   **/
  const AABox& getBoundingBox() const { return data_bbox; }
    
  /**
   * get the bbox
   */
  BBoxDeco* get_bboxdeco();
  
   /**
   * get a bbox
   */
  BBoxDeco* get_bboxdeco(int id);
  
  /**
   * get the background
   */
  Background* get_background() const { return background; }
  
  /** 
   * get a background
   */
  Background* get_background(int id);
  
  /**
   * obtain subscene's axis-aligned bounding box. 
   **/
  const AABox& getBoundingBox();

 /**
   * get information about stacks
   */
  int get_id_count(TypeID type, bool recursive);
  int get_ids(TypeID type, int* ids, char** types, bool recursive);

  virtual int getAttributeCount(AABox& bbox, AttribID attrib);
  
  virtual void getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result);
  virtual String getTextAttribute(AABox& bbox, AttribID attrib, int index);

  /* Update matrices etc. in preparation for rendering */
  void update(RenderContext* renderContext);
  
  /* Do the OpenGL rendering */
  void render(RenderContext* renderContext, bool opaquePass);

  void renderClipplanes(RenderContext* renderContext);
  void disableClipplanes(RenderContext* renderContext);
  
  void renderUnsorted(RenderContext* renderContext);
  void renderZsort(RenderContext* renderContext);
  
  /**
   * Get and set flag to ignore elements in bounding box
   **/
  
  int getIgnoreExtent(void) const { return (int) ignoreExtent; }
  void setIgnoreExtent(int in_ignoreExtent);
  
  void setEmbedding(int which, Embedding value);  /* which is 0=viewport, 1=projection, 2=model */
  Embedding getEmbedding(Embedded which);
  Subscene* getMaster(Embedded which);
  
  void setUserMatrix(double* src);
  void setUserProjection(double* src);
  void setScale(double* src);
  void setViewport(double x, double y, double width, double height); /* Sets relative (i.e. [0,1]x[0,1]) viewport size */
  void setPosition(double* src);
  
  void getUserMatrix(double* dest);
  void getUserProjection(double* dest);
  void getScale(double* dest);
  void getPosition(double* dest);
  
  double* getMousePosition();
  void clearMouseListeners();
  void addMouseListener(Subscene* sub);
  void deleteMouseListener(Subscene* sub);
  void getMouseListeners(unsigned int max, int* ids);
  
  float getDistance(const Vertex& v) const;

// Translate from OpenGL window-relative coordinates (relative to bottom left corner of window) to
// viewport relative (relative to bottom left corner of viewport)
  void translateCoords(int* mouseX, int* mouseY) const { *mouseX = *mouseX - pviewport.x; *mouseY = *mouseY - pviewport.y; }
  
  
  UserViewpoint* getUserViewpoint();
  ModelViewpoint* getModelViewpoint();

  virtual void getTypeName(char* buffer, int buflen) { strncpy(buffer, "subscene", buflen); };
  
  Background* get_background(); 
  
  /* This vector lists other subscenes that will be controlled
     by mouse actions on this one. We need to delete
     those entries if the subscene is deleted!  */
     
  std::vector<Subscene*> mouseListeners;
  
  // These are set after rendering the scene
  Vec4 Zrow;
  Vec4 Wrow;
  Matrix4x4 modelMatrix, projMatrix;
  Rect2 pviewport;  // viewport in pixels
    
  /**
   * mouse support
   */
  void buttonBegin(int which, int mouseX, int mouseY);
  void buttonUpdate(int which, int mouseX, int mouseY);
  void buttonEnd(int which);
  
  void wheelRotate(int dir);
  
  MouseModeID getMouseMode(int button);
  void        setMouseMode(int button, MouseModeID mode);
  WheelModeID getWheelMode();
  void        setWheelMode(WheelModeID mode);

  void        setMouseCallbacks(int button, userControlPtr begin, userControlPtr update, 
                                userControlEndPtr end, userCleanupPtr cleanup, void** user);
  void        getMouseCallbacks(int button, userControlPtr *begin, userControlPtr *update, 
                                userControlEndPtr *end, userCleanupPtr *cleanup, void** user);
  void        setWheelCallback(userWheelPtr wheel, void* user);
  void        getWheelCallback(userWheelPtr *wheel, void** user);
  
  // o DRAG FEATURE: mouseSelection
  int drag;
  double  mousePosition[4];
  
  void mouseSelectionBegin(int mouseX,int mouseY);
  void mouseSelectionUpdate(int mouseX,int mouseY);
  void mouseSelectionEnd();
  
  MouseSelectionID getSelectState();
  void setSelectState(MouseSelectionID state);
  
private:
    
  /**
   * compute bounding-box
   **/
  void calcDataBBox();
  
  /**
   * shrink bounding-box when something has been removed
   **/

  void shrinkBBox();
  
  /**
   * bounding box of subscene
   **/
  AABox data_bbox;
  
  bool ignoreExtent;
  bool bboxChanges;
  
  /**
   * mouse support
   */
  
  viewControlPtr ButtonBeginFunc[3], ButtonUpdateFunc[3];
  viewControlEndPtr ButtonEndFunc[3];
  viewWheelPtr WheelRotateFunc;
  
  viewControlPtr getButtonBeginFunc(int which);
  viewControlPtr getButtonUpdateFunc(int which);
  viewControlEndPtr getButtonEndFunc(int which);
  
  MouseModeID mouseMode[3];
  
  WheelModeID wheelMode;
  
  MouseSelectionID selectState;
  
  void noneBegin(int mouseX, int mouseY) {};
  void noneUpdate(int mouseX, int mouseY)  {};
  void noneEnd() {};
  
  // o DRAG FEATURE: adjustDirection
  
  void polarBegin(int mouseX, int mouseY);
  void polarUpdate(int mouseX, int mouseY);
  void polarEnd();
  
  void trackballBegin(int mouseX, int mouseY);
  void trackballUpdate(int mouseX, int mouseY);
  void trackballEnd();
  
  void oneAxisBegin(int mouseX, int mouseY);
  void oneAxisUpdate(int mouseX, int mouseY);  
  
  void wheelRotateNone(int dir) {};
  void wheelRotatePull(int dir);
  void wheelRotatePush(int dir);
  
  PolarCoord camBase, dragBase, dragCurrent;
  Vertex rotBase, rotCurrent, axis[3];
  
  
  // o DRAG FEATURE: adjustZoom
  
  void adjustZoomBegin(int mouseX, int mouseY);
  void adjustZoomUpdate(int mouseX, int mouseY);
  void adjustZoomEnd();
  
  int zoomBaseY;
  
  // o DRAG FEATURE: adjustFOV (field of view)
  
  void adjustFOVBegin(int mouseX, int mouseY);
  void adjustFOVUpdate(int mouseX, int mouseY);
  void adjustFOVEnd();
  
  int fovBaseY;
  
  // o DRAG FEATURE: user supplied callback
  
  void userBegin(int mouseX, int mouseY);
  void userUpdate(int mouseX, int mouseY);
  void userEnd();

  bool busy;
  int activeButton;
  
  void* wheelData;
  userWheelPtr wheelCallback;
  
  void userWheel(int dir);
  
  void* userData[9];
  userControlPtr beginCallback[3], updateCallback[3];
  userControlEndPtr endCallback[3];
  userCleanupPtr cleanupCallback[3];
  
};

} // namespace rgl

#endif // SUBSCENE_H
