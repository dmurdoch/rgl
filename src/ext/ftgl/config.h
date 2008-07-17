/* In rgl, we don't run the FTGL configure script, and we don't have 
   RTTI.  It appears as though the configure script is not needed for the 
   subset we use (except we need config.h, hence this file), and we can 
   use static_casts in place of dynamic_casts, hence the define below.
*/

#define dynamic_cast static_cast
