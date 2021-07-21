0.107.10:

Fixed segfaults that showed up in last submission.

0.107.9:

Fixed some missed bugs that caused trouble in BIGL and related packages.

Added support for a future release of the "waldo" package.

Other minor stuff.

0.107.5:

This revision has a fairly large number of additions and
bug fixes.  The main additions are in the area of
user-customization.  See the NEWS.md file for details. 
A minor change is to move some hard dependencies to soft
dependencies, as suggested by Brian Ripley some time ago.

The main CRAN issue happens when Pandoc is unavailable.  It is
only needed to rebuild the vignettes; they will rebuild without
it if the markdown package is available, but as stubs with a
warning, as the graphics inclusions need Pandoc.
A minor issue is that webshot2, which is needed to make 
headless snapshots, is not on CRAN.  It is available in a 
private repository that I maintain.
