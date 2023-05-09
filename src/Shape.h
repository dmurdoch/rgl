#ifndef SHAPE_H
#define SHAPE_H

#include <vector>
#include <unordered_map>

#include "SceneNode.h"
#include "Material.h"
#include "RenderContext.h"

#include "opengl.h"
#include "geom.h"

namespace rgl {

//
// CLASS
//   Shape
//

class Shape : public SceneNode
{
public:
  Shape(Material& in_material,bool in_ignoreExtent, TypeID in_typeID=SHAPE, bool in_bboxChanges=false);
  ~Shape();
  
  /**
   * render shape.
   * Default Implementation: uses z-buffer and a display list 
   * that stores everything from a call to draw().  
   **/
  virtual void render(RenderContext* renderContext);

  /**
   * request update of node due to content change. 
   * This will result in a new 'recording' of the display list.
   **/
  virtual void update(RenderContext* renderContext);

  /**
   * draw. 
   **/
  virtual void draw(RenderContext* renderContext);

  /**
   * obtain bounding box
   **/
  const AABox& getBoundingBox() const { return boundingBox; }
  
  /**
   * does this shape change dimensions according to the way it is rendered?
   * if so, the above is just a guess...
   **/
  const bool getBBoxChanges() const { return bboxChanges; }

  /**
   * this shows how the shape would be sized in the given context
   **/
  virtual AABox& getBoundingBox(Subscene* subscene) { return boundingBox; }
  
  /**
   * obtain material
   **/
  Material* getMaterial()  { return &material; }
  
  const bool getIgnoreExtent() const { return ignoreExtent; }

  virtual std::string getTypeName() { return "shape"; };
  
  /**
   * invalidate display list
   **/
  void invalidateDisplaylist();
  
  /**
   * access to individual items
   **/
   
  virtual int getElementCount(void) = 0; 
  
  /**
   * access to primitives (e.g. facets of sphere)
   **/
  virtual int getPrimitiveCount(void) { return getElementCount(); } 

  /* overrides */
  int getAttributeCount(SceneNode* subscene, AttribID attrib);
  void getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result);
  
  /**
   * location of individual parts
   **/
  
  virtual Vertex getPrimitiveCenter(int index) { return boundingBox.getCenter(); }

  /**
   * Starting to render the shape.  After this, the renderContext won't change until
   * the next call.  This will only be called once per rendering.
   **/
  virtual void renderBegin(RenderContext* renderContext) { };

  /**
   * begin sending items.  This may be called multiple times, e.g. if the
   * items are being intermixed with items from other shapes
   **/
  virtual void drawBegin(RenderContext* renderContext);

  /**
   * send one item
   **/
  virtual void drawPrimitive(RenderContext* renderContext, int index) = 0;

  /**
   * end sending items
   **/
  virtual void drawEnd(RenderContext* renderContext);
  
  /**
   * Some shapes (currently just sprites) contain others.  Do a recursive search
   */
  virtual Shape* get_shape(int id) { return NULL; }
  
  const bool isTransparent() const { return transparent; }
  
  const bool isBlended() const { return blended; }
  
  /**
   * Does this shape need to go at the head of the shape list, rather than the tail?
   * (e.g. clip planes need to come first 
   **/
  
  virtual bool isClipPlane() { return false; }

  /* call this first to set the context where the next functions
   * need to operate
   */
  
  void setShapeContext(Subscene* in_subscene, int in_nclipplanes,
                       int in_nlights);
  /**
   * The methods below have similar names and uses as 
   * Javascript methods in shaders.src.js.  Make sure changes
   * happen in both places!
   */

  ShaderFlags getShaderFlags();
  
  std::string getShaderDefines(ShaderFlags flags);
  
  virtual void initialize();

protected:
  /**
   * bounding volume of overall geometry
   **/
  AABox    boundingBox;
  
  /**
   * bounding volume changes depending on the scene?
   **/
  bool     bboxChanges;
  
  /*
   * whether this object should be ignored in scene bounding box calculations
   */ 
  bool     ignoreExtent; 
  
  /**
   * material
   **/
  Material material;
  
  Subscene* subscene;
  int nclipplanes;
  int nlights;
  
private:
#ifndef RGL_NO_OPENGL  
  /**
   * display list
   **/
  GLuint   displayList;

#endif	

  int	   drawLevel;     /* for debugging */

protected:
  /**
   * update indicator
   **/
  bool     doUpdate;
  bool     transparent, blended;
#ifndef RGL_NO_OPENGL
  std::unordered_map<std::string, GLint> glLocs;
  bool     glLocs_has_key(std::string key);
#endif
};

class ShapeItem {
public:
  ShapeItem(Shape* in_shape, int in_itemnum) : shape(in_shape), itemnum(in_itemnum) {};
  Shape* shape;
  int itemnum;
};

} // namespace rgl

#endif // SHAPE_H
