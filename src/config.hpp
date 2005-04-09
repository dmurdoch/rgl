#ifndef RGL_CONFIG_HPP
#define RGL_CONFIG_HPP
// ---------------------------------------------------------------------------
// Platform detection
// ---------------------------------------------------------------------------
#if defined(__APPLE__)
#define RGL_OSX 1
#endif
#if defined(_WIN32) || defined(__WIN32__) || defined(WIN32)
#define RGL_W32 1
#endif
#if !defined(RGL_OSX) && !defined(RGL_W32)
#define RGL_X11 1
#endif
// ---------------------------------------------------------------------------
#endif //RGL_CONFIG_HPP

