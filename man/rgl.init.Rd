\name{rgl.init}
\title{Initializing RGL}
\alias{rgl.init}
\description{
Initializing the RGL system.
}
\usage{
rgl.init(initValue = 0, onlyNULL = FALSE, 
         debug = getOption("rgl.debug", FALSE))
}
\arguments{
  \item{initValue}{value for internal use only}
  \item{onlyNULL}{only initialize the null (no display) device}
  \item{debug}{enable some debugging messages}
}

\value{
Normally the user doesn't call \code{rgl.init} at all:  it
is called when the package is loaded.  It returns no
useful value.
}
\details{
  If \code{useNULL} is \code{TRUE}, RGL will use a \dQuote{null}
  device.  This device records objects as they are plotted, but 
  displays nothing. It is intended for use with \code{\link{rglwidget}}
  and similar functions.
  
  Currently \code{debug} only controls messages printed by the OpenGL
  library during initialization.  In future \code{debug = TRUE} may
  become more verbose.

For display within an OpenGL window in R, RGL requires the OpenGL
system to be installed and available.  If there is a problem 
initializing it, you may see the message
\verb{'rgl.init' failed, running with 'rgl.useNULL = TRUE'.}  There
are several causes and remedies:
\itemize{
\item{On any system, the OpenGL libraries need to be present for RGL to be able to start an OpenGL device.}
\itemize{
\item{On macOS, you need to install XQuartz.  It is available from
\url{https://www.xquartz.org}.}
\item{On Linux, you need to install Mesa 3D.  One of these commands
may work, depending on your system:
\verb{
  zypper source-install --build-deps-only Mesa # openSUSE/SLED/SLES
  yum-builddep mesa      # yum Fedora, OpenSuse(?)
  dnf builddep mesa      # dnf Fedora
  apt-get build-dep mesa # Debian, Ubuntu and related
  }
}
\item{Windows should have OpenGL installed by default.}
}
\item{On Unix-alike systems (macOS and Linux, for example), RGL
normally
uses the GLX system for creating displays.  If the graphic is created
on a remote machine, it may need to use \dQuote{Indirect GLX} (IGLX).  Due
to security concerns, this is often disabled by default.  See
\url{https://www.x.org/wiki/Development/Security/Advisory-2014-12-09/}
for a discussion of the security issues, and 
\url{https://unix.stackexchange.com/q/317954}
for ways to re-enable IGLX.}
\item{The \url{https://www.virtualgl.org} project is intended to 
be a way to avoid IGLX, by rendering remotely and sending bitmaps
to the local machine.  It's not a simple install...}
\item{If you don't need to see RGL displays on screen, you
can use the \dQuote{NULL device}.  See \code{\link{rgl.useNULL}}.}
\item{If you can't build the \pkg{rgl} package with OpenGL
support, you can
disable it and use the NULL device.  (This may happen automatically
during configuration, but you'll get a tested result if you
specify it explicitly.)  See the instructions in the
\file{README} file in the source tarball.}
}
}
