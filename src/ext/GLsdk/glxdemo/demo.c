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

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/keysym.h>
#include <GL/gl.h>
#include <GL/glx.h>
#include "GL/glprocs.h"


/*
 * Define a structure keeping all application data on a per window
 * basis.
 */

typedef struct {        
    /* Intialized data */

    char  *windowTitle;

    int   xpos;
    int   ypos;
    int   width;    /* Size of client region */
    int   height;

    int   pfdFlags; /* Flags for selecting pixel format descriptor */

    /* Computed data */

    int   hasMultitexture;  /* Supports multi-texture */
    int   hasWinSwapHint;   /* Supports WinSwapHint */

    int   spin;             /* Rotation angle of triangle per window */
    int   texid;            /* Texture id per window */

    Display *display;
    GLXContext context;
    Window window;

    /* If we are using multiple renderers in a single process or on 
     * multiple threads, we must keep our function table for 
     * OpenGL 1.2, OpenGL 1.3 and extension functions 
     */

#ifdef _APP_PROCTABLE
    _GLextensionProcs extensionProcs;
#endif
} WindowData;

/*
  Using strstr for extension search can result in false positives
  because of substring matches. Since extension names in the
  extension string are separated by spaces, this can be fixed simply
  by looking for a space OR the end-of-string character immediately
  following the extension we're looking for (by skipping ahead 'len'
  characters).
*/
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

/*
 * Initialize the OpenGL context - create textures, check the extensions
 * supported by the driver etc.
 */
static void
InitializeOpenGL(WindowData *pwdata)
{
    const GLubyte *extstrGL;

    GLubyte image[] = {
        0xFF, 0x00, 0xFF, 0x00,
        0x00, 0xFF, 0x00, 0xFF,
        0xFF, 0x00, 0xFF, 0x00,
        0x00, 0xFF, 0x00, 0xFF,
    };

    /* Setup the extensions */

    extstrGL = glGetString(GL_EXTENSIONS);

    /* Check for multi-texture extension. */

    if (GL_TRUE == IsExtensionSupported (extstrGL, "GL_ARB_multitexture")) {
        pwdata->hasMultitexture = GL_TRUE;

        /* Multi-texturing is supported. Create a texture for unit1 and
         * bind it in MODULATE mode.
         */

        /* ==========================================================
         * ==========================================================
         * Use an extension function without doing anything special!
         * OpenGL 1.2, OpenGL 1.3 procs can be used similarly - as
         * long we ensure it is supported - just as we have done
         * for multi-texturing here.
         * ==========================================================
         * ==========================================================
         */

        glActiveTextureARB (GL_TEXTURE1_ARB);       /* Use unit1 */

        glGenTextures (1, &pwdata->texid);

        glBindTexture (GL_TEXTURE_2D, pwdata->texid);   /* Bound on unit 1 */
        glTexImage2D (GL_TEXTURE_2D, 0, GL_LUMINANCE, 4, 4, 0, 
                            GL_LUMINANCE, GL_UNSIGNED_BYTE, image);

        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

        glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

        glEnable (GL_TEXTURE_2D);
    }
}



