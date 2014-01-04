#include "Surface.hpp"
#include "Material.hpp"

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
: Shape(in_material, in_ignoreExtent)
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
  
  if (user_normals)
    normalArray.alloc(nvertex);
    
  int iy  = 0;
  for(int iz=0;iz<nz;iz++) {
    for(int ix=0;ix<nx;ix++,iy++) {    
      *z = (float) in_z[zmat ? iy : iz];
      *x = (float) in_x[xmat ? iy : ix];
      *y = (float) in_y[iy];

      vertexArray[iy] = v;

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
          texCoordArray[iy].s = in_texture_s[iy];
          texCoordArray[iy].t = in_texture_t[iy];
        }
      }
    }
  }
  use_normal    = user_normals || material.lit || ( material.texture && material.texture->is_envmap() );
  if ( use_normal && !user_normals ) {
    normalArray.alloc(nvertex);
    iy = 0;
    for(int iz=0;iz<nz;iz++) 
      for(int ix=0;ix<nx;ix++,iy++) 
        normalArray[iy] = getNormal(ix, iz);
  }    
  use_texcoord  = user_textures || ( material.texture && !(material.texture->is_envmap() ) ); 
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

void Surface::draw(RenderContext* renderContext)
{
  bool missing;
  drawBegin(renderContext);

  for(int iz=0;iz<nz-1;iz++) {

    missing = true;
    
    for(int ix=0;ix<nx;ix++) {

      int i;
      
      if ( missing != (vertexArray[iz*nx+ix].missing() || vertexArray[(iz+1)*nx+ix].missing()) ) {
        missing = !missing;
        if (missing) glEnd();
        else glBegin(GL_QUAD_STRIP);
      }
      if (!missing) {
        // If orientation == 1, we draw iz+1 first, otherwise iz first      
        i = (iz+  orientation)*nx+ix;
  
        glArrayElement( i );
  
        i = (iz+ !orientation)*nx+ix;
        glArrayElement( i );
      }
    }
    if (!missing) glEnd();
  }

  drawEnd(renderContext);
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
  if (num) accu = accu * (1.0/num);
  return accu;  
} 

Vertex Surface::getElementCenter(int index) 
{
  return getCenter( index % (nx-1), index / (nx-1) );
}

void Surface::drawBegin(RenderContext* renderContext)
{
  Shape::drawBegin(renderContext);
  material.beginUse(renderContext);
  vertexArray.beginUse();

  if (use_texcoord)
    texCoordArray.beginUse();
    
  if (use_normal)
    normalArray.beginUse();

}

void Surface::drawElement(RenderContext* renderContext, int index)
{
  int ix = index % (nx-1), iz = index / (nx-1),
      s = iz*nx + ix;
  if (!vertexArray[s].missing() &&
      !vertexArray[s+1].missing() &&
      !vertexArray[s+nx].missing() &&
      !vertexArray[s+nx+1].missing()) {
    glBegin(GL_QUAD_STRIP);
    for (int i = 0 ; i < 2; ++i ) {
      ix = s % nx + i;
      for (int j = 0 ; j < 2; ++j ) {
        if (orientation)
          iz = s / nx + !j;
        else
          iz = s / nx + j;
        glArrayElement( iz*nx + ix );       
      }
    }
    glEnd();
  }
}  
  
void Surface::drawEnd(RenderContext* renderContext) 
{

  if (use_normal)
    normalArray.endUse();
    
  if (use_texcoord)
    texCoordArray.endUse();

  vertexArray.endUse();

  material.endUse(renderContext);
  Shape::drawEnd(renderContext);

}

int Surface::getAttributeCount(AABox& bbox, AttribID attrib)
{
  switch (attrib) {
    case VERTICES: return nx*nz;
    case NORMALS: if (use_normal)
    		    return nx*nz;
    		  else
    		    return 0;
    case TEXCOORDS: if (use_texcoord) 
    		      return nx*nz;
    		    else
    		      return 0;
    case SURFACEDIM: return 1;
  }
  return Shape::getAttributeCount(bbox, attrib);
}

void Surface::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    switch (attrib) {
      case VERTICES: {
        while (first < n) {
          *result++ = vertexArray[first].x;
          *result++ = vertexArray[first].y;
          *result++ = vertexArray[first].z;
          first++;
        }
        return;
      }        
      case NORMALS: {
        while (first < n) {
          *result++ = normalArray[first].x;
          *result++ = normalArray[first].y;
          *result++ = normalArray[first].z;
          first++;
        }
        return;
      }
      case TEXCOORDS: {
        while (first < n) {
          *result++ = texCoordArray[first].s;
	  *result++ = texCoordArray[first].t;
	  first++;
	}
	return;
      }
      case SURFACEDIM: {
        *result++ = nx;
        *result++ = nz;
        return;
      }
    }
    Shape::getAttribute(bbox, attrib, first, count, result);
  }
}
