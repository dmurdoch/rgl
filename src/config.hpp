#ifndef RGL_CONFIG_HPP
#define RGL_CONFIG_HPP
// ---------------------------------------------------------------------------
// Platform detection
// ---------------------------------------------------------------------------
#if defined(__APPLE__)
# define RGL_OSX 1
# if defined(RGL_USE_CARBON)
#  define RGL_CARBON 1
# else
#  define RGL_X11 1
# endif
#else
# if defined(_WIN32) || defined(__WIN32__) || defined(WIN32)
#  define RGL_W32 1
# else
#  define RGL_X11 1
# endif
#endif
// ---------------------------------------------------------------------------
#endif //RGL_CONFIG_HPP

