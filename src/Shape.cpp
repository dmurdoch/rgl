
#include <algorithm>
#include <functional>

#include <sstream>
#include <iomanip>

#include "Shape.h"
#include "SceneNode.h"
#include "SpriteSet.h"
#include "R.h"

using namespace rgl;

//////////////////////////////////////////////////////////////////////////////
//
// CLASS
//   Shape
//

Shape::Shape(Material& in_material, bool in_ignoreExtent, TypeID in_typeID, bool in_bboxChanges)
: SceneNode(in_typeID), bboxChanges(in_bboxChanges), ignoreExtent(in_ignoreExtent), material(in_material),
#ifndef RGL_NO_OPENGL  
  displayList(0), 
#endif
  drawLevel(0), doUpdate(true), transparent(in_material.isTransparent()),
  blended(in_material.isTransparent())
  
{
#ifndef RGL_NO_OPENGL
  vbo = 0;
  ibo = 0;
#endif
  uninitialize();
}

Shape::~Shape()
{
#ifndef RGL_NO_OPENGL
  if (!doUseShaders && displayList)
    glDeleteLists(displayList, 1);
#endif
}

void Shape::update(RenderContext* renderContext)
{
  doUpdate = false;
}

void Shape::draw(RenderContext* renderContext)
{ 
  drawBegin(renderContext);
  SAVEGLERROR;
  
  for(int i=0;i<getPrimitiveCount();i++) 
    drawPrimitive(renderContext, i);
    
  SAVEGLERROR;  
  drawEnd(renderContext);
  SAVEGLERROR;
}

void Shape::render(RenderContext* renderContext)
{
#ifndef RGL_NO_OPENGL
  renderBegin(renderContext);
  
  if (doUseShaders) {
  	if (doUpdate)
  		update(renderContext);
  	draw(renderContext);
  } else {
    if (displayList == 0)
      displayList = glGenLists(1);
    
    SAVEGLERROR;
    if (doUpdate) {
      update(renderContext);
      SAVEGLERROR;
      glNewList(displayList, GL_COMPILE_AND_EXECUTE);
      SAVEGLERROR;
      draw(renderContext);
      SAVEGLERROR;
      glEndList();
      SAVEGLERROR;
    } else {
      glCallList(displayList);
      SAVEGLERROR;
    } 
  }
#endif
}

void Shape::invalidateDisplaylist()
{
  doUpdate = true;
}

void Shape::drawBegin(RenderContext* renderContext)
{
  if (drawLevel) {
    drawLevel = 0;
    Rf_error("Internal error:  nested Shape::drawBegin");
  }
  drawLevel++;
}

