\name{drawToBitmap}
\alias{drawToBitmap}
\title{
Render text to bitmap.
}
\description{
Draws text on an integer array.  Uses the same code
as is used to draw text via textures.
}
\usage{
drawToBitmap(texts, 
             cex = par3d(cex), 
             family = par3d("family"), 
             fontfile = NULL,
             font = par3d("font"), 
             showBaselines = FALSE,
             onePerLine = FALSE,
             unique = !onePerLine,
             minWidth = 0, minHeight = 0,
             powerOfTwo = TRUE,
             verbose = FALSE)
}
\arguments{
  \item{texts}{
The text to draw.
}
  \item{cex, family, font}{
Text characteristics.
}
  \item{fontfile}{
If present, overrides \code{family}.
}
  \item{showBaselines}{
Whether to render the baselines of the text (for debugging purposes).
  }
  \item{onePerLine}{
Whether to force all strings onto separate lines in the result.
  }
  \item{unique}{
Whether to omit strings that are identical to others.
  }
  \item{minWidth, minHeight}{
Min dimensions for bitmap.
  }
  \item{powerOfTwo}{
Whether to round up the dimensions of the bitmap to the next power of two.  This may be needed if used as a texture.
  }
  \item{verbose}{
Print text measurements 
  }
}
\details{
Renders the text to a bitmap in memory, and returns locations
to be used when drawing texture.

The bitmap width (number of columns) is initially the width of the
widest string, but may be increased if \code{minWidth} is bigger
or \code{powerOfTwo} is \code{TRUE}.
}
\value{
An integer array with attribute \code{info} containing information about each string given in the input, plus these computed values:
\item{height, width}{dimensions of "ink" for this string}
\item{x_advance, y_advance}{amount to move "pen" after drawing}
\item{x_bearing, y_bearing}{positioning within cell}
\item{ascent, descent}{characteristics of main font for
this string; mixing fonts (e.g. by including emojis or
characters from other alphabets) will invalidate these values}
\item{baseline}{the row containing the character baseline,
adjusted for mixed fonts if necessary}
\item{x, y}{pixel location where rendering was drawn (using (0,0) justification)}
}
\author{
Duncan Murdoch
}

\examples{
text <- c("abc", "Tokyo (\u6771\u4eac)", "\u6771\u4eac", "abc")

# First draw one per line, spaced appropriately

bm <- drawToBitmap(text, cex = 3, family = "sans", font = 1,
                   powerOfTwo = FALSE,
                   showBaselines = TRUE, onePerLine = TRUE,
                   verbose = TRUE)
image(1:nrow(bm), 1:ncol(bm), bm, xlab="col", ylab="row")

# Next pack all the unique images tightly into the bitmap
bm <- drawToBitmap(text, cex = 3, family = "sans", font = 1,
                   powerOfTwo = FALSE,
                   showBaselines = TRUE, onePerLine = FALSE, verbose = TRUE)
image(1:nrow(bm), 1:ncol(bm), bm, xlab="col", ylab="row")
}
