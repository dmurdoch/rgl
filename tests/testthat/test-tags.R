library(rgl)

test_that("tags work", {
  material3d(tag = "hello")
  expect_equal(material3d("tag"), "hello")

  file <- normalizePath(system.file("textures/worldsmall.png",                              package = "rgl"))
  material3d(texture = file)
  expect_equal(material3d("texture"), file)
  expect_equal(material3d("tag"), "hello")

  open3d()
  x <- points3d(1,2,3, tag = "hello2")
  expect_equal(unclass(x), tagged3d("hello2"))
  expect_equal(unclass(x), tagged3d("hello2", full = TRUE)$id)
  expect_equal(tagged3d(ids = x), "hello2")
})
