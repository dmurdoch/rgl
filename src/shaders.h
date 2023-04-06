#ifndef SHADERS_H
#define SHADERS_H

#include <string>

namespace rgl {

enum ShaderType {
	VERTEX_SHADER = 0,
	FRAGMENT_SHADER,
	NUM_SHADERS
};

std::string defaultShader(ShaderType type);

} // namespace rgl

#endif // SHADERS_H
