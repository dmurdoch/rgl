rglToLattice <- function(rotm = par3d("userMatrix")) {
  if (!requireNamespace("orientlib", quietly = TRUE))
    stop("The orientlib package is needed for this function")
  e <- -orientlib::eulerzyx(orientlib::rotmatrix(rotm[1:3, 1:3]))@x*180/pi
  list(z = e[1], y = e[2], x = e[3])
}

rglToBase <- function(rotm = par3d("userMatrix")) {
  if (!requireNamespace("orientlib", quietly = TRUE))
    stop("The orientlib package is needed for this function")
  e <- (orientlib::eulerzyx(orientlib::rotmatrix((rotm[1:3,1:3]))))@x*180/pi
  list(theta = e[1], phi = 90 - e[3])
}
