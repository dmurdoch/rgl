#ifndef PIXMAP_H
#define PIXMAP_H

// C++ header file
// This file is part of RGL
//
// $Id: pixmap.h,v 1.1 2003/03/25 00:13:21 dadler Exp $

#include <stdio.h>
#include "opengl.h"

class PixmapFormat;
  
enum PixmapTypeID { INVALID=0, RGB24, RGB32, RGBA32, GRAY8 };

enum PixmapFileFormatID {
PIXMAP_FILEFORMAT_PNG = 0,
PIXMAP_FILEFORMAT_LAST
};

class Pixmap {
public:
  
  Pixmap();
  ~Pixmap();
  bool init(PixmapTypeID typeID, int width, int height, int bits_per_channel);
  bool load(const char* filename);
  bool save(PixmapFormat* format, const char* filename);

  PixmapTypeID typeID;
  int width;
  int height;
  int bits_per_channel;
  int bytesperrow;
  unsigned char *data;
};


class PixmapFormat {
public:
  virtual bool checkSignature(FILE* file) = 0;
  virtual bool load(FILE* file, Pixmap* pixmap) = 0;
  virtual bool save(FILE* file, Pixmap* pixmap) = 0;
};


extern PixmapFormat* pixmapFormat[PIXMAP_FILEFORMAT_LAST];

#endif /* PIXMAP_H */
