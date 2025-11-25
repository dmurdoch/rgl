#include "Color.h"
#include "types.h"
#include "R.h"

#include <cstdlib>
#include <cstring> // for memcpy

using namespace rgl;

//
// COLOR UTILS
//

//
// FUNCTION
//   HexCharToNibble
//

static u8 HexCharToNibble(char c) {
  u8 nibble = 0;

  if ((c >= '0') && (c <= '9'))
    nibble = c - '0';
  else if (( c >= 'A') && (c <= 'F'))
    nibble = (c - 'A') + 10;
  else if (( c >= 'a') && (c <= 'f'))
    nibble = (c - 'a') + 10;

  return nibble;
}

//
// FUNCTION
//   StringToRGB8
//

static void StringToRGB8(const char* string, u8* colorptr) {

  char* strptr = (char*) string;
  int cnt = 0;

  if (( *strptr++ == '#') && (cnt < 3)) {
    char c;

    while( (c = *strptr++) != '\0' ) {
  
      u8 component;

      component = static_cast<u8>(HexCharToNibble(c) << 4);
      
      if ( (c = *strptr++) == '\0')
        break;

      component |= HexCharToNibble(c);

      *colorptr++ = component; cnt++;
    }
  }

  for(int i=cnt;i<3;i++)
    *colorptr++ = 0x00;
}

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Color
//
//

Color::Color()
{
  data[0] = 1.0f;
  data[1] = 1.0f;
  data[2] = 1.0f;
  data[3] = 1.0f;
}

Color::Color(float red, float green, float blue, float alpha)
{
  data[0] = red;
  data[1] = green;
  data[2] = blue;
  data[3] = alpha;
}

Color::Color(u8 red, u8 green, u8 blue, u8 alpha)
{
  data[0] = ((float)red)/255.0f;
  data[1] = ((float)green)/255.0f;
  data[2] = ((float)blue)/255.0f;
  data[3] = ((float)alpha)/255.0f;
}

Color::Color(const char* string)
{
  u8 tmp[4];

  tmp[3] = 255;

  StringToRGB8(string, tmp);
  for (int i=0;i<4;i++)
    data[i] = ((float)tmp[i])/255.0f;
}

void Color::set3iv(int* color)
{
  data[0] = ((float)color[0])/255.0f;
  data[1] = ((float)color[1])/255.0f;
  data[2] = ((float)color[2])/255.0f;
  data[3] = 1.0f;
}

// TODO: move to rendergl.cpp

#include "opengl.h"

void Color::useClearColor() const
{
#ifndef RGL_NO_OPENGL
  glClearColor(data[0],data[1],data[2], data[3]);
  SAVEGLERROR;
#endif
}

void Color::useColor() const
{
#ifndef RGL_NO_OPENGL
  if (!doUseShaders) {
    glColor4fv(data);
    SAVEGLERROR;
  }
#endif
}


//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   ColorArray
//

ColorArray::ColorArray() 
{
  arrayptr = NULL;
  ncolor   = 0;
  nalpha   = 0;
#ifndef RGL_NO_OPENGL  
  location = -1;
  offset = -1;
#endif
}

ColorArray::ColorArray( Color& bg, Color &fg )
{
  ncolor   = 2;
  nalpha   = 2;
#ifndef RGL_NO_OPENGL  
  location = -1;
  offset = -1;
#endif
  arrayptr = (u8*) realloc( NULL, sizeof(u8) * 4 * ncolor);
  arrayptr[0] = bg.getRedub();
  arrayptr[1] = bg.getBlueub();
  arrayptr[2] = bg.getGreenub();
  arrayptr[3] = bg.getAlphaub();
  arrayptr[4] = fg.getRedub();
  arrayptr[5] = fg.getBlueub();
  arrayptr[6] = fg.getGreenub();
  arrayptr[7] = fg.getAlphaub();
  hint_alphablend = ( (bg.getAlphaub() < 255) || (fg.getAlphaub() < 255) ) ? true : false;
}

ColorArray::ColorArray( ColorArray& src ) {
  ncolor = src.ncolor;
  nalpha = src.nalpha;
#ifndef RGL_NO_OPENGL  
  location = -1;
  offset = -1;
#endif
  hint_alphablend = src.hint_alphablend;
  if (ncolor > 0) {
    arrayptr = (u8*) realloc( NULL, sizeof(u8) * 4 * ncolor);
    memcpy( arrayptr, src.arrayptr, sizeof(u8) * 4 * ncolor);
  } else {
    arrayptr = NULL;
  }
}

ColorArray::~ColorArray() {
  if (arrayptr)
    free(arrayptr);
}

void ColorArray::set( int in_ncolor, char** in_color, int in_nalpha, double* in_alpha)
{
  ncolor  = getMax(in_ncolor, in_nalpha);
  nalpha  = in_nalpha;
  u8* ptr = arrayptr = (u8*) realloc( arrayptr, sizeof(u8) * 4 * ncolor);

  hint_alphablend = false;

  for (unsigned int i=0;i<ncolor;i++) {
    StringToRGB8(in_color[i%in_ncolor], ptr);
    if (in_nalpha > 0) {
      u8 alpha = (u8) ( clamp( (float) in_alpha[i%in_nalpha], 0.0f, 1.0f) * 255.0f );
      if (alpha < 255)
        hint_alphablend = true;
      ptr[3] = alpha;
    } else
      ptr[3] = 0xFF;
    ptr += 4;
  }
}

