set.seed(123)
test_that("readOBJ works", {
	# textured rectangular prism
	obj_file <- "# geometric vertices
v 1 1 -0.125
v 1 -1 -0.125
v -1 -1 -0.125
v -1 1 -0.125
v 1 1 0.125
v 1 -1 0.125
v -1 -1 0.125
v -1 1 0.125
# texture coordinates
vt 0.025 1
vt 0.025 0
vt 0.425 0
vt 0.425 1
vt 0.575 1
vt 0.575 0
vt 0.975 0
vt 0.975 1
vt 0.52 0
vt 0.48 0
vt 0.48 1
vt 0.52 1
# Textured polygonal face element
f 1/1 2/2 3/3 4/4
f 5/5 8/8 7/7 6/6
f 6/9 7/10 3/11 2/12
f 7/9 8/10 4/11 3/12
f 8/9 5/10 1/11 4/12
f 5/9 6/10 2/11 1/12"
	filename <- tempfile(fileext = ".obj")
	writeLines(obj_file, filename)
	mesh <- readOBJ(filename)
	unlink(filename)
	open3d()
	shade3d(mesh)
	x <- scene3d()
	expect_known_value(x, 'testdata/obj.rds')
	close3d()
})
