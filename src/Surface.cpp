#include "Surface.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Surface
//

Surface::Surface(Material& in_material, int in_nx, int in_nz, double* in_x, double* in_z, double* in_y)
: Shape(in_material)
{
  nx = in_nx;
  nz = in_nz;

  int nvertex = nx*nz;

  material.colorPerVertex(true, nvertex);

  vertexArray.alloc(nvertex);

  if (material.texture)
    texCoordArray.alloc(nvertex);

  Vertex v;

  int iy  = 0;
  for(int iz=0;iz<nz;iz++) {
    v.z = (float) in_z[iz];
    for(int ix=0;ix<nx;ix++,iy++) {
      v.x = (float) in_x[ix];
      v.y = (float) in_y[iy];

      vertexArray[iy] = v;

      if (material.texture) {
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

  if (ix < nx-1) {
    if (iz > 0)     // right/top
      n[num++] = vertexArray.getNormal(i, i+1, i-nx );
    if (iz < nz-1)  // right/bottom
      n[num++] = vertexArray.getNormal(i, i+nx, i+1 );
  }
  if (ix > 0) { 
    if (iz > 0)     // left/top
      n[num++] = vertexArray.getNormal(i, i-nx, i-1 );
    if (iz < nz-1)  // left/bottom
      n[num++] = vertexArray.getNormal(i, i-1, i+nx );
  }

  Vertex total(0.0f,0.0f,0.0f);

  for(i=0;i<num;i++)
    total += n[i];

  total.normalize();

  glNormal3f(total.x,total.y,total.z);
}

void Surface::draw(RenderContext* renderContext)
{
  material.beginUse(renderContext);
  vertexArray.beginUse();

  if (material.texture)
    texCoordArray.beginUse();

  for(int iz=0;iz<nz-1;iz++) {
    glBegin(GL_QUAD_STRIP);
    for(int ix=0;ix<nx;ix++) {

      int i;

      i = (iz)  *nx+ix;
      if (material.lit)
        setNormal(ix, iz);
      glArrayElement( i );

      i = (iz+1)*nx+ix;
      if (material.lit)
        setNormal(ix, iz+1);
      glArrayElement( i );

    }
    glEnd();
  }

  if (material.texture)
    texCoordArray.endUse();

  vertexArray.endUse();

  material.endUse(renderContext);
}

void Surface::renderZSort(RenderContext* renderContext)
{
  Shape::renderZSort(renderContext);
}
