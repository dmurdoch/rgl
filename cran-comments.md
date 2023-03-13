# 1.1.3:

This release contains relatively large changes
described below.  It tests quite cleanly on R versions
3.5.x to R-devel, with the only issues being its size
and sometimes check times.

An issue with declaration problems in Windows R-devel
has been fixed, and some missing checks have been added.

The segfault on the M1Mac reported on CRAN may have
been fixed:  a similar one has definitely been fixed.

I have run checks on most reverse dependencies and
no problems have  been identified.

One major change affects how the OpenGL functions are
loaded:  I now use a `glad` loader, which will load 
function pointers rather than static links to 
OpenGL functions.  This will allow `rgl` to take
advantage of more recent OpenGL functions in a future
release.

Several bugs have been fixed.  Most notably, the
`glad` loader showed one segfault which I think may
have been happening intermittently in the past.
In addition, changes have been made to work around
a limitation in the Jupyter environment to allow
`rgl` graphics to work there.

Here is the full list of changes:

## Major changes

* A new function `hover3d()` has been added to display
"hover hints":  labels next to points when the mouse 
passes near them.
* A new material property `"texmode"` has been added
to control how textures are applied.  The default is `"modulate"`,
consistent with previous versions.  If set to `"replace"`,
the texture is displayed without any lighting effects or dependence
on the original color of the surface.
* Many of the demos have been moved to a new vignette called 
`demos`.
* `rgl` now uses the `glad` loader which will eventually allow
access to newer OpenGL functions in systems that support them.

## Minor changes

* The `texenvmap = TRUE` material property is now supported
in WebGL.
* The method of including shader source code
has changed to work around a limitation in Jupyter.
* The default C++ standard is now accepted, rather
than requiring C++11.  On R versions prior to R 4.2.0
C++11 is still requested.

## Bug fixes

* The `as.mesh3d.rglId()` and `as.triangles3d.rglId()` methods
and the `selectpoints3d()`, `writeOBJ()`, `writePLY()` 
and `writeSTL()`
functions did not handle indices
in the objects they were processing (issue #293).
* Transparent planes were not always drawn properly
in WebGL (issue #300).
* `view3d()` now returns a `lowlevel()` result so that 
it will be handled properly in WebGL vignettes with 
auto printing.
* If `transform3d()` or `rotate3d()` changed the orientation
of a `mesh3d` object with normals, the normals ended up
with the wrong sign. (Reported by Stephane Laurent.)
* `scene3d()` (and hence `rglwidget()`) did not save
the normals for unlit objects.  When the objects were
also indexed, this prevented proper calculation of 
front and back.  This is fixed, and a warning is
issued if normals are not provided when needed.
* It was possible to call `glVersion` before OpenGL was
initialized; this resulted in a segfault with the new
`glad` loader, and may have been the cause of some older crashes
as well.  This has been fixed.
* `readOBJ()` did not handle comments properly.
* Sprites consisting only of line segments (as used
for example by `pch3d()`) caused rendering to fail in
`rglwidget()` (issue #316).
