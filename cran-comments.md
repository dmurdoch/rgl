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
