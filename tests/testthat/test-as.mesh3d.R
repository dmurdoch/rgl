test_that("mergeVertices works", {
  # Pre 4.0.0, stringsAsFactors defaulted to TRUE
  options(stringsAsFactors = FALSE)
	open3d()
  col <- rainbow(14)
  # Older R versions added FF for default alpha=1
  col <- sub("^(#......)FF$", "\\1", col)
	(mesh1 <- cuboctahedron3d(col = col, meshColor = "face"))
	id <- shade3d(mesh1)
	(mesh2 <- as.mesh3d(id))
	shade3d(translate3d(mesh2, 3, 0, 0))
	(mesh3 <- mergeVertices(mesh2))
	shade3d(translate3d(mesh3, 6, 0, 0))
	expect_known_scene("mergeVertices")
})
