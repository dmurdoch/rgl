# 1.3.18

This is a small release requested by CRAN to fix these issues:
 - complaint about a define in the FTGL library
 - complaint about using Rf_GetOption.
 - numerous implicit type conversions leading to warnings from the compiler.
It also includes:
 - some memory leaks reported on the rgl web site.
 - some updates to software that it uses.
 
As far as I can tell, all issues have been fixed.  Since almost
nothing affects the exports, I haven't run full reverse dependency
checks.
