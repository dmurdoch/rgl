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
             powerOfTwo = TRUE,
             verbose = FALSE,
             showBaselines = FALSE,
             onePerLine = FALSE)
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
  \item{powerOfTwo}{
Whether to round up the dimensions of the bitmap to the next power of two.  This may be needed if used as a texture.
  }
  \item{verbose}{
Print text measurements 
}
  \item{showBaselines}{
Whether to render the baselines of the text (for debugging purposes).
  }
  \item{onePerLine}{
Whether to force all strings onto separate lines in the result.
  }
}
\details{
Renders the text to a bitmap in memory, and returns locations
to be used when drawing texture.

If any strings (plus formatting for them) are exactly repeated,
only one copy will be written to the bitmap.
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
text <- c("abc", "Tokyo (\u6771\u4eac)", "\u6771\u4eac", "abc")
bm <- drawToBitmap(text, cex = 3, family = "sans", font = 1,
                   powerOfTwo = FALSE,
                   showBaselines = TRUE, onePerLine = TRUE)
plot.new()
rasterImage(bm, 0, 0, 1, 1)
dim(bm)
attr(bm, "metrics")
}