#include "SphereSet.h"
#include "Viewpoint.h"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   SphereSet
//

SphereSet::SphereSet(Material& in_material, int in_ncenter, double* in_center, int in_nradius, double* in_radius,
                     int in_ignoreExtent, bool in_fastTransparency)
 : Shape(in_material, in_ignoreExtent, SHAPE, true), 
   center(in_ncenter, in_center), 
   radius(in_nradius, in_radius),
   lastdrawn(-1),
   lastendcap(true),
   fastTransparency(in_fastTransparency)
{
  material.colorPerVertex(false);

  if (material.lit)
    sphereMesh.setGenNormal(true);
  if ( (material.texture) && (!material.texture->is_envmap() ) )
    sphereMesh.setGenTexCoord(true);

  sphereMesh.setGlobe(16,16);
  
  for (int i=0;i<center.size();i++)
    boundingBox += Sphere( center.get(i), radius.getRecycled(i) );
  
  facets = sphereMesh.getPrimitiveCount();
}

SphereSet::~SphereSet()
{
}

AABox& SphereSet::getBoundingBox(Subscene* subscene)
{
  Vertex scale = subscene->getModelViewpoint()->scale;
  scale.x = 1.0f/scale.x;
  scale.y = 1.0f/scale.y;
  scale.z = 1.0f/scale.z;
  
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
  lastdrawn = -1;
}

void SphereSet::drawPrimitive(RenderContext* renderContext, int index) 
{
  Vertex pt;
  BBoxDeco* bboxdeco = 0;
  if (material.marginCoord >= 0) {
    Subscene* subscene = renderContext->subscene;
    bboxdeco = subscene->get_bboxdeco();
  }
  if (fastTransparency) {
    if (bboxdeco) {
      invalidateDisplaylist();
      pt = bboxdeco->marginVecToDataVec(center.get(index), renderContext, &material);
    } else
      pt = center.get(index);
    
    if ( pt.missing() || ISNAN(radius.getRecycled(index)) ) return;
    
    material.useColor(index);
    sphereMesh.setCenter( pt );
    sphereMesh.setRadius( radius.getRecycled(index) );
    sphereMesh.update( renderContext->subscene->getModelViewpoint()->scale );
    sphereMesh.draw(renderContext);
    
  } else {
   int i1 = index / facets, i2 = index % facets;
   bool endcap = i2 < sphereMesh.getSegments() 
   	      || i2 >= facets - sphereMesh.getSegments();
	
   if (i1 != lastdrawn) {
     if (bboxdeco) {
       invalidateDisplaylist();
       pt = bboxdeco->marginVecToDataVec(center.get(i1), renderContext, &material);
     } else
       pt = center.get(index);
     if ( pt.missing() || ISNAN(radius.getRecycled(i1)) ) return;

     material.useColor(i1);
     if (lastdrawn >= 0)
       sphereMesh.drawEnd( renderContext );
     
     sphereMesh.setCenter( pt );
     sphereMesh.setRadius( radius.getRecycled(i1) );
   
     sphereMesh.update( renderContext->subscene->getModelViewpoint()->scale );
     sphereMesh.drawBegin( renderContext, endcap);
     lastdrawn = i1;
     lastendcap = endcap;
   } else if (endcap != lastendcap) {
     sphereMesh.drawEnd( renderContext );
     sphereMesh.drawBegin( renderContext, endcap);
     lastendcap = endcap;
   }
   sphereMesh.drawPrimitive(renderContext, i2);
  }
}

void SphereSet::drawEnd(RenderContext* renderContext)
{
  if (lastdrawn >= 0)
    sphereMesh.drawEnd( renderContext );
  lastdrawn = -1;
  material.endUse(renderContext);
  Shape::drawEnd(renderContext);  
}

void SphereSet::render(RenderContext* renderContext) 
{
  if (renderContext->subscene->getModelViewpoint()->scaleChanged) 
    doUpdate = true;
  Shape::render(renderContext);
}

int SphereSet::getPrimitiveCount()
{
  return (fastTransparency ? 1 : facets) * getElementCount();
}

Vertex SphereSet::getPrimitiveCenter(int index)
{
  if (fastTransparency) {
    return center.get(index);
  } else {
    int i1 = index / facets, i2 = index % facets;
    if (i1 != lastdrawn) {
      if ( center.get(i1).missing() || ISNAN(radius.getRecycled(i1)) ) return center.get(i1);
      sphereMesh.setCenter( center.get(i1) );
      sphereMesh.setRadius( radius.getRecycled(i1) );
      sphereMesh.update();
      
      lastdrawn = i1;
    }
    return sphereMesh.getPrimitiveCenter(i2);
  }
}
		
	
int SphereSet::getAttributeCount(AABox& bbox, AttribID attrib) 
{
  switch (attrib) {
    case RADII:    return radius.size();
    case VERTICES: return center.size();
    case FLAGS:    return 2;    
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
      case FLAGS:
        if (first == 0) *result++ = ignoreExtent;
        *result++ = (double) fastTransparency;
        return;
    }  
    Shape::getAttribute(bbox, attrib, first, count, result);
  }
}

