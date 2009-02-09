#ifndef SHAPE_HPP
#define SHAPE_HPP

#include "SceneNode.hpp"
#include "Material.hpp"
#include "RenderContext.hpp"

#include "opengl.hpp"
#include "geom.hpp"

//
// CLASS
//   Shape
//

class Shape : public SceneNode
{
public:
  Shape(Material& in_material,bool in_ignoreExtent,TypeID in_typeID=SHAPE);
  ~Shape();
  
  /**
   * render shape.
   * Default Implementation: uses z-buffer and a display list 
   * that stores everything from a call to draw().
   **/
  virtual void render(RenderContext* renderContext);

  /**
   * render shape using z value in renderContext
   * Implementation: does call render()
   **/
  virtual void renderZSort(RenderContext* renderContext);

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
   * obtain material
   **/
  const Material& getMaterial() const { return material; }
  
  const bool getIgnoreExtent() const { return ignoreExtent; }

  virtual void getShapeName(char* buffer, int buflen) { strncpy(buffer, "shape", buflen); };
  
  /**
   * invalidate display list
   **/
  void invalidateDisplaylist();
  
  /**
   * access to individual items
   **/
   
  virtual int getElementCount(void) = 0; 
  
  /**
   * location of individual items
   **/
  
  virtual Vertex getElementCenter(int index) { return boundingBox.getCenter(); }

  /**
   * begin sending items 
   **/
  virtual void drawBegin(RenderContext* renderContext);

  /**
   * send one item
   **/
  virtual void drawElement(RenderContext* renderContext, int index) = 0;

  /**
   * end sending items
   **/
  virtual void drawEnd(RenderContext* renderContext);

  const bool isTransparent() const { return transparent; }
  
  const bool isBlended() const { return blended; }
  
protected:
  /**
   * bounding volume of overall geometry
   **/
  AABox    boundingBox;
  
  /*
   * whether this object should be ignored in scene bounding box calculations
   */ 
  bool     ignoreExtent; 
  
  /**
   * material
   **/
  Material material;
private:
  /**
   * display list
   **/
  GLuint   displayList;
  int	   drawLevel;     /* for debugging */
protected:
  /**
   * update indicator
   **/
  bool     doUpdate;
  bool     transparent, blended;
};

class ShapeItem {
public:
  ShapeItem(Shape* in_shape, int in_itemnum) : shape(in_shape), itemnum(in_itemnum) {};
  Shape* shape;
  int itemnum;
};

#endif // SHAPE_HPP
