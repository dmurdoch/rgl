#ifndef PIXMAP_H
#define PIXMAP_H

// C++ header file
// This file is part of RGL

#include <cstdio>
#include "opengl.h"

namespace rgl {

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
  bool load(const double* _data);
  bool save(PixmapFormat* format, const char* filename);
  void clear();
  PixmapTypeID typeID;
  unsigned int width;
  unsigned int height;
  unsigned int bits_per_channel;
  unsigned int bytesperrow;
  unsigned char *data;
};


class PixmapFormat {
public:
  virtual ~PixmapFormat() { }  
  virtual bool checkSignature(std::FILE* file) = 0;
  virtual bool load(std::FILE* file, Pixmap* pixmap) = 0;
  virtual bool save(std::FILE* file, Pixmap* pixmap) = 0;
};


extern PixmapFormat* pixmapFormat[PIXMAP_FILEFORMAT_LAST];

} // namespace rgl

#endif /* PIXMAP_H */
