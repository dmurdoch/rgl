#ifndef RGL_MATH_H
#define RGL_MATH_H

// C++ header file
// This file is part of RGL
//
// $Id: math.h,v 1.5 2004/08/27 15:58:57 dadler Exp $

#include <math.h>
#include <float.h>


#include "types.h"

#ifndef PI
#define PI      3.1415926535897932384626433832795
#define CONST_PI 3.1415926535897932384626433832795
#endif

/*
#ifndef sinf
#define sinf(X) sin(X)
#define cosf(X) cos(X)
#define asinf(X) asin(X)
#define acosf(X) acos(X)
#define tanf(X) tan(X)
#define sqrtf(X) sqrt(X)
#endif
 */

template<class T>
inline T pi()
{
  return static_cast<T>( CONST_PI );
}  

template<class T>
inline T deg2rad(T deg)
{
  return ( pi<T>() / T(180.0) ) * deg;
}

template<class T>
inline T rad2deg(T rad)
{
  return rad / ( pi<T>() / T(180.0) );
}

template<class T>
T square(T x)
{
  return static_cast<T>( sqrt( static_cast<double>(x) ) );
}

template<>
inline float square(float x)
{
  return sqrtf( x );
}

// inline float deg2radf(float deg) { return ((float)(PI/180.0)) * deg; }
// inline float rad2degf(float rad) { return rad / ((float)(PI/180.0)); }

inline float deg2radf(float deg) { return deg2rad<float>(deg); }
inline float rad2degf(float rad) { return rad2deg<float>(rad); }


struct Vec3
{

  float x,y,z;
  
  Vec3() : x(0),y(0),z(0) { }
  Vec3(float in_x,float in_y, float in_z) : x(in_x), y(in_y), z(in_z) { }
  Vec3(const Vec3& that) : x(that.x), y(that.y), z(that.z) { }
  inline float getLength() const
  {
    return square<float>( x*x + y*y + z*z );
  }
  void normalize();
  Vec3 cross(Vec3 op2) const;
  float operator * (Vec3 op2);
  Vec3 operator * (float value);
  Vec3 operator+(Vec3 op2) const;
  Vec3 operator-(Vec3 op2) const;
  void   operator+=(Vec3 op2);
  void   rotateX(float degree);
  void   rotateY(float degree);

  static inline Vec3& asVec3(float* ptr) {
    return *( reinterpret_cast<Vec3*>( ptr ) );
  }
};

template<>
inline void copy(double* from, Vec3* to, int size)
{
  copy(from, (float*) to, size*3);
}

typedef Vec3    Vertex;
typedef Vertex  Vertex3;
typedef Vertex3 Normal;


struct Vec4
{
  
  float x,y,z,w;

  Vec4(const Normal& n) : x(n.x), y(n.y), z(n.z), w(0.0f) {};
  Vec4() {};
  Vec4(const float x, const float y, const float z, const float w=1.0f);
  float operator * (const Vec4& op2) const;
  Vec4 operator * (const float value) const;
  Vec4 operator + (const Vec4& op2) const;

  static inline Vec4& asVec4(float* ptr) {
    return *( reinterpret_cast<Vec4*>( ptr ) );
  }
};

class Matrix4x4
{
public:
  Matrix4x4();
  Matrix4x4(const Matrix4x4& src);
  Matrix4x4(const double*);
  Vec3 operator*(Vec3 op2) const;
  Vec4 operator*(const Vec4& op2) const;
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

struct Rect
{
  int x, y;
  int width, height;
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
  Vec3 vector() const;
  float theta;
  float phi;
};


typedef Vec4 Vertex4;

#endif /* MATH_H */
