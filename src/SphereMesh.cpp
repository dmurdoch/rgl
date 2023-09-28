#include "R.h"
#include "SphereMesh.h"
#include "SphereSet.h"
#include "subscene.h"

#include "opengl.h"
#include <map>

using namespace rgl;

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

  nvertex = (sections+1) * (segments+1);

  vertexArray.alloc(nvertex);

  if (genNormal || doUseShaders)
    normalArray.alloc(nvertex);

  if (genTexCoord || doUseShaders)
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

    Vertex p(0.0f,0.0f,1.0f);

    float fy = ((float)iy)/((float)sections);

    float phi = philow + fy * (phihigh - philow);

    p.rotateX( -phi );

    for (int ix=0;ix<=segments;ix++,i++) {

      float fx  = ((float)ix)/((float)segments);
      float theta = fx * 360.0f;

      Vertex q(p);

      q.rotateY( theta );
      
      if (doUseShaders) 
        
        vertexArray[i] = q;
     
      else {
        
        q.x *= radius / scale.x;
        q.y *= radius / scale.y;
        q.z *= radius / scale.z;
        
        vertexArray[i] = center + q;
      }
      
      if (genNormal || doUseShaders) {
        q.x *= scale.x*scale.x;
        q.y *= scale.y*scale.y;
        q.z *= scale.z*scale.z;
        normalArray[i] = q;
        normalArray[i].normalize();
      }

      if (genTexCoord || doUseShaders) {
        texCoordArray[i].s = fx;
        texCoordArray[i].t = fy;
      }

    }
  }
}

/* Set the modelviewmatrix for a shader */

Matrix4x4 SphereMesh::MVmodification(const Vertex& scale)
{
  return  Matrix4x4::translationMatrix(center.x, center.y, center.z) 
        * Matrix4x4::scaleMatrix(radius/scale.x, radius/scale.y, radius/scale.z);
}

void SphereMesh::draw(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  vertexArray.beginUse();

  if (genNormal || doUseShaders)
    normalArray.beginUse();

  if (genTexCoord || doUseShaders)
    texCoordArray.beginUse();
  
  if (doUseShaders) {
    inds.resize(2*(segments + 1));
  }
  
  for(int i=0; i<sections; i++ ) {

    int curr = i * (segments+1);
    int next = curr + (segments+1);

    if (doUseShaders) {

      int nextind = 0;
      
      for (int j=0; j<=segments; j++) {
        inds[nextind++] = next + j;
        inds[nextind++] = curr + j;
      }
      if (doUseShaders)
        glDrawElements(GL_QUAD_STRIP, inds.size(), GL_UNSIGNED_INT, inds.data());
    } else {
      glBegin(GL_QUAD_STRIP);
      for(int j=0;j<=segments;j++) {
        glArrayElement( next + j );
        glArrayElement( curr + j );
      }
      glEnd();
    }
  }
  

  SAVEGLERROR;
  
  vertexArray.endUse();

  if (genNormal || doUseShaders)
    normalArray.endUse();

  if (genTexCoord || doUseShaders)
    texCoordArray.endUse();
  
  SAVEGLERROR;
#endif
}

void SphereMesh::drawBegin(RenderContext* renderContext, bool endcap)
{
#ifndef RGL_NO_OPENGL
  vertexArray.beginUse();

  if (genNormal || doUseShaders)
    normalArray.beginUse();

  if (genTexCoord || doUseShaders)
    texCoordArray.beginUse();
  
  if (!doUseShaders) {
    if (endcap)
      glBegin(GL_TRIANGLES);
    else
      glBegin(GL_QUADS);
  }
#endif
}

void SphereMesh::drawPrimitive(RenderContext* renderContext, int i)
{
#ifndef RGL_NO_OPENGL
  int ll = (segments + 1)*(i/segments) + i % segments;

  if (doUseShaders) {
    inds.push_back(ll);
    inds.push_back(ll + 1);
    inds.push_back(ll + segments + 2);
    inds.push_back(ll + segments + 1);
  } else {
    if (i < segments) {
      glArrayElement(ll);
      glArrayElement(ll + segments + 2);
      glArrayElement(ll + segments + 1);
    } else if (i < segments*(sections - 1)) {
      glArrayElement(ll);
      glArrayElement(ll + 1);
      glArrayElement(ll + segments + 2);
      glArrayElement(ll + segments + 1);
    } else {
      glArrayElement(ll);
      glArrayElement(ll + 1);
      glArrayElement(ll + segments + 1);
    }
  }
#endif
}

Vertex SphereMesh::getPrimitiveCenter(int i) 
{
  int ll = (segments + 1)*(i/segments) + i % segments;
  if (doUseShaders)
    return center + vertexArray[ll]*radius;
  else
    return vertexArray[ll];
}

void SphereMesh::doIndices() {
#ifndef RGL_NO_OPENGL
  if (inds.size()) {
    glDrawElements(GL_QUADS, inds.size(), GL_UNSIGNED_INT, inds.data());
    inds.clear();
  } 
#endif
}

void SphereMesh::drawEnd(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  
  if (!doUseShaders)
    glEnd();

  vertexArray.endUse();

  if (genNormal || doUseShaders)
    normalArray.endUse();

  if (genTexCoord || doUseShaders)
    texCoordArray.endUse();
#endif
}

#ifndef RGL_NO_OPENGL
void SphereMesh::initialize(
    std::unordered_map<std::string, GLint> &glLocs,
    std::vector<GLubyte> &vertexbuffer)
{
  vertexArray.appendToBuffer(vertexbuffer);
  vertexArray.setAttribLocation(glLocs["aPos"]);
  
  if (glLocs.find("aNorm") != glLocs.end()) {
    normalArray.appendToBuffer(vertexbuffer);
    normalArray.setAttribLocation(glLocs.at("aNorm"));
  }
  
  if (glLocs.find("aTexcoord") != glLocs.end()) {
    texCoordArray.appendToBuffer(vertexbuffer);
    texCoordArray.setAttribLocation(glLocs["aTexcoord"]);
  }
}
#endif