#ifndef PLX_SELECT_H
#define PLX_SELECT_H

// C++ header file
// This file is part of RGL
//
// $Id: select.h,v 1.2 2004/08/10 01:43:07 murdoch Exp $

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

