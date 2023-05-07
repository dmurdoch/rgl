
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
	
#ifndef RGL_NO_OPENGL
	if (GLAD_GL_VERSION_2_1) {
		Subscene* subscene = renderContext->subscene;
		if (!is_initialized() || 
      nclipplanes < subscene->countClipplanes() || 
      nlights < subscene->countLights() ) {
			setShapeContext(subscene, subscene->countClipplanes(), 
                   subscene->countLights());
			initialize();
		}
		glUseProgram(shaderProgram);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		
		float mat[16];
		subscene->modelMatrix.getData(mat);
		glUniformMatrix4fv(glLocs.at("mvMatLoc"), 1, GL_FALSE, mat);
		subscene->projMatrix.getData(mat);
		glUniformMatrix4fv(glLocs.at("prMatLoc"), 1, GL_FALSE, mat);
	}
#endif  
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
  int idx = index*nverticesperelement;
  if (hasmissing) {
    bool skip = false;
    for (int j=0; j<nverticesperelement; j++) {
      int elt = nindices ? indices[idx + j] : idx + j;
      skip |= vertexArray[elt].missing();
      if (skip) return;
    }
  }
  if (nindices)
    glDrawElements(type, nverticesperelement, GL_UNSIGNED_INT, indices + idx);
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
  
  drawEnd(renderContext);
  SAVEGLERROR;
}

