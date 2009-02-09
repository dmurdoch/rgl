#include "SpriteSet.hpp"

#include "R.h"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   SpriteSet
//

SpriteSet::SpriteSet(Material& in_material, int in_nvertex, double* in_vertex, int in_nsize, double* in_size,
                     int in_ignoreExtent)
 : Shape(in_material, in_ignoreExtent), 
  vertex(in_nvertex, in_vertex),
   size(in_nsize, in_size)
{ 
  material.colorPerVertex(false);

  for(int i=0;i<vertex.size();i++)
    boundingBox += Sphere( vertex.get(i), size.getRecycled(i) );
}

SpriteSet::~SpriteSet()
{ }

int SpriteSet::getElementCount(void) 
{
  return vertex.size();
}
  
Vertex SpriteSet::getElementCenter(int index)
{
  return vertex.get(index);
}

void SpriteSet::drawBegin(RenderContext* renderContext)
{
  double mdata[16] = { 0 };
  
  Shape::drawBegin(renderContext);

  glGetDoublev(GL_MODELVIEW_MATRIX, mdata);

  m = Matrix4x4(mdata);

  material.beginUse(renderContext);
  
  glPushMatrix();

  glLoadIdentity();
  
  doTex = (material.texture) ? true : false;

  glNormal3f(0.0f,0.0f,1.0f);


}

void SpriteSet::drawElement(RenderContext* renderContext, int index)
{
  Vertex& o = vertex.get(index);
  float   s = size.getRecycled(index);
  if (o.missing() || ISNAN(s)) return;

  Vertex  v;
  s = s * 0.5f;
  v = m * o;

  material.useColor(index);
  
  glBegin(GL_QUADS);
  
  if (doTex)
    glTexCoord2f(0.0f,0.0f);
  glVertex3f(v.x - s, v.y - s, v.z);

  if (doTex)
    glTexCoord2f(1.0f,0.0f);
  glVertex3f(v.x + s, v.y - s, v.z);

  if (doTex)
    glTexCoord2f(1.0f,1.0f);
  glVertex3f(v.x + s, v.y + s, v.z);

  if (doTex)
    glTexCoord2f(0.0f,1.0f);
  glVertex3f(v.x - s, v.y + s, v.z);  
  
  glEnd();
}
  
void SpriteSet::drawEnd(RenderContext* renderContext)
{
  glPopMatrix();

  material.endUse(renderContext);
  Shape::drawEnd(renderContext);
}

void SpriteSet::render(RenderContext* renderContext)
{ 
  draw(renderContext);
}
