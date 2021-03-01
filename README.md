
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RGL - 3D visualization device system for R using OpenGL

![](man/figures/README/polyhedra-rgl-1.png)<!-- -->

## INTRODUCTION

The RGL package is a visualization device system for R, using OpenGL or
WebGL as the rendering backend. An OpenGL rgl device at its core is a
real-time 3D engine written in C++. It provides an interactive viewpoint
navigation facility (mouse + wheel support) and an R programming
interface. WebGL, on the other hand, is rendered in a web browser; rgl
produces the input file, and the browser shows the images.

## LICENSE

The software is released under the GNU Public License. See “COPYING” for
details.

## FEATURES

-   portable R package using OpenGL (if available) on macOS, Win32 and
    X11
-   can produce 3D graphics in web pages using WebGL
-   R programming interface
-   interactive viewpoint navigation
-   automatic data focus
-   geometry primitives: points, lines, triangles, quads, texts, point
    sprites
-   high-level geometry: surface, spheres
-   up to 8 light sources
-   alpha-blending (transparency)
-   side-dependent fill-mode rendering (dots, wired and filled)
-   texture-mapping with mipmapping and environment mapping support
-   environmental effects: fogging, background sphere
-   bounding box with axis ticks marks
-   undo operation: shapes and light-sources are managed on type stacks,
    where the top-most objects can be popped, or any item specified by
    an identifier can be removed

## PLATFORMS

macOS Windows 7/10 Unix-derivatives

## BUILD TOOLS

R recommended tools (gcc toolchain) On Windows, Rtools40 (or earlier
versions for pre-R-4.0.0)

## REQUIREMENTS

For OpenGL display:

Windowing System (unix/x11 or win32) OpenGL Library OpenGL Utility
Library (GLU)

For WebGL display:

Browser with WebGL enabled.

## Installation on Debian:

To install OpenGL support:

aptitude install libgl1-mesa-dev libglu1-mesa-dev

## OPTIONS

libpng library version 1.2.9 or newer (pixmap import/export support)
freetype library (optional on Unix for resizable anti-aliased fonts),
required on Windows

## BUILDING/INSTALLING FROM SOURCE PACKAGE

The R build tool is the primary tool to build the RGL package.

## BUILDING ON MICROSOFT WINDOWS

Install Rtools40 or newer.

An Internet connection will be needed, as FreeType is automatically
downloaded from <https://github.com/rwinlib>.

## BUILDING ON UNIX-STYLE OS (macOS, Linux, FreeBSD, … )

The build is controlled by an autoconf configure script. You provide the
options through the R CMD build/INSTALL command

e.g.  $ R CMD INSTALL –configure-args=“&lt;configure args…&gt;” rgl

COMMON UNIX-STYLE OS OPTIONS —————————-

–with-gl-includes=<path> GL C header files include path

–with-gl-libraries=<path> GL library linkage path

–with-gl-prefix=<libprefix> GL library prefix (e.g. Mesa)

–disable-libpng disable libpng support

–with-libpng-prefix=<install location> force LibPNG library install
prefix (e.g. /usr/local)

–disable-libpng-config explicitly disable libpng-config

–disable-libpng-dynamic use static libpng library

–disable-opengl disable all OpenGL displays; WebGL is still available

You may find that your distro doesn’t have all necessary development
libraries installed: read the error messages for hints! This line has
been reported to be sufficient on FC 5 or 6:

yum install mesa-libGL-devel mesa-libGLU-devel libpng-devel

X11 WINDOWING SYSTEM OPTIONS —————————-

The X11 windowing system is needed for OpenGL display in macOS and
Unix-alikes.

–x-includes=<path> X11 C header files include path

–x-libraries=<path> X11 library linkage path

BUILDING WITHOUT OPENGL ———————–

As of version 0.104.1, it is possible to build the package without
OpenGL support on Unix-alikes (including macOS) with the configure
option –disable-opengl For example,

R CMD INSTALL –configure-args=“–disable-opengl” rgl\_0.104.1.tar.gz

On Windows, OpenGL support cannot currently be disabled.

## DEMOS: LOADING AND RUNNING DEMONSTRATIONS

    library(rgl)
    demo(rgl)

## CREDITS

Daniel Adler <dadler@uni-goettingen.de>  
Duncan Murdoch <murdoch@stats.uwo.ca>  
Oleg Nenadic <onenadi@uni-goettingen.de>  
Simon Urbanek <simon.urbanek@math.uni-augsburg.de>  
Ming Chen <mchen34@uwo.ca>  
Albrecht Gebhardt <albrecht.gebhardt@uni-klu.ac.at>  
Ben Bolker <bolker@zoo.ufl.edu>  
Gabor Csardi <csardi@rmki.kfki.hu>  
Adam Strzelecki <ono@java.pl>  
Alexander Senger <senger@physik.hu-berlin.de>  
The R Core Team for some code from R.  
Dirk Eddelbuettel <edd@debian.org>  
The authors of Shiny for their private RNG code.  
Jeroen Ooms for Rtools40 and FreeType help.  
Yohann Demont for Shiny code, suggestions, and testing.  
Joshua Ulrich for a lot of help with the Github migration.  
Xavier Fernandez i Marin for help debugging the build.

## WEBSITE

<https://github.com/dmurdoch/rgl>
