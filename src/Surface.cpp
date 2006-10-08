#include "Surface.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Surface
//
// in_coords permutes the coordinates to allow surfaces over arbitrary planes
// orientation is 1 to swap front and back

Surface::Surface(Material& in_material, int in_nx, int in_nz, double* in_x, double* in_z, double* in_y, 
	         int* in_coords, int in_orientation, int in_ignoreExtent)
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

  int iy  = 0;
  for(int iz=0;iz<nz;iz++) {
    *z = (float) in_z[iz];
    for(int ix=0;ix<nx;ix++,iy++) {
      *x = (float) in_x[ix];
      *y = (float) in_y[iy];

      vertexArray[iy] = v;

      if ( (material.texture) && (! material.texture->is_envmap() ) ) {
        texCoordArray[iy].s = ((float)ix)/((float)(nx-1));
        texCoordArray[iy].t = 1.0f - ((float)iz)/((float)(nx-1));
      }

      boundingBox += v;
    }
  }
}

void Surface::setNormal(int ix, int iz)
{
  Vertex n[4];

  int i = iz*nx + ix;
  int num = 0;
  
  if (!vertexArray[i].missing()) {
    if (ix < nx-1 && !vertexArray[i+1].missing() ) {
      if (iz > 0 && !vertexArray[i-nx].missing() )     // right/top
        n[num++] = vertexArray.getNormal(i, i+1, i-nx );
      if (iz < nz-1 && !vertexArray[i+nx].missing() )  // right/bottom
        n[num++] = vertexArray.getNormal(i, i+nx, i+1 );
    }
    if (ix > 0 && !vertexArray[i-1].missing() ) { 
      if (iz > 0 && !vertexArray[i-nx].missing() )     // left/top
        n[num++] = vertexArray.getNormal(i, i-nx, i-1 );
      if (iz < nz-1 && !vertexArray[i+nx].missing() )  // left/bottom
        n[num++] = vertexArray.getNormal(i, i-1, i+nx );
    }
  }
  Vertex total(0.0f,0.0f,0.0f);

  for(i=0;i<num;i++)
    total += n[i];

  total.normalize();

  if (orientation) glNormal3f(-total.x,-total.y,-total.z);
  else glNormal3f(total.x,total.y,total.z);    
}

void Surface::draw(RenderContext* renderContext)
{
  material.beginUse(renderContext);
  vertexArray.beginUse();

  bool use_texcoord = material.texture && !(material.texture->is_envmap() );
  bool use_normal   = material.lit || ( (material.texture) && (material.texture->is_envmap() ) );
  bool missing;
  
  if (use_texcoord)
    texCoordArray.beginUse();

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
  
        if (use_normal)
          setNormal(ix, iz+orientation);
        glArrayElement( i );
  
        i = (iz+ !orientation)*nx+ix;
        if (use_normal)
          setNormal(ix, iz+!orientation);
        glArrayElement( i );
      }
    }
    if (!missing) glEnd();
  }

  if (use_texcoord)
    texCoordArray.endUse();

  vertexArray.endUse();

  material.endUse(renderContext);
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
  
void Surface::renderZSort(RenderContext* renderContext)
{
  std::multimap<float,int> distanceMap;
  for (int ix = 0 ; ix < nx-1 ; ++ix ) {
    for (int iz = 0 ; iz < nz-1 ; ++iz ) {
      float distance = renderContext->getDistance( getCenter(ix, iz) );
      distanceMap.insert( std::pair<float,int>(-distance,iz*nx + ix) );
    }
  }

  material.beginUse(renderContext);
  vertexArray.beginUse();

  bool use_texcoord = material.texture && !(material.texture->is_envmap() );
  bool use_normal   = material.lit || ( (material.texture) && (material.texture->is_envmap() ) );

  if (use_texcoord)
    texCoordArray.beginUse();

  for ( std::multimap<float,int>::iterator iter = distanceMap.begin(); iter != distanceMap.end() ; ++ iter ) {
    int s = iter->second;
    if (!vertexArray[s].missing() &&
        !vertexArray[s+1].missing() &&
        !vertexArray[s+nx].missing() &&
        !vertexArray[s+nx+1].missing()) {
      glBegin(GL_QUAD_STRIP);
      for (int i = 0 ; i < 2; ++i ) {
        int ix = s % nx + i;
        for (int j = 0 ; j < 2; ++j ) {
          int iz;
          if (orientation)
            iz = s / nx + !j;
          else
            iz = s / nx + j;
          if (use_normal)
            setNormal(ix, iz);
          glArrayElement( iz*nx + ix );       
        }
      }
      glEnd();
    }
  }  

  if (use_texcoord)
    texCoordArray.endUse();

  vertexArray.endUse();

  material.endUse(renderContext);
}
