#include <algorithm>
#include "ABCLineSet.h"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   PlaneSet
//

ABCLineSet::ABCLineSet(Material& in_material, int in_nbase, double* in_base, int in_ndir, double* in_dir)
  : 
  LineSet(in_material,true, false/* true */),
  nLines(max(in_nbase, in_ndir)),
  base(in_nbase, in_base), 
  direction(in_ndir, in_dir)
{
  /* We'll set up 1 segment per line.  Each segment has 2 vertices, and each vertex
   gets 3 color components and 1 alpha component. */
  ARRAY<int> colors(3*nLines);
  ARRAY<double> alphas(nLines);
  
  if (material.colors.getLength() > 1) {
    material.colors.recycle(nLines); 
    for (int i=0; i<nLines; i++) {
      Color color=material.colors.getColor(i);
      for (int j=0; j<2; j++) {
        colors.ptr[6*i+3*j+0] = color.getRedub();
        colors.ptr[6*i+3*j+1] = color.getGreenub();
        colors.ptr[6*i+3*j+2] = color.getBlueub();
        alphas.ptr[2*i+j]     = color.getAlphaf();
      }
    }
    material.colors.set(2*nLines, colors.ptr, 2*nLines, alphas.ptr);
    material.colorPerVertex(true, 2*nLines);  
  }
  
  ARRAY<double> vertices(6*nLines);
  for (int i=0; i<vertices.size(); i++)
    vertices.ptr[i] = NA_REAL;
  initPrimitiveSet(2*nLines, vertices.ptr);
}

AABox& ABCLineSet::getBoundingBox(Subscene* subscene)
{
  updateSegments(subscene->getBoundingBox());
  return LineSet::getBoundingBox(subscene); 
}

void ABCLineSet::renderBegin(RenderContext* renderContext)
{
  updateSegments(renderContext->subscene->getBoundingBox());
  invalidateDisplaylist();
  LineSet::renderBegin(renderContext);
}

void ABCLineSet::updateSegments(const AABox& sceneBBox)
{
  double bbox[2][3] = { {sceneBBox.vmin.x, sceneBBox.vmin.y, sceneBBox.vmin.z},
  {sceneBBox.vmax.x, sceneBBox.vmax.y, sceneBBox.vmax.z} };
  double x[2][3];
  for (int elem = 0; elem < nLines; elem++) {
    Vertex bv = base.getRecycled(elem);
    double b[3] = { bv.x, bv.y, bv.z };
    Vertex dv = direction.getRecycled(elem);
    double d[3] = { dv.x, dv.y, dv.z };
    
    //    Rprintf("bbox min=%f %f %f max=%f %f %f\n", bbox[0][0], bbox[0][1], bbox[0][2],
    //                                                bbox[1][0], bbox[1][1], bbox[1][2]);
    double smin = R_NegInf, smax = R_PosInf;
    for (int i=0; i<3; i++) {   // which coordinate
      if (d[i] != 0) {  
        double s[2];
        for (int j=0; j<2; j++) // which limit
          s[j] = (bbox[j][i] - b[i])/d[i];
        smin = max(smin, min(s[0], s[1]));
        smax = min(smax, max(s[0], s[1]));
      }
    }
    if (smin <= smax) {
      for (int k=0; k<3; k++) {
        x[0][k] = b[k] + smin*d[k];
        x[1][k] = b[k] + smax*d[k];
      }
      setVertex(2*elem + 0, x[0]);
      setVertex(2*elem + 1, x[1]);
    } else { 
      double missing[3] = {NA_REAL, NA_REAL, NA_REAL};
      setVertex(2*elem + 0, missing);
      setVertex(2*elem + 1, missing);
    }
  }
}

void ABCLineSet::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  updateSegments(bbox);
  LineSet::getAttribute(bbox, attrib, first, count, result);
}

