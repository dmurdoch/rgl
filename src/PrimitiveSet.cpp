
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
  indices.clear();
#ifndef RGL_NO_OPENGL
  vbo                 = 0;
#endif
}

void PrimitiveSet::initPrimitiveSet(
    int in_nvertices, 
    double* in_vertices,
    int in_nindices,
    int* in_indices
) {
  size_t nvertices    = in_nvertices;
  if (in_nindices)
    nprimitives       = in_nindices / nverticesperelement;
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
  if (in_nindices) {
    indices.resize(in_nindices);
    for(int i=0; i < in_nindices; i++) {
      indices[i] = (GLuint)in_indices[i];
    }
  } else
    indices.clear();
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
  size_t nvertices    = in_nvertices;
  if (in_nindices)
    nprimitives       = in_nindices / nverticesperelement;
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
  
  if (in_nindices) {
    indices.resize(in_nindices);
    for(int i=0; i < in_nindices; i++) {
      indices[i] = (GLuint)in_indices[i];
    }
  } else
    indices.clear();
}

PrimitiveSet::~PrimitiveSet () 
{
}

// ---------------------------------------------------------------------------

void PrimitiveSet::drawBegin(RenderContext* renderContext)
{
  Shape::drawBegin(renderContext);
	
#ifndef RGL_NO_OPENGL
  if (doUseShaders)
  	Shape::beginShader(renderContext);
 
  BBoxDeco* bboxdeco = 0;
  if (material.marginCoord >= 0) {
    Subscene* subscene = renderContext->subscene;
    bboxdeco = subscene->get_bboxdeco();
  }
  if (bboxdeco) {
    if (!doUseShaders)
      invalidateDisplaylist();
    verticesTodraw.duplicate(vertexArray);
    for (int i=0; i < vertexArray.size(); i++)
      verticesTodraw.setVertex(i, bboxdeco->marginVecToDataVec(vertexArray[i], renderContext, &material) );
    verticesTodraw.replaceInBuffer(vertexbuffer);
    verticesTodraw.beginUse();
  } else {
    vertexArray.beginUse();
  }
#endif
  SAVEGLERROR;
  material.beginUse(renderContext);
  SAVEGLERROR;
}

// ---------------------------------------------------------------------------

void PrimitiveSet::drawRange(int start, int stop)
{
#ifndef RGL_NO_OPENGL
  if (start >= stop) return;
  size_t nindices = indices.size();
  if (doUseShaders) {
    if (!nindices)
      glDrawArrays(type, start, nverticesperelement*(stop - start) );
    else
      glDrawElements(type, nverticesperelement*(stop - start), 
                     GL_UNSIGNED_INT, 
                     indices.data() + nverticesperelement*start);
  } else {
    glBegin(type);
    for (int i = start; i < stop; i++) {
      int elt0 = nverticesperelement*i;
      for (int j = 0; j < nverticesperelement; j++) {
        int elt = elt0 + j;
        if (nindices)
          elt = indices[elt];
        glArrayElement(elt);
      }
    }
    glEnd();
  }
#endif
}
void PrimitiveSet::drawAll(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
	size_t nindices = indices.size();
  if (!hasmissing) {
    drawRange(0, nprimitives);
  } else {
    bool missing = true;
  	int first = 0;
    for (int i=0; i<nprimitives; i++) {
      bool skip = false;
    	int elt0 = nverticesperelement*i;
      for (int j=0; j<nverticesperelement; j++) {
      	int elt = elt0 + j;
      	if (nindices)
      		elt = indices[elt];
        skip |= vertexArray[elt].missing();
      }
      if (missing != skip) {
        missing = !missing;
      	if (missing)
      		drawRange(first, i);
        else
      		first = i;
      }
    }
    if (!missing)
    	drawRange(first, nprimitives);
  }              
#endif
}

// ---------------------------------------------------------------------------

void PrimitiveSet::drawPrimitive(RenderContext* renderContext, int index)
{
#ifndef RGL_NO_OPENGL
  int idx = index*nverticesperelement;
	size_t nindices = indices.size();
  if (hasmissing) {
    bool skip = false;
    for (int j=0; j<nverticesperelement; j++) {
      int elt = nindices ? indices[idx + j] : idx + j;
      skip |= vertexArray[elt].missing();
      if (skip) return;
    }
  }
  if (nindices)
    glDrawElements(type, nverticesperelement, GL_UNSIGNED_INT, indices.data() + idx);
  else
    glDrawArrays(type, idx, nverticesperelement);
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
  
#ifndef RGL_NO_OPENGL
  if (doUseShaders && flags.is_twosided) {
  	beginSideTwo();
  	drawAll(renderContext);
  }
#endif
  
  drawEnd(renderContext);
  SAVEGLERROR;
}

