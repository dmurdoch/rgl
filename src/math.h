#ifndef MATH_H
#define MATH_H

// C++ header file
// This file is part of RGL
//
// $Id: math.h,v 1.3 2003/11/21 15:13:55 dadler Exp $

#include <math.h>
#include <float.h>

#ifndef PI
#define PI      3.1415926535897932384626433832795
#endif

#ifndef sinf
#define sinf(X) sin(X)
#define cosf(X) cos(X)
#define asinf(X) asin(X)
#define acosf(X) acos(X)
#define tanf(X) tan(X)
#define sqrtf(X) sqrt(X)
#endif

inline float deg2radf(float deg) { return ((float)(PI/180.0)) * deg; }
inline float rad2degf(float rad) { return rad / ((float)(PI/180.0)); }

inline int   getMin(int a, int b)     { return (a <= b) ? a : b; }
inline float getMin(float a, float b) { return (a <= b) ? a : b; }
inline int   getMax(int a, int b)     { return (a >= b) ? a : b; }
inline float getMax(float a, float b) { return (a >= b) ? a : b; }

inline float clamp(float v, float floor, float ceil) { return (v<floor) ? floor : ( (v>ceil) ? ceil : v ); }
inline int   clamp(int   v, int   floor, int   ceil) { return (v<floor) ? floor : ( (v>ceil) ? ceil : v ); }

struct Vertex
{
  Vertex() {};
  Vertex(float x,float y, float z);
  float getLength() const;
  void normalize();
  Vertex cross(Vertex op2) const;
  float operator * (Vertex op2);
  Vertex operator * (float value);
  Vertex operator+(Vertex op2) const;
  Vertex operator-(Vertex op2) const;
  void   operator+=(Vertex op2);
  void   rotateX(float degree);
  void   rotateY(float degree);
  float x,y,z;
};

typedef Vertex  Vertex3;
typedef Vertex3 Normal;


struct Vertex4
{
  Vertex4(const Normal& n) : x(n.x), y(n.y), z(n.z), w(0.0f) {};
  Vertex4() {};
  Vertex4(const float x, const float y, const float z, const float w=1.0f);
  float operator * (const Vertex4& op2) const;
  Vertex4 operator * (const float value) const;
  Vertex4 operator + (const Vertex4& op2) const;
  float x,y,z,w;
};

class Matrix4x4
{
public:
  Matrix4x4();
  Matrix4x4(const Matrix4x4& src);
  Matrix4x4(const double*);
  Vertex operator*(Vertex op2) const;
  Vertex4 operator*(const Vertex4& op2) const;
  Matrix4x4 operator*(const Matrix4x4& op2) const;
  void setIdentity(void);
  void setRotate(int axis, float degree);
private:
  inline float  val(int row, int column) const { return data[4*column+row]; }
  inline float& ref(int row, int column) { return data[4*column+row]; }
  float data[16];
};


//
// CLASS
//   RectSize
//

struct RectSize
{
  RectSize() : width(0), height(0) {};
  RectSize(int in_width, int in_height) : width(in_width), height(in_height) {};
  int width;
  int height;
};


//
// CLASS
//   PolarCoord
//

struct PolarCoord
{
  PolarCoord(float in_theta=0.0f, float in_phi=0.0f) : theta(in_theta), phi(in_phi) {};
  PolarCoord(const PolarCoord& src) : theta(src.theta), phi(src.phi) {};
  PolarCoord operator + (const PolarCoord& op2) const { return PolarCoord(theta+op2.theta, phi+op2.phi); }
  PolarCoord operator - (const PolarCoord& op2) const { return PolarCoord(theta-op2.theta, phi-op2.phi); }
  float theta;
  float phi;
};


//
// CLASS
//   AABox (axis-aligned box)
//

class Sphere;

class AABox {
public:
  AABox();
  void invalidate(void);
  bool isValid(void) const;
  void operator += (const AABox& aabox);
  void operator += (const Sphere& sphere);
  void operator += (const Vertex& vertex);
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
  Vertex center;
  float radius;
};


//
// CLASS
//   Frustum
//

class Frustum {
public:
  void enclose(float sphere_radius, float fovangle, RectSize& winsize);
  float left, right, bottom, top, znear, zfar, distance;
};


#endif /* MATH_H */
