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
#include <GL/glprocs.h>

#include <stdio.h>
#include <assert.h>

#include "demogl.h"

static char szAppName[] = "OpenGL";
HINSTANCE _hInstance;

WindowData wdata[] = {
    {"MS OpenGL",   50,  50, 150, 150, 
        PFD_DRAW_TO_WINDOW | PFD_DOUBLEBUFFER | PFD_GENERIC_FORMAT},

    {"ICD OpenGL",  50, 250, 200, 200, 
        PFD_DRAW_TO_WINDOW | PFD_DOUBLEBUFFER},    
};

int nWnd = sizeof (wdata) / sizeof (wdata[0]);;

#define TESTFLAGS (PFD_DRAW_TO_WINDOW | PFD_DOUBLEBUFFER | PFD_GENERIC_FORMAT)

//******************************************************************
//******************************************************************

WindowData  *currentWindowData;

// Function to get thread local proc table.

_GLextensionProcs *_GET_TLS_PROCTABLE(void) 
{
    // Return the pointer to the extension proc table 
    // hanging off the current local data.

    return (&currentWindowData->extensionProcs);
}

//******************************************************************
//******************************************************************
    
//========================================================================
// Setup a pixel format for a window, create context and initialize 
// OpenGL 1.2 procs.

void SetupWindow (HWND hWnd, WindowData *pwdata)
{
    int iPixelFormat = 0;
    int numPixelFmts;
    PIXELFORMATDESCRIPTOR pfd;
    int i;

    pwdata->hDC = GetDC (hWnd);     // Create a DC for the window.

    // Search for a pixel format which matches the flags specified for
    // the window.

    numPixelFmts = DescribePixelFormat (pwdata->hDC, 1, sizeof (pfd), NULL);

    for (i = 0; i < numPixelFmts; i++) {
        DescribePixelFormat (pwdata->hDC, i+1, sizeof(pfd), &pfd);

        if ((pfd.dwFlags & TESTFLAGS) == pwdata->pfdFlags) {
            iPixelFormat = i+1;
            break;
        }
    }

    if (iPixelFormat == 0) {        // Did not find a suitable pixel format
        assert (0);
        exit(1);
    }

    // Set pixel format for the window

    if (SetPixelFormat (pwdata->hDC, iPixelFormat, &pfd) == FALSE) {
        assert (0);
        exit (1);
    }

    // Create a context for the window

    pwdata->hRC = wglCreateContext (pwdata->hDC);

    // Bind this context to this thread. Since each thread is working on
    // each window, we have to do MakeCurrent only once.

    wglMakeCurrent (pwdata->hDC, pwdata->hRC);

    //********************************************************
    //********************************************************
    // Every time we do MakeCurrent, we must setup the global
    // ptr to currentWindowData so that we have the correct
    // proc table for OpenGL functions.

    currentWindowData = pwdata;

    //********************************************************
    //********************************************************

    // Initialize the OpenGL context.

    InitializeOpenGL (pwdata);
}

//========================================================================
// Proc to receive window messages