#ifndef RGL_NO_OPENGL
void Shape::beginShader(RenderContext* renderContext)
{  
	if (doUseShaders) {
		Subscene* subscene = renderContext->subscene;
		if (!is_initialized() || 
      nclipplanes < subscene->countClipplanes() || 
      nlights < subscene->countLights() ) {
			setShapeContext(subscene, subscene->countClipplanes(), 
                   subscene->countLights());
			initialize();
			loadBuffers();
		}
		glUseProgram(shaderProgram);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		float mat[16];
		subscene->modelMatrix.getData(mat);
		glUniformMatrix4fv(glLocs.at("mvMatrix"), 1, GL_FALSE, mat);
		
		subscene->projMatrix.getData(mat);
		glUniformMatrix4fv(glLocs.at("prMatrix"), 1, GL_FALSE, mat);
		
		if (glLocs_has_key("invPrMatrix")) {
			subscene->projMatrix.inverse().getData(mat);
			glUniformMatrix4fv(glLocs.at("invPrMatrix"), 1, GL_FALSE, mat);
		}
		
		if (glLocs_has_key("normMatrix")) {
			Matrix4x4 normMatrix = subscene->modelMatrix.inverse();
			normMatrix.transpose();
			normMatrix.getData(mat);
			glUniformMatrix4fv(glLocs.at("normMatrix"), 1, GL_FALSE, mat);
		}
		if (glLocs_has_key("emission")) {
			glUniform3fv(glLocs.at("emission"), 1, material.emission.data);
		}
		if (glLocs_has_key("shininess")) {
			glUniform1f(glLocs.at("shininess"), material.shininess);
		}
		if (glLocs_has_key("ambient")) { // just test one, and they should all be there
			float ambient[3*nlights], 
            specular[3*nlights], 
            diffuse[3*nlights],
            lightDir[3*nlights];
			int viewpoint[nlights], finite[nlights];
			for (int i=0; i < subscene->countLights(); i++) {
				Light *light = subscene->getLight(i);
				for (int j=0; j < 3; j++) {
					ambient[3*i + j] = light->ambient.data[j]*material.ambient.data[j];
					specular[3*i + j] = light->specular.data[j]*material.specular.data[j];
					diffuse[3*i + j] = light->diffuse.data[j];
					lightDir[3*i + j] = light->position[j];
				}
				viewpoint[i] = light->viewpoint;
				finite[i] = light->posisfinite;
			}
			for (int i=subscene->countLights(); i < nlights; i++)
				for (int j=0; j < 3; j++) {
					ambient[3*i + j] = 0;
					specular[3*i + j] = 0;
					diffuse[3*i + j] = 0;
				}
			glUniform3fv( glLocs.at("ambient"), 3*nlights, ambient);
			glUniform3fv( glLocs.at("specular"), 3*nlights, specular);
			glUniform3fv( glLocs.at("diffuse"), 3*nlights, diffuse);
			glUniform3fv( glLocs.at("lightDir"), 3*nlights, lightDir);
			glUniform1iv( glLocs.at("viewpoint"), nlights, viewpoint);
			glUniform1iv( glLocs.at("finite"), nlights, finite);
		}
		
		if (glLocs_has_key("uFogMode")) { // If it has one, it has them all
			Background* bg = subscene->get_background();
			if (bg) {
				int fogtype = bg->fogtype - 1;
				glUniform1i(glLocs["uFogMode"], fogtype);
				if (fogtype != 0)
				{
					Color color = bg->material.colors.getColor(0);
					glUniform3f(glLocs["uFogColor"],  color.getRedf(), color.getGreenf(), color.getBluef());
					
				}
			}
		}
		if (glLocs_has_key("front"))
			glUniform1i(glLocs["front"], 1);
	}
}

void Shape::beginSideTwo()
{
	glUniform1i(glLocs.at("front"), 0);
	material.beginSide(false);
}
#endif

void Shape::drawEnd(RenderContext* renderContext)
{
  if (drawLevel != 1) {
    drawLevel = 0;
    Rf_error("Internal error: Shape::drawEnd without drawBegin");
  }
  drawLevel--;
}

int Shape::getAttributeCount(SceneNode* subscene, AttribID attrib)
{
  switch (attrib) { 
    case COLORS:  return material.colors.getLength();
    case CENTERS: return getPrimitiveCount();
    case FLAGS:   return 1;
  }
  return 0;
}

void Shape::getAttribute(SceneNode* subscene, AttribID attrib, int first, int count, double* result)
{
  int n = getAttributeCount(subscene, attrib);
  if (first + count < n) n = first + count;
  if (first < n) {
    switch (attrib) {
      case COLORS:
        while (first < n) {
          Color color = material.colors.getColor(first);
          *result++ = color.data[0];
          *result++ = color.data[1];
          *result++ = color.data[2];
          *result++ = color.data[3];
          first++;
        }
        return;
      case CENTERS:
        while (first < n) {
          Vertex center = getPrimitiveCenter(first);
          *result++ = center.x;
          *result++ = center.y;
          *result++ = center.z;
          first++;
        }
        return;
      case FLAGS:
        if (first == 0) *result++ = (double)ignoreExtent;
        return;
    }
  }
}

void Shape::setShapeContext(Subscene* in_subscene, int in_nclipplanes,
                            int in_nlights)
{
	subscene = in_subscene;
	nclipplanes = in_nclipplanes;
	nlights = in_nlights;
}

