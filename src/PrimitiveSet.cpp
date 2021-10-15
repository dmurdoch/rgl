#include "PrimitiveSet.h"
#include "BBoxDeco.h"
#include "subscene.h"
#include "R.h"

using namespace rgl;

// ===[ PRIMITIVE SET ]=======================================================

PrimitiveSet::PrimitiveSet (

    Material& in_material, 
    int in_type,
    int in_nverticesperelement,
    bool in_ignoreExtent,
    bool in_bboxChange
    ) :
Shape(in_material, in_ignoreExtent, SHAPE, in_bboxChange)
{
  type                = in_type;
  nverticesperelement = in_nverticesperelement;
  nvertices           = 0;
  nindices            = 0;
}

void PrimitiveSet::initPrimitiveSet(
    int in_nvertices, 
    double* in_vertices,
    int in_nindices,
    int* in_indices
) {
  nvertices           = in_nvertices;
  nindices            = in_nindices;
  if (nindices)
    nprimitives       = nindices / nverticesperelement;
  else
    nprimitives       = nvertices / nverticesperelement;
  vertexArray.alloc(nvertices);
  hasmissing = false;
  for(int i=0;i<nvertices;i++) {
    vertexArray[i].x = (float) in_vertices[i*3+0];
    vertexArray[i].y = (float) in_vertices[i*3+1];
    vertexArray[i].z = (float) in_vertices[i*3+2];
    boundingBox += vertexArray[i];
    hasmissing |= vertexArray[i].missing();
  }
  if (nindices) {
    indices = new GLuint[nindices];
    for(int i=0; i < nindices; i++) {
      indices[i] = (GLuint)in_indices[i];
    }
  } else
    indices = NULL;
}

PrimitiveSet::PrimitiveSet (

    Material& in_material, 
    int in_nvertices, 
    double* in_vertices, 
    int in_type, 
    int in_nverticesperelement,
    bool in_ignoreExtent,
    int in_nindices, int* in_indices,
    bool in_bboxChange

)
  :
Shape(in_material, in_ignoreExtent, SHAPE, in_bboxChange)
{
  type                = in_type;
  nverticesperelement = in_nverticesperelement;
  nvertices           = in_nvertices;
  nindices            = in_nindices;
  if (nindices)
    nprimitives       = nindices / nverticesperelement;
  else
    nprimitives       = nvertices / nverticesperelement;
  material.colorPerVertex(true, nvertices);

  vertexArray.alloc(nvertices);
  hasmissing = false;
  for(int i=0;i<nvertices;i++) {
    vertexArray[i].x = (float) in_vertices[i*3+0];
    vertexArray[i].y = (float) in_vertices[i*3+1];
    vertexArray[i].z = (float) in_vertices[i*3+2];
    boundingBox += vertexArray[i];
    hasmissing |= vertexArray[i].missing();
  }
  
  if (nindices) {
    indices = new GLuint[nindices];
    for(int i=0; i < nindices; i++) {
      indices[i] = (GLuint)in_indices[i];
    }
  } else
    indices = NULL;
}

PrimitiveSet::~PrimitiveSet () 
{
  if (nindices)
    delete [] indices;
}

// ---------------------------------------------------------------------------

void PrimitiveSet::drawBegin(RenderContext* renderContext)
{
  Shape::drawBegin(renderContext);
  material.beginUse(renderContext);
  SAVEGLERROR;
  BBoxDeco* bboxdeco = 0;
  if (material.marginCoord >= 0) {
    Subscene* subscene = renderContext->subscene;
    bboxdeco = subscene->get_bboxdeco();
  }
  if (bboxdeco) {
    invalidateDisplaylist();
    verticesTodraw.alloc(vertexArray.size());
    for (int i=0; i < vertexArray.size(); i++)
      verticesTodraw.setVertex(i, bboxdeco->marginVecToDataVec(vertexArray[i], renderContext, &material) );
    verticesTodraw.beginUse();
  } else
    vertexArray.beginUse();
  SAVEGLERROR;
}

