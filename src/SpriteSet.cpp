
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
                     bool in_fixedSize, Scene *in_scene, double* in_adj,
                     int in_npos, int *in_pos, double in_offset)
 : Shape(in_material, in_ignoreExtent, SHAPE, true), 
  vertex(in_nvertex, in_vertex),
   size(in_nsize, in_size),
   pos(in_npos, in_pos),
   offset(in_offset),
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
  if (!in_adj)
    adj = Vec3(0.5, 0.5, 0.5);
  else
    adj = Vec3(in_adj[0], in_adj[1], in_adj[2]);
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

/* These routines are for debugging
 
static void printMatrix(const char* msg, double* m) {
  Rprintf("%s:\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n%f %f %f %f\n",
          msg, m[0], m[4], m[8], m[12],
                                  m[1], m[5], m[9], m[13],
                                                     m[2], m[6], m[10], m[14],
                                                                         m[3], m[7], m[11], m[15]);
}

static void printMatrix(const char* msg, Matrix4x4 m) {
  double data[16];
  m.getData(data);
  printMatrix(msg, data);
}

static void printMVMatrix(const char* msg) {
  double m[16] = {0};
#ifndef RGL_NO_OPENGL
  glGetDoublev(GL_MODELVIEW_MATRIX, m);
#endif
  printMatrix(msg, m);
}

static void printPRMatrix(const char* msg) {
  double m[16] = {0};
#ifndef RGL_NO_OPENGL
  glGetDoublev(GL_PROJECTION_MATRIX, m);
#endif
  printMatrix(msg, m);  
}
*/

