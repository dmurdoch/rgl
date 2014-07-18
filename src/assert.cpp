#include "R.h"
#include "assert.h"

void rgl_assert (const char* assertion, const char* file, int line)
{
    error("Assertion failure: %s\nFile: %s\nLine: %d\nPlease report to rgl maintainer.",
           assertion, file, line);
}

