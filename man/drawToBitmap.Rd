\name{drawToBitmap}
\alias{drawToBitmap}
\title{
Render text to bitmap.
}
\description{
Draws text on a native raster.  Used to make textures holding the text.
}
\usage{
drawToBitmap(texts, 
             cex = par3d(cex), 
             family = par3d("family"), 
             font = par3d("font"), 
             background = "transparent", 
             verbose = FALSE,
             powerOfTwo = TRUE)
}
\arguments{
  \item{texts}{
The text to draw.
}
  \item{cex}{
Character expansion.
}
  \item{family}{
Font family.
}
  \item{font}{
Font style number (1 to 4)
}
  \item{background}{
Background color for bitmap
}
  \item{verbose}{
Print text measurements 
}
}
\details{
Renders the text to a bitmap in memory, and returns locations
to be used when drawing texture.

If any strings (plus formatting for them) are exactly repeated,
only one copy will be written to the bitmap.

If \code{powerOfTwo} is \code{TRUE}, the dimensions of the bitmap
will be rounded up to the next power of two.
}
\value{
A native raster with attribute \code{metrics}, containing information about each string given in the input, plus these computed values:
\item{x, y}{pixel location where rendering was drawn (using (0,0) justification)}
\item{width}{width in pixels}
\item{descent, ascent}{pixels below and above the origin}
}
\author{
Duncan Murdoch
}

\examples{
library(rgl)
text <- c("abc", "Tokyo (東京)", "東京", "abc")
bm <- drawToBitmap(text, cex = 3, powerOfTwo = FALSE)
grid::grid.raster(bm)
dim(bm)
attr(bm, "metrics")
}