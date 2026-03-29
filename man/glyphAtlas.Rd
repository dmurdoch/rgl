\name{glyphAtlas}
\alias{glyphAtlas}
\alias{print.glyph_atlas}
\alias{plot.glyph_atlas}
\title{Build a glyph atlas from strings}
\usage{
glyphAtlas(
  text,
  family = "sans",
  font = 1,
  cex = 1,
  col = "black",
  monochrome = TRUE,
  atlas = NULL
)

\method{print}{glyph_atlas}(x, verbose = FALSE, ...)

\method{plot}{glyph_atlas}(x, y, interpolate = FALSE, ...)
}
\arguments{
\item{text}{Strings to add to the atlas}

\item{family, font, cex}{Graphical parameters for text}

\item{col}{Color of text (if not `monochrome`)}

\item{monochrome}{Whether to build a monochrome or full
color atlas.}

\item{atlas}{If \code{atlas} is a \code{"glyph_atlas"}
object, the atlas will be initialized
to this value.  If it is the string \code{"scene"},
the current rgl scene's atlas will be used.}

\item{x}{The glyph atlas to plot.}

\item{verbose}{Whether to give a verbose display.}

\item{...}{Extra parameters are passed to the default
plot method, but are ignored in the print method.}

\item{y}{Ignored.}

\item{interpolate}{Whether to interpolate pixels.}
}
\value{
`glyphAtlas` returns a list of class `"glyph_atlas"`.  The
list contains these components:
\item{buffer}{A matrix or array holding the buffer of rendered characters.}
\item{fonts}{A vector of font descriptions.}
\item{glyphs}{A dataframe with one line per rendered glyph.}
\item{strings}{A dataframe holding the strings that were rendered.}
\item{fragments}{A dataframe holding the map from strings to glyphs.}
\item{monochrome}{Is this a monochrome atlas?}
\item{position}{Where the next glyph would be written if more are added.}
}
\description{
These functions are mainly intended for debugging
\pkg{rgl}'s text code.

\code{glyphAtlas} accepts strings and builds an atlas of
glyphs so those strings can be rendered.  It wraps a
a C function used by \pkg{rgl} to draw 3D text.
}
\details{
`glyphAtlas` starts with a small 32 x 32 pixel atlas and grows it as necessary by doubling both length and
width.  When it does this, it rearranges the locations of
the glyphs in the buffer, but doesn't change the `glyphnum`
values that appear in the `fragments` record.
}
\examples{
text <- c("Some text", "Tokyo (\u6771\u4eac) \U1F600")
atlas_monochrome <- glyphAtlas(text)
atlas_monochrome
# Each letter appears only once:
plot(atlas_monochrome)

atlas_color <- glyphAtlas(text, monochrome = FALSE,
                          col = c("red", "blue"))
# Notice the "o" appears once in each color:
plot(atlas_color)

atlas_mono2 <- glyphAtlas("hello", atlas = atlas_monochrome)
}
