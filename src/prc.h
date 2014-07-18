#ifndef RGL_PRC_H
#define RGL_PRC_H

#include "render.h"

using namespace rgl;

namespace prc {
class oPRCFile;
}

struct prcout {
  prcout(const char *filename, const RenderContext* rendercontext);
  ~prcout();
  prc::oPRCFile* file;
  const RenderContext* const rc;
  Vertex      scale;
  double *transform;
  double invorientation[16];
};

#endif /* RGL_PRC_H */
	       
