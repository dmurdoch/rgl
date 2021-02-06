# Contributing to `rgl`

This outlines how to propose a change to `rgl`.  It is based
on the corresponding document from the `tidyverse` project.
For detailed info about contributing to tidyverse packages, please see the
[**development contributing guide**](https://rstd.io/tidy-contrib). 

## Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in
the documentation directly using the GitHub web interface, as
long as the changes are made in the _source_ file. `rgl` 
puts help pages in `.Rd` files in the `man` directory (not
in comments in the R source files, as many other projects do). 


## Bigger changes

If you want to make a bigger change, it's a good idea to first file an issue and make sure we agree that it’s needed. 
If you’ve found a bug, please file an issue that illustrates the bug with a minimal 
[reprex](https://www.tidyverse.org/help/#reprex) (this will also help you write a unit test, if needed).

### Pull request process

*   Fork the package and clone onto your computer. If you
haven't done this before, we recommend using the Github
web interface to fork, RStudio's `New Project... | Version
Control | Git` menu to import the repository.  Then you
can create branches locally, and push them to Github
when you want to create a PR.

*   Install all development dependencies with `devtools::install_deps(dependencies = TRUE)`, and then make sure the package passes R CMD check by running `Build | Check`.
    If R CMD check doesn't pass cleanly, it's a good idea to ask for help before continuing. 

*   Make your changes, commit to git, push to Github, and then create a PR on 
    the Github web page.
    The title of your PR should briefly describe the change.
    The body of your PR should contain `Fixes #issue-number`.

### Code style

*  `rgl` is an old package, with many contributors.  The style
is not completely consistent, but you should try to follow
what you see.  Please don't change the style of existing 
code unless it is necessary for your change.

