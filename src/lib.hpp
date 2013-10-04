#ifndef RGL_LIB_HPP
#define RGL_LIB_HPP
// ---------------------------------------------------------------------------
// $Id$
// ---------------------------------------------------------------------------

namespace rgl {

// ---------------------------------------------------------------------------
bool init(bool onlyNULLDevice);
const char * GUIFactoryName(bool useNULLDevice);    
void quit();
void printMessage(const char* string);
double getTime();
// ---------------------------------------------------------------------------

} // namespace rgl

#endif // RGL_LIB_HPP

