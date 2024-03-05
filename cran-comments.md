# 1.3.1

This adds a workaround to a bug in the interaction of the
`markdown` and `knitr` packages that caused the vignettes
to attempt to produce snapshots if Pandoc was not available,
even though Pandoc is not needed.

# 1.3.0

This small release is at the request of Tomas to adapt to
upcoming changes in Rtools on Windows.  It also contains
a number of other changes (mostly bug fixes and minor
improvements, described in the NEWS.md file).  I ran revdep
checks and didn't see any problems.
