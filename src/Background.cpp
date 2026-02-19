#include "Background.h"
#include "Viewpoint.h"
#include "scene.h"
#include "rglmath.h"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Background
//

Material Background::defaultMaterial( Color(0.3f,0.3f,0.3f), Color(1.0f,0.0f,0.0f) );

Background::Background(Material& in_material, bool in_sphere, int in_fogtype,
                       float in_fogScale)
: Shape(in_material, true, BACKGROUND), sphere(in_sphere), fogtype(in_fogtype),
  fogScale(in_fogScale), quad(NULL)
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
    
    material.depth_mask = false;
    material.depth_test = false;

    sphereMesh.setGlobe (16,16);

    sphereMesh.setCenter( Vertex(0.0f,0.0f,0.0f) );
    sphereMesh.setRadius( 1.0f );
    sphereMesh.update();
  }
  else if (material.texture) {
    double vertices[12] = { -1, -1, 1,
                             1, -1, 1,
                             1,  1, 1,
                            -1,  1, 1 };
    double texcoords[8] = { 0, 0, 
                            1, 0,
                            1, 1,
                            0, 1 };
    material.colorPerVertex(false);
    material.colors.recycle(1);
    quad = new QuadSet(material, 4, vertices, NULL, texcoords, true, 0, NULL, 0, 1);
    quad->owner = this;
  } else
    material.colors.recycle(1);    
}

Background::~Background()
{
  if (quad) {
    quad->owner = NULL;
    quad = NULL;
  }
}	

GLbitfield Background::getClearFlags(RenderContext* renderContext)
{
  if (clearColorBuffer) {
    material.colors.getColor(0).useClearColor();
    return GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT;
  } else
    return GL_DEPTH_BUFFER_BIT;
}

// FIXME:  this doesn't follow the pattern of other render methods.

void Background::render(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  Subscene* subscene = renderContext->subscene;
  UserViewpoint* userviewpoint = subscene->getUserViewpoint();
  
  const AABox& bbox = subscene->getBoundingBox();

  // setup fog
  
  if ((fogtype != FOG_NONE) && (bbox.isValid() )) {
    // Sphere bsphere(bbox);
    glFogfv(GL_FOG_COLOR, material.colors.getColor(0).getFloatPtr() );

    switch(fogtype) {
    case FOG_LINEAR:
      glFogi(GL_FOG_MODE, GL_LINEAR);
      glFogf(GL_FOG_START, userviewpoint->frustum.znear /*bsphere.radius*2*/);
      // glFogf(GL_FOG_END,   userviewpoint->frustum.zfar /*bsphere.radius*3*/ );
      // Scale fog density up by fogScale
      glFogf(GL_FOG_END, (userviewpoint->frustum.zfar - userviewpoint->frustum.znear)/fogScale + 
                          userviewpoint->frustum.znear);
      break;
    case FOG_EXP:
      glFogi(GL_FOG_MODE, GL_EXP);
      // glFogf(GL_FOG_DENSITY, 1.0f/userviewpoint->frustum.zfar /*(bsphere.radius*3)*/ );
      // Multiply fog density parameter by fogScale
      glFogf(GL_FOG_DENSITY, fogScale*1.0f/userviewpoint->frustum.zfar /*(bsphere.radius*3)*/ );
      break;
    case FOG_EXP2:
      glFogi(GL_FOG_MODE, GL_EXP2);
      // Multiply fog density parameter by fogScale
      glFogf(GL_FOG_DENSITY, fogScale*1.0f/userviewpoint->frustum.zfar /*(bsphere.radius*3)*/ );
      break;
    }

    glEnable(GL_FOG);
  } else {
    glDisable(GL_FOG);
  }

  // render bg sphere 
  
  if (sphere) { 
    /* The way we draw a background sphere is to start by rotating
     * the sphere so the pole is at (0, 1, 0) instead of (0, 0, 1),
     * then scale it to 4 times the radius of the bounding box,
     * then translate it to the center of the bbox and apply
     * the model-view transformation to it.  After that, 
     * flatten it to zero thickness in the z direction.
     */

    Matrix4x4 savedModelMatrix = subscene->modelMatrix;
    
    AABox bbox = subscene->getBoundingBox();
    Vec3 center = bbox.getCenter();
    Vec3 scale = subscene->getModelViewpoint()->scale;
    double zoom = subscene->getUserViewpoint()->getZoom();
    
    Matrix4x4 m;
    m.setRotate(0, 90);
    /* This calculation gets the aspect ratio
     * from the scale and range, by undoing aspect3d()
     */
    Vec3 ranges = bbox.vmax - bbox.vmin;
    float avgscale = ranges.getLength()/sqrtf(3.0f);
    Vec3 aspect(ranges.x*scale.x/avgscale, ranges.y*scale.y/avgscale, ranges.z*scale.z/avgscale);
    float maxaspect = std::max(aspect.x, std::max(aspect.y, aspect.z));
    m.multLeft(Matrix4x4::scaleMatrix(zoom*2.0*maxaspect*ranges.x/aspect.x,
                                      zoom*2.0*maxaspect*ranges.y/aspect.y,
                                      zoom*2.0*maxaspect*ranges.z/aspect.z));
    m.multLeft(Matrix4x4::translationMatrix(center.x, center.y, center.z));
    
    m.multLeft(savedModelMatrix);
    
    center = savedModelMatrix * center;
    m.multLeft(Matrix4x4::translationMatrix(-center.x, -center.y, -center.z));
    m.multLeft(Matrix4x4::scaleMatrix(1.0, 1.0, 0.25/zoom));
    m.multLeft(Matrix4x4::translationMatrix(center.x, center.y, center.z));
    subscene->modelMatrix.loadData(m);
    subscene->loadMatrices();
    
    Shape::render(renderContext);
    
    subscene->modelMatrix.loadData(savedModelMatrix);
    subscene->loadMatrices();
    
  } else if (quad) {
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
    
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    
    quad->draw(renderContext);

    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
  }
#endif    
}

