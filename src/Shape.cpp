
#include <algorithm>
#include <functional>

#include "Shape.h"
#include "SceneNode.h"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Shape
//

Shape::Shape(Material& in_material, bool in_ignoreExtent, TypeID in_typeID, bool in_bboxChanges)
: SceneNode(in_typeID), bboxChanges(in_bboxChanges), ignoreExtent(in_ignoreExtent), material(in_material),
#ifndef RGL_NO_OPENGL  
  displayList(0), 
#endif
  drawLevel(0), doUpdate(true), transparent(in_material.isTransparent()),
  blended(in_material.isTransparent())
  
{
}

Shape::~Shape()
{
#ifndef RGL_NO_OPENGL
  if (displayList)
    glDeleteLists(displayList, 1);
#endif
}

void Shape::update(RenderContext* renderContext)
{
  doUpdate = false;
}

void Shape::draw(RenderContext* renderContext)
{ 
  drawBegin(renderContext);
  SAVEGLERROR;
  
  for(int i=0;i<getPrimitiveCount();i++) 
    drawPrimitive(renderContext, i);
    
  SAVEGLERROR;  
  drawEnd(renderContext);
  SAVEGLERROR;
}

void Shape::render(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
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
#endif
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

int Shape::getAttributeCount(SceneNode* subscene, AttribID attrib)
{
  switch (attrib) { 
    case COLORS:  return material.colors.getLength();
    case CENTERS: return getPrimitiveCount();
    case FLAGS:   return 1;
  }
  return 0;
}

void Shape::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
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
          Vertex center = getPrimitiveCenter(first);
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

ShaderFlags Shape::getDefFlags()
{
	ShaderFlags result = {
	  .fat_lines = false,
	  .fixed_quads = false,
	  .fixed_size = false,
	  .has_fog = false,
	  .has_normals = false,
	  .has_texture = false,
	  .is_brush = false,
	  .is_lines = false,
	  .is_lit = false,
	  .is_points = false,
	  .is_transparent = false,
	  .is_twosided = false,
	  .needs_vnormal = false,
	  .rotating = false,
	  .round_points = false
  };

	result.is_lines = 
		
	result.fat_lines = 	material.lwd != 1.0 && 
		                  (result.is_lines ||
		                   material.front == Material::LINE_FACE ||
		                   material.back == Material::LINE_FACE);
	return result;
}