ShaderFlags Shape::getShaderFlags()
{
  ShaderFlags result;
	if (!subscene)
		return result;
  
  std::string type = getTypeName();
  double attrib;
  bool sphere = false;
  if (type == "background") {
    getAttribute(subscene, FLAGS, 0, 1, &attrib);
    sphere = attrib > 0.0;
  }
  
  result.is_lines = type == "lines" ||
                    type == "linestrip" ||
                    type == "abclines";
  
  result.fat_lines =   material.lwd != 1.0 && 
                      (result.is_lines ||
                       material.front == Material::LINE_FACE ||
                       material.back == Material::LINE_FACE);
  
  result.sprites_3d = false;
  result.fixed_size = type == "text";
  if (!result.fixed_size ) {
    SpriteSet* sprite = dynamic_cast<SpriteSet*>(this);
    if (sprite) {
      result.fixed_size = sprite->isFixedSize();
      result.sprites_3d = sprite->getAttributeCount(subscene, IDS) > 0;
    }
  }
  result.fixed_quads = (type == "text" || type == "sprites") && !result.sprites_3d;
  
  result.has_fog = material.fog;
  result.has_normals = (type == "spheres") ||
  	                   getAttributeCount(subscene, NORMALS) > 0;

  if (material.texture) {
    result.has_texture = getAttributeCount(subscene, TEXCOORDS) > 0 ||
     (type == "sprites" && !result.sprites_3d) ||
     type == "spheres" ||
     (type == "background" && sphere);
  } else
    result.has_texture = false;
  
  result.is_brush = false;  /* check: brushes only exist in WebGL? */

  result.is_lit = material.lit && (
    type == "triangles" ||
    type == "quads" ||
    type == "surface" ||
    type == "planes" ||
    type == "spheres" ||
    type == "sprites" ||
    type == "bboxdeco");

  result.is_points = type == "points" ||
    material.front == Material::POINT_FACE ||
    material.back == Material::POINT_FACE;

  result.is_transparent = (result.has_texture && material.isTransparent());
  if (!result.is_transparent) {
    int n = getAttributeCount(subscene, COLORS);
    for (int i=0;i < n;i++) {
      Color color = material.colors.getColor(i);
      if (color.getAlphaf() < 1.0f) {
        result.is_transparent = true;
        break;
      }
    }
  }
  
  result.is_twosided = ((type == "triangles" ||
    type == "quads" ||
    type == "surface" ||
    type == "spheres" ||
    type == "bboxdeco") && material.front != material.back) ||
    (type == "background" && sphere);
  
  result.needs_vnormal = (result.is_lit && !result.sprites_3d &&
    !result.fixed_quads && !result.is_brush) ||
    (result.is_twosided && result.has_normals);
  
  if (getTypeID() == SHAPE && getAttributeCount(subscene, FLAGS) >= 3) {
    getAttribute(subscene, FLAGS, 2, 1, &attrib);
    result.rotating = attrib > 0.0;
  } else
    result.rotating = false;
    
  result.round_points = material.point_antialias;
  
  result.is_smooth = material.smooth && (
    type == "triangles" ||
    type == "quads" ||
    type == "surface" ||
    type == "planes" ||
    type == "spheres");
  
  result.depth_sort = result.is_transparent && (
    type == "triangles" ||
    type == "quads" ||
    type == "surface" ||
    type == "spheres" ||
    type == "sprites" ||
    type == "text");
  
  result.is_subscene = type == "subscene";
  
  result.is_clipplanes = type == "clipplanes";
  
  return result;
}

