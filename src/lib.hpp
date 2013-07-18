#ifndef RGL_LIB_HPP
#define RGL_LIB_HPP
// ---------------------------------------------------------------------------
// $Id$
// ---------------------------------------------------------------------------
namespace lib {
// ---------------------------------------------------------------------------
bool init(bool onlyNULLDevice);
const char * GUIFactoryName(bool useNULLDevice);    
void quit();
void printMessage(const char* string);
double getTime();
// ---------------------------------------------------------------------------
} // namespace lib
// ---------------------------------------------------------------------------
#endif // RGL_LIB_HPP

