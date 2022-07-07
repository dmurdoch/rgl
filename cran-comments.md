0.109.6

This is a small update that fixes a major bug, some minor
ones, and makes one small change.

The major bug is a segfault caused when trying to load 
a default font in X11.  If the font is not present, 
rgl would try to dereference a null pointer:  this is now
fixed.  Simon Urbanek reported this and asked for this
update.

The minor issue and bugs are described in the NEWS file.

Regarding CRAN checks:  I don't know what caused the
vignette errors that are reported there.  Probably they
are unrelated to the bugs that were fixed.  If more 
information is available about exactly what is failing, 
I'll try to fix it.

The very large size of macos installs is due to them
including debug information in the libs.  Other platforms
exceed the size limits by a bit, but I think this is
unavoidable given the amount of code in rgl.