// ---------------------------------------------------------------------------

void PrimitiveSet::drawAll(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  if (!hasmissing) {
    if (!nindices)
      glDrawArrays(type, 0, nverticesperelement*nprimitives );
    else
      glDrawElements(type, nindices, GL_UNSIGNED_INT, indices);
  } else {
    bool missing = true;
    for (int i=0; i<nprimitives; i++) {
      bool skip = false;
      int elt = nindices ? indices[nverticesperelement*i] :
                                   nverticesperelement*i;
      for (int j=0; j<nverticesperelement; j++)
        skip |= vertexArray[elt + j].missing();
      if (missing != skip) {
        missing = !missing;
        if (missing) glEnd();
        else glBegin(type);
      }
      if (!missing) 
        for (int j=0; j<nverticesperelement; j++) {
          glArrayElement( elt + j);
        }
    }
    if (!missing) glEnd();
  }              
#endif
}

// ---------------------------------------------------------------------------

void PrimitiveSet::drawPrimitive(RenderContext* renderContext, int index)
{
#ifndef RGL_NO_OPENGL
  int elt = nindices ? indices[index*nverticesperelement] :
                       index*nverticesperelement;
  if (hasmissing) {
    bool skip = false;
    for (int j=0; j<nverticesperelement; j++)
      skip |= vertexArray[elt + j].missing();
    if (skip) return;
  }
  glDrawArrays(type, elt, nverticesperelement);
#endif
}

// ---------------------------------------------------------------------------

void PrimitiveSet::drawEnd(RenderContext* renderContext)
{
  vertexArray.endUse();
  SAVEGLERROR;
  material.endUse(renderContext);
  SAVEGLERROR;
  Shape::drawEnd(renderContext);
}

// ---------------------------------------------------------------------------

void PrimitiveSet::draw(RenderContext* renderContext)
{
  drawBegin(renderContext);
  SAVEGLERROR;

  drawAll(renderContext);
  SAVEGLERROR;
  
  drawEnd(renderContext);
  SAVEGLERROR;
}

int PrimitiveSet::getAttributeCount(AABox& bbox, AttribID attrib)
{
  switch (attrib) {
    case VERTICES: return nvertices;
    case INDICES: return nindices;
  }
  return Shape::getAttributeCount(bbox, attrib);
}

void PrimitiveSet::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    switch (attrib) {
    case VERTICES:
      while (first < n) {
        *result++ = vertexArray[first].x;
        *result++ = vertexArray[first].y;
        *result++ = vertexArray[first].z;
        first++;
      }
      return;
    case INDICES:
      while (first < n)
        *result++ = indices[first++];
      return;
    }
    Shape::getAttribute(bbox, attrib, first, count, result);
  }
}

// ===[ FACE SET ]============================================================

FaceSet::FaceSet(

  Material& in_material, 
  int in_nelements, 
  double* in_vertex, 
  double* in_normals,
  double* in_texcoords,
  int in_type, 
  int in_nverticesperelement,
  bool in_ignoreExtent,
  int in_nindices, 
  int* in_indices,
  int in_useNormals,
  int in_useTexcoords,
  bool in_bboxChange

)
: PrimitiveSet(in_material, in_nelements, in_vertex, in_type, in_nverticesperelement, in_ignoreExtent, 
  in_nindices, in_indices, in_bboxChange)
{
  if (in_useNormals)
    initNormals(in_normals);
  else
    normalArray.alloc(0);
  if (in_useTexcoords) {
    texCoordArray.alloc(nvertices);
    for(int i=0;i<nvertices;i++) {
      texCoordArray[i].s = (float) in_texcoords[i*2+0];
      texCoordArray[i].t = (float) in_texcoords[i*2+1];      
    }
  }
}

FaceSet::FaceSet(Material& in_material, 
    int in_type,
    int in_nverticesperelement,
    bool in_ignoreExtent,
    bool in_bboxChange
    ) :
  PrimitiveSet(in_material, in_type, in_nverticesperelement, in_ignoreExtent,in_bboxChange)
{ 
}

