#include <map>
#include "Shape.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Shape
//

Shape::Shape(Material& in_material, bool in_ignoreExtent, TypeID in_typeID)
: SceneNode(in_typeID), ignoreExtent(in_ignoreExtent), material(in_material), 
  displayList(0), doUpdate(true), transparent(in_material.isTransparent()),
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
  
  for(int i=0;i<getElementCount();i++) 
    drawElement(renderContext, i);
    
  drawEnd(renderContext);
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
  std::multimap<float,int> distanceMap;

  for(int index=0;index<getElementCount();index++) {
    float distance = renderContext->getDistance( getElementCenter(index) );
    distanceMap.insert( std::pair<const float,int>( -distance , index ) );
  }
  std::multimap<float,int>::iterator iter;

  drawBegin(renderContext);

  for (iter = distanceMap.begin() ; iter != distanceMap.end() ; ++iter ) {
    int index = iter->second;
    drawElement(renderContext, index);
  } 

  drawEnd(renderContext);
}

void Shape::invalidateDisplaylist()
{
  doUpdate = true;
}
