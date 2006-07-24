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

#include <windows.h>    // Required inclusion on windows
#include <GL/gl.h>      // OpenGL definitions
#include <GL/glprocs.h> // OpenGL {1.2, 1.3, 1.4, 1.5} and extension functions

#include "demogl.h"


//====================================================================
//  Using strstr for extension search can result in false positives
//  because of substring matches. Since extension names in the
//  extension string are separated by spaces, this can be fixed simply
//  by looking for a space OR the end-of-string character immediately
//  following the extension we're looking for (by skipping ahead 'len'
//  characters).
//====================================================================
static GLboolean IsExtensionSupported(const GLubyte *extensionStr,
                                      const GLubyte *checkExtension)
{
    const GLubyte  *s;
	GLint len;

	s = extensionStr;
	len = strlen (checkExtension);

	while ((s = strstr (s, checkExtension)) != NULL) {
		s += len;

		if ((*s == ' ') || (*s == '\0')) {
			return (GL_TRUE);
		}
	}

	return (GL_FALSE);
}
//========================================================================
// Initialize the OpenGL context - create textures, check the extensions
// supported by the driver etc.

void InitializeOpenGL (WindowData *pwdata)
{
    const GLubyte *extstrGL;

    GLubyte image[] = {
        0xFF, 0x00, 0xFF, 0x00,
        0x00, 0xFF, 0x00, 0xFF,
        0xFF, 0x00, 0xFF, 0x00,
        0x00, 0xFF, 0x00, 0xFF,
    };

    // Setup the extensions

    extstrGL = glGetString (GL_EXTENSIONS);

    // Check for WIN_swap_hint extension.
    if (GL_TRUE == IsExtensionSupported(extstrGL, "GL_WIN_swap_hint")) {
        pwdata->hasWinSwapHint = TRUE;
    }

    // Check for multi-texture extension.
    if (GL_TRUE == IsExtensionSupported (extstrGL, "GL_ARB_multitexture")) {
        pwdata->hasMultitexture = TRUE;

        // Multi-texturing is supported. Create a texture for unit1 and
        // bind it in MODULATE mode.

        //==========================================================
        //==========================================================
        // Use an extension function without doing anything special!
        // OpenGL 1.2, OpenGL 1.3 procs can be used similarly - as
        // long we ensure it is supported - just as we have done
        // for multi-texturing here.
        //==========================================================
        //==========================================================

        glActiveTextureARB (GL_TEXTURE1_ARB);       // Use unit1

        glGenTextures (1, &pwdata->texid);

        glBindTexture (GL_TEXTURE_2D, pwdata->texid);   // Bound on unit 1
        glTexImage2D (GL_TEXTURE_2D, 0, GL_LUMINANCE, 4, 4, 0, 
                            GL_LUMINANCE, GL_UNSIGNED_BYTE, image);

        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

        glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

        glEnable (GL_TEXTURE_2D);
    }
}

//========================================================================

void DrawScene (WindowData *pwdata)
{
    // If WIN_swap_hint extension is supported, use it to create GREEN
    // border around the frame. We render the first frame with GREEN.
    // The second frame is the actual rendering rectangle - but is 
    // swapped with a smaller swap rectangle.

    if (pwdata->hasWinSwapHint) {
        glClearColor (0.0, 1.0, 0.0, 0.0);      // GREEN
        glClear(GL_COLOR_BUFFER_BIT);

        SwapBuffers (pwdata->hDC);

        // Setup the swap hint rect for the next frame

        //==========================================================
        //==========================================================
        // Use an extension function without doing anything special!
        // OpenGL 1.2, OpenGL 1.3 procs can be used similarly - as
        // long we ensure it is supported - just as we have done
        // for SwapHint here.
        //==========================================================
        //==========================================================

        glAddSwapHintRectWIN(20, 20, pwdata->width - 40, pwdata->height - 40);
    }

    // Render a triangle - multi-textured if ARB_multitexture is supported.

    glClearColor (0.0, 0.0, 0.0, 0.0);          // BLACK
    glClear(GL_COLOR_BUFFER_BIT);

    glMatrixMode (GL_MODELVIEW);
    glLoadIdentity();

    glRotatef (pwdata->spin, 0.0, 0.0, 1.0);

    pwdata->spin += 2;

    if (pwdata->spin >= 360) {
        pwdata->spin = 0;
    }

    if (pwdata->hasMultitexture) {
        //==========================================================
        //==========================================================
        // Use an extension function without doing anything special!
        // OpenGL 1.2, OpenGL 1.3 procs can be used similarly - as
        // long we ensure it is supported - just as we have done
        // for MultiTexCoord here.
        //==========================================================
        //==========================================================

        glBegin( GL_POLYGON );
            glMultiTexCoord2fARB (GL_TEXTURE1_ARB, 0.0, 0.0);
            glColor3f (1.0, 0.0, 0.0); 
            glVertex3f(0.0, 0.0, 0.0);
                                
            glMultiTexCoord2fARB (GL_TEXTURE1_ARB, 1.0, 0.0);
            glColor3f (0.0, 1.0, 0.0); 
            glVertex3f(0.5, 0.0, 0.0);

            glMultiTexCoord2fARB (GL_TEXTURE1_ARB, 1.0, 1.0);
            glColor3f (0.0, 0.0, 1.0); 
            glVertex3f(0.5, 0.5, 0.0);          
        glEnd();
    } else {
        glBegin( GL_POLYGON );
            glColor3f (1.0, 0.0, 0.0); 
            glVertex3f(0.0, 0.0, 0.0);
                                
            glColor3f (0.0, 1.0, 0.0); 
            glVertex3f(0.5, 0.0, 0.0);

            glColor3f (0.0, 0.0, 1.0); 
            glVertex3f(0.5, 0.5, 0.0);          
        glEnd();
    }

    SwapBuffers (pwdata->hDC);
}
