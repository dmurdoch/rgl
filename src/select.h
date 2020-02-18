#ifndef PLX_SELECT_H
#define PLX_SELECT_H

// C++ header file
// This file is part of RGL

#include "scene.h"

namespace rgl {

//
// Mouse selection rectangle
//

class SELECT
{
public:
  inline SELECT() { };
  void render(double* position);
};

} // namespace rgl

#endif // PLX_SELECT_H

