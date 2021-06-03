
#include "SpriteSet.h"
#include "Shape.h"
#include "R.h"
#include <algorithm>

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   SpriteSet
//

SpriteSet::SpriteSet(Material& in_material, int in_nvertex, double* in_vertex, int in_nsize, double* in_size,
                     int in_ignoreExtent, int count, Shape** in_shapelist, double* in_userMatrix,
                     bool in_fixedSize, Scene *in_scene)
 : Shape(in_material, in_ignoreExtent, SHAPE, true), 
  vertex(in_nvertex, in_vertex),
   size(in_nsize, in_size),
   fixedSize(in_fixedSize),
   scene(in_scene)
{ 
  if (!count)
    material.colorPerVertex(false);
  else {
    blended = false;
    for (int i=0;i<count;i++) {
      shapes.push_back(in_shapelist[i]->getObjID());
      blended |= in_shapelist[i]->isBlended();
    }
    for (int i=0;i<16;i++)
      userMatrix[i] = *(in_userMatrix++);
  }
  for(int i=0;i<vertex.size();i++)
    boundingBox += Sphere( vertex.get(i), static_cast<float>(size.getRecycled(i)/1.414) );
}

SpriteSet::~SpriteSet()
{ 
  shapes.clear();
}

int SpriteSet::getElementCount(void) 
{
  return vertex.size();
}
	
Vertex SpriteSet::getPrimitiveCenter(int index)
{
  return vertex.get(index);
}

void SpriteSet::drawBegin(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  double mdata[16] = { 0 }, pdata[16] = { 0 };
  
  Shape::drawBegin(renderContext);

  glGetDoublev(GL_MODELVIEW_MATRIX, mdata);

  m = Matrix4x4(mdata);

  glPushMatrix();
  
  if (fixedSize) {
    glMatrixMode(GL_PROJECTION);
  
    glGetDoublev(GL_PROJECTION_MATRIX, pdata);
  
    p = Matrix4x4(pdata);
  
    glPushMatrix();
    glLoadIdentity();
  
    glMatrixMode(GL_MODELVIEW);
  }

  if (!shapes.size()) {
    doTex = (material.texture) ? true : false;
    glNormal3f(0.0f,0.0f,1.0f);
    material.beginUse(renderContext);
  }
#endif
}

void SpriteSet::drawPrimitive(RenderContext* renderContext, int index)
{
#ifndef RGL_NO_OPENGL
  Vertex o;
  BBoxDeco* bboxdeco = 0;
  if (material.marginCoord >= 0) {
    Subscene* subscene = renderContext->subscene;
    bboxdeco = subscene->get_bboxdeco();
  }  
  if (bboxdeco) 
    o = bboxdeco->marginVecToDataVec(vertex.get(index), renderContext, &material);
  else
    o = vertex.get(index);
  float   s = size.getRecycled(index);
  if (o.missing() || ISNAN(s)) return;

  Vec3 v3;
  Vec4 v4;
  
  glLoadIdentity();
  if (fixedSize) {
    float winwidth  = (float) renderContext->rect.width;
    float winheight = (float) renderContext->rect.height;
    // The magic number 27 is chosen so that plotmath3d matches text3d.
    float scalex = 27.0f/winwidth, scaley = 27.0f/winheight;
    v4 =  p * (m * Vec4(o.x, o.y, o.z, 1.0f));
    glTranslatef(v4.x/v4.w, v4.y/v4.w, v4.z/v4.w);
    glScalef(scalex, scaley, (scalex + scaley)/2.0f);
  } else {
    s = s * 0.5f;	
    v3 = m * o;
    glTranslatef(v3.x, v3.y, v3.z);
  }
  
  if (shapes.size()) {
    Shape::drawEnd(renderContext);  // The shape will call drawBegin/drawEnd

    glMultMatrixd(userMatrix);
    
    glScalef(s,s,s);
    for (std::vector<int>::iterator i = shapes.begin(); i != shapes.end() ; ++ i ) 
      scene->get_shape(*i)->draw(renderContext);  
    
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
#endif
}
  
void SpriteSet::drawEnd(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  if (fixedSize) {
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
  }
  glPopMatrix();
  
  if (!shapes.size())
    material.endUse(renderContext);
  Shape::drawEnd(renderContext);
#endif
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
    case IDS:	   
    case TYPES:    return static_cast<int>(shapes.size());
    case USERMATRIX: {
      if (!shapes.size()) return 0;
      else return 4;
    }
    case FLAGS:	   return 2;
  }
  return Shape::getAttributeCount(bbox, attrib);
}

void SpriteSet::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);
  int ind = 0;

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
      case IDS:
        for (std::vector<int>::iterator i = shapes.begin(); i != shapes.end() ; ++ i ) {
      	  if ( first <= ind  && ind < n )  
            *result++ = *i;
          ind++;
        }
        return;
      case USERMATRIX:
        while (first < n) {
          *result++ = userMatrix[first];
          *result++ = userMatrix[4 + first];
          *result++ = userMatrix[8 + first];
          *result++ = userMatrix[12 + first];
          first++;
        }
        return;
      case FLAGS:
      	if (first == 0) *result++ = (double) ignoreExtent;
      	*result++ = (double) fixedSize;
      	return;
    }  
    Shape::getAttribute(bbox, attrib, first, count, result);
  }
}

String SpriteSet::getTextAttribute(AABox& bbox, AttribID attrib, int index)
{
  int n = getAttributeCount(bbox, attrib);
  if (index < n && attrib == TYPES) {
    char* buffer = R_alloc(20, 1);    
    scene->get_shape(shapes[index])->getTypeName(buffer, 20);
    return String(static_cast<int>(strlen(buffer)), buffer);
  } else
    return Shape::getTextAttribute(bbox, attrib, index);
}

Shape* SpriteSet::get_shape(int id)
{
  return scene->get_shape(id);
}

void SpriteSet::remove_shape(int id)
{
  shapes.erase(std::remove(shapes.begin(), shapes.end(), id), shapes.end());
}
