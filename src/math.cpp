// C++ source
// This file is part of RGL.
//
// $Id: math.cpp,v 1.1 2003/03/25 00:13:21 dadler Exp $

#include "math.h"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Vertex
//

Vertex::Vertex(float in_x, float in_y, float in_z)
{
  x = in_x;
  y = in_y;
  z = in_z;
}

float Vertex::getLength() const
{
  return sqrtf(x*x+y*y+z*z);
}

void Vertex::normalize()
{
  float len = this->getLength();
  if (len != 0.0f) {
    float f = 1.0f/len;
    x *= f;
    y *= f;
    z *= f;
  }
}

Vertex Vertex::cross(Vertex op2) const
{
  Vertex v;
  v.x = y * op2.z - z * op2.y;
  v.y = z * op2.x - x * op2.z;
  v.z = x * op2.y - y * op2.x;
  return v;
}

Vertex Vertex::operator * (float s)
{
  Vertex v;

  v.x = x*s;
  v.y = y*s;
  v.z = z*s;

  return v;
}

float Vertex::operator * (Vertex v)
{
  return (x*v.x + y*v.y + z*v.z);
}

Vertex Vertex::operator - (Vertex op2) const 
{
  Vertex v;

  v.x = x - op2.x;
  v.y = y - op2.y;
  v.z = z - op2.z;

  return v;
}

void Vertex::operator += (Vertex op2) 
{
  x += op2.x;
  y += op2.y;
  z += op2.z;
}

Vertex Vertex::operator + (Vertex op2) const
{
  Vertex t(*this);

  t += op2;

  return t;
}

void Vertex::rotateX(float degree)
{
  Vertex t(*this);

  float rad = deg2radf(degree);
  float s = sinf(rad);
  float c = cosf(rad);

  y = c*t.y + -s*t.z;
  z = s*t.y +  c*t.z;
}

