#ifndef RGL_LIB_H
#define RGL_LIB_H
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

#endif // RGL_LIB_H

