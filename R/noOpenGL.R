noOpenGL <- local({
  pkg <- system.file(package = "rgl")
  r_arch <- .Platform$r_arch
  chname <- paste0("rgl", .Platform$dynlib.ext)
  DLLpath <- if (nzchar(r_arch))
    file.path(pkg, "libs", r_arch)
  else
    file.path(pkg, "libs")
  !file.exists(file.path(DLLpath, chname))
})
