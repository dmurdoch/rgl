\name{setGraphicsDelay}
\alias{setGraphicsDelay}
\alias{RGL_SLOW_DEV}
\title{
Set a one-time slowdown on opening standard graphics
}
\description{
This function is mainly for internal use, to work around  
a bug in macOS Catalina:  if base plotting happens
too quickly after opening RGL and the first call to quartz, R crashes.

This inserts a delay after the first call to open the 
graphics device.  The default is
no delay, unless on Catalina with no graphics device
currently open but the \code{\link{quartz}} device set
as the default, when a 1 second delay will be added.
Use environment variable "RGL_SLOW_DEV = value" to set
a different default delay. 

It works by changing the value of \code{\link{options}("device")},
so explicit calls to the device will not be affected.

It is called automatically when the \pkg{rgl} package is loaded.  
}
\usage{
setGraphicsDelay(delay = Sys.getenv("RGL_SLOW_DEV", 0), 
                 unixos = "none")
}
\arguments{
  \item{delay}{
Number of seconds for the delay.
}
  \item{unixos}{
The name of the Unix OS.  If set to \code{"Darwin"}, 
and the version is 19.0.0 or greater, the default delay is
changed to 1 second.
}
}
\value{
Called for the side effect of adding the delay to the first
opening of the graphics device.
}