void ColorArray::set( int in_ncolor, int* in_color, int in_nalpha, double* in_alpha)
{
  ncolor  = getMax(in_ncolor, in_nalpha);
  nalpha  = in_nalpha;
  u8* ptr = arrayptr = (u8*) realloc( arrayptr, sizeof(u8) * 4 * ncolor);

  hint_alphablend = false;

  for (unsigned int i=0;i<ncolor;i++) {
    int base = (i%in_ncolor) * 3;
    ptr[0] = (u8) in_color[base];
    ptr[1] = (u8) in_color[base+1];
    ptr[2] = (u8) in_color[base+2];
    if (in_nalpha > 0) {
      u8 alpha = (u8) ( clamp( (float) in_alpha[i%in_nalpha], 0.0f, 1.0f) * 255.0f );
      if (alpha < 255)
        hint_alphablend = true;
      ptr[3] = alpha;
    } else
      ptr[3] = 0xFF;
    ptr += 4;    
  }
}

void ColorArray::set(ColorArray src) {
  ncolor = src.ncolor;
  nalpha = src.nalpha;
  arrayptr = (u8*) realloc( arrayptr, sizeof(u8) * 4 * ncolor);
  memcpy(arrayptr, src.arrayptr, sizeof(u8) * 4 * ncolor);
  hint_alphablend = false;
}

unsigned int ColorArray::getLength() const
{
  return ncolor;
}

bool ColorArray::hasAlpha() const
{
  return hint_alphablend;
}

#ifndef RGL_NO_OPENGL
void ColorArray::setAttribLocation(GLint loc)
{
	location = loc;
}

void ColorArray::appendToBuffer(std::vector<GLubyte>& buffer, unsigned int nvertices)
{
	offset = buffer.size();
	const GLubyte* p = reinterpret_cast<const GLubyte*>(arrayptr);
	while (nvertices > 0) {
		int inserts = nvertices > ncolor ? ncolor : nvertices;
	  buffer.insert(buffer.end(), p, p + 4*inserts*sizeof(u8));
	  nvertices -= inserts;
	}
}
#endif

void ColorArray::useArray() const
{
#ifndef RGL_NO_OPENGL
	if (doUseShaders && location >= 0) {
		glEnableVertexAttribArray(location); 
		SAVEGLERROR;
		glVertexAttribPointer(location, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, (GLbyte*)0 + offset);
		SAVEGLERROR;
	} else if (!doUseShaders) {
		glEnableClientState(GL_COLOR_ARRAY);
		SAVEGLERROR;
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, (const GLvoid*) arrayptr );
		SAVEGLERROR;
  }
#endif
}

void ColorArray::enduseArray()
{
#ifndef RGL_NO_OPENGL	
	if (doUseShaders && location >= 0)
		glDisableVertexAttribArray(location); 
	else
		glDisableClientState(GL_COLOR_ARRAY);
#endif
}

void ColorArray::useColor(int index) const
{
#ifndef RGL_NO_OPENGL 
	if (doUseShaders && location >= 0) {
		glVertexAttrib4Nubv(location, (const GLubyte*) &arrayptr[ index * 4]);
	} else {
    glColor4ubv( (const GLubyte*) &arrayptr[ index * 4] );
  }
	SAVEGLERROR;
#endif
}

Color ColorArray::getColor(int index) const
{
  return Color( arrayptr[index*4], arrayptr[index*4+1], arrayptr[index*4+2], arrayptr[index*4+3] );
}

void ColorArray::recycle(unsigned int newsize)
{
  if (ncolor != newsize) {
    if (ncolor > 1) {

      if (newsize > 0) {
        arrayptr = (u8*) realloc(arrayptr, sizeof(u8)*4*newsize);

        for(unsigned int i=ncolor;i<newsize;i++) {
          int m = (i % ncolor)*4;
          arrayptr[i*4+0] = arrayptr[ m + 0];
          arrayptr[i*4+1] = arrayptr[ m + 1];
          arrayptr[i*4+2] = arrayptr[ m + 2];
          arrayptr[i*4+3] = arrayptr[ m + 3];
        }
      } else 
        arrayptr = NULL;

      ncolor = newsize;
    }
  }
}

void ColorArray::replicate(unsigned int each)
{
  size_t newsize = each*ncolor;
  if (newsize > 0) {
    arrayptr = (u8*) realloc(arrayptr, sizeof(u8)*4*newsize);
    for(int i0=0;i0<ncolor;i0++) {
      int i = ncolor - 1 - i0;
      for (int j=0; j<each; j++)
        for (int k=0; k<4; k++) 
          arrayptr[4*each*i + 4*j + k] = arrayptr[4*i + k];
    }
  } else 
    arrayptr = NULL;
  ncolor = newsize;
}
