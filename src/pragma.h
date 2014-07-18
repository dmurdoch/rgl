#ifndef RGL_PRAGMA_H
#define RGL_PRAGMA_H

/**
 * compiler- and platform-specific pragma's
 **/

//
// ---[ Borland C++ ]---------------------------------------------------------
//
#ifdef __BCPLUSPLUS__
#define _RWSTD_NO_EXCEPTIONS

#define ARCH_X86

#endif

//
// ---[ Microsoft Visual C++ ]------------------------------------------------
//
#ifdef _MSC_VER 


#pragma warning(disable:4530)
/**
 * remove warnings on truncated 'debug information' to 255 characters
 **/
#pragma warning(disable:4786)

/**
 * remove warnings " 'this' : used in base member initializer list "
 **/
#pragma warning(disable:4355) 

#ifdef _M_IX86
#define ARCH_X86
#endif

#endif

//
// ---[ GCC ]-----------------------------------------------------------------
//
#ifdef __GNUC__

#ifdef _X86_
#define ARCH_X86
#endif

#endif

#endif // RGL_PRAGMA_H