LONG WINAPI WndProc (HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    PAINTSTRUCT ps;
    WindowData  *pwdata;
    RECT        rect;

    // Obtain the window data for this thread. Note that WM_CREATE cannot
    // "read" the values in window data since it has not yet been setup until
    // we have gone through creation/initialization. Also, pwdata as
    // computed below is incorrect when we receive WM_CREATE msg.

    if (hWnd == wdata[0].hWnd) {
        pwdata = &wdata[0];
    } else {
        pwdata = &wdata[1];
    }

    // Process the window message.

    switch (msg) {
    case WM_CREATE:
        SetupWindow (hWnd, ((LPCREATESTRUCT) lParam)->lpCreateParams);
        return (0);

    case WM_SIZE:
        pwdata->width  = LOWORD (lParam);
        pwdata->height = HIWORD (lParam);

        glViewport (0, 0, pwdata->width, pwdata->height);
        return 0;

    case WM_PAINT:
        // Since both the contexts are running on the same thread,
        // make the context for the current window current 
        // before rendering.

        wglMakeCurrent (pwdata->hDC, pwdata->hRC);

        //********************************************************
        //********************************************************
        // Every time we do MakeCurrent, we must setup the global
        // ptr to currentWindowData so that we have the correct
        // proc table for OpenGL functions.
    
        currentWindowData = pwdata;
    
        //********************************************************
        //********************************************************

        BeginPaint (hWnd, &ps);
        DrawScene(pwdata);          // Update the client area
        EndPaint (hWnd, &ps);

        return 0;       
            
    case WM_DESTROY:
        // Delete the context. 

        wglDeleteContext (pwdata->hRC);

        // In multi-window scenario, post the quit message
        // only when the number of window becomes zero.

        nWnd -= 1;

        if (nWnd == 0) {
            PostQuitMessage( 0 );
        }
        return 0;
    }

    return DefWindowProc (hWnd, msg, wParam, lParam);
}

//========================================================================

int ThreadMain (int i)
{
    //******************************************************************
    //******************************************************************

    // Initialize the OpenGL extension proc table for this window data.
    // (One time intiailization per device context). We do it early
    // so that even wgl Extensions are correctly available to the thread.

    _InitExtensionProcs (&wdata[i].extensionProcs);

    //******************************************************************
    //******************************************************************

    // Create a window for the application.

    wdata[i].hWnd = CreateWindow(
                szAppName,              // Application name
                wdata[i].windowTitle,   // Window title text
                WS_OVERLAPPEDWINDOW |   // Window style 
                WS_CLIPCHILDREN |       // Needed for OpenGL
                WS_CLIPSIBLINGS,        // Needed for OpenGL
                wdata[i].xpos,  wdata[i].ypos, 
                wdata[i].width, wdata[i].height,
                NULL,                   // No parent window
                NULL,                   // Use the window class menu.
                _hInstance,             // This instance owns this window
                &wdata[i]);             // Application window data structure

    // Check for window creation

    if (!wdata[i].hWnd) {
        assert (0);
        exit (1);
    }

    // Make the window visible & update its client area

    ShowWindow (wdata[i].hWnd, SW_SHOWNORMAL);
    UpdateWindow (wdata[i].hWnd);            // Send WM_PAINT message

    return (0);
}

//========================================================================
// Windows main program.

int WINAPI WinMain (HINSTANCE hInstance,
                    HINSTANCE hPrevInstance,
                    LPSTR lpszCmdLine, int nCmdShow)
{

    WNDCLASS wc;   // windows class sruct

    int      i;
    HANDLE   hThread;   
    DWORD    IDThread;

    MSG msg;  // message struct 

    _hInstance = hInstance; // Save for later use.

    // Fill in window class structure with parameters that
    //  describe the main window.

    wc.style         = CS_HREDRAW | CS_VREDRAW;     // Class style(s).
    wc.lpfnWndProc   = (WNDPROC)WndProc;            // Window Procedure
    wc.cbClsExtra    = 0;     
    wc.cbWndExtra    = 0;    
    wc.hInstance     = hInstance;                   // Owner of this class
    wc.hIcon         = NULL;                        // Icon name 
    wc.hCursor       = LoadCursor(NULL, IDC_ARROW); // Cursor
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);    // Default color
    wc.lpszMenuName  = NULL; 
    wc.lpszClassName = szAppName;                   // Name to register as

    // Register the window class

    RegisterClass( &wc );

    // Create multiple windows without creating threads.

    for (i = 0; i < nWnd; i++) {
        ThreadMain (i);
    }

    // Enter the Windows message loop. Get and dispatch messages
    // until WM_QUIT.

    while (GetMessage(&msg, // message structure
               NULL,        // handle of window receiving the message
               0,           // lowest message id to examine
               0)) {        // highest message id to examine
        TranslateMessage (&msg);
        DispatchMessage (&msg);
    }

    return (msg.wParam);
}