std::string Shape::getShaderDefines(ShaderFlags flags)
{
	if (!subscene)
		return "";
	
	std::string type = getTypeName();
	
	std::string title = "  /* ****** "+type+" object "+std::to_string(getObjID())+" shader ****** */\n";
	
	std::string defines =
		"#line 0 3\n#define NCLIPPLANES " + std::to_string(nclipplanes) + "\n"+
		"#define NLIGHTS " + std::to_string(nlights) + "\n";
	
	if (flags.fat_lines)
		defines = defines + "#define FAT_LINES 1\n";
	
	if (flags.fixed_quads)
		defines = defines + "#define FIXED_QUADS 1\n";
	
	if (flags.fixed_size)
		defines = defines + "#define FIXED_SIZE 1\n";
	
	if (flags.has_fog)
		defines = defines + "#define HAS_FOG 1\n";
	
	if (flags.has_normals)
		defines = defines + "#define HAS_NORMALS 1\n";
	
	if (flags.has_texture) {
		std::string textypes[] = {"alpha", "luminance", "luminance.alpha", "rgb", "rgba"};
		std::string texmodes[] = {"replace", "modulate", "decal", "blend", "add"};
		defines = defines + "#define HAS_TEXTURE 1\n";
		defines = defines + "#define TEXTURE_" + textypes[material.textype - 1] + "\n";
		defines = defines + "#define TEXMODE_" + texmodes[material.texmode] + "\n";
		if (material.envmap)
			defines = defines + "#define USE_ENVMAP 1\n";
	}
	
	if (flags.is_brush)
		defines = defines + "#define IS_BRUSH 1\n";  
	
	if (type == "linestrip")
		defines = defines + "#define IS_LINESTRIP 1\n";         
	
	if (flags.is_lit)
		defines = defines + "#define IS_LIT 1\n"; 
	
	if (flags.is_points) {
		defines = defines + "#define IS_POINTS 1\n";
		std::ostringstream ss;
		ss << std::fixed << std::setprecision(1) << material.size;
		defines = defines + "#define POINTSIZE " + ss.str() + "\n";
	}
	
	if (type == "sprites")
		defines = defines + "#define IS_SPRITES 1\n";
	
	if (type == "text")
		defines = defines + "#define IS_TEXT 1\n";
	
	if (flags.is_transparent)
		defines = defines + "#define IS_TRANSPARENT 1\n"; 
	
	if (flags.is_twosided)
		defines = defines + "#define IS_TWOSIDED 1\n";
	
	if (flags.needs_vnormal)
		defines = defines + "#define NEEDS_VNORMAL 1\n";
	
	if (flags.rotating)
		defines = defines + "#define ROTATING 1\n";
	
	if (flags.round_points)        
		defines = defines + "#define ROUND_POINTS 1\n";   

	return title + defines;
}

#ifndef RGL_NO_OPENGL
void Shape::checkShader(const char* type, GLuint shader)
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

void Shape::checkProgram(GLuint program)
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

void Shape::initialize()
{
	SceneNode::initialize();
}

void Shape::initShader()
{
	GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
	flags = getShaderFlags();
	
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
	
	vertexbuffer.clear();
	indexbuffer.clear();
	
	glBindAttribLocation(shaderProgram, 0, "aPos");
	glLocs["aPos"] = 0;

	glBindAttribLocation(shaderProgram, 1, "aCol");
	glLocs["aCol"] = 1;
	
	/* NB:  these must come after the glBindAttribLocation calls */
	glLinkProgram(shaderProgram);
	checkProgram(shaderProgram);
	
	if (flags.fixed_quads && !flags.sprites_3d)
	  glLocs["aOfs"] = glGetAttribLocation(shaderProgram, "aOfs");
	
	std::string type = getTypeName();
	if (flags.has_texture || type == "text") {
	  glLocs["aTexcoord"] = glGetAttribLocation(shaderProgram, "aTexcoord");
	  glLocs["uSampler"] = glGetUniformLocation(shaderProgram, "uSampler");
	}
	
	if (flags.has_fog && !flags.sprites_3d) {
	  glLocs["uFogMode"] = glGetUniformLocation(shaderProgram, "uFogMode");
	  glLocs["uFogColor"] = glGetUniformLocation(shaderProgram, "uFogColor");
	  glLocs["uFogParms"] = glGetUniformLocation(shaderProgram, "uFogParms");
	}
	
	if (nclipplanes && !flags.sprites_3d) {
	  glLocs["vClipplane"] = glGetUniformLocation(shaderProgram,"vClipplane");
	}
	
	if (flags.is_lit) {
	  glLocs["emission"] = glGetUniformLocation(shaderProgram, "emission");
	  glLocs["shininess"] = glGetUniformLocation(shaderProgram, "shininess");
	  if (nlights > 0) {
	    glLocs["ambient"] = glGetUniformLocation(shaderProgram, "ambient");
	    glLocs["specular"] = glGetUniformLocation(shaderProgram, "specular");
	    glLocs["diffuse"] = glGetUniformLocation(shaderProgram, "diffuse" );
	    glLocs["lightDir"] = glGetUniformLocation(shaderProgram, "lightDir");
	    glLocs["viewpoint"] = glGetUniformLocation(shaderProgram, "viewpoint");
	    glLocs["finite"] = glGetUniformLocation(shaderProgram, "finite" );
	  }
	}
	
	if (flags.fat_lines) {
	  glLocs["aNext"] = glGetAttribLocation(shaderProgram, "aNext");
	  glLocs["aPoint"] = glGetAttribLocation(shaderProgram, "aPoint");
	  glLocs["uAspect"] = glGetUniformLocation(shaderProgram, "uAspect");
	  glLocs["uLwd"] = glGetUniformLocation(shaderProgram, "uLwd");
	}
	
	if (!flags.sprites_3d) {
	  glLocs["mvMatrix"] = glGetUniformLocation(shaderProgram, "mvMatrix");
	  glLocs["prMatrix"] = glGetUniformLocation(shaderProgram, "prMatrix");
	  
	  if (flags.fixed_size) {
	    glLocs["textScale"] = glGetUniformLocation(shaderProgram, "textScale");
	  }
	}
	
	if (flags.needs_vnormal) {
	  glLocs["aNorm"] = glGetAttribLocation(shaderProgram, "aNorm");
	  glLocs["normMatrix"] = glGetUniformLocation(shaderProgram, "normMatrix");
	}
	
	if (flags.is_twosided) {
	  glLocs["front"] = glGetUniformLocation(shaderProgram, "front");
	  if (flags.has_normals)
	    glLocs["invPrMatrix"] = glGetUniformLocation(shaderProgram, "invPrMatrix");
	}
}

