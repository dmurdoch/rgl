#include "SphereSet.hpp"
#include "Viewpoint.hpp"
#include "R.h"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   SphereSet
//

SphereSet::SphereSet(Material& in_material, int in_ncenter, double* in_center, int in_nradius, double* in_radius,
                     int in_ignoreExtent)
 : Shape(in_material, in_ignoreExtent), 
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
   
   sphereMesh.update( renderContext->viewpoint->scale );

   sphereMesh.draw(renderContext);
}

void SphereSet::drawEnd(RenderContext* renderContext)
{
  material.endUse(renderContext);
  Shape::drawEnd(renderContext);  
}

void SphereSet::render(RenderContext* renderContext) {
  if (renderContext->viewpoint->scaleChanged) 
    doUpdate = true;
  Shape::render(renderContext);
}
