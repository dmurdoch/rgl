0.105.13:

Tweak to src/Makevars.in to allow build on Solaris,
minor changes to reduce Solaris warnings.

0.105.12:

Added drat repository to DESCRIPTION to hold webshot2.

0.105.11:

Made the startup code more likely to fall back to no-OpenGL.

0.105.10:

Remove the slower clipMesh3d example.

0.105.9:

Fix gl2ps.c so pedantic setting doesn't issue warning.

0.105.8:

There are two main additions in this release:

  - Support for R Markdown documents has been significantly 
    improved - now (with the suggested non-CRAN webshot2 package)
    headless machines can insert snapshots of rgl scenes.
    
  - Support for older or limited platforms has been improved.
    Now systems that have broken X11 installations can be told
    to avoid X11 more easily, as builds with no X11 at all 
    should happen routinely (in addition to the full builds
    on systems that support them).
    
Another large change is that the home of the source code has
moved to Github from R-forge.
  
There are also several bug fixes and minor additions, as described in the NEWS file.
