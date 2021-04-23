expect_known_scene <- function(name, close = TRUE) {
	testthat::local_edition(2)
	result <- expect_known_value(scene3d(), file=paste0("testdata/", name, ".rds"))
  if (close)
  	close3d()
  result
}