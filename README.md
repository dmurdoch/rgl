
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RGL - 3D visualization device system for R using OpenGL

![](man/figures/READMEpolyhedra-1-rgl.png)<!-- -->

## INTRODUCTION

The RGL package is a visualization device system for R, using OpenGL or
WebGL as the rendering backend. An OpenGL rgl device at its core is a
real-time 3D engine written in C++. It provides an interactive viewpoint
navigation facility (mouse + wheel support) and an R programming
interface. WebGL, on the other hand, is rendered in a web browser; rgl
produces the input file, and the browser shows the images.

## WEBSITE

A `pkgdown` website is here:

<https://dmurdoch.github.io/rgl/>

The unreleased development version website is here:

<https://dmurdoch.github.io/rgl/dev/>

See [this
vignette](https://dmurdoch.github.io/rgl/dev/articles/pkgdown.html) for
details on producing your own `pkgdown` website that includes `rgl`
graphics.

The currently active development site is here:

<https://github.com/dmurdoch/rgl>

## NOTE ABOUT DEVEL VERSIONS

`rgl` can make use of development versions of some packages: `webshot2`,
`chromote`, `pkgdown`. Though it doesn’t require any of these, they each
provide some nice features:

-   `webshot2` and `chromote` support good quality PNG snapshots of
    `rgl` scenes, even on servers that don’t have a graphics display.
-   The devel version of `pkgdown` supports inclusion of `rgl` graphics
    in example code in automatically built package websites. (It also
    supports inclusion of `htmlwidgets` for other dynamic web packages
    like `plotly`, `leaflet`, etc.)

Unfortunately, being development versions, these packages sometimes
introduce bugs that break `rgl` usage. Currently (November 8, 2021) the
main branches of all packages are fine. I recommend the following code
to install them:

``` r
remotes::install_github(c("rstudio/webshot2",
                          "rstudio/chromote",
                          "r-lib/pkgdown"))
```

## INSTALLATION

Most users will want to install the latest CRAN release. For Windows,
macOS and some Linux platforms, installation can be easy, as CRAN
distributes binary versions:

    # Install latest release from CRAN
    install.packages("rgl")

To install the latest development version from Github, you’ll need to do
a source install. Those aren’t easy! Try

    # Install development version from Github
    remotes::install_github("dmurdoch/rgl")

If that fails, read the instructions below.

## LICENSE

The software is released under the GNU Public License. See
[COPYING](./COPYING) for details.

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

**For OpenGL display:**

Windowing System (unix/x11 or Windows)  
OpenGL Library  
OpenGL Utility Library (GLU)

**For WebGL display:**

A browser with WebGL enabled. See <https://get.webgl.org>.

## Installing OpenGL support

**Debian:**  
aptitude install libgl1-mesa-dev libglu1-mesa-dev

**Fedora:**  
yum install mesa-libGL-devel mesa-libGLU-devel libpng-devel

**macOS:**  
Install XQuartz.  
`rgl` should work with XQuartz 2.7.11 or newer, but it will probably
need rebuilding if the XQuartz version changes. XQuartz normally needs
re-installation whenever the macOS version changes.

**Windows:**  
Windows normally includes OpenGL support, but to get the appropriate
include files etc., you will need the appropriate version of
[Rtools](https://cran.r-project.org/bin/windows/Rtools/) matched to your
R version.

## Options

The **libpng** library version 1.2.9 or newer is needed for pixmap
import/export support.

The **freetype** library is needed for resizable anti-aliased fonts. On
Windows, it will be downloaded from <https://github.com/rwinlib> during
the install.

## BUILDING/INSTALLING

Binary builds of `rgl` are available for some platforms on CRAN.

For source builds, install the prerequisites as described above,
download the tarball and at the command line run

    R CMD INSTALL rgl_0.107.25.tar.gz

(with the appropriate version of the tarball). The build uses an
`autoconf` configure script; to see the options, expand the tarball and
run `./configure --help`.

Alternatively, in R run

    install.packages("rgl")

to install from CRAN, or

    remotes::install_github("dmurdoch/rgl")

to install the development version from Github.

Sometimes binary development versions are available for Windows and
macOS using

    install.packages("rgl", repos = "https://dmurdoch.github.io/drat",
                     type = "binary")

but these are not always kept up to date.

## BUILDING WITHOUT OPENGL

As of version 0.104.1, it is possible to build the package without
OpenGL support on Unix-alikes (including macOS) with the configure
option –disable-opengl For example,

    R CMD INSTALL --configure-args="--disable-opengl" rgl_0.107.25.tar.gz 

On Windows, OpenGL support cannot currently be disabled.

## DOCUMENTATION and DEMOS:

    library(rgl)
    browseVignettes("rgl")
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
The authors of `knitr` for their graphics inclusion code. Jeroen Ooms
for `Rtools40` and `FreeType` help.  
Yohann Demont for Shiny code, suggestions, and testing.  
Joshua Ulrich for a lot of help with the Github migration. Xavier
Fernandez i Marin for help debugging the build.  
George Helffrich for draping code.  
Ivan Krylov for window_group code in X11.  
Michael Sumner for as.mesh3d.default enhancement.  
Tomas Kalibera for `winutf8` help.
