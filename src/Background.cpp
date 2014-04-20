#include "Background.hpp"
#include "Viewpoint.hpp"
#include "scene.h"
#include "rglmath.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Background
//

Material Background::defaultMaterial( Color(0.3f,0.3f,0.3f), Color(1.0f,0.0f,0.0f) );

Background::Background(Material& in_material, bool in_sphere, int in_fogtype)
: Shape(in_material, true, BACKGROUND), sphere(in_sphere), fogtype(in_fogtype)
{
  clearColorBuffer = true;

  if (sphere) {
    material.colors.recycle(2);
    material.front = Material::CULL_FACE;

    material.colorPerVertex(false);

    if (material.back == Material::FILL_FACE)
      clearColorBuffer = false;

    if ( (material.lit) || ( (material.texture) && (material.texture->is_envmap() ) ) )
      sphereMesh.setGenNormal(true);
    if ( (material.texture) && (!material.texture->is_envmap() ) )
      sphereMesh.setGenTexCoord(true);

    sphereMesh.setGlobe (16,16);

    sphereMesh.setCenter( Vertex(0.0f,0.0f,0.0f) );
    sphereMesh.setRadius( 1.0f );
    sphereMesh.update();
  }
  else
    material.colors.recycle(1);
}

GLbitfield Background::getClearFlags(RenderContext* renderContext)
{
  if (clearColorBuffer) {
    material.colors.getColor(0).useClearColor();
    return GL_COLOR_BUFFER_BIT;
  } else
    return 0;
}

// FIXME:  this doesn't follow the pattern of other render methods.

void Background::render(RenderContext* renderContext)
{
  Subscene* subscene = renderContext->subscene;
  Viewpoint* viewpoint = subscene->getViewpoint();
  
  const AABox& bbox = subscene->getBoundingBox();

  // setup fog
  
  if ((fogtype != FOG_NONE) && (bbox.isValid() )) {
    // Sphere bsphere(bbox);

    glFogfv(GL_FOG_COLOR, material.colors.getColor(0).getFloatPtr() );

    switch(fogtype) {
    case FOG_LINEAR:
      glFogi(GL_FOG_MODE, GL_LINEAR);
      glFogf(GL_FOG_START, viewpoint->frustum.znear /*bsphere.radius*2*/);
      glFogf(GL_FOG_END,   viewpoint->frustum.zfar /*bsphere.radius*3*/ );
      break;
    case FOG_EXP:
      glFogi(GL_FOG_MODE, GL_EXP);
      glFogf(GL_FOG_DENSITY, 1.0f/viewpoint->frustum.zfar /*(bsphere.radius*3)*/ );
      break;
    case FOG_EXP2:
      glFogi(GL_FOG_MODE, GL_EXP2);
      glFogf(GL_FOG_DENSITY, 1.0f/viewpoint->frustum.zfar /*(bsphere.radius*3)*/ );
      break;
    }

    glEnable(GL_FOG);
  } else {
    glDisable(GL_FOG);
  }

  // render bg sphere 
  
  if (sphere) {

    float fov = viewpoint->getFOV();
    float hlen, znear;
    
    if (fov > 0.0) {
      float rad = math::deg2rad(fov/2.0f);

      hlen  = math::sin(rad) * math::cos(math::deg2rad(45.0));
      znear = hlen / math::tan(rad);
    } else {
      hlen = math::cos(math::deg2rad(45.0));
      znear = hlen;
    }
    
    float zfar  = znear + 1.0f;
    float hwidth, hheight;

    float winwidth  = (float) renderContext->rect.width;
    float winheight = (float) renderContext->rect.height;

    // aspect ratio

    if (winwidth >= winheight) {
      hwidth  = hlen;
      hheight = hlen * (winheight / winwidth);
    } else {
      hwidth  = hlen * (winwidth  / winheight);
      hheight = hlen;
    }

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    if (fov != 0.0) {
      glFrustum(-hwidth, hwidth, -hheight, hheight, znear, zfar );
    } else {
      glOrtho(-hwidth, hwidth, -hheight, hheight, znear, zfar );
    }
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glTranslatef(0.0f,0.0f,-znear);

    viewpoint->setupOrientation(renderContext);
    

    Shape::render(renderContext);

  } 
}

void Background::drawElement(RenderContext* renderContext, int index)
{
  glPushAttrib(GL_ENABLE_BIT);

  material.beginUse(renderContext);
  
  material.useColor(1);
 
  glDisable(GL_DEPTH_TEST);
  glDepthMask(GL_FALSE);

  sphereMesh.draw(renderContext);

  material.endUse(renderContext);

  glPopAttrib();
}

int Background::getAttributeCount(AABox& bbox, AttribID attrib) 
{
  switch (attrib) {    
    case FLAGS: return 4;
  }
  return Shape::getAttributeCount(bbox, attrib);
}

void Background::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);

  if (first + count < n) n = first + count;
  if (first < n) {
    switch(attrib) {
    case FLAGS:
      if (first <= 0)  
        *result++ = (double) sphere;
      if (first <= 1)
	*result++ = (double) fogtype == FOG_LINEAR;
      if (first <= 2)
	*result++ = (double) fogtype == FOG_EXP;
      if (first <= 3)
	*result++ = (double) fogtype == FOG_EXP2;
      return;
    }
    Shape::getAttribute(bbox, attrib, first, count, result);
  }
}

