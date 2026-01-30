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
  
  Vertex pt(0., 0., 0.);
  sphereMesh.setCenter( pt );
  sphereMesh.setRadius( 1.0 );
  sphereMesh.update();
  
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
  
#ifndef RGL_NO_OPENGL
  Shape::beginShader(renderContext);
  material.colors.setAttribLocation(glLocs.at("aCol"));
#endif  
}
 

void SphereSet::setSphereMVmatrix(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  Subscene* subscene = renderContext->subscene;
  float mat[16];
  Matrix4x4 MV = subscene->modelMatrix 
  * sphereMesh.MVmodification(renderContext->subscene->getModelViewpoint()->scale) ;
  
  MV.getData(mat);
  
  glUniformMatrix4fv(glLocs.at("mvMatrix"), 1, GL_FALSE, mat);
  
  if (glLocs_has_key("normMatrix")) {
    Matrix4x4 normMatrix = MV.inverse();
    normMatrix.transpose();
    normMatrix.getData(mat);
    glUniformMatrix4fv(glLocs.at("normMatrix"), 1, GL_FALSE, mat);
  }
  
#endif
}

/* A primitive here is a whole sphere */
void SphereSet::drawPrimitive(RenderContext* renderContext, int index) 
{
#ifndef RGL_NO_OPENGL
  Vertex pt;
  BBoxDeco* bboxdeco = 0;
  if (material.marginCoord >= 0) {
    Subscene* subscene = renderContext->subscene;
    bboxdeco = subscene->get_bboxdeco();
  }
  if (fastTransparency) {
    if (bboxdeco) {
      pt = bboxdeco->marginVecToDataVec(center.get(index), renderContext, &material);
    } else
      pt = center.get(index);
    
    if ( pt.missing() || ISNAN(radius.getRecycled(index)) ) return;
    
    material.useColor(index);
    sphereMesh.setCenter( pt );
    sphereMesh.setRadius( radius.getRecycled(index) );
    setSphereMVmatrix(renderContext);
    sphereMesh.draw(renderContext);
  } else {
   int i1 = index / facets, i2 = index % facets;
   bool endcap = i2 < sphereMesh.getSegments() 
   	      || i2 >= facets - sphereMesh.getSegments();
	
   if (i1 != lastdrawn) {
     if (lastdrawn >= 0) {
       sphereMesh.doIndices( );
     }
     if (bboxdeco) {
       invalidateDisplaylist();
       pt = bboxdeco->marginVecToDataVec(center.get(i1), renderContext, &material);
     } else
       pt = center.get(i1);
     if ( pt.missing() || ISNAN(radius.getRecycled(i1)) ) return;

     material.useColor(i1);
     
     sphereMesh.setCenter( pt );
     sphereMesh.setRadius( radius.getRecycled(i1) );
     setSphereMVmatrix(renderContext);
     lastdrawn = i1;
     lastendcap = endcap;
   }
   sphereMesh.drawPrimitive(renderContext, i2);
  }
#endif
}

void SphereSet::drawEnd(RenderContext* renderContext)
{
  if (lastdrawn >= 0) {
    sphereMesh.doIndices();
    sphereMesh.drawEnd( renderContext );
#ifndef RGL_NO_OPENGL
    Shape::endShader();
#endif
  }
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
		
	
int SphereSet::getAttributeCount(SceneNode* subscene, AttribID attrib) 
{
  switch (attrib) {
    case RADII:    return radius.size();
    case VERTICES: return center.size();
    case FLAGS:    return 2;    
  }
  return Shape::getAttributeCount(subscene, attrib);
}

void SphereSet::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
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
    Shape::getAttribute(subscene, attrib, first, count, result);
  }
}

void SphereSet::initialize()
{
#ifndef RGL_NO_OPENGL
  Shape::initialize();
  
  initShader();
  
  sphereMesh.initialize(glLocs, vertexbuffer);
  
  
#endif  
}
