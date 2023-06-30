# 1.2.0

This release is at the request of Prof Ripley because of C++17
conflicts.  His log listed a lot of them, but I think they are all
consequences of `length` being defined as part of the R API and also used
in the C++ run-time.

There are also other changes, but none of them are huge:

## Major changes

* Support for non-PNG textures has been added.  Currently 
supported:  JPEG files and any other object
for which `grDevices::as.raster()` works, e.g. matrices.
(Fixes issue #196.)

## Minor changes

* Support for "alt" text has been added to `rglwidget()`.
Full support in R Markdown or `knitr` requires a `knitr` update
to version 1.42.12 or newer.
* Some of the tests have been relaxed slightly so they 
shouldn't trigger errors on the M1Mac test platform.
* Internally, the C++ code has dropped the use of the internally
defined `String` type, settling on `std::string` instead.
* `subdivision3d()`, `clipMesh3d()` and related functions now
(optionally) record the original faces associated with each new one
in a `mesh$tags` addition to the output.

## Bug fixes

* The `Makevars.win` file was being produced incorrectly on
older Windows versions.
* `rgl.window2user()` did not work correctly when multiple panes
were showing.  This caused `arrow3d()` to fail in some panes
(issue #354).
* `selectpoints3d()` had a typo which was revealed by 
warnings in recent R versions.
* `getShaders()` was broken in 1.1.3.
* `arc3d()` can now handle "arcs" that are straight lines along
a radius (issue #357).
* Spheres did not show textures correctly (issue #360).
* `hover3d()` failed to display default labels in R (issue #362).
* `shade3d()` didn't handle meshes with a mix of triangles and
quads properly when `meshColor == "faces"`.
* `subdivision3d()` and related functions now handle colors
properly.
* `addNormals()` sometimes gave `NaN` values due to rounding
error (issue #372).
* `arc3d()` sometimes missed plotting the last segment of the arc (issue #369).
* `R_NO_REMAP` has been defined to prevent conflict between 
R internals and C++17 library.
