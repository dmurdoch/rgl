
#include <string>
#include <fstream>
#include <iostream>

#include "init.h"
#include "shaders.h"

#undef length     /* not Rf_length! */

using namespace rgl;

static std::string defaultShaders[NUM_SHADERS];
static std::string shaderFilenames[NUM_SHADERS] =
	{"rgl_vertex.glsl", "rgl_fragment.glsl"};

std::string rgl::defaultShader(ShaderType type)
{
	std::string result = defaultShaders[type];
	if (!result.length()) {
		std::string filename = rglHome + "/htmlwidgets/lib/rglClass/shaders/" + shaderFilenames[type];
		std::ifstream file(filename);
		if (!file) {
			// Error handling: file could not be opened
				return "";
			}
			
		std::string file_contents((std::istreambuf_iterator<char>(file)),
                   std::istreambuf_iterator<char>());
		result = file_contents;
	}
	return result;
}
