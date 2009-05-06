#include "geom.hpp"
#include "R.h"

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
  if (!ISNAN(v.x)) {
    vmin.x = getMin(vmin.x, v.x);
    vmax.x = getMax(vmax.x, v.x);   
  }
  if (!ISNAN(v.y)) {
    vmin.y = getMin(vmin.y, v.y);
    vmax.y = getMax(vmax.y, v.y);   
  }
  if (!ISNAN(v.z)) {
    vmin.z = getMin(vmin.z, v.z);
    vmax.z = getMax(vmax.z, v.z);
  }
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

bool AABox::operator < (const AABox& that) const
{
  return true;
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

Sphere::Sphere(const AABox& bbox, const Vertex& s)
{
  Vertex hdiagonal( ((bbox.vmax - bbox.vmin) * 0.5f).scale(s) );
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

void Frustum::enclose(float sphere_radius, float fovangle, int width, int height)
{
  float s=0.5, t=1.0;
  
  if (fovangle != 0.0) {
    float fovradians = math::deg2rad(fovangle/2.0f);

    s = math::sin(fovradians);
    t = math::tan(fovradians);

    ortho = false;
  } else {
    ortho = true;
  }

  distance = sphere_radius / s;

  znear = distance - sphere_radius;
  zfar  = znear + sphere_radius*2.0f;

  float hlen = t * znear;

  // hold aspect ratio 1:1

  float hwidth, hheight;

  bool inside = false;

  if (inside) {

    // inside bounding sphere: fit to max(winsize)

    if (width >= height) {
      hwidth  = hlen;
      hheight = hlen * ( (float)height ) /  ( (float)width );
    } else {
      hwidth  = hlen * ( (float)width  ) / ( (float)height );
      hheight = hlen;
    }
  } else {

    // outside(in front of) bounding sphere: fit to min(winsize)

    if (width >= height) {
      hwidth  = hlen * ( (float)width ) / ( (float)height );
      hheight = hlen;
    } else {
      hwidth  = hlen;
      hheight = hlen * ( (float)height ) / ( (float)width );
    }

  } 

  left   = -hwidth;
  right  =  hwidth;
  bottom = -hheight;
  top    =  hheight;
}
