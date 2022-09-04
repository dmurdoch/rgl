0.110.1

This is a fairly small update.

The main reason for the submission is to fix an
incompatibility with `Rcmdr` that was introduced in the
last release.  When run from `tcltk`, `rgl` plots sometimes
locked up the whole system.  Some other important bug
fixes avoid segfaults in unusual circumstances.  Details
and other changes are described in the `NEWS.md` file.

When locally running R-devel check I see a message about
`tripack`, which is ACM-licensed.  It is only a suggested
package, and is only
present to support extracting data from `"tri"` objects
defined in it.

Reverse dependency checks:  IN PROGRESS.  After a random selection
of 30% done, no changes.

Regarding CRAN checks:  I don't know what caused the
vignette errors that are reported there, but I've seen
vignette builds fail when a compatible version of Pandoc 
was unavailable.

The very large size of macos installs is due to them
including debug information in the libs.  Other platforms
exceed the size limits by a bit, but I think this is
unavoidable given the amount of code in rgl.
