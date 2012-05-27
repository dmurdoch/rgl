#include "SpriteSet.hpp"

#include "R.h"

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   SpriteSet
//

SpriteSet::SpriteSet(Material& in_material, int in_nvertex, double* in_vertex, int in_nsize, double* in_size,
                     int in_ignoreExtent, int count, Shape** in_shapelist, double* in_userMatrix)
 : Shape(in_material, in_ignoreExtent), 
  vertex(in_nvertex, in_vertex),
   size(in_nsize, in_size)
{ 
  if (!count)
    material.colorPerVertex(false);
  else {
    for (int i=0;i<count;i++)
      shapes.push_back(in_shapelist[i]);
    for (int i=0;i<16;i++)
      userMatrix[i] = *(in_userMatrix++);
  }
  for(int i=0;i<vertex.size();i++)
    boundingBox += Sphere( vertex.get(i), size.getRecycled(i) );
}

SpriteSet::~SpriteSet()
{ 
  shapes.clear();
}

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

  glPushMatrix();

  if (!shapes.size()) {
    doTex = (material.texture) ? true : false;
    glNormal3f(0.0f,0.0f,1.0f);
    material.beginUse(renderContext);
  }
}

void SpriteSet::drawElement(RenderContext* renderContext, int index)
{
  Vertex& o = vertex.get(index);
  float   s = size.getRecycled(index);
  if (o.missing() || ISNAN(s)) return;

  Vertex  v;
  s = s * 0.5f;
  v = m * o;

  glLoadIdentity();
  glTranslatef(v.x, v.y, v.z);
  
  if (shapes.size()) {
    Shape::drawEnd(renderContext);  // The shape will call drawBegin/drawEnd

    glMultMatrixd(userMatrix);
    
    glScalef(s,s,s);
    for (std::vector<Shape*>::iterator i = shapes.begin(); i != shapes.end() ; ++ i ) 
      (*i)->draw(renderContext);  
    
    Shape::drawBegin(renderContext);
 }  else {
    material.useColor(index);
  
    glBegin(GL_QUADS);
  
    if (doTex)
      glTexCoord2f(0.0f,0.0f);
    glVertex3f(-s, -s, 0.0f);
 
    if (doTex)
      glTexCoord2f(1.0f,0.0f);
    glVertex3f(s, -s, 0.0f);

    if (doTex)
      glTexCoord2f(1.0f,1.0f);
    glVertex3f(s, s, 0.0);

    if (doTex)
      glTexCoord2f(0.0f,1.0f);
    glVertex3f(-s, s, 0.0f);  
  
    glEnd();
  }
}
  
void SpriteSet::drawEnd(RenderContext* renderContext)
{
  glPopMatrix();

  if (!shapes.size())
    material.endUse(renderContext);
  Shape::drawEnd(renderContext);
}

void SpriteSet::render(RenderContext* renderContext)
{ 
    draw(renderContext);
}

int SpriteSet::getAttributeCount(AABox& bbox, AttribID attrib) 
{
  switch (attrib) {
    case VERTICES: return vertex.size();
    case RADII:    return size.size();
  }
  return Shape::getAttributeCount(bbox, attrib);
}

void SpriteSet::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    switch(attrib) {
      case VERTICES:
        while (first < n) {
          Vertex v = vertex.get(first);
          *result++ = v.x;
          *result++ = v.y;
          *result++ = v.z;
          first++;
        }
        return;     
      case RADII:
        while (first < n) 
          *result++ = size.get(first++);
        return;
    }  
    Shape::getAttribute(bbox, attrib, first, count, result);
  }
}

