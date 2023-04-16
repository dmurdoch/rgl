
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
}

Shape::~Shape()
{
#ifndef RGL_NO_OPENGL
  if (displayList)
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
    error("Internal error:  nested Shape::drawBegin");
  }
  drawLevel++;
}

void Shape::drawEnd(RenderContext* renderContext)
{
  if (drawLevel != 1) {
    drawLevel = 0;
    error("Internal error: Shape::drawEnd without drawBegin");
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
  result.has_normals = type == "spheres";
  if (!result.has_normals)
    result.has_normals = getAttributeCount(subscene, NORMALS) > 0;

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
		"#define NCLIPPLANES " + std::to_string(nclipplanes) + "\n"+
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

void Shape::initialize()
{
  SceneNode::initialize();
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
		
		GLuint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
		source = material.shaders[FRAGMENT_SHADER];
		if (source.size() == 0)
			source = defaultShader(FRAGMENT_SHADER);
		sources[1] = source.c_str();
		glShaderSource(fragmentShader, 2, sources, NULL);
		glCompileShader(fragmentShader);
		
		Rprintf("created shaders");
		
		GLuint shaderProgram = glCreateProgram();
		glAttachShader(shaderProgram, vertexShader);
		glAttachShader(shaderProgram, fragmentShader);
		
		glBindAttribLocation(shaderProgram, 0, "aPos");
		glLocs["aPos"] = 0;
		glBindAttribLocation(shaderProgram, 1, "aCol");
		glLocs["aCol"] = 1;
		
		glLinkProgram(shaderProgram);
		
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
#endif
}