void FaceSet::initFaceSet(
  int in_nelements, 
  double* in_vertex, 
  double* in_normals,
  double* in_texcoords
) {
  initPrimitiveSet(in_nelements, in_vertex);
  
  bool useTexcoords = (in_texcoords) ? true : false;

  if (in_normals)
    initNormals(in_normals);

  if (useTexcoords) {
    texCoordArray.alloc(nvertices);
    for(int i=0;i<nvertices;i++) {
      texCoordArray[i].s = (float) in_texcoords[i*2+0];
      texCoordArray[i].t = (float) in_texcoords[i*2+1];      
    }
  }
}

void FaceSet::initNormals(double* in_normals)
{
  normalArray.alloc(nvertices);
  if (in_normals) {
    for(int i=0;i<nvertices;i++) {
      normalArray[i].x = (float) in_normals[i*3+0];
      normalArray[i].y = (float) in_normals[i*3+1];
      normalArray[i].z = (float) in_normals[i*3+2];
    }
  } else if (!nindices){
    for (int i=0;i<=nvertices-nverticesperelement;i+=nverticesperelement) 
    {   
      if (hasmissing && (vertexArray[i].missing() ||
          vertexArray[i+1].missing() ||
          vertexArray[i+2].missing()) ) {
        normalArray[i] = Vertex(0.0, 0.0, 0.0);
      } else
        normalArray[i] = vertexArray.getNormal(i,i+1,i+2);
      for (int j=1;j<nverticesperelement;++j)    
        normalArray[i+j] = normalArray[i];
    }
  } else {
    for (int i=0;i < nvertices; i++)
      normalArray[i] = Vertex(0.0, 0.0, 0.0);
    for (int i=0;i<=nindices-nverticesperelement;i+=nverticesperelement) 
    {   
      if (!hasmissing || (vertexArray[indices[i]].missing() &&
          !vertexArray[indices[i+1]].missing() &&
          !vertexArray[indices[i+2]].missing()) ) {
        Vertex faceNormal = vertexArray.getNormal(indices[i],indices[i+1],indices[i+2]);
      
        for (int j=0;j<nverticesperelement;++j)    
          normalArray[indices[i+j]] += faceNormal;
      }
    }
    for (int i=0; i < nvertices; i++)
      normalArray[i].normalize();
  }
}

// ---------------------------------------------------------------------------

void FaceSet::drawBegin(RenderContext* renderContext)
{  
  PrimitiveSet::drawBegin(renderContext);

  if (material.lit) {
    if (normalArray.size() < nvertices)
      initNormals(NULL);
    
    BBoxDeco* bboxdeco = 0;
    if (material.marginCoord >= 0) {
      Subscene* subscene = renderContext->subscene;
      bboxdeco = subscene->get_bboxdeco();
    }
    if (bboxdeco) {
      normalsToDraw.alloc(normalArray.size());
      for (int i=0; i < normalArray.size(); i++)
        normalsToDraw.setVertex(i, bboxdeco->marginNormalToDataNormal(normalArray[i], renderContext, &material) );
      normalsToDraw.beginUse();
    } else
      normalArray.beginUse();
  }
  texCoordArray.beginUse();
}

// ---------------------------------------------------------------------------

void FaceSet::drawEnd(RenderContext* renderContext)
{  
  texCoordArray.endUse();
  
  if (material.lit)
    normalArray.endUse();

  PrimitiveSet::drawEnd(renderContext);
}


int FaceSet::getAttributeCount(AABox& bbox, AttribID attrib)
{
  switch (attrib) {
    case NORMALS: return nvertices;
    case TEXCOORDS: return texCoordArray.size();
  }
  return PrimitiveSet::getAttributeCount(bbox, attrib);
}

void FaceSet::getAttribute(AABox& bbox, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(bbox, attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    switch (attrib) {
      case NORMALS: {
        if (normalArray.size() < n)
          initNormals(NULL);
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
    }
    PrimitiveSet::getAttribute(bbox, attrib, first, count, result);
  }
}
