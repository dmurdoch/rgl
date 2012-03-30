#include <map>
#include "Shape.hpp"
#include "R.h"

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
    }
  }
}
