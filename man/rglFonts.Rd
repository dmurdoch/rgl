\name{rglFonts}
\alias{rglFonts}
\title{
Specify FreeType fonts
}
\description{
Specify FreeType fonts for use in \pkg{rgl} graphics.
}
\usage{
rglFonts(...)
}
\arguments{
  \item{ ... }{Device dependent font definitions for use with FreeType.}  
}
\details{
By default, \pkg{rgl} uses system fonts on all platforms.
This function allows the defaults to be overridden by
specifying font families or font files that can be read by \code{pangocairo}
on your system.  

\code{rglFonts} takes two sorts of parameters.  As of 
\pkg{rgl} version 1.4.0, the
normal way is for each argument to be named and consist
of a length 1 character vector.  In this case the argument
name can be used as the \code{family} in a call to
\code{\link{text3d}} and related functions, and the
value of the string will be passed to the
\code{pangocairo} engine to determine the font family. 
For example, \code{rglFonts(sans = "Arial")} will define
the \code{Arial} font to be used when \code{"sans"} is
requested.

For compatibility with older versions, \code{rglFonts}
also allows the value to be 
a vector of four filenames of TrueType font files which
will be used for the four styles regular, bold, italic and bold italic, e.g.
\code{rglFonts(sans = c("/path/to/FreeSans.ttf", ...))}.  In order to 
limit the file size, the \pkg{rgl} package ships with just 3 font files, for 
regular versions of the \code{serif}, \code{sans} and \code{mono} families.  
Additional free font files were available in the past from the
Amaya project, though currently the
\code{\link{rglExtrafonts}} function provides an easier way
to register new fonts.
}
\value{
the current set of font definitions.
}
\seealso{\code{\link{text3d}}}
\examples{
\dontrun{
rglFonts(sans = "Arial")
} 
}