int PrimitiveSet::getAttributeCount(SceneNode* subscene, AttribID attrib)
{
  switch (attrib) {
    case VERTICES: return vertexArray.size();
    case INDICES: return indices.size();
  }
  return Shape::getAttributeCount(subscene, attrib);
}

void PrimitiveSet::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
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
        *result++ = indices[first++] + 1;
      return;
    }
    Shape::getAttribute(subscene, attrib, first, count, result);
  }
}

void PrimitiveSet::initialize()
{
	Shape::initialize();
#ifndef RGL_NO_OPENGL
	if (doUseShaders) {
		initShader();
	  vertexArray.appendToBuffer(vertexbuffer);
	  vertexArray.setAttribLocation(glLocs["aPos"]);
	  
	  if (material.useColorArray)
	    material.colors.appendToBuffer(vertexbuffer, vertexArray.size());
	    
	  material.colors.setAttribLocation(glLocs["aCol"]);

	  if (material.texture && glLocs_has_key("uSampler"))
	    material.texture->setSamplerLocation(glLocs["uSampler"]);
	  
	}
	SAVEGLERROR;
#endif
}

// ===[ FACE SET ]============================================================

FaceSet::FaceSet(

  Material& in_material, 
  int in_nvertex, 
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
: PrimitiveSet(in_material, in_nvertex, in_vertex, in_type, in_nverticesperelement, in_ignoreExtent, 
  in_nindices, in_indices, in_bboxChange)
{
  if (in_useNormals)
    initNormals(in_normals);
  else
    normalArray.alloc(0);
  if (in_useTexcoords) {
  	size_t nvertices = vertexArray.size();
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
  int in_nvertex, 
  double* in_vertex, 
  double* in_normals,
  double* in_texcoords
) {
  initPrimitiveSet(in_nvertex, in_vertex);
  
  bool useTexcoords = (in_texcoords) ? true : false;

  if (in_normals)
    initNormals(in_normals);

  if (useTexcoords) {
  	size_t nvertices = vertexArray.size();
    texCoordArray.alloc(nvertices);
    for(int i=0;i<nvertices;i++) {
      texCoordArray[i].s = (float) in_texcoords[i*2+0];
      texCoordArray[i].t = (float) in_texcoords[i*2+1];      
    }
  }
}

void FaceSet::initNormals(double* in_normals)
{

	size_t nindices = indices.size();
	size_t nvertices = vertexArray.size();
  normalArray.alloc(nvertices);
  if (!nvertices)
    return;
  
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
#ifndef RGL_NO_OPENGL
  flags.has_normals = true;
#endif
}

// ---------------------------------------------------------------------------

void FaceSet::drawBegin(RenderContext* renderContext)
{  
  if (material.lit && 
      normalArray.size() < vertexArray.size())
      initNormals(NULL);
  
  PrimitiveSet::drawBegin(renderContext);
  
  if (material.lit) {
    BBoxDeco* bboxdeco = 0;
    if (material.marginCoord >= 0) {
      Subscene* subscene = renderContext->subscene;
      bboxdeco = subscene->get_bboxdeco();
    }
    if (bboxdeco) {
      normalsToDraw.duplicate(normalArray);
      for (int i=0; i < normalArray.size(); i++)
        normalsToDraw.setVertex(i, bboxdeco->marginNormalToDataNormal(normalArray[i], renderContext, &material) );
      normalsToDraw.beginUse();
    } else {
      normalArray.beginUse();
    }
  }
  if (texCoordArray.size())
    texCoordArray.beginUse();
  SAVEGLERROR;
#ifndef RGL_NO_OPENGL
  // printBufferInfo();
  // printAttributes(nvertices);
  // printUniforms();
  // SAVEGLERROR;
#endif
}

// ---------------------------------------------------------------------------

void FaceSet::drawEnd(RenderContext* renderContext)
{  
  texCoordArray.endUse();
  
  if (material.lit)
    normalArray.endUse();

  PrimitiveSet::drawEnd(renderContext);
}


int FaceSet::getAttributeCount(SceneNode* subscene, AttribID attrib)
{
  switch (attrib) {
    case NORMALS: return normalArray.size();
    case TEXCOORDS: return texCoordArray.size();
  }
  return PrimitiveSet::getAttributeCount(subscene, attrib);
}

void FaceSet::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
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
    PrimitiveSet::getAttribute(subscene, attrib, first, count, result);
  }
}

void FaceSet::initialize()
{
	PrimitiveSet::initialize();
#ifndef RGL_NO_OPENGL
	if (normalArray.size() < vertexArray.size())
		initNormals(NULL);
	if (glLocs_has_key("aNorm")) {
	  normalArray.setAttribLocation(glLocs["aNorm"]);
		normalArray.appendToBuffer(vertexbuffer);
  }
	if (glLocs_has_key("aTexcoord")) {
		texCoordArray.setAttribLocation(glLocs["aTexcoord"]);
		texCoordArray.appendToBuffer(vertexbuffer);
	}
#endif
}
