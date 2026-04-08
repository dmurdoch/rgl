expect_known_scene <- function(name, scene = scene3d(), close = TRUE, file = paste0("testdata/", name, ".rds"), ...) {
	testthat::local_edition(2)
	result <- testthat::expect_known_value(object = scene, file = file, ...)
  if (close)
  	close3d()
  result
}

expect_snapshot_scene <- function(scene = scene3d(), close = TRUE, style = "json2", ...) {
  testthat::local_edition(3)
  proxy <- old_compare_proxy.rglscene(scene)
  testthat::expect_snapshot_value(proxy, style = style, ...)
}