void Background::drawPrimitive(RenderContext* renderContext, int index)
{
#ifndef RGL_NO_OPENGL  
  
  glPushAttrib(GL_ENABLE_BIT);

  material.beginUse(renderContext);
  
  material.useColor(1);
 
  glDisable(GL_DEPTH_TEST);
  glDepthMask(GL_FALSE);

  sphereMesh.draw(renderContext);

  material.endUse(renderContext);

  glPopAttrib();
#endif
}

int Background::getAttributeCount(SceneNode* subscene, AttribID attrib) 
{
  switch (attrib) {    
  case FLAGS: return 4;
  case FOGSCALE: return 1;
  case TYPES:
  case IDS: if (quad) return 1;
            else return 0;
         
  }
  return Shape::getAttributeCount(subscene, attrib);
}

void Background::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);

  if (first + count < n) n = first + count;
  if (first < n) {
    switch(attrib) {
    case FLAGS:
      if (first <= 0)  
        *result++ = (double) sphere;
      if (first <= 1)
	*result++ = (double) (fogtype == FOG_LINEAR);
      if (first <= 2)
	*result++ = (double) (fogtype == FOG_EXP);
      if (first <= 3)
	*result++ = (double) (fogtype == FOG_EXP2);
      return;
    case FOGSCALE:
      if (first <= 0)
        *result++ = fogScale;
      return;
    case IDS:
      if (quad)
      	*result++ = quad->getObjID();
      return;
    }
    Shape::getAttribute(subscene, attrib, first, count, result);
  }
}

std::string Background::getTextAttribute(SceneNode* subscene, AttribID attrib, int index)
{
  int n = getAttributeCount(subscene, attrib);
  if (index < n && attrib == TYPES)
    return quad->getTypeName();
  else
    return Shape::getTextAttribute(subscene, attrib, index);
}
