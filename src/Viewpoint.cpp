#include "Viewpoint.h"

#include "subscene.h"
#include "opengl.h"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   UserViewpoint -- the viewer's portion of the viewpoint
//   ModelViewpoint -- the model's portion
//
//   These were previously just one Viewpoint class, but subscenes mean they need to be split
//

UserViewpoint::UserViewpoint(float in_fov, float in_zoom) :
    SceneNode(USERVIEWPOINT),
    fov(in_fov),
    zoom(in_zoom),
    viewerInScene(false)
{
}

ModelViewpoint::ModelViewpoint(PolarCoord in_position, Vec3 in_scale, bool in_interactive) :
    SceneNode(MODELVIEWPOINT),
    interactive(in_interactive)
{
    scale = in_scale;
    scaleChanged = true;    
     
    setPosition(in_position);
    clearMouseMatrix();
}

PolarCoord& ModelViewpoint::getPosition()
{
  return position;
}

ModelViewpoint::ModelViewpoint(double* in_userMatrix, Vec3 in_scale, bool in_interactive) :
    SceneNode(MODELVIEWPOINT),
    position( PolarCoord(0.0f, 0.0f) ),
    interactive(in_interactive)
{
    for (int i=0; i<16; i++) {
	userMatrix[i] = in_userMatrix[i];
    }
    scale = in_scale;
    scaleChanged = true;
    
    clearMouseMatrix();
}


void ModelViewpoint::setPosition(const PolarCoord& in_position)
{
    Matrix4x4 M,N;
    M.setRotate(0, in_position.phi);
    N.setRotate(1, -in_position.theta);
    M = M * N;
    M.getData((double*)userMatrix);
    position = in_position;
}

void ModelViewpoint::clearMouseMatrix()
{
    Matrix4x4 M;
    M.setIdentity();
    M.getData((double*)mouseMatrix);
}

float UserViewpoint::getZoom() const
{
  return zoom;
}

void UserViewpoint::setZoom(const float in_zoom)
{
  zoom = in_zoom;
}

bool ModelViewpoint::isInteractive() const
{
  return interactive;
}

void UserViewpoint::setFOV(const float in_fov)
{
  fov = clamp(in_fov, 0.0, 179.0 );
}

float UserViewpoint::getFOV() const
{
  return fov;
}

void UserViewpoint::setupFrustum(RenderContext* rctx, const Sphere& viewSphere)
{
  frustum.enclose(viewSphere.radius, fov, rctx->subscene->pviewport[2], rctx->subscene->pviewport[3]);
  if (!viewerInScene) {
    eye.x = 0.;
    eye.y = 0.;
    eye.z = frustum.distance;
  } else {
    float oldnear = frustum.znear;
    frustum.znear -= -eye.z + frustum.distance;
    frustum.zfar  -= -eye.z + frustum.distance;
    if (frustum.zfar < 0) 
      frustum.zfar = 1;	
    if (frustum.znear < frustum.zfar/100.)  // we lose log2(100) bits of depth resolution
      frustum.znear = frustum.zfar/100.;
    float ratio = frustum.znear/oldnear;
    frustum.left   = frustum.left*ratio   + eye.x;
    frustum.right  = frustum.right*ratio  + eye.x;
    frustum.top    = frustum.top*ratio    + eye.y;
    frustum.bottom = frustum.bottom*ratio + eye.y;
  }    

  // zoom

  frustum.left *= zoom;
  frustum.right *= zoom;
  frustum.bottom *= zoom;
  frustum.top *= zoom;
  
  if (frustum.ortho) {
    glOrtho(frustum.left, frustum.right, frustum.bottom, frustum.top, frustum.znear, frustum.zfar);  
  } else {
    glFrustum(frustum.left, frustum.right, frustum.bottom, frustum.top, frustum.znear, frustum.zfar);  
  }

}

Vertex UserViewpoint::getObserver()
 {
  return this->eye;
}

void UserViewpoint::setObserver(bool automatic, Vertex eye)
 {
  viewerInScene = !automatic;
  if (viewerInScene && !ISNAN(eye.x) &&!ISNAN(eye.y) && !ISNAN(eye.z))
    this->eye = eye;
}

void UserViewpoint::setupViewer()
{
  glTranslatef(-eye.x, -eye.y, -eye.z);
}

void ModelViewpoint::setupOrientation() const
{
  glMultMatrixd(mouseMatrix);
  glMultMatrixd(userMatrix);

}

void ModelViewpoint::setupTransformation(Vertex center)
{     
  // modelview
  setupOrientation();
  glScaled(scale.x, scale.y, scale.z);
  glTranslatef( -center.x, -center.y, -center.z );
}

void ModelViewpoint::updateMouseMatrix(Vec3 dragStart, Vec3 dragCurrent)
{
	Vec3 axis = dragStart.cross(dragCurrent);

	float angle = dragStart.angle(dragCurrent);

	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
	if (axis.getLength() > 0)
	  glRotatef((GLfloat)angle, (GLfloat)axis.x, (GLfloat)axis.y, (GLfloat)axis.z);
	glGetDoublev(GL_MODELVIEW_MATRIX,mouseMatrix);
	glPopMatrix();
}

void ModelViewpoint::updateMouseMatrix(PolarCoord newpos)
{
    Matrix4x4 M,N;
    M.setRotate(0, newpos.phi);
    N.setRotate(1, -newpos.theta);
    M = M * N;
    M.getData((double*)mouseMatrix);
}

void ModelViewpoint::mouseOneAxis(Vertex dragStart,Vertex dragCurrent,Vertex axis)
{
    float angle = math::rad2deg(dragCurrent.x-dragStart.x);
    Matrix4x4 M((double *)userMatrix);
    Vec4 v = M * Vec4(axis.x, axis.y, axis.z);
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
    glRotatef((GLfloat)angle, (GLfloat)v.x/v.w, (GLfloat)v.y/v.w, (GLfloat)v.z/v.w);
    glGetDoublev(GL_MODELVIEW_MATRIX,mouseMatrix);
    glPopMatrix();
}

void ModelViewpoint::mergeMouseMatrix()
{
    Matrix4x4 M((double *)userMatrix), N((double *)mouseMatrix);
    M = N * M;
    M.getData((double *)userMatrix);
    N.setIdentity();
    N.getData((double *)mouseMatrix);
}

void ModelViewpoint::getUserMatrix(double* dest)
{
	for(int i=0; i<16;i++)
		dest[i] = userMatrix[i];
}

void ModelViewpoint::setUserMatrix(double* src)
{
	for(int i=0; i<16;i++)
		userMatrix[i] = src[i];
}

void ModelViewpoint::getScale(double* dest)
{
    dest[0] = scale.x;
    dest[1] = scale.y;
    dest[2] = scale.z;
}

void ModelViewpoint::setScale(double* src)
{
    scale.x = src[0];
    scale.y = src[1];
    scale.z = src[2];
    scaleChanged = true;
}

void ModelViewpoint::getPosition(double* dest)
{
    dest[0] = position.theta;
    dest[1] = position.phi;
}

void ModelViewpoint::setPosition(double* src)
{
    position.theta = src[0];
    position.phi = src[1];
}
