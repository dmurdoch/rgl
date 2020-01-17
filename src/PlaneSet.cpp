#include <algorithm>
#include "PlaneSet.h"
#include "Viewpoint.h"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   PlaneSet
//

PlaneSet::PlaneSet(Material& in_material, int in_nnormal, double* in_normal, int in_noffset, double* in_offset)
 : 
   TriangleSet(in_material,true, false/* true */),
   nPlanes(max(in_nnormal, in_noffset)),
   normal(in_nnormal, in_normal), 
   offset(in_noffset, in_offset)
{
  /* We'll set up 4 triangles per plane, in case we need to render
     a hexagon.  Each triangle has 3 vertices (so 12 for the plane), and each vertex
     gets 3 color components and 1 alpha component. */
  ARRAY<int> colors(36*nPlanes);
  ARRAY<double> alphas(12*nPlanes);

  if (material.colors.getLength() > 1) {
    material.colors.recycle(nPlanes); 
  
    for (int i=0; i<nPlanes; i++) {
      Color color=material.colors.getColor(i);
      for (int j=0; j<12; j++) {
        colors.ptr[36*i+3*j+0] = color.getRedub();
        colors.ptr[36*i+3*j+1] = color.getGreenub();
        colors.ptr[36*i+3*j+2] = color.getBlueub();
        alphas.ptr[12*i+j]     = color.getAlphaf();
      }
    }
    material.colors.set(12*nPlanes, colors.ptr, 12*nPlanes, alphas.ptr);
    material.colorPerVertex(true, 12*nPlanes);
  }
  
  ARRAY<double> vertices(36*nPlanes),
                normals(36*nPlanes);
  for (int i=0; i<vertices.size(); i++)
    vertices.ptr[i] = NA_REAL;
  for (int i=0; i<nPlanes; i++)
    for (int j=0; j<12; j++) {
      normals.ptr[36*i+3*j+0] = normal.getRecycled(i).x;
      normals.ptr[36*i+3*j+1] = normal.getRecycled(i).y;
      normals.ptr[36*i+3*j+2] = normal.getRecycled(i).z;
    }  
  initFaceSet(12*nPlanes, vertices.ptr, normals.ptr, NULL);
}

AABox& PlaneSet::getBoundingBox(Subscene* subscene)
{
  updateTriangles(subscene->getBoundingBox());
  return TriangleSet::getBoundingBox(subscene); 
}

void PlaneSet::renderBegin(RenderContext* renderContext)
{
  updateTriangles(renderContext->subscene->getBoundingBox());
  invalidateDisplaylist();
  TriangleSet::renderBegin(renderContext);
}

void PlaneSet::updateTriangles(const AABox& sceneBBox)
{
  int perms[3][3] = { {0,0,1}, {1,2,2}, {2,1,0} };
  double bbox[2][3] = { {sceneBBox.vmin.x, sceneBBox.vmin.y, sceneBBox.vmin.z},
                       {sceneBBox.vmax.x, sceneBBox.vmax.y, sceneBBox.vmax.z} };
  double x[12][3];
  for (int elem = 0; elem < nPlanes; elem++) {
    Vertex Av = normal.getRecycled(elem);
    double A[3] = { Av.x, Av.y, Av.z };
    double d = offset.getRecycled(elem);
    int nhits = 0;
    int face1[12], face2[12]; /* to identify which faces of the cube we're on */
    
    /* Find intersection of bbox edges with plane.  Problem: 
     * there might be 3 edges all intersecting the plane 
     * at the same place, i.e. a vertex of the bbox.  Need
     * to fix this case.
     */ 
    for (int i=0; i<3; i++)
      for (int j=0; j<2; j++)
        for (int k=0; k<2; k++) {
          int u=perms[0][i], v=perms[1][i], w=perms[2][i];
          if (A[w] != 0.0) {
            double intersect = -(d + A[u]*bbox[j][u] + A[v]*bbox[k][v])/A[w];
  	        if (bbox[0][w] <= intersect && intersect <= bbox[1][w]) {
  	          x[nhits][u] = bbox[j][u];
  	          x[nhits][v] = bbox[k][v];
  	          x[nhits][w] = intersect;
  	          /* Check for duplicate */
  	          int dup = 0;
  	          for (int l=0; l < nhits; l++) {
  	            if (abs(x[l][0] - x[nhits][0]) <= 1.e-8*abs(x[l][0]) 
                 && abs(x[l][1] - x[nhits][1]) <= 1.e-8*abs(x[l][1])
                 && abs(x[l][2] - x[nhits][2]) <= 1.e-8*abs(x[l][2])) {
  	              dup = 1;
  	              break;
  	            }
  	          }
  	          if (!dup) {
  	            face1[nhits] = j + 2*u;
  	            face2[nhits] = k + 2*v;
  	            nhits++;
  	          }
  	        }
  	      }
        }
    
    if (nhits > 3) {
      /* Re-order the intersections so the triangles work */
      for (int i=0; i<nhits-2; i++) {
        int which=0; /* initialize to suppress warning */
        for (int j=i+1; j<nhits; j++) {
          if (face1[i] == face1[j] || face1[i] == face2[j] 
           || face2[i] == face1[j] || face2[i] == face2[j] ) {
            which = j;
            break;
          }
        }
        if (which > i+1) {
          for (int j=0; j<3; j++) 
            swap(x[i+1][j], x[which][j]);
          swap(face1[i+1], face1[which]);
          swap(face2[i+1], face2[which]);
        }
      }
    }
    
    if (nhits >= 3) { 
      /* Put in order so that the normal points out the FRONT of the faces */
      Vec3 v0(x[0][0] - x[1][0] , x[0][1] - x[1][1], x[0][2] - x[1][2]),
           v2(x[2][0] - x[1][0] , x[2][1] - x[1][1], x[2][2] - x[1][2]),
           vx = v0.cross(v2);
      
      bool reverse = vx*Av > 0;
      
      for (int i=0; i<nhits-2; i++) {
        setVertex(12*elem + 3*i, x[0]); 
        for (int j=1; j<3; j++) {
          if (reverse)
            setVertex(12*elem + 3*i + 3-j, x[i+j]);
          else
            setVertex(12*elem + 3*i + j, x[i+j]);
        }
      }
    } else 
      nhits = 2; /* all missing */
      
    double missing[3] = {NA_REAL, NA_REAL, NA_REAL};
    for (int i=nhits-2; i<4; i++) 
      for (int j=0; j<3; j++) 
        setVertex(12*elem + 3*i + j, missing);
  }
}

int PlaneSet::getAttributeCount(AABox& bbox, AttribID attrib)
{
	switch (attrib) {
	case NORMALS: 
	case OFFSETS: return nPlanes;
	}
	return TriangleSet::getAttributeCount(bbox, attrib);
}

void PlaneSet::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
	int n = getAttributeCount(bbox, attrib);
	if (first + count < n) n = first + count;
	if (first < n) {
		if (attrib == NORMALS) {
			while (first < n) {
				*result++ = normal.getRecycled(first).x;
				*result++ = normal.getRecycled(first).y;
				*result++ = normal.getRecycled(first).z;
				first++;
			}
		} else if (attrib == OFFSETS) {
			while (first < n) 
				*result++ = offset.getRecycled(first++);
		} else {
			updateTriangles(bbox);
			TriangleSet::getAttribute(bbox, attrib, first, count, result);
		}
	}
}
