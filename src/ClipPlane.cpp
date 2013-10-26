#include "ClipPlane.hpp"
#include "Viewpoint.hpp"
#include "R.h"
#include <algorithm>

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   ClipPlaneSet
//

int ClipPlaneSet::num_planes = 0;

ClipPlaneSet::ClipPlaneSet(Material& in_material, int in_nnormal, double* in_normal, int in_noffset, double* in_offset)
 : 
   Shape(in_material,true),
   nPlanes(max(in_nnormal, in_noffset)),
   normal(in_nnormal, in_normal), 
   offset(in_noffset, in_offset)
{
}

int ClipPlaneSet::getAttributeCount(AABox& bbox, AttribID attrib)
{
  switch (attrib) {
    case NORMALS: 
    case OFFSETS: return nPlanes;
  }
  return 0;
}

void ClipPlaneSet::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    if (attrib == NORMALS) {
      while (first < n) {
	*result++ = normal.getRecycled(first).x;
	*result++ = normal.getRecycled(first).y;
	*result++ = normal.getRecycled(first).z;
        first++;
      }
    } else if (attrib == OFFSETS) {
	while (first < n) 
	  *result++ = offset.getRecycled(first++);
    }
  }
}

void ClipPlaneSet::renderBegin(RenderContext* renderContext)
{
  firstPlane = GL_CLIP_PLANE0 + num_planes;
  num_planes += nPlanes;
}

void ClipPlaneSet::drawElement(RenderContext* renderContext, int index)
{
  GLdouble eqn[4];
  eqn[0] = normal.getRecycled(index).x;
  eqn[1] = normal.getRecycled(index).y;
  eqn[2] = normal.getRecycled(index).z;
  eqn[3] = offset.getRecycled(index);
  glClipPlane(firstPlane + index, eqn);
  glEnable(firstPlane + index);
}

void ClipPlaneSet::enable(bool show)
{
  for (int i=0; i<nPlanes; i++) {
    if (show) glEnable(firstPlane + i);
    else      glDisable(firstPlane + i);
  }
}
