#include "Shape.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Shape
//

Shape::Shape(Material& in_material, bool in_ignoreExtent, TypeID in_typeID)
: SceneNode(in_typeID), ignoreExtent(in_ignoreExtent), material(in_material), 
  displayList(0), doUpdate(true)
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

void Shape::render(RenderContext* renderContext)
{
  if (displayList == 0)
    displayList = glGenLists(1);

  if (doUpdate) {
    update(renderContext);
    glNewList(displayList, GL_COMPILE_AND_EXECUTE);
    draw(renderContext);
    glEndList();
  } else 
    glCallList(displayList);
}


void Shape::renderZSort(RenderContext* renderContext)
{
  render(renderContext);
}

void Shape::invalidateDisplaylist()
{
  doUpdate = true;
}
