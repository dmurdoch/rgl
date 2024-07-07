# 1.3.9

This is a minor release, containing several bug fixes and minor 
updates.

The CRAN checks identify a non-API reference to R_InputHandlers.  I haven't done
anything about this yet; it isn't mentioned in the "Moving into C API
compliance" section of WRE.  It's needed for the X11 display, and I
don't know an alternative.
