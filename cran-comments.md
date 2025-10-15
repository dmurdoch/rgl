# 1.3.30

This is a relatively minor release.

* Support for classes defined in the `tripack` package
has been dropped at the request of CRAN.
* Added the `latex3d()` function to draw LaTeX text using the
`xdvir` package.
* Both `plotmath3d()` and `latex3d()` now use default
`cex = par3d("cex")`, and have new argument `polygon_offset`.

## Bug fixes

* `arrow3d(type = "extrusion")` was broken by the changes to triangulation in version 1.3.16.
* Changes last year to `writePLY()` introduced an error
in some cases (issue #489).