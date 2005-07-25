// C++ source
// This file is part of RGL.
//
// $Id$

#include "pixmap.h"

#include "lib.hpp"

// PNG FORMAT IMPLEMENTATION

#ifdef HAVE_PNG_H
#include "pngpixmap.h"
PNGPixmapFormat png;
#endif

// PIXMAP FORMAT TABLE

PixmapFormat* pixmapFormat[PIXMAP_FILEFORMAT_LAST] =
{
  
// PNG FORMAT
  
#ifdef HAVE_PNG_H
  &png,
#else
  NULL,
#endif


};

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Pixmap
//

Pixmap::Pixmap()
{
  typeID = INVALID;
  width = 0;
  height = 0;
  bits_per_channel = 0;
  data = NULL;
  bytesperrow = 0;
}

Pixmap::~Pixmap()
{
  if (data)
    delete[] data;
}

bool Pixmap::init(PixmapTypeID in_typeID, int in_width, int in_height, int in_bits_per_channel) 
{
  if (data)
    delete data;
  
  typeID = in_typeID;
  width  = in_width;
  height = in_height;
  bits_per_channel = in_bits_per_channel;
  
  int channels;

  if (typeID == RGB24)
    channels = 3;
  else if (typeID == RGBA32)
    channels = 4;
  else if (typeID == GRAY8)
    channels = 1;
  else
    return false;

  bytesperrow = ( (channels * bits_per_channel) >> 3 ) * width;

  data = new unsigned char [ bytesperrow * height ];

  return true;
}

bool Pixmap::load(const char* filename)
{
  bool success = false;

  FILE* file = NULL;

  file = fopen(filename, "rb");
  if (!file) {
    char buffer[256];
    sprintf(buffer, "Pixmap load: unable to open file '%s' for reading", filename);
    lib::printMessage(buffer);
    return false;
  }

  bool support = false;

  for(int i=0;i<PIXMAP_FILEFORMAT_LAST;i++) {

    PixmapFormat* format;

    format = pixmapFormat[i];

    if ( (format) && (format->checkSignature(file) ) ) {
      support = true;
      success = format->load(file, this);
      break;
    }
  }

  if (!support) {
    lib::printMessage("Pixmap load: file format unsupported");
  }
  
  if (!success) {
    lib::printMessage("Pixmap load: failed");
  }

  fclose(file);
  
  return success;
}


bool Pixmap::save(PixmapFormat* format, const char* filename)
{
  FILE* file = NULL;

  file = fopen(filename, "wb");
  if (!file) {
    char buffer[256];
    sprintf(buffer, "Pixmap save: unable to open file '%s' for writing", filename);
    lib::printMessage(buffer);
    return false;
  }
  
  bool success = format->save(file, this);

  fclose(file);

  return success;
}
