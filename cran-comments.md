0.104.16:

Fixed revdep issues in nat and plot3Drgl.  No other revdep
problems found.

0.104.15:

There are fairly large changes in this update, intended to
make it easier to install rgl:

 - The requirement for R 4+ has been relaxed, allowing it to
 install on older releases again.
 - The requirement for OpenGL libraries has been removed,
 allowing an install that can produce WebGL only.
 - The use of mathjaxr has been removed, since Debian had
 policy problems with it.
 
There are also several bug fixes and minor additions, as described in the NEWS file.
