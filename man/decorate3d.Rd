\name{decorate3d}
\alias{decorate3d}
\title{
Add decorations to a 3D plot
}
\description{
\code{decorate3d} adds the usual decorations to a plot:  labels, axes, etc.  
}
\usage{
decorate3d(xlim = NULL, ylim = NULL, zlim = NULL, 
           xlab = "x", ylab = "y", zlab = "z", 
           box = TRUE, axes = TRUE, 
           main = NULL, sub = NULL, 
           top = TRUE, aspect = FALSE, expand = 1.03, 
           tag = material3d("tag"), ...)
}
\arguments{  
  \item{xlim, ylim, zlim}{These are used
for the labels.}
  \item{xlab, ylab, zlab}{labels for the coordinates.}
  \item{box, axes}{whether to draw a box and axes.}
  \item{main, sub}{main title and subtitle.}
  \item{top}{whether to bring the window to the top when done.}
  \item{aspect}{either a logical indicating whether to adjust the aspect ratio, or a new ratio.}
  \item{expand}{how much to expand the box around the data, if it is drawn.}
  \item{tag}{optional label for objects
  being produced.}
  \item{...}{ignored.}
}
\value{
The RGL id values for those items.
}
\examples{
open3d()
shade3d(tetrahedron3d(), col = "red")
decorate3d(main = "A Tetrahedron")
}