bool Shape::glLocs_has_key(std::string key) {
	return glLocs.find(key) != glLocs.end();
}


void Shape::loadBuffers()
{
	glDeleteBuffers(1, &vbo);
	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, vertexbuffer.size(), 
              vertexbuffer.data(), GL_STATIC_DRAW);
	
	glDeleteBuffers(1, &ibo);
	if (indexbuffer.size()) {
		glGenBuffers(1, &ibo);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexbuffer.size(),
               indexbuffer.data(), GL_STATIC_DRAW);
  } else {
  	ibo = 0;
  	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
  }
}

void Shape::printUniform(const char *name, int rows, int cols, int transposed,
                                GLint type) {
	float data[4*nlights > 16 ? 4*nlights : 16];
	int idata[nlights];
	
	GLint location;
	if (glLocs_has_key(name)) {
		location = glLocs[name];
		Rprintf("%s: (%d)\n", name, location);
		if (type == GL_FLOAT)
			glGetUniformfv(shaderProgram, location, data);
		else if (type == GL_INT)
			glGetUniformiv(shaderProgram, location, idata);
		else{
			Rprintf("unknown type: %d", type);
			return;
		}
		for (int i=0; i < rows; i++) {
			for (int j=0; j < cols; j++) {
				int index = transposed ? (i + cols*j) : (j + cols*i);
				if (type == GL_FLOAT)
					Rprintf("%.3f ", data[index]);
				else if (type == GL_INT)
					Rprintf("%d ", idata[index]);
			}
			Rprintf("\n");
		}
	} else Rprintf("%s: not defined\n", name);
	SAVEGLERROR;
}

void Shape::printUniforms() {
	printUniform("mvMatrix", 4, 4, true, GL_FLOAT);
	printUniform("prMatrix", 4, 4, true, GL_FLOAT);	
	printUniform("normMatrix", 4, 4, true, GL_FLOAT);
	printUniform("invPrMatrix", 4, 4, true, GL_FLOAT);	
	
	printUniform("uFogMode", 1, 1, false, GL_INT);
	printUniform("uFogColor", 1, 3, false, GL_FLOAT);
	printUniform("uFogParms", 1, 4, false, GL_FLOAT);
	
	printUniform("emission", 1, 3, false, GL_FLOAT);
	printUniform("shininess", 1, 1, false, GL_FLOAT);
	printUniform("ambient", nlights, 3, false, GL_FLOAT);
	printUniform("specular", nlights, 3, false, GL_FLOAT);
	printUniform("diffuse", nlights, 3, false, GL_FLOAT);
	printUniform("lightDir", nlights, 3, false, GL_FLOAT);	
	printUniform("viewpoint", 1, 1, false, GL_INT);
	printUniform("finite", 1, 1, false, GL_INT);
	
}

void Shape::printBufferInfo() {
	GLint idata, vbo;
	glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &vbo);
	Rprintf("Bound array buffer: %d", vbo);
	glGetBufferParameteriv(GL_ARRAY_BUFFER, GL_BUFFER_SIZE, &idata);
	Rprintf(" size: %#x", idata);
	glGetBufferParameteriv(GL_ARRAY_BUFFER, GL_BUFFER_USAGE, &idata);
	Rprintf(" usage: %s", idata == GL_STATIC_DRAW ? "GL_STATIC_DRAW" : "?");
	Rprintf("\n");
	SAVEGLERROR;
}