int PrimitiveSet::getAttributeCount(SceneNode* subscene, AttribID attrib)
{
  switch (attrib) {
    case VERTICES: return nvertices;
    case INDICES: return nindices;
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

#ifndef RGL_NO_OPENGL
static void checkShader(const char* type, GLuint shader)
{
	GLint status;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
	if (!status) {
		GLchar infoLog[2000];
		GLsizei len;
		glGetShaderInfoLog(shader, sizeof(infoLog), &len, infoLog);
		error("Compile issue for %s shader:\n%s\n", type, infoLog);
	}
}

static void checkProgram(GLuint program)
{
	GLint status;
	glGetProgramiv(program, GL_LINK_STATUS, &status);
	if (!status) {
		GLchar infoLog[2000];
		GLsizei len;
		glGetProgramInfoLog(program, sizeof(infoLog), &len, infoLog);
		error("Shader link issue:\n%s", infoLog);
	}
}
#endif


void PrimitiveSet::initialize()
{
	Shape::initialize();
#ifndef RGL_NO_OPENGL
	if (GLAD_GL_VERSION_2_1) {
		GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
		ShaderFlags flags = getShaderFlags();
		
		std::string defines = getShaderDefines(flags);
		std::string source = material.shaders[VERTEX_SHADER];
		if (source.size() == 0)
			source = defaultShader(VERTEX_SHADER);
		const char *sources[2];
		sources[0] = defines.c_str();
		sources[1] = source.c_str();
		glShaderSource(vertexShader, 2, sources, NULL);
		glCompileShader(vertexShader);
		checkShader("vertex", vertexShader);
		
		GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
		source = material.shaders[FRAGMENT_SHADER];
		if (source.size() == 0)
			source = defaultShader(FRAGMENT_SHADER);
		sources[1] = source.c_str();
		glShaderSource(fragmentShader, 2, sources, NULL);
		glCompileShader(fragmentShader);
		checkShader("fragment", fragmentShader);
		
		shaderProgram = glCreateProgram();
		glAttachShader(shaderProgram, vertexShader);
		glAttachShader(shaderProgram, fragmentShader);
		
		buffer.clear();
		
		glBindAttribLocation(shaderProgram, 0, "aPos");
		vertexArray.appendToBuffer(buffer);
		glLocs["aPos"] = 0;
		vertexArray.setAttribLocation(glLocs["aPos"]);
		
		glBindAttribLocation(shaderProgram, 1, "aCol");
		glLocs["aCol"] = 1;
		material.colors.setAttribLocation(glLocs["aCol"]);
		if (material.useColorArray)
			material.colors.appendToBuffer(buffer);
		
		glLinkProgram(shaderProgram);
		checkProgram(shaderProgram);
		
		if (flags.fixed_quads && !flags.sprites_3d)
			glLocs["aOfs"] = glGetAttribLocation(shaderProgram, "aOfs");
		
		std::string type = getTypeName();
		if (flags.has_texture || type == "text") {
			glLocs["texLoc"] = glGetAttribLocation(shaderProgram, "aTexcoord");
			glLocs["sampler"] = glGetUniformLocation(shaderProgram, "uSampler");
		}
		
		if (flags.has_fog && !flags.sprites_3d) {
			glLocs["uFogMode"] = glGetUniformLocation(shaderProgram, "uFogMode");
			glLocs["uFogColor"] = glGetUniformLocation(shaderProgram, "uFogColor");
			glLocs["uFogParms"] = glGetUniformLocation(shaderProgram, "uFogParms");
		}
		
		if (nclipplanes && !flags.sprites_3d) {
			glLocs["clipLoc"] = glGetUniformLocation(shaderProgram,"vClipplane");
		}
		
		if (flags.is_lit) {
			glLocs["emissionLoc"] = glGetUniformLocation(shaderProgram, "emission");
			glLocs["shininessLoc"] = glGetUniformLocation(shaderProgram, "shininess");
			if (nlights > 0) {
				glLocs["ambientLoc"] = glGetUniformLocation(shaderProgram, "ambient");
				glLocs["specularLoc"] = glGetUniformLocation(shaderProgram, "specular");
				glLocs["diffuseLoc"] = glGetUniformLocation(shaderProgram, "diffuse" );
				glLocs["lightDirLoc"] = glGetUniformLocation(shaderProgram, "lightDir");
				glLocs["viewpointLoc"] = glGetUniformLocation(shaderProgram, "viewpoint");
				glLocs["finiteLoc"] = glGetUniformLocation(shaderProgram, "finite" );
			}
		}
		
		if (flags.fat_lines) {
			glLocs["nextLoc"] = glGetAttribLocation(shaderProgram, "aNext");
			glLocs["pointLoc"] = glGetAttribLocation(shaderProgram, "aPoint");
			glLocs["aspectLoc"] = glGetUniformLocation(shaderProgram, "uAspect");
			glLocs["lwdLoc"] = glGetUniformLocation(shaderProgram, "uLwd");
		}
		
		if (!flags.sprites_3d) {
			glLocs["mvMatLoc"] = glGetUniformLocation(shaderProgram, "mvMatrix");
			glLocs["prMatLoc"] = glGetUniformLocation(shaderProgram, "prMatrix");
			
			if (flags.fixed_size) {
				glLocs["textScaleLoc"] = glGetUniformLocation(shaderProgram, "textScale");
			}
		}
		
		if (flags.needs_vnormal) {
			glLocs["normLoc"] = glGetAttribLocation(shaderProgram, "aNorm");
			glLocs["normMatLoc"] = glGetUniformLocation(shaderProgram, "normMatrix");
		}
		
		if (flags.is_twosided) {
			glLocs["frontLoc"] = glGetUniformLocation(shaderProgram, "front");
			if (flags.has_normals)
				glLocs["invPrMatLoc"] = glGetUniformLocation(shaderProgram, "invPrMatrix");
		}
	}
	
	glDeleteBuffers(1, &vbo);
	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, buffer.size()*sizeof(GLfloat), 
               buffer.data(), GL_STATIC_DRAW);
	
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


int FaceSet::getAttributeCount(SceneNode* subscene, AttribID attrib)
{
  switch (attrib) {
    case NORMALS: return nvertices;
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
	if (glLocs.find("aNorm") != glLocs.end())
	  normalArray.setAttribLocation(glLocs["aNorm"]);
	// FIXME:  also needs texCoordArray
#endif
}