static void
DrawScene(WindowData *pwdata)
{
    /* Render a triangle - multi-textured if ARB_multitexture is supported. */

    glClearColor (0.0, 0.0, 0.0, 0.0);          /* BLACK */
    glClear (GL_COLOR_BUFFER_BIT);

    glMatrixMode (GL_MODELVIEW);
    glLoadIdentity();

    glRotatef (pwdata->spin, 0.0, 0.0, 1.0);

    pwdata->spin += 2;

    if (pwdata->spin >= 360) {
        pwdata->spin = 0;
    }

    if (pwdata->hasMultitexture) {
        /*
         * ==========================================================
         * ==========================================================
         * Use an extension function without doing anything special!
         * OpenGL 1.2, OpenGL 1.3 procs can be used similarly - as
         * long we ensure it is supported - just as we have done
         * for MultiTexCoord here.
         * ==========================================================
         * ==========================================================
         */ 

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

    glXSwapBuffers(pwdata->display, pwdata->window);
}


/*
 * Create an RGB OpenGL window.
 * Return the window and context handles.
 */
static void
MakeWindow( Display *dpy, const char *name,
            int x, int y, int width, int height,
            WindowData *winData )
{
   int attrib[] = { GLX_RGBA,
		    GLX_RED_SIZE, 1,
		    GLX_GREEN_SIZE, 1,
		    GLX_BLUE_SIZE, 1,
                    GLX_DOUBLEBUFFER,
		    None };
   int scrnum;
   XSetWindowAttributes attr;
   unsigned long mask;
   Window root;
   Window win;
   GLXContext ctx;
   XVisualInfo *visinfo;

   scrnum = DefaultScreen( dpy );
   root = RootWindow( dpy, scrnum );

   visinfo = glXChooseVisual( dpy, scrnum, attrib );
   if (!visinfo) {
      printf("Error: couldn't get an RGB, Double-buffered visual\n");
      exit(1);
   }

   /* window attributes */
   attr.background_pixel = 0;
   attr.border_pixel = 0;
   attr.colormap = XCreateColormap( dpy, root, visinfo->visual, AllocNone);
   attr.event_mask = StructureNotifyMask | ExposureMask | KeyPressMask;
   mask = CWBackPixel | CWBorderPixel | CWColormap | CWEventMask;

   win = XCreateWindow( dpy, root, 0, 0, width, height,
		        0, visinfo->depth, InputOutput,
		        visinfo->visual, mask, &attr );

   /* set hints and properties */
   {
      XSizeHints sizehints;
      sizehints.x = x;
      sizehints.y = y;
      sizehints.width  = width;
      sizehints.height = height;
      sizehints.flags = USSize | USPosition;
      XSetNormalHints(dpy, win, &sizehints);
      XSetStandardProperties(dpy, win, name, name,
                              None, (char **)NULL, 0, &sizehints);
   }

   ctx = glXCreateContext( dpy, visinfo, NULL, True );
   if (!ctx) {
      printf("Error: glXCreateContext failed\n");
      exit(1);
   }

   XFree(visinfo);

   winData->display = dpy;
   winData->window = win;
   winData->context = ctx;
}


static void
EventLoop(WindowData *winData)
{
   while (1) {
      static long mask = StructureNotifyMask | ExposureMask | KeyPressMask;
      XEvent event;
      while (XCheckWindowEvent(winData->display, winData->window,
                               mask, &event)) {
         if (event.xany.window == winData->window) {
            switch (event.type) {
            case Expose:
               DrawScene(winData);
               break;
            case ConfigureNotify:
               glViewport(0, 0,
                          event.xconfigure.width, event.xconfigure.height);
               break;
            case KeyPress:
               {
                  char buffer[10];
                  int r;
                  r = XLookupString(&event.xkey, buffer, sizeof(buffer),
                                    NULL, NULL);
                  if (buffer[0] == 27) {
                     /* escape */
                        return;
                  }
               }
            }
         }
      }
      DrawScene(winData);
   }
}


int
main(int argc, char *argv[])
{
   Display *dpy;
   WindowData winData;

   dpy = XOpenDisplay(NULL);
   if (!dpy) {
      printf("Error: couldn't open default display.\n");
      return -1;
   }

   MakeWindow(dpy, "glprocs test", 0, 0, 300, 300, &winData);
   XMapWindow(dpy, winData.window);
   glXMakeCurrent(dpy, winData.window, winData.context);

   InitializeOpenGL(&winData);

   EventLoop(&winData);

   glXDestroyContext(dpy, winData.context);
   XDestroyWindow(dpy, winData.window);
   XCloseDisplay(dpy);

   return 0;
}