void Shape::printAttribute(const char* name, int nvertices) {
	GLint idata;
	void* pdata;
	
	if (glLocs_has_key(name)) {
		GLint location = glLocs[name];
		Rprintf("%s (%d):", name, location);
		glGetVertexAttribiv(location, GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING,
                      &idata);
		SAVEGLERROR;
		if (idata)
			Rprintf(" on vbo %d", idata);
		else
			Rprintf(" not bound");
		glGetVertexAttribiv(location, GL_VERTEX_ATTRIB_ARRAY_ENABLED,
                      &idata);
		SAVEGLERROR;
		int enabled = idata;
		if (enabled)
			Rprintf(" enabled");
		else
			Rprintf(" not enabled");
		
		glGetVertexAttribiv(location, GL_VERTEX_ATTRIB_ARRAY_SIZE, &idata);
		SAVEGLERROR;
		int size = idata;
		
		glGetVertexAttribiv(location, GL_VERTEX_ATTRIB_ARRAY_STRIDE, &idata);
		SAVEGLERROR;
		int stride = idata;
		
		glGetVertexAttribiv(location, GL_VERTEX_ATTRIB_ARRAY_TYPE, &idata);
		SAVEGLERROR;
		GLint type = idata;
		Rprintf(" %s[%d]", type == GL_FLOAT ? "GL_FLOAT" : 
            type == GL_INT ? "GL_INT" : 
            type == GL_BYTE ? "GL_BYTE" : 
            type == GL_UNSIGNED_BYTE ? "GL_UNSIGNED_BYTE" :
            "GL_??", size);
		
		glGetVertexAttribiv(location, GL_VERTEX_ATTRIB_ARRAY_NORMALIZED, &idata);
		SAVEGLERROR;
		GLint normalized = idata;
		if (normalized)
			Rprintf(" normalized");
		
		glGetVertexAttribPointerv(location, GL_VERTEX_ATTRIB_ARRAY_POINTER, &pdata);
		SAVEGLERROR;
		void* offset = pdata;
		Rprintf(" offset %p", offset);
		Rprintf("\n");
		if (type == GL_FLOAT) {
			
			if (enabled) {
				int step = 0;
				for (int i = 0; i < nvertices; i++) {
					float* value = reinterpret_cast<float*>(vertexbuffer.data() + 
                                             reinterpret_cast<std::uintptr_t>(offset) + step);
					for (int j = 0; j < size; j++, value++)
						Rprintf("%8.4f ", *value);
					Rprintf("\n");
					if (stride)
						step += stride;
					else
						step += size*sizeof(float);
				} 
			} else {
				float value[size];
				glGetVertexAttribfv(location,  GL_CURRENT_VERTEX_ATTRIB,
                        value);
				SAVEGLERROR;
				for (int j = 0; j < size; j++)
					Rprintf("%8.4f ", value[j]);
				Rprintf("\n");
			}
		} else if (type == GL_UNSIGNED_BYTE) {
			if (enabled) {
				int step = 0;
				for (int i = 0; i < nvertices; i++) {
					GLubyte* value = reinterpret_cast<GLubyte*>(vertexbuffer.data() + 
						reinterpret_cast<std::uintptr_t>(offset) + step);
					for (int j = 0; j < size; j++, value++)
						Rprintf("%02x ", *value);
					Rprintf("\n");
					if (stride)
						step += stride;
					else
						step += size*sizeof(GLubyte);
				} 
			} else {
				GLint value[size];
				glGetVertexAttribiv(location,  GL_CURRENT_VERTEX_ATTRIB,
                        value);
				SAVEGLERROR;
				for (int j = 0; j < size; j++)
					Rprintf("%02x ", value[j]);
				Rprintf("\n");
			}
		}
	} else
		Rprintf("%s not defined\n", name);
	SAVEGLERROR;
}

void Shape::printAttributes(int nvertices) {
	printAttribute("aPos", nvertices);
	printAttribute("aCol", nvertices);
	printAttribute("aNorm", nvertices);
	printAttribute("aPos1", nvertices);
	printAttribute("aPos2", nvertices);
}

#endif
