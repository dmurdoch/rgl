#include "shaders.h"
#include "init.h"

#include <string>
#include <fstream>
#include <iostream>

using namespace rgl;

static std::string defaultShaders[NUM_SHADERS];
static std::string shaderFilenames[NUM_SHADERS] =
	{"rgl_vertex.glsl", "rgl_fragment.glsl"};

std::string rgl::defaultShader(ShaderType type)
{
	std::string result = defaultShaders[type];
	if (!result.size()) {
		std::string filename = rglHome + "/shaders/" + shaderFilenames[type];
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

UserData::UserData(int in_size, int in_dim, double* values) {
  size = in_size;
  dim = in_dim;
  location = -1;
  offset = -1;
  floats.reserve(size*dim);
  for (int i = 0; i < size*dim; i++)
    floats.push_back(static_cast<float>(*values++));
}

void UserData::recycle(unsigned int newsize) {
  floats.resize(newsize*dim);
  if (newsize > size) {
    for (int i=size; i < newsize; i++) {
      int i0 = i % size;
      for (int j=0; j < dim; j++)
        floats[i*dim + j] = floats[i0*dim + j];
    }
  }
  size = newsize;
}

#ifndef RGL_NO_OPENGL
void UserData::beginUse() {
  if (location >= 0) {
    glEnableVertexAttribArray(location);
    glVertexAttribPointer(location, dim, GL_FLOAT, GL_FALSE, 0, (GLbyte*)0 + offset);
  }
}

void UserData::endUse() {
  if (location >= 0)
    glDisableVertexAttribArray(location);
}

void UserData::appendToBuffer(std::vector<GLubyte>& buffer)
{
  offset = buffer.size();
  const GLubyte* p;
  p = reinterpret_cast<const GLubyte*>(floats.data());
  buffer.insert(buffer.end(), p, p + floats.size()*sizeof(float));
}

void UserData::uploadUniform() {
  switch(dim) {
  case 1: glUniform1fv(location, size, floats.data()); break;
  case 2: glUniform2fv(location, size, floats.data()); break;
  case 3: glUniform3fv(location, size, floats.data()); break;
  case 4: glUniform4fv(location, size, floats.data()); break;
  case 16: glUniformMatrix4fv(location, size, false, floats.data()); break;
  default: Rf_error("Only scalar floats, vec2, vec3, vec4 and mat4 are supported.");
  }
}
#endif
