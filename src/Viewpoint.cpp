#include "Viewpoint.hpp"

#include "opengl.h"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Viewpoint
//

Viewpoint::Viewpoint(PolarCoord in_position, float in_fov, float in_zoom, bool in_interactive) :
    SceneNode(VIEWPOINT),
    position( in_position ),
    fov(in_fov),
    zoom(in_zoom),
    interactive(in_interactive)
{
}


PolarCoord& Viewpoint::getPosition()
{
  return position;
}

void Viewpoint::setPosition(const PolarCoord& in_position)
{
  position = in_position;
}

float Viewpoint::getZoom() const
{
  return zoom;
}

void Viewpoint::setZoom(const float in_zoom)
{
  zoom = in_zoom;
}

bool Viewpoint::isInteractive() const
{
  return interactive;
}

void Viewpoint::setFOV(const float in_fov)
{
  fov = clamp(in_fov, 1.0, 179.0 );
}

float Viewpoint::getFOV() const
{
  return fov;
}

void Viewpoint::setupFrustum(RenderContext* rctx, const Sphere& viewSphere)
{
  frustum.enclose(viewSphere.radius, fov, rctx->rect.width, rctx->rect.height);

  // zoom

  float factor = 1.0f/(1.0f+zoom* ((float)(VIEWPOINT_MAX_ZOOM-1)) );

  frustum.left *= factor;
  frustum.right *= factor;
  frustum.bottom *= factor;
  frustum.top *= factor;
}

void Viewpoint::setupOrientation(RenderContext* rctx) const
{
  glRotatef( position.phi,   1.0f, 0.0f, 0.0f);
  glRotatef(-position.theta, 0.0f, 1.0f, 0.0f);
}

void Viewpoint::setupTransformation(RenderContext* rctx, const Sphere& viewSphere)
{     
  // projection

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glFrustum(frustum.left, frustum.right, frustum.bottom, frustum.top, frustum.znear, frustum.zfar);  

  // modelview

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glTranslatef( 0.0f, 0.0f, -frustum.distance );

  setupOrientation(rctx);

  glTranslatef( -viewSphere.center.x, -viewSphere.center.y, -viewSphere.center.z );
}


Vertex Viewpoint::getCOP(const Sphere& viewSphere) const
{
  return viewSphere.center + ( position.vector() * frustum.distance * 2.0f );
}
