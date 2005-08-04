#ifndef RGL_MATH_H
#define RGL_MATH_H

// C++ header file
// This file is part of RGL
//
// $Id$

#include <math.h>
#include <float.h>

#include "types.h"

#ifndef M_PI
#define M_PI      3.1415926535897932384626433832795
#endif

namespace math {

  // template-based math functions with default 'double' implementation using math.h

  template<typename T> inline T acos(T x) { return static_cast<T>( ::acos( static_cast<double>(x) ) ); }
  template<typename T> inline T asin(T x) { return static_cast<T>( ::asin( static_cast<double>(x) ) ); }
  template<typename T> inline T atan(T x) { return static_cast<T>( ::atan( static_cast<double>(x) ) ); }
  template<typename T> inline T atan2(T x, T y) { return static_cast<T>( ::atan2( static_cast<double>(x), static_cast<double>(y) ) ); }
  template<typename T> inline T cos(T x) { return static_cast<T>( ::cos( static_cast<double>(x) ) ); }
  template<typename T> inline T sin(T x) { return static_cast<T>( ::sin( static_cast<double>(x) ) ); }
  template<> inline float sin(float rad) { return ::sinf(rad); }
  template<typename T> inline T tan(T x) { return static_cast<T>( ::tan( static_cast<double>(x) ) ); }
  // template<typename T> inline T acosh(T x) { return static_cast<T>( ::acosh( static_cast<double>(x) ) ); }
  // template<typename T> inline T asinh(T x) { return static_cast<T>( ::asinh( static_cast<double>(x) ) ); }
  // template<typename T> inline T atanh(T x) { return static_cast<T>( ::atanh( static_cast<double>(x) ) ); }
  // template<typename T> inline T cosh(T x) { return static_cast<T>( ::cosh( static_cast<double>(x) ) ); }
  // template<typename T> inline T sinh(T x) { return static_cast<T>( ::sinh( static_cast<double>(x) ) ); }
  // template<typename T> inline T tanh(T x) { return static_cast<T>( ::tanh( static_cast<double>(x) ) ); }
  template<typename T> inline T exp(T x) { return static_cast<T>( ::exp( static_cast<double>(x) ) ); }
  template<typename T> inline T exp2(T x) { return static_cast<T>( ::exp2( static_cast<double>(x) ) ); }
//  template<typename T> inline T expm1(T x) { return static_cast<T>( ::expm1( static_cast<double>(x) ) ); }
  template<typename T> inline T log(T x) { return static_cast<T>( ::log( static_cast<double>(x) ) ); }
  template<typename T> inline T log10(T x) { return static_cast<T>( ::log10( static_cast<double>(x) ) ); }
  template<typename T> inline T log2(T x) { return static_cast<T>( ::log2( static_cast<double>(x) ) ); }
  template<typename T> inline T log1p(T x) { return static_cast<T>( ::log1p( static_cast<double>(x) ) ); }
  template<typename T> inline T logb(T x) { return static_cast<T>( ::logb( static_cast<double>(x) ) ); }
  template<typename T> inline T modf(T x, T* y) { double i; double r = ::modf( static_cast<double>(x), &i ); *y = static_cast<T>(i); return static_cast<T>(r); }
  template<> inline double modf(double x, double* y) { return ::modf(x,y); }
  template<> inline float  modf(float x, float* y) { return ::modff(x,y); }
  template<typename T> inline T ldexp(T x, int y) { return static_cast<T>( ::ldexp(static_cast<double>(x),y) ); }
//  template<typename T> inline T frexp(T x, int* y) { return static_cast<T>( ::frexp( static_cast<double>(x),n) ); }
  template<typename T> inline int ilogb(T x) { return ::ilogb( static_cast<double>(x) ); }
  template<typename T> inline T scalbn(T x, int n) { return static_cast<T>( ::scalbn( static_cast<double>(x),n ) ); }
  template<typename T> inline T fabs(T x) { return static_cast<T>( ::fabs( static_cast<double>(x) ) ); }
  template<typename T> inline T cbrt(T x) { return static_cast<T>( ::cbrt( static_cast<double>(x) ) ); }
//  template<typename T> inline T hypot(T x) { return static_cast<T>( ::hypot( static_cast<double>(x) ) ); }
  template<typename T> inline T pow(T x, T y) { return static_cast<T>( ::pow( static_cast<double>(x), static_cast<double>(y) ) ); }
  template<typename T> inline T sqrt(T x) { return static_cast<T>( ::sqrt( static_cast<double>(x) ) ); }
  template<typename T> inline T erf(T x) { return static_cast<T>( ::erf( static_cast<double>(x) ) ); }
  template<typename T> inline T erfc(T x) { return static_cast<T>( ::erfc( static_cast<double>(x) ) ); }
  template<typename T> inline T lgamma(T x) { return static_cast<T>( ::lgamma( static_cast<double>(x) ) ); }
  template<typename T> inline T tgamma(T x) { return static_cast<T>( ::tgamma( static_cast<double>(x) ) ); }
  template<typename T> inline T ceil(T x) { return static_cast<T>( ::ceil( static_cast<double>(x) ) ); }
  template<typename T> inline T floor(T x) { return static_cast<T>( ::floor( static_cast<double>(x) ) ); }
  template<typename T> inline T nearbyint(T x) { return static_cast<T>( ::nearbyint( static_cast<double>(x) ) ); }
  template<typename T> inline T rint(T x) { return static_cast<T>( ::rint( static_cast<double>(x) ) ); }
  template<typename T> inline long int lrint(T x) { return ( ::lrint( static_cast<double>(x) ) ); }
//  template<typename T> inline long long int llrint(T x) { return ::llrint( static_cast<double>(x) ); }
  template<typename T> inline T round(T x) { return static_cast<T>( ::round( static_cast<double>(x) ) ); }

  template<class T> inline T pi() { return static_cast<T>( M_PI ); }  
  template<class T> inline T deg2rad(T deg) { return ( pi<T>() / T(180.0) ) * deg; }
  template<class T> inline T rad2deg(T rad) { return rad / ( pi<T>() / T(180.0) ); }

}


// inline float deg2radf(float deg) { return ((float)(PI/180.0)) * deg; }
// inline float rad2degf(float rad) { return rad / ((float)(PI/180.0)); }

// inline float deg2radf(float deg) { return deg2rad<float>(deg); }
// inline float rad2degf(float rad) { return rad2deg<float>(rad); }


struct Vec3
{

  float x,y,z;
  
  Vec3() : x(0),y(0),z(0) { }
  Vec3(float in_x,float in_y, float in_z) : x(in_x), y(in_y), z(in_z) { }
  Vec3(const Vec3& that) : x(that.x), y(that.y), z(that.z) { }
  inline float getLength() const
  {
    return math::sqrt( x*x + y*y + z*z );
  }
  void normalize();
  Vec3 cross(Vec3 op2) const;
  float angle(const Vec3& op2) const;
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

  Vec4(const Normal& n, float in_w=0.0f) : x(n.x), y(n.y), z(n.z), w(in_w) {};
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
  Vec4 getRow(int row);
  void setIdentity(void);
  void setRotate(int axis, float degree);
  void getData(double* dest);
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
  Rect(int in_x, int in_y, int in_w, int in_h)
  : x(in_x)
  , y(in_y)
  , width(in_w)
  , height(in_h) 
  { }
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
