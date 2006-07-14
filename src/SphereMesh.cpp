#include "SphereMesh.hpp"

#include "opengl.hpp"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   SphereMesh
//


SphereMesh::SphereMesh()
: center( Vertex(0.0f,0.0f,0.0f) ), 
  radius( 1.0f ),
  philow(-90.0f ),
  phihigh( 90.0f ),
  segments( 16 ),
  sections( 16 ),
  type( GLOBE ),
  genNormal(false),
  genTexCoord(false)
{
}

void SphereMesh::setGlobe(int in_segments, int in_sections)
{
  type     = GLOBE;
  segments = in_segments;
  sections = in_sections;
  setupMesh();
}

void SphereMesh::setTesselation(int level)
{
  type     = TESSELATION;
}

void SphereMesh::setupMesh()
{
  // setup arrays

  int nvertex = (sections+1) * (segments+1);

  vertexArray.alloc(nvertex);

  if (genNormal)
    normalArray.alloc(nvertex);

  if (genTexCoord)
    texCoordArray.alloc(nvertex);  
}

void SphereMesh::setCenter(const Vertex& in_center)
{
  center = in_center;
}

void SphereMesh::setRadius(float in_radius)
{
  radius = in_radius;
}

void SphereMesh::update()
{
  Vertex scale;
  scale.x = scale.y = scale.z = 1.0;
  update(scale);
}

void SphereMesh::update(const Vertex& scale)
{
  int i = 0;

  for(int iy=0;iy<=sections;iy++) {

    Vertex p(0.0f,0.0f,radius);

    float fy = ((float)iy)/((float)sections);

    float phi = philow + fy * (phihigh - philow);

    p.rotateX( -phi );

    for (int ix=0;ix<=segments;ix++,i++) {

      float fx  = ((float)ix)/((float)segments);
      float theta = fx * 360.0f;

      Vertex q(p);

      q.rotateY( theta );
      
      q.x /= scale.x;
      q.y /= scale.y;
      q.z /= scale.z;

      vertexArray[i] = center + q;

      if (genNormal) {
	q.x *= scale.x*scale.x;
	q.y *= scale.y*scale.y;
	q.z *= scale.z*scale.z;
        normalArray[i] = q;
        normalArray[i].normalize();
      }

      if (genTexCoord) {
        texCoordArray[i].s = fx;
        texCoordArray[i].t = fy;
      }

    }
  }
}

void SphereMesh::draw(RenderContext* renderContext)
{
  vertexArray.beginUse();

  if (genNormal)
    normalArray.beginUse();

  if (genTexCoord)
    texCoordArray.beginUse();

  for(int i=0; i<sections; i++ ) {

    int curr = i * (segments+1);
    int next = curr + (segments+1);

    glBegin(GL_QUAD_STRIP);
    for(int i=0;i<=segments;i++) {
      glArrayElement( next + i );
      glArrayElement( curr + i );
    }
    glEnd();
  }

  vertexArray.endUse();

  if (genNormal)
    normalArray.endUse();

  if (genTexCoord)
    texCoordArray.endUse();
}