void SpriteSet::drawBegin(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  
  Shape::drawBegin(renderContext);

  m = Matrix4x4(renderContext->subscene->modelMatrix);
  
  if (fixedSize) {
    
    p = Matrix4x4(renderContext->subscene->projMatrix);
  
    renderContext->subscene->projMatrix.setIdentity();
  
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
  /* We need to modify the variable rather than the GPU's
   * copy, because some objects refer to it
   */
  Matrix4x4 *modelMatrix = &renderContext->subscene->modelMatrix;
  
  if (fixedSize) {
    float winwidth  = (float) renderContext->rect.width;
    float winheight = (float) renderContext->rect.height;
    // The magic number 27 is chosen so that plotmath3d matches text3d.
    float scalex = 27.0f/winwidth, scaley = 27.0f/winheight;
    v3 =  (p * m) * o;
    *modelMatrix = Matrix4x4::translationMatrix(v3.x, v3.y, v3.z)*
                   Matrix4x4::scaleMatrix(scalex, scaley, (scalex + scaley)/2.0f);
  } else {
    s = s * 0.5f;	
    v3 = m * o;
    *modelMatrix = Matrix4x4::translationMatrix(v3.x, v3.y, v3.z);
  }
  
  if (pos.size())
    getAdj(index);
  
  if (shapes.size()) {
    Shape::drawEnd(renderContext);  // The shape will call drawBegin/drawEnd
    *modelMatrix = (*modelMatrix)*
                   Matrix4x4::scaleMatrix(2*s,2*s,2*s)*
                   Matrix4x4::translationMatrix((1.0 - 2.0*adj.x), 
                                                (1.0 - 2.0*adj.y),
                                                (1.0 - 2.0*adj.z))*
                   Matrix4x4(userMatrix);

    /* Since we modified modelMatrix, we need to reload it */
    renderContext->subscene->loadMatrices();    
    
    for (std::vector<int>::iterator i = shapes.begin(); i != shapes.end() ; ++ i ) 
      scene->get_shape(*i)->draw(renderContext);  
    
    Shape::drawBegin(renderContext);
 }  else {
    material.useColor(index);
    /* Since we modified modelMatrix, we need to reload it */
    renderContext->subscene->loadMatrices();
    glBegin(GL_QUADS);
    if (doTex)
      glTexCoord2f(0.0f,0.0f);
    glVertex3f(s*(0.0 - 2.0*adj.x), 
               s*(0.0 - 2.0*adj.y), 
               s*(1.0 - 2.0*adj.z));
 
    if (doTex)
      glTexCoord2f(1.0f,0.0f);
    glVertex3f(s*(2.0 - 2.0*adj.x), 
               s*(0.0 - 2.0*adj.y), 
               s*(1.0 - 2.0*adj.z));

    if (doTex)
      glTexCoord2f(1.0f,1.0f);
    glVertex3f(s*(2.0 - 2.0*adj.x), 
               s*(2.0 - 2.0*adj.y), 
               s*(1.0 - 2.0*adj.z));

    if (doTex)
      glTexCoord2f(0.0f,1.0f);
    glVertex3f(s*(0.0 - 2.0*adj.x), 
               s*(2.0 - 2.0*adj.y), 
               s*(1.0 - 2.0*adj.z)); 
  
    glEnd();
  }
#endif
}
  
void SpriteSet::getAdj(int index)
{
  int p = pos.get(index);
  switch(p) {
    case 0:
    case 1:
    case 3:
    case 5:
    case 6:
      adj.x = 0.5;
      break;
    case 2:
      adj.x = 1.0 + offset;
      break;
    case 4:
      adj.x = -offset;
      break;
  }
  switch(p) {
    case 0:
    case 2:
    case 4:
    case 5:
    case 6:
      adj.y = 0.5;
      break;
    case 1:
      adj.y = 1.0 + offset;
      break;
    case 3:
      adj.y = -offset;
      break;
  }
  switch(p) {
    case 0:
    case 1:
    case 2:
    case 3:
    case 4:
      adj.z = 0.5;
      break;
    case 5:
      adj.z = -offset;
      break;
    case 6:
      adj.z = 1.0 + offset;
      break;
  }
}

void SpriteSet::drawEnd(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  if (fixedSize) {
    renderContext->subscene->projMatrix = Matrix4x4(p);
  }
  renderContext->subscene->modelMatrix = Matrix4x4(m);
  /* Restore the original GPU matrices */
  renderContext->subscene->loadMatrices();  
  if (!shapes.size())
    material.endUse(renderContext);
  Shape::drawEnd(renderContext);
#endif
}

void SpriteSet::render(RenderContext* renderContext)
{ 
    draw(renderContext);
}

int SpriteSet::getAttributeCount(SceneNode* subscene, AttribID attrib) 
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
    case ADJ: return 1;
    case POS: return pos.size();
  }
  return Shape::getAttributeCount(subscene, attrib);
}

void SpriteSet::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
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
          *result++ = userMatrix[4*first];
          *result++ = userMatrix[4*first+1];
          *result++ = userMatrix[4*first+2];
          *result++ = userMatrix[4*first+3];
          first++;
        }
        return;
      case FLAGS:
      	if (first == 0) *result++ = (double) ignoreExtent;
      	*result++ = (double) fixedSize;
      	return;
      case ADJ:
        if (pos.size() > 0) {
          *result++ = offset;
          *result++ = NA_REAL;
          *result++ = NA_REAL;
        } else {
          *result++ = adj.x;
          *result++ = adj.y;
    	  *result++ = adj.z;
        }
      	return;
      case POS:
      	while (first < n)
      	  *result++ = pos.get(first++);
      	return;      	
    }  
    Shape::getAttribute(subscene, attrib, first, count, result);
  }
}

String SpriteSet::getTextAttribute(SceneNode* subscene, AttribID attrib, int index)
{
  int n = getAttributeCount(subscene, attrib);
  if (index < n && attrib == TYPES) {
    char* buffer = R_alloc(20, 1);    
    scene->get_shape(shapes[index])->getTypeName(buffer, 20);
    return String(static_cast<int>(strlen(buffer)), buffer);
  } else
    return Shape::getTextAttribute(subscene, attrib, index);
}

Shape* SpriteSet::get_shape(int id)
{
  return scene->get_shape(id);
}

void SpriteSet::remove_shape(int id)
{
  shapes.erase(std::remove(shapes.begin(), shapes.end(), id), shapes.end());
}
