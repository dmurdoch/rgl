// C++ source
// This file is part of RGL.
//
// $Id: x11lib.inc,v 1.1 2005/02/15 19:37:32 dadler Exp $

#include "lib.h"


//
// ===[ GUI IMPLEMENTATION ]=================================================
//

#include "x11gui.h"

gui::X11GUIFactory* gpX11GUIFactory = NULL;

gui::GUIFactory* getGUIFactory()
{
  return (gui::GUIFactory*) gpX11GUIFactory;
}

//
// ===[ R INTEGRATION ]=======================================================
//

#include <R.h>
#include <R_ext/eventloop.h>

static InputHandler* R_handler = NULL;

static void R_rgl_eventHandler(void * userData)
{
  gpX11GUIFactory->processEvents();
}

static void set_R_handler()
{
  // add R input handler (R_ext/eventloop.h)
  // approach taken from GtkDevice ... good work guys!
  
  R_handler = ::addInputHandler(R_InputHandlers, gpX11GUIFactory->getFD(), R_rgl_eventHandler, XActivity);

  // seek end of node
  
  while(R_handler->next)
    R_handler = R_handler->next;
}

static void unset_R_handler()
{
  if (R_handler) {
    ::removeInputHandler(&R_InputHandlers, R_handler);
    R_handler = NULL;
  }
}

//
// ===[ LIB INIT / QUIT ]=====================================================
//


bool lib_init()
{
  bool success = false;

  // construct GUI Factory
  
  gpX11GUIFactory = new gui::X11GUIFactory(NULL);
 
  if ( gpX11GUIFactory->isConnected() ) {
    set_R_handler();
    success = true;
  }
  return success;
}

void lib_quit()
{
  unset_R_handler();
  delete gpX11GUIFactory;
}

//
// ===[ LIB SERVICES ]=======================================================
//

//
// printMessage
//

#include <stdio.h>

void printMessage( const char* string ) {
  fprintf(stderr, "RGL: %s\n", string);
}

//
// getTime
//

#include <sys/time.h>
#include <unistd.h>

double getTime() {
  struct timeval t;
  gettimeofday(&t,NULL);
  return ( (double) t.tv_sec ) * 1000.0 + ( ( (double) t.tv_usec ) / 1000.0 ); 
}
