#include "SphereSet.hpp"
#include "Viewpoint.hpp"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   SphereSet
//

SphereSet::SphereSet(Material& in_material, int in_ncenter, double* in_center, int in_nradius, double* in_radius,
                     int in_ignoreExtent)
 : Shape(in_material, in_ignoreExtent, SHAPE, true), 
   center(in_ncenter, in_center), 
   radius(in_nradius, in_radius)
{
  material.colorPerVertex(false);

  if (material.lit)
    sphereMesh.setGenNormal(true);
  if ( (material.texture) && (!material.texture->is_envmap() ) )
    sphereMesh.setGenTexCoord(true);

  sphereMesh.setGlobe(16,16);
  
  for (int i=0;i<center.size();i++)
    boundingBox += Sphere( center.get(i), radius.getRecycled(i) );
}

SphereSet::~SphereSet()
{
}

AABox& SphereSet::getBoundingBox(Subscene* subscene)
{
  Vertex scale = subscene->getModelViewpoint()->scale;
  scale.x = 1.0/scale.x;
  scale.y = 1.0/scale.y;
  scale.z = 1.0/scale.z;
  
  boundingBox.invalidate();
  for(int i=0;i<getElementCount();i++) {
    boundingBox += center.get(i) + scale*radius.getRecycled(i);
    boundingBox += center.get(i) - scale*radius.getRecycled(i);
  }
  return boundingBox;
}

void SphereSet::drawBegin(RenderContext* renderContext)
{
  Shape::drawBegin(renderContext);
  material.beginUse(renderContext);
}

void SphereSet::drawElement(RenderContext* renderContext, int index) 
{
   if ( center.get(index).missing() || ISNAN(radius.getRecycled(index)) ) return;

   material.useColor(index);

   sphereMesh.setCenter( center.get(index) );
   sphereMesh.setRadius( radius.getRecycled(index) );
   
   sphereMesh.update( renderContext->subscene->getModelViewpoint()->scale );

   sphereMesh.draw(renderContext);
}

void SphereSet::drawEnd(RenderContext* renderContext)
{
  material.endUse(renderContext);
  Shape::drawEnd(renderContext);  
}

void SphereSet::render(RenderContext* renderContext) 
{
  if (renderContext->subscene->getModelViewpoint()->scaleChanged) 
    doUpdate = true;
  Shape::render(renderContext);
}

int SphereSet::getAttributeCount(AABox& bbox, AttribID attrib) 
{
  switch (attrib) {
    case RADII:    return radius.size();
    case VERTICES: return center.size();
  }
  return Shape::getAttributeCount(bbox, attrib);
}

void SphereSet::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    switch (attrib) {
      case VERTICES:
        while (first < n) {
          *result++ = center.get(first).x;
          *result++ = center.get(first).y;
          *result++ = center.get(first).z;
          first++;
        }
        return;
      case RADII:
        while (first < n) 
          *result++ = radius.get(first++);
        return;
    }  
    Shape::getAttribute(bbox, attrib, first, count, result);
  }
}

