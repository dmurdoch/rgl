# Configuration for Windows only

lines <- readLines("src/Makevars.win.in")
lines <- sub("@HIDE_IF_R42PLUS@", if (getRversion() < '4.2.0') "" else "#", lines, fixed = TRUE)
writeLines(lines, "src/Makevars.win")
