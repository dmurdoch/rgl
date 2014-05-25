
#include <algorithm>
#include <functional>

#include "Shape.hpp"
#include "SceneNode.hpp"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Shape
//

Shape::Shape(Material& in_material, bool in_ignoreExtent, TypeID in_typeID, bool in_bboxChanges)
: SceneNode(in_typeID), bboxChanges(in_bboxChanges), ignoreExtent(in_ignoreExtent), material(in_material), 
  displayList(0), drawLevel(0), doUpdate(true), transparent(in_material.isTransparent()),
  blended(in_material.isTransparent())
  
{
}

Shape::~Shape()
{
  if (displayList)
    glDeleteLists(displayList, 1);
}

void Shape::update(RenderContext* renderContext)
{
  doUpdate = false;
}

void Shape::draw(RenderContext* renderContext)
{ 
  drawBegin(renderContext);
  SAVEGLERROR;
  
  for(int i=0;i<getElementCount();i++) 
    drawElement(renderContext, i);
    
  SAVEGLERROR;  
  drawEnd(renderContext);
  SAVEGLERROR;
}

void Shape::render(RenderContext* renderContext)
{
  renderBegin(renderContext);
  
  if (displayList == 0)
    displayList = glGenLists(1);
    
  SAVEGLERROR;
  if (doUpdate) {
    update(renderContext);
    SAVEGLERROR;
    glNewList(displayList, GL_COMPILE_AND_EXECUTE);
    SAVEGLERROR;
    draw(renderContext);
    SAVEGLERROR;
    glEndList();
    SAVEGLERROR;
  } else {
    glCallList(displayList);
    SAVEGLERROR;
  }  
}

void Shape::invalidateDisplaylist()
{
  doUpdate = true;
}

void Shape::drawBegin(RenderContext* renderContext)
{
  if (drawLevel) {
    drawLevel = 0;
    error("Internal error:  nested Shape::drawBegin");
  }
  drawLevel++;
}

void Shape::drawEnd(RenderContext* renderContext)
{
  if (drawLevel != 1) {
    drawLevel = 0;
    error("Internal error: Shape::drawEnd without drawBegin");
  }
  drawLevel--;
}

int Shape::getAttributeCount(AABox& bbox, AttribID attrib)
{
  switch (attrib) { 
    case COLORS:  return material.colors.getLength();
    case CENTERS: return getElementCount();
    case FLAGS:   return 1;
  }
  return 0;
}

void Shape::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    switch (attrib) {
      case COLORS:
        while (first < n) {
          Color color = material.colors.getColor(first);
          *result++ = color.data[0];
          *result++ = color.data[1];
          *result++ = color.data[2];
          *result++ = color.data[3];
          first++;
        }
        return;
      case CENTERS:
        while (first < n) {
          Vertex center = getElementCenter(first);
          *result++ = center.x;
          *result++ = center.y;
          *result++ = center.z;
          first++;
        }
        return;
      case FLAGS:
        if (first == 0) *result++ = (double)ignoreExtent;
        return;
    }
  }
}

Shape* rgl::get_shape_from_list(std::vector<Shape*> shapes, int id, bool recursive)
{
  std::vector<Shape*>::iterator ishape;

  if (shapes.empty()) 
    return NULL;
  
  ishape = std::find_if(shapes.begin(), shapes.end(), 
                        std::bind2nd(std::ptr_fun(&sameID), id));
  if (ishape != shapes.end()) return *ishape;
  
  if (recursive) 
    for (std::vector<Shape*>::iterator i = shapes.begin(); i != shapes.end() ; ++ i ) {
      Shape* shape = (*i)->get_shape(id);
      if (shape) return shape;
    }
  return NULL;
}
