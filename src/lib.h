#ifndef LIB_H
#define LIB_H

// C++ header file
// This file is part of RGL
//
// $Id: lib.h,v 1.1 2003/03/25 00:13:21 dadler Exp $

bool lib_init();
void lib_quit();

// lib services:

void   printMessage(const char* string);
double getTime();

#endif /* LIB_H */
