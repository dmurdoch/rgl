#ifndef __DEMOGL_H__ 
#define __DEMOGL_H__ 
   
/*
** License Applicability. Except to the extent portions of this file are
** made subject to an alternative license as permitted in the SGI Free
** Software License B, Version 1.1 (the "License"), the contents of this
** file are subject only to the provisions of the License. You may not use
** this file except in compliance with the License. You may obtain a copy
** of the License at Silicon Graphics, Inc., attn: Legal Services, 1600
** Amphitheatre Parkway, Mountain View, CA 94043-1351, or at:
** 
** http://oss.sgi.com/projects/FreeB
** 
** Note that, as provided in the License, the Software is distributed on an
** "AS IS" basis, with ALL EXPRESS AND IMPLIED WARRANTIES AND CONDITIONS
** DISCLAIMED, INCLUDING, WITHOUT LIMITATION, ANY IMPLIED WARRANTIES AND
** CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A
** PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
** 
** Original Code. The Original Code is: OpenGL Sample Implementation,
** Version 1.2.1, released January 26, 2000, developed by Silicon Graphics,
** Inc. The Original Code is Copyright (c) 1991-2000 Silicon Graphics, Inc.
** Copyright in any portions created by third parties is as indicated
** elsewhere herein. All Rights Reserved.
** 
** Additional Notice Provisions: This software was created using the
** OpenGL(R) version 1.2.1 Sample Implementation published by SGI, but has
** not been independently verified as being compliant with the OpenGL(R)
** version 1.2.1 Specification.
*/

// Define a structure keeping all application data on a per window
// basis.

typedef struct {        
    // Intialized data

    char  *windowTitle;

    int   xpos;
    int   ypos;
    int   width;    // Size of client region
    int   height;

    int   pfdFlags; // Flags for selecting pixel format descriptor

    // Computed data

    int   hasMultitexture;  // Supports multi-texture
    int   hasWinSwapHint;   // Supports WinSwapHint

    int   spin;             // Rotation angle of triangle per window
    int   texid;            // Texture id per window

    HWND  hWnd;     // Main window handle.
    HDC   hDC;      // Device context
    HGLRC hRC;      // OpenGL context

    // If we are using multiple renderers in a single process or on 
    // multiple threads, we must keep our function table for 
    // OpenGL 1.2, OpenGL 1.3 and extension functions 

#ifdef _APP_PROCTABLE
    _GLextensionProcs extensionProcs;
#endif
} WindowData;

// Extern defintions for rendering functions in demogl.c.
   
void InitializeOpenGL (WindowData *pwdata);
void DrawScene (WindowData *pwdata);

#endif /* __DEMOGL_H__ */ 
