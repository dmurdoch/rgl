#ifndef GEOM_HPP
#define GEOM_HPP

#include "rglmath.h"

namespace rgl {

//
// CLASS
//   AABox (axis-aligned box)
//

class Sphere;

class AABox {
public:
  AABox();
  AABox(const AABox& that)
   : vmin(that.vmin), vmax(that.vmax)
  { }
  void invalidate(void);
  bool isValid(void) const;
  void operator += (const AABox& aabox);
  void operator += (const Sphere& sphere);
  void operator += (const Vertex& vertex);
  bool operator < (const AABox& aabox) const;
  Vertex getCenter(void) const;
  Vertex vmin, vmax;
};


//
// CLASS
//   Sphere
//

class Sphere {
public:
  Sphere() : center(0,0,0), radius(1) {};
  Sphere(const Vertex& center, const float radius);
  Sphere(const float radius);
  Sphere(const AABox& aabox);
  Sphere(const AABox& aabox, const Vertex& scale);
  Vertex center;
  float radius;
};


//
// CLASS
//   Frustum
//

class Frustum {
public:
  Frustum() : ortho(false) {};
  void enclose(float sphere_radius, float fovangle, int win_width, int win_height);
  float left, right, bottom, top, znear, zfar, distance;
  bool ortho;
};

} // namespace rgl

#endif // GEOM_HPP
