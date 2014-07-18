// C++ source
// This file is part of RGL.
//
// $Id$

#include "rglmath.h"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Vertex
//

void Vec3::normalize()
{
  float len = this->getLength();
  if (len != 0.0f) {
    float f = 1.0f/len;
    x *= f;
    y *= f;
    z *= f;
  }
}

Vec3 Vec3::cross(Vec3 op2) const
{
  Vec3 v;
  v.x = y * op2.z - z * op2.y;
  v.y = z * op2.x - x * op2.z;
  v.z = x * op2.y - y * op2.x;
  return v;
}

float Vec3::angle(const Vec3& that) const
{
  float dot;
  dot = x*that.x + y*that.y + z*that.z;
  return math::rad2deg(math::acos( dot/(this->getLength() * that.getLength())));

}

Vec3 Vec3::operator * (float s) const
{
  Vec3 v;

  v.x = x*s;
  v.y = y*s;
  v.z = z*s;

  return v;
}

float Vec3::operator * (Vec3 v) const
{
  return (x*v.x + y*v.y + z*v.z);
}

Vec3 Vec3::operator - (Vec3 op2) const 
{
  Vec3 v;

  v.x = x - op2.x;
  v.y = y - op2.y;
  v.z = z - op2.z;

  return v;
}

void Vec3::operator += (Vec3 op2) 
{
  x += op2.x;
  y += op2.y;
  z += op2.z;
}

Vec3 Vec3::scale(const Vec3& op2) const
{
  Vec3 t(*this);
  t.x *= op2.x;
  t.y *= op2.y;
  t.z *= op2.z;
  return t;
}

Vec3 Vertex::operator + (Vec3 op2) const
{
  Vec3 t(*this);

  t += op2;

  return t;
}

void Vec3::rotateX(float degree)
{
  Vec3 t(*this);

  float rad = math::deg2rad(degree);
  float s = math::sin(rad);
  float c = math::cos(rad);

  y = c*t.y + -s*t.z;
  z = s*t.y +  c*t.z;
}

void Vec3::rotateY(float degree)
{
  Vec3 t(*this);

  float rad = math::deg2rad(degree);
  float s = math::sin(rad);
  float c = math::cos(rad);

  x =  c*t.x + s*t.z;
  z = -s*t.x + c*t.z;
}