void Vertex::rotateY(float degree)
{
  Vertex t(*this);

  float rad = deg2radf(degree);
  float s = sinf(rad);
  float c = cosf(rad);

  x =  c*t.x + s*t.z;
  z = -s*t.x + c*t.z;
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Vertex4
//

Vertex4::Vertex4(const float in_x, const float in_y, const float in_z, const float in_w)
{
  x = in_x;
  y = in_y;
  z = in_z;
  w = in_w;
};

float Vertex4::operator * (const Vertex4& v) const
{
  return (x*v.x + y*v.y + z*v.z + w*v.w);
}

Vertex4 Vertex4::operator * (const float s) const
{
  Vertex4 r;

  r.x = x*s;
  r.y = y*s;
  r.z = z*s;
  r.w = w*s;

  return r;
}

Vertex4 Vertex4::operator + (const Vertex4& v) const
{
  return Vertex4(x+v.x, y+v.y, z+v.z, w+v.w);
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Matrix4x4
//

Matrix4x4::Matrix4x4()
{
}

Matrix4x4::Matrix4x4(const Matrix4x4& src)
{
  for(int i=0;i<16;i++)
    data[i] = src.data[i];
}

Matrix4x4::Matrix4x4(const double* from)
{
  for(int i=0;i<16;i++)
    data[i] = (float) from[i];
}

Vertex Matrix4x4::operator * (const Vertex v) const {
  Vertex r;
  const float v_w = 1.0f;

  r.x = val(0,0) * v.x + val(0,1) * v.y + val(0,2) * v.z + val(0,3) * v_w;
  r.y = val(1,0) * v.x + val(1,1) * v.y + val(1,2) * v.z + val(1,3) * v_w;
  r.z = val(2,0) * v.x + val(2,1) * v.y + val(2,2) * v.z + val(2,3) * v_w;

  return r;
}

Vertex4 Matrix4x4::operator*(const Vertex4& v) const {

  Vertex4 r;

  r.x = val(0,0) * v.x + val(0,1) * v.y + val(0,2) * v.z + val(0,3) * v.w;
  r.y = val(1,0) * v.x + val(1,1) * v.y + val(1,2) * v.z + val(1,3) * v.w;
  r.z = val(2,0) * v.x + val(2,1) * v.y + val(2,2) * v.z + val(2,3) * v.w;
  r.w = val(3,0) * v.x + val(3,1) * v.y + val(3,2) * v.z + val(3,3) * v.w;

  return r;
}


Matrix4x4 Matrix4x4::operator * (const Matrix4x4& op2) const {

  Matrix4x4 r;

  for(int i=0;i<4;i++)
    for(int j=0;j<4;j++) {
      float tmp = 0;

      for(int k=0;k<4;k++)
        tmp += val(i, k) * op2.val(k, j);

      r.ref(i,j) = tmp;
    }

  return r;
}

void Matrix4x4::setIdentity(void) {
  for(int i=0;i<16;i++)
    data[i] = 0.0f;
  ref(0,0) = 1.0f;
  ref(1,1) = 1.0f;
  ref(2,2) = 1.0f;
  ref(3,3) = 1.0f;
}

void Matrix4x4::setRotate(const int axis, const float degree) {
  float rad = deg2radf(degree);
  float s   = sinf(rad);
  float c   = cosf(rad);
  setIdentity();
  switch(axis) {
    case 0:
      ref(1,1) = c;
      ref(1,2) = -s;
      ref(2,1) = s;
      ref(2,2) = c;
      break;
    case 1:
      ref(0,0) = c;
      ref(0,2) = s;
      ref(2,0) = -s;
      ref(2,2) = c;
      break;
    case 2:
      ref(0,0) = c;
      ref(0,1) = -s;
      ref(1,0) = s;
      ref(1,1) = c;
      break;
  }
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   AABox
//

AABox::AABox()
{
  invalidate();
}

void AABox::invalidate(void)
{
  vmax = Vertex( -FLT_MAX, -FLT_MAX, -FLT_MAX );
  vmin = Vertex(  FLT_MAX,  FLT_MAX,  FLT_MAX );
}

void AABox::operator += (const Vertex& v)
{
  vmin.x = getMin(vmin.x, v.x);
  vmin.y = getMin(vmin.y, v.y);
  vmin.z = getMin(vmin.z, v.z);

  vmax.x = getMax(vmax.x, v.x);
  vmax.y = getMax(vmax.y, v.y);
  vmax.z = getMax(vmax.z, v.z);
}

void AABox::operator += (const AABox& aabox)
{
  *this += aabox.vmin;
  *this += aabox.vmax;
}

void AABox::operator += (const Sphere& sphere)
{
  *this += sphere.center - Vertex(sphere.radius,sphere.radius,sphere.radius);
  *this += sphere.center + Vertex(sphere.radius,sphere.radius,sphere.radius);
}

bool AABox::isValid(void) const
{
  return ((vmax.x >= vmin.x) && (vmax.y >= vmin.y) && (vmax.z >= vmin.z)) ? true : false;
}

Vertex AABox::getCenter(void) const
{
  return Vertex( (vmax + vmin) * 0.5f );
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Sphere
//

Sphere::Sphere(const AABox& bbox)
{
  Vertex hdiagonal( (bbox.vmax - bbox.vmin) * 0.5f );

  center = bbox.getCenter();
  radius = hdiagonal.getLength();
}

Sphere::Sphere(const float in_radius)
: center(0.0f, 0.0f, 0.0f), radius(in_radius)
{
}

Sphere::Sphere(const Vertex& in_center, const float in_radius)
: center(in_center), radius(in_radius)
{
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Frustum
//

//
// setup frustum to enclose the space given by a bounding sphere, 
// field-of-view angle and window size.
//
// window size is used to provide aspect ratio.
//
// 

void Frustum::enclose(float sphere_radius, float fovangle, RectSize& winsize)
{
  float fovradians = deg2radf(fovangle/2.0f);

  float s = sinf(fovradians);
  float t = tanf(fovradians);

  distance = sphere_radius / s;

  znear = distance - sphere_radius;
  zfar  = znear + sphere_radius*2.0f;

  float hlen = t * znear;

  // hold aspect ratio 1:1

  float hwidth, hheight;

  bool inside = false;

  if (inside) {

    // inside bounding sphere: fit to max(winsize)

    if (winsize.width >= winsize.height) {
      hwidth  = hlen;
      hheight = hlen * ( (float)winsize.height ) /  ( (float)winsize.width );
    } else {
      hwidth  = hlen * ( (float)winsize.width  ) / ( (float) winsize.height );
      hheight = hlen;
    }
  } else {

    // outside(in front of) bounding sphere: fit to min(winsize)

    if (winsize.width >= winsize.height) {
      hwidth  = hlen * ( (float)winsize.width ) / ( (float)winsize.height );
      hheight = hlen;
    } else {
      hwidth  = hlen;
      hheight = hlen * ( (float)winsize.height ) / ( (float)winsize.width );
    }

  } 

  left   = -hwidth;
  right  =  hwidth;
  bottom = -hheight;
  top    =  hheight;
}
