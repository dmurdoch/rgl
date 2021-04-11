\name{rglExtrafonts}
\alias{rglExtrafonts}
\title{
Register extra fonts
}
\description{
This function uses the \href{https://github.com/wch/extrafont}{extrafont} 
package to help register system fonts for use with
FreeType in \pkg{rgl}.
}
\usage{
rglExtrafonts(..., quiet = TRUE)
}
\arguments{
  \item{\dots}{
Vectors of fonts to try.  See the Details.
}
  \item{quiet}{
Whether to print information on progress.
}
}
\details{
The \pkg{extrafont}
package collects information on
installed fonts from the system.  When you first
install \pkg{extrafont}, or after new fonts have been installed on your
system, run \code{extrafont::font_import()} to build
its database of system fonts.  

Fonts can be installed in \pkg{rgl} using
\code{rglExtrafonts(rglname = familyname)} or \code{rglExtrafonts(familyname)}.  In this call
\code{familyname} is a vector of family names to look
for in the \pkg{extrafont} database using \code{extrafont::choose_font(familyname)}; the first one found
will be registered with \pkg{rgl}.  The optional name \code{rglname} will also be usable to refer to the font family.

If none of the given family names is found, no change
will be made to the registered fonts in \pkg{rgl}.

During startup, \pkg{rgl} detects whether \pkg{extrafont}
is installed, and if so runs 
\verb{

rglExtrafonts(sans = c("Helvetica", "Arial"), 
              serif = c("Times", "Times New Roman"), 
              mono = c("Courier", "Courier New"))
              
} 
to attempt to set up the default fonts.

Fonts found by \pkg{extrafont} can also be used in
some other graphics devices besides \pkg{rgl}; see 
\href{https://github.com/wch/extrafont}{the extrafont documentation}
for details.
}
\note{
Each font in a display needs a unique \pkg{rgl} name;
if the associated font for a given name is changed,
all previously plotted text will also change.

Currently \code{\link{rglwidget}} displays will not 
respect the new definitions.
}
\value{
Invisibly returns a vector giving the \pkg{rgl} name
and the family name for the newly installed font.
}
\author{
Duncan Murdoch
}
\seealso{
\code{\link{text3d}}, \code{\link{rglFonts}}
}
\examples{
if (requireNamespace("extrafont") && !in_pkgdown_example()) {
  
  open3d()
  text3d(1,1,1, "Default", family = "sans", cex = 2)  
  
  # Attempt to register new sans-serif font:
  newfamily <- rglExtrafonts(newsans = c("Comic Sans MS", "Impact", 
                                         "Verdana", "Tahoma"))
  
  text3d(2,2,2, newfamily, family = "newsans", cex = 2)
  
}
}
