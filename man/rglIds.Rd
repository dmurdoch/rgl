\name{rglIds}
\alias{lowlevel}
\alias{highlevel}
\alias{rglId}
\alias{rglLowlevel}
\alias{rglHighlevel}
\alias{print.rglId}
\title{
rgl id values
}
\description{
All objects in an \pkg{rgl} scene have a
numerical id.  These ids are normally stored
in vectors of class \code{"rglIds"}, which
will also have class \code{"rglHighlevel"}
or \code{"rglLowlevel"} depending on 
whether a high level function like 
\code{\link{plot3d}} or \code{\link{persp3d}}, or a low level function created the objects.


}
\usage{
lowlevel(ids = integer())
highlevel(ids = integer())
\method{print}{rglId}(x, 
      rglwidget = getOption("rgl.printRglwidget", FALSE),
      ...)
}
\arguments{
  \item{ids}{
A vector of object ids.
}
  \item{x}{
An \code{"rglId"} object to print.
}
  \item{rglwidget}{
Whether to create and print an rgl widget.
If false, nothing is printed.
}
  \item{...}{
Other arguments which will be passed to
\code{\link{rglwidget}} if it is used.
}
}
\details{
These functions and classes are intended to allow
\pkg{rgl} scenes to be automatically 
displayed in R Markdown documents.  However,
this is not fully in place yet, so
explicit \code{rglwidget()} calls are
still recommended.

Note that \emph{all} objects in the current
scene will be printed by default, not just
the ids in \code{x}.  (The reason for this
is that lights are also objects; printing
objects without lights would rarely make
sense.)
}
\value{
Objects of class \code{c("rglHighlevel", "rglId")} or \code{c("rglLowlevel", "rglId")}.  
}
\author{
Duncan Murdoch
}
\examples{
x <- matrix(rnorm(30), ncol = 3, dimnames = list(NULL, c("x", "y", "z")))
p <- plot3d(x, type = "s")
str(p)
if (interactive())
  print(p, rglwidget = TRUE)
}