#ifndef LIB_H
#define LIB_H

// C++ header file
// This file is part of RGL
//
// $Id$

bool lib_init();
void lib_quit();

// lib services:

void   printMessage(const char* string);
double getTime();

#endif /* LIB_H */
