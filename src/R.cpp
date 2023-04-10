#include <string>
#include "R.h"

namespace rgl {

using namespace rgl;

char* copyStringToR(std::string s) {
	/* R has highjacked length() */
	char* result;
	size_t len = s.size();
	result = R_alloc(len + 1, 1);
	strncpy(result, s.c_str(), len);
	result[len] = '\0';
	return result;
}

}
