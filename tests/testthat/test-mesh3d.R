test_that("ensureMatrix works", {
  expect_equal(dim(ensureMatrix(1, nrow=1)), c(1,1))
})

test_that("mesh3d works", {
	expect_s3_class(mesh3d(1:3, 1:3, 4, triangles=1:3), "mesh3d")
})


test_that("tmesh3d works", {
	open3d()
	m <- tmesh3d(rbind(1, 2, 1:3), 1:3, homogeneous=FALSE)
	expect_s3_class(m, "mesh3d")
	expect_named(m, c("vb", "it", "material", 
										"normals", "texcoords", "meshColor"),
							 ignore.order = TRUE)
	shade3d(m)
	expect_known_value(scene3d(), file="testdata/tmesh3d.rds")
	close3d()
})

test_that("qmesh3d works", {
	open3d()
	m <- qmesh3d(rbind(1, 2, 1:4), 1:4, homogeneous=FALSE)
	expect_s3_class(m, "mesh3d")
	expect_named(m, c("vb", "ib", "material", 
										"normals", "texcoords", "meshColor"),
							 ignore.order = TRUE)
	shade3d(m)
	expect_known_value(scene3d(), file="testdata/qmesh3d.rds")
	close3d()
})

test_that("shade3d, wire3d and dot3d work", {
	open3d()
	mesh <- cuboctahedron3d(col = "red")
	shade3d(mesh)
	wire3d(translate3d(mesh, 1,1,1))
	dot3d(translate3d(mesh, 2,2,2))
	expect_known_value(scene3d(), file="testdata/shade3detc.rds")
	close3d()
})

test_that("shade3d, wire3d and dot3d work", {
	open3d()
	mesh <- cuboctahedron3d(col = "red")
	shade3d(mesh)
	wire3d(translate3d(mesh, 1,1,1))
	dot3d(translate3d(mesh, 2,2,2))
	expect_known_value(scene3d(), file="testdata/shade3detc.rds")
	close3d()
})


test_that("transformations work", {
	open3d()
	mesh <- cuboctahedron3d(col = "red")
	shade3d(translate3d(mesh, 1,2,3))
  shade3d(rotate3d(mesh, 35, 1,2,3))
  shade3d(scale3d(mesh, 1,2,3))
	expect_known_value(scene3d(), file="testdata/transformations.rds")
	close3d()
})
