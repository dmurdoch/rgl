#ifndef COLOR_H
#define COLOR_H

//
// CLASS
//   Color
//
// IMPLEMENTATION
//   uses floats as the general format for single colors, clear colors,
//   lighting and material color properties
//

#include <vector>
#ifndef RGL_NO_OPENGL
#include "glad/gl.h"
#endif
#include "types.h"

namespace rgl {

class Color
{
public:
  Color();
  Color(float red, float green, float blue, float alpha=1.0f);
  Color(u8 red, u8 green, u8 blue, u8 alpha);
  Color(const char* string);
  float  getRedf()   const { return data[0]; }
  float  getGreenf() const { return data[1]; }
  float  getBluef()  const { return data[2]; }
  float  getAlphaf() const { return data[3]; }
  u8     getRedub()  const { return (u8) (data[0]*255.0f); }
  u8     getGreenub()const { return (u8) (data[1]*255.0f); }
  u8     getBlueub() const { return (u8) (data[2]*255.0f); }
  u8     getAlphaub()const { return (u8) (data[3]*255.0f); }
  float* getFloatPtr() const { return (float*) data; }
  /// set by integer ptr
  void   set3iv(int* color);
  void useClearColor() const;
  void useColor() const;
  float data[4];
};

//
// CLASS
//   ColorArray
// IMPLEMENTATION
//   uses unsigned bytes as internal format for mass color datas
//   carries alpha values
//

class ColorArray
{
public:
  ColorArray();
  ColorArray( ColorArray& src );
  ColorArray( Color& bg, Color& fg );
  ~ColorArray();
//  void set( int ncolor, RColor* rcolors, u8 alpha=255 );
  void set( int ncolor, char** colors, int nalpha, double* alphas );
  void set( int ncolor, int* colors, int nalpha, double* alphas );
  void set( ColorArray src );
  void useColor( int index ) const;
  void useArray() const;
  void enduseArray();
  unsigned int getLength() const;
  Color getColor( int index ) const;
  void setColor( int index, Color color);
  void recycle( unsigned int newsize );
  void replicate(unsigned int each );
  bool hasAlpha() const;
#ifndef RGL_NO_OPENGL
  void setAttribLocation(GLint loc);
  void appendToBuffer(std::vector<GLubyte>& buffer, unsigned int nvertices);
#endif
private:
  bool hint_alphablend;
  unsigned int ncolor;
  unsigned int nalpha;
  u8* arrayptr;
  friend class Material;
#ifndef RGL_NO_OPENGL
  GLint location;
  GLint offset;
#endif
};

} // namespace rgl

#endif // COLOR_H

