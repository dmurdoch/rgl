test_that("ensureMatrix works", {
  expect_equal(dim(ensureMatrix(1, nrow=1)), c(1,1))
})

test_that("mesh3d works", {
	expect_s3_class(mesh3d(1:3, 1:3, 4, triangles=1:3), "mesh3d")
})

test_that("tmesh3d works", {
	m <- tmesh3d(rbind(1, 2, 1:3), 1:3, homogeneous=FALSE)
	expect_s3_class(m, "mesh3d")
	expect_named(m, c("vb", "it", "material", 
										 "normals", "texcoords", "meshColor"),
							 ignore.order = TRUE)
	shade3d(m)
	expect_snapshot(unclass(scene3d()))
})

test_that("qmesh3d works", {
	m <- qmesh3d(rbind(1, 2, 1:4), 1:4, homogeneous=FALSE)
	expect_s3_class(m, "mesh3d")
	expect_named(m, c("vb", "ib", "material", 
										 "normals", "texcoords", "meshColor"),
							 ignore.order = TRUE)
	shade3d(m)
	expect_snapshot(unclass(scene3d()))
})