#include "PrimitiveSet.hpp"
#include "R.h"

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
}

void PrimitiveSet::initPrimitiveSet(
    int in_nvertices, 
    double* in_vertices
) {
  nvertices           = in_nvertices;
  nprimitives         = in_nvertices / nverticesperelement;
  vertexArray.alloc(nvertices);
  hasmissing = false;
  for(int i=0;i<nvertices;i++) {
    vertexArray[i].x = (float) in_vertices[i*3+0];
    vertexArray[i].y = (float) in_vertices[i*3+1];
    vertexArray[i].z = (float) in_vertices[i*3+2];
    boundingBox += vertexArray[i];
    hasmissing |= vertexArray[i].missing();
  }
}

PrimitiveSet::PrimitiveSet (

    Material& in_material, 
    int in_nvertices, 
    double* in_vertices, 
    int in_type, 
    int in_nverticesperelement,
    bool in_ignoreExtent,
    bool in_bboxChange

)
  :
Shape(in_material, in_ignoreExtent, SHAPE, in_bboxChange)
{
  type                = in_type;
  nverticesperelement = in_nverticesperelement;
  nvertices           = in_nvertices;
  nprimitives         = in_nvertices / nverticesperelement;
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
}

// ---------------------------------------------------------------------------

void PrimitiveSet::drawBegin(RenderContext* renderContext)
{
  Shape::drawBegin(renderContext);
  material.beginUse(renderContext);
  SAVEGLERROR;
  vertexArray.beginUse();
  SAVEGLERROR;
}

// ---------------------------------------------------------------------------

void PrimitiveSet::drawAll(RenderContext* renderContext)
{
  if (!hasmissing)
    glDrawArrays(type, 0, nverticesperelement*nprimitives );
    // FIXME: refactor to vertexArray.draw( type, 0, nverticesperelement*nprimitives );
  else {
    bool missing = true;
    for (int i=0; i<nprimitives; i++) {
      bool skip = false;
      for (int j=0; j<nverticesperelement; j++) 
        skip |= vertexArray[nverticesperelement*i + j].missing();
      if (missing != skip) {
        missing = !missing;
        if (missing) glEnd();
        else glBegin(type);
      }
      if (!missing) 
        for (int j=0; j<nverticesperelement; j++)
          glArrayElement( nverticesperelement*i + j );
    }
    if (!missing) glEnd();
  }              
}

// ---------------------------------------------------------------------------

void PrimitiveSet::drawElement(RenderContext* renderContext, int index)
{
  if (hasmissing) {
    bool skip = false;
    for (int j=0; j<nverticesperelement; j++) 
      skip |= vertexArray[index*nverticesperelement + j].missing();
    if (skip) return;
  }
  glDrawArrays(type, index*nverticesperelement, nverticesperelement);
  // FIXME: refactor to vertexArray.draw( type, index*nverticesperelement, nverticesperelement );
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

int PrimitiveSet::getAttributeCount(AttribID attrib)
{
  switch (attrib) {
    case VERTICES: return nvertices;
  }
  return Shape::getAttributeCount(attrib);
}

void PrimitiveSet::getAttribute(AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    if (attrib == VERTICES) {
      while (first < n) {
        *result++ = vertexArray[first].x;
        *result++ = vertexArray[first].y;
        *result++ = vertexArray[first].z;
        first++;
      }
    } else
      Shape::getAttribute(attrib, first, count, result);
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
  int in_useNormals,
  int in_useTexcoords,
  bool in_bboxChange

)
: PrimitiveSet(in_material, in_nelements, in_vertex, in_type, in_nverticesperelement, in_ignoreExtent, in_bboxChange)
{
  if (material.lit) {
    normalArray.alloc(nvertices);
    if (in_useNormals) {
      for(int i=0;i<nvertices;i++) {
        normalArray[i].x = (float) in_normals[i*3+0];
        normalArray[i].y = (float) in_normals[i*3+1];
        normalArray[i].z = (float) in_normals[i*3+2];
      }
    } else {
      for (int i=0;i<=nvertices-nverticesperelement;i+=nverticesperelement) 
      {   
        if (hasmissing && (vertexArray[i].missing() ||
                           vertexArray[i+1].missing() ||
                           vertexArray[i+2].missing()) )
          normalArray[i] = Vertex(0.0, 0.0, 0.0);
        else
          normalArray[i] = vertexArray.getNormal(i,i+1,i+2);
        for (int j=1;j<nverticesperelement;++j)    
          normalArray[i+j] = normalArray[i];
      }
    }
  }
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
  
  bool useNormals = (in_normals) ? true : false;
  bool useTexcoords = (in_texcoords) ? true : false;

  if (material.lit) {
    normalArray.alloc(nvertices);
    if (useNormals) {
      for(int i=0;i<nvertices;i++) {
        normalArray[i].x = (float) in_normals[i*3+0];
        normalArray[i].y = (float) in_normals[i*3+1];
        normalArray[i].z = (float) in_normals[i*3+2];
      }
    } else {
      for (int i=0;i<=nvertices-nverticesperelement;i+=nverticesperelement) 
      {   
        if (hasmissing && (vertexArray[i].missing() ||
                           vertexArray[i+1].missing() ||
                           vertexArray[i+2].missing()) )
          normalArray[i] = Vertex(0.0, 0.0, 0.0);
        else
          normalArray[i] = vertexArray.getNormal(i,i+1,i+2);
        for (int j=1;j<nverticesperelement;++j)    
          normalArray[i+j] = normalArray[i];
      }
    }
  }
  if (useTexcoords) {
    texCoordArray.alloc(nvertices);
    for(int i=0;i<nvertices;i++) {
      texCoordArray[i].s = (float) in_texcoords[i*2+0];
      texCoordArray[i].t = (float) in_texcoords[i*2+1];      
    }
  }
}

// ---------------------------------------------------------------------------

void FaceSet::drawBegin(RenderContext* renderContext)
{  
  PrimitiveSet::drawBegin(renderContext);

  if (material.lit)
    normalArray.beginUse();
    
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


int FaceSet::getAttributeCount(AttribID attrib)
{
  switch (attrib) {
    case NORMALS: if (material.lit)
    		    return nvertices;
    		  else
    		    return 0;
    case TEXCOORDS: return texCoordArray.size();
  }
  return PrimitiveSet::getAttributeCount(attrib);
}

void FaceSet::getAttribute(AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    switch (attrib) {
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
    }
    PrimitiveSet::getAttribute(attrib, first, count, result);
  }
}