bool Vec3::missing() const
{
  return ISNAN(x) || ISNAN(y) || ISNAN(z);
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Vec4
//

Vec4::Vec4(const float in_x, const float in_y, const float in_z, const float in_w)
{
  x = in_x;
  y = in_y;
  z = in_z;
  w = in_w;
}

float Vec4::operator * (const Vec4& v) const
{
  return (x*v.x + y*v.y + z*v.z + w*v.w);
}

Vec4 Vec4::operator * (const float s) const
{
  Vec4 r;

  r.x = x*s;
  r.y = y*s;
  r.z = z*s;
  r.w = w*s;

  return r;
}

Vec4 Vec4::operator + (const Vec4& v) const
{
  return Vec4(x+v.x, y+v.y, z+v.z, w+v.w);
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

Vec3 Matrix4x4::operator * (const Vec3 v) const {
  Vec3 r;
  const float v_w = 1.0f;

  r.x = val(0,0) * v.x + val(0,1) * v.y + val(0,2) * v.z + val(0,3) * v_w;
  r.y = val(1,0) * v.x + val(1,1) * v.y + val(1,2) * v.z + val(1,3) * v_w;
  r.z = val(2,0) * v.x + val(2,1) * v.y + val(2,2) * v.z + val(2,3) * v_w;

  return r;
}

Vec4 Matrix4x4::operator*(const Vec4& v) const {

  Vec4 r;

  r.x = val(0,0) * v.x + val(0,1) * v.y + val(0,2) * v.z + val(0,3) * v.w;
  r.y = val(1,0) * v.x + val(1,1) * v.y + val(1,2) * v.z + val(1,3) * v.w;
  r.z = val(2,0) * v.x + val(2,1) * v.y + val(2,2) * v.z + val(2,3) * v.w;
  r.w = val(3,0) * v.x + val(3,1) * v.y + val(3,2) * v.z + val(3,3) * v.w;

  return r;
}

bool Vec4::missing() const
{
  return ISNAN(x) || ISNAN(y) || ISNAN(z) || ISNAN(w);
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

Matrix4x4 Matrix4x4::inverse() const {

//
// From Mesa-2.2\src\glu\project.c
//

//
// Invert matrix m.  This algorithm contributed by Stephane Rehel
// <rehel@worldnet.fr>
//

/* Here's some shorthand converting standard (row,column) to index. */
#define m11 data[ 0+0]
#define m12 data[ 4+0]
#define m13 data[ 8+0]
#define m14 data[12+0]
#define m21 data[ 0+1]
#define m22 data[ 4+1]
#define m23 data[ 8+1]
#define m24 data[12+1]
#define m31 data[ 0+2]
#define m32 data[ 4+2]
#define m33 data[ 8+2]
#define m34 data[12+2]
#define m41 data[ 0+3]
#define m42 data[ 4+3]
#define m43 data[ 8+3]
#define m44 data[12+3]

	register double det;
	double tmp[16]; 

	/* Inverse = adjoint / det. (See linear algebra texts.)*/

	tmp[0]= m22 * m33 - m23 * m32;
	tmp[1]= m23 * m31 - m21 * m33;
	tmp[2]= m21 * m32 - m22 * m31;

	/* Compute determinant as early as possible using these cofactors. */
	det= m11 * tmp[0] + m12 * tmp[1] + m13 * tmp[2];

	/* Run singularity test. */
	if (det == 0.0) {
		Rprintf("invert_matrix: Warning: Singular matrix.\n");
                for (size_t i=0;i<16;i++)
                  tmp[i]=0.;
	}
	else {
		double d12, d13, d23, d24, d34, d41;
		register double im11, im12, im13, im14;

		det= 1. / det;

		/* Compute rest of inverse. */
		tmp[0] *= det;
		tmp[1] *= det;
		tmp[2] *= det;
		tmp[3]  = 0.;

		im11= m11 * det;
		im12= m12 * det;
		im13= m13 * det;
		im14= m14 * det;
		tmp[4] = im13 * m32 - im12 * m33;
		tmp[5] = im11 * m33 - im13 * m31;
		tmp[6] = im12 * m31 - im11 * m32;
		tmp[7] = 0.;

		/* Pre-compute 2x2 dets for first two rows when computing */
		/* cofactors of last two rows. */
		d12 = im11*m22 - m21*im12;
		d13 = im11*m23 - m21*im13;
		d23 = im12*m23 - m22*im13;
		d24 = im12*m24 - m22*im14;
		d34 = im13*m24 - m23*im14;
		d41 = im14*m21 - m24*im11;

		tmp[8] =  d23;
		tmp[9] = -d13;
		tmp[10] = d12;
		tmp[11] = 0.;

		tmp[12] = -(m32 * d34 - m33 * d24 + m34 * d23);
		tmp[13] =  (m31 * d34 + m33 * d41 + m34 * d13);
		tmp[14] = -(m31 * d24 + m32 * d41 + m34 * d12);
		tmp[15] =  1.;

	}
// Rprintf("mat\n");
// Rprintf("%f %f %f %f\n", m11, m12, m13, m14);
// Rprintf("%f %f %f %f\n", m21, m22, m23, m24);
// Rprintf("%f %f %f %f\n", m31, m32, m33, m34);
// Rprintf("%f %f %f %f\n", m41, m42, m43, m44);
// 
// Rprintf("invmat\n");
// Rprintf("%f %f %f %f\n", tmp[0+0], tmp[4+0], tmp[8+0], tmp[12+0]);
// Rprintf("%f %f %f %f\n", tmp[0+1], tmp[4+1], tmp[8+1], tmp[12+1]);
// Rprintf("%f %f %f %f\n", tmp[0+2], tmp[4+2], tmp[8+2], tmp[12+2]);
// Rprintf("%f %f %f %f\n", tmp[0+3], tmp[4+3], tmp[8+3], tmp[12+3]);
#undef m11
#undef m12
#undef m13
#undef m14
#undef m21
#undef m22
#undef m23
#undef m24
#undef m31
#undef m32
#undef m33
#undef m34
#undef m41
#undef m42
#undef m43
#undef m44

  return Matrix4x4(tmp);
}

Vec4 Matrix4x4::getRow(int row) const {
  Vec4 r;
  
  r.x = val(row, 0);
  r.y = val(row, 1);
  r.z = val(row, 2);
  r.w = val(row, 3);
  
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
  float rad = math::deg2rad(degree);
  float s   = math::sin(rad);
  float c   = math::cos(rad);
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

void Matrix4x4::setTranslate(const Vertex& vec) {
  setIdentity();
  ref(0,3) = vec.x;
  ref(1,3) = vec.y;
  ref(2,3) = vec.z;
}

void Matrix4x4::transpose() {
  for (int i = 0; i < 3; i++)
    for (int j = i+1; j < 4; j++) {
      float temp = val(i,j);
      ref(i,j) = val(j,i);
      ref(j,i) = temp;
    }
}

void Matrix4x4::getData(double* dest)
{
	for(int i=0;i<16;i++)
    	dest[i] = data[i];
}

Vertex PolarCoord::vector() const { 
  float t = math::deg2rad(theta);
  float p = math::deg2rad(phi);
  return Vertex (
    math::cos(p) * math::sin(t),
    math::sin(p),
    math::cos(p) * math::cos(t)
  );
}
