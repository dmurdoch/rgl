#include "R.h"
#include "Surface.h"
#include "Material.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Surface
//
// in_coords permutes the coordinates to allow surfaces over arbitrary planes
// orientation is 1 to swap front and back

Surface::Surface(Material& in_material, int in_nx, int in_nz, double* in_x, double* in_z, double* in_y,
                 double* in_normal_x, double* in_normal_z, double* in_normal_y,
                 double* in_texture_s, double* in_texture_t,
	         int* in_coords, int in_orientation, int* in_flags, int in_ignoreExtent)
: FaceSet(in_material, GL_QUADS, 4, in_ignoreExtent, false)
{
  nx = in_nx;
  nz = in_nz;
  coords[0] = *(in_coords++);
  coords[1] = *(in_coords++);
  coords[2] = *(in_coords++);
  orientation = in_orientation;

  int nvertex = nx*nz;

  material.colorPerVertex(true, nvertex);

  vertexArray.alloc(nvertex);

  if (material.texture)
    texCoordArray.alloc(nvertex);

  Vertex v;
  float *x,*y,*z, *va[3];
  
  va[0] = &(v.x);
  va[1] = &(v.y);
  va[2] = &(v.z);
  
  x = va[coords[0]-1];
  y = va[coords[1]-1];
  z = va[coords[2]-1];
  
  int xmat = in_flags[0];
  int zmat = in_flags[1];
  user_normals = in_flags[2];
  user_textures = in_flags[3];
  
  normalArray.alloc(nvertex);
  
  hasmissing = false;
  
  int iy  = 0;
  for(int iz=0;iz<nz;iz++) {
    for(int ix=0;ix<nx;ix++,iy++) {  
      *z = (float) in_z[zmat ? iy : iz];
      *x = (float) in_x[xmat ? iy : ix];
      *y = (float) in_y[iy];
      vertexArray[iy] = v;
      hasmissing |= v.missing();
      
      boundingBox += v;
	
      if ( user_normals ) {
        *x = (float) in_normal_x[iy];
        *y = (float) in_normal_y[iy];
        *z = (float) in_normal_z[iy];
        
        v.normalize();
        normalArray[iy] = v;
      }
      
      if ( (material.texture) && (! material.texture->is_envmap() ) ) {
        if (!user_textures) {
          texCoordArray[iy].s = ((float)ix)/((float)(nx-1));
          texCoordArray[iy].t = 1.0f - ((float)iz)/((float)(nz-1));
        } else {
          texCoordArray[iy].s = static_cast<float>(in_texture_s[iy]);
          texCoordArray[iy].t = static_cast<float>(in_texture_t[iy]);
        }
      }
    }
  }
  for(int iz=1;iz<nz;iz++) {
  	for(int ix=1;ix<nx;ix++) {
  		int i1 = iz*nx + ix, i2 = i1 - 1, i3 = i2 - nx, i4 = i3 + 1;
  		if (!hasmissing || 
          (!vertexArray[i1].missing() &&
           !vertexArray[i2].missing() &&
           !vertexArray[i3].missing() &&
           !vertexArray[i4].missing())) {
  			indices.push_back(i1);
  			indices.push_back(i2);
  			indices.push_back(i3);
  			indices.push_back(i4);
  		}
  	}
  }
  if ( !user_normals ) {
    normalArray.alloc(nvertex);
    iy = 0;
    for(int iz=0;iz<nz;iz++) 
      for(int ix=0;ix<nx;ix++,iy++) 
        normalArray[iy] = getNormal(ix, iz);
  }    
  if ((material.point_antialias && ( material.front == material.POINT_FACE 
                                  || material.back  == material.POINT_FACE))
   || (material.line_antialias  && ( material.front == material.LINE_FACE 
                                  || material.back  == material.LINE_FACE))) blended = true;
}

Vertex Surface::getNormal(int ix, int iz)
{
  int i = iz*nx + ix;
  Vertex total(0.0f,0.0f,0.0f);  
  if (!vertexArray[i].missing()) {
    // List the 8 surrounding vertices.  Repat the 1st one to make looping simpler. 
    int ind[9];  
    int xv[9] =  {    1,     1,      0,    -1,     -1,   -1,     0,      1,      1   };
    int zv[9] =  {    0,     -1,     -1,   -1,     0,    1,      1,      1,      0   };    
    int okay[9];  /* checks of surrounding vertices from right counterclockwise */
    for (int j=0; j<8; j++) {
      int xval = ix + xv[j], zval = iz + zv[j];
      if (0 <= xval && xval < nx && 0 <= zval && zval < nz) {
        ind[j] = i + xv[j] + zv[j]*nx; 
        okay[j] = !vertexArray[ind[j]].missing();
      } else {
        okay[j] = 0;
	ind[j] = 0;
      }
    }
    okay[8] = okay[0];
    ind[8] = ind[0];
    /* Estimate normal by averaging cross-product in successive triangular sectors */
    for (int j=0; j<8; j++) {
      if (okay[j] && okay[j+1] ) 
        total += vertexArray.getNormal(i, ind[j], ind[j+1] );
    } 
    total.normalize();
  }
  if (orientation) {
    total.x = -total.x;
    total.y = -total.y;
    total.z = -total.z;
  }
  return total;
}

Vertex Surface::getCenter(int ix, int iz)
{
  Vertex accu(0.0f,0.0f,0.0f);
  int num = 0;
  if ( !vertexArray[iz*nx + ix].missing() ) {
    accu = accu + vertexArray[iz*nx + ix];
    num++;
  }
  if ( !vertexArray[iz*nx + ix+1].missing() ) {
    accu = accu + vertexArray[iz*nx + ix+1];
    num++;
  }
  if ( !vertexArray[(iz+1)*nx + ix].missing() ) {
    accu = accu + vertexArray[(iz+1)*nx + ix];
    num++;
  }
  if ( !vertexArray[(iz+1)*nx + ix+1].missing() ) {
    accu = accu + vertexArray[(iz+1)*nx + ix+1];
    num ++;
  }
  if (num) accu = accu * (1.0f/num);
  return accu;  
} 

Vertex Surface::getPrimitiveCenter(int index) 
{
  return getCenter( index % (nx-1), index / (nx-1) );
}


int Surface::getAttributeCount(SceneNode* subscene, AttribID attrib)
{
  switch (attrib) {
    case SURFACEDIM: return 1;
    case FLAGS: return 2; 
  }
  return FaceSet::getAttributeCount(subscene, attrib);
}

void Surface::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    switch (attrib) {
      case SURFACEDIM: {
        *result++ = nx;
        *result++ = nz;
        return;
      }
      case FLAGS:
        if (first == 0) *result++ = (double) ignoreExtent;
        *result++ = (double) orientation;
        return;
      }
    FaceSet::getAttribute(subscene, attrib, first, count, result);
  }
}
