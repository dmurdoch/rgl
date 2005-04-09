#ifndef PLX_SELECT_H
#define PLX_SELECT_H

// C++ header file
// This file is part of RGL
//
// $Id$

#include "scene.h"

//
// Mouse selection rectangle
//

class SELECT
{
public:
  inline SELECT() { };
  void render(double* position);
};

#endif // PLX_SELECT_H

