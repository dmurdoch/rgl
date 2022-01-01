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

test_that("pop3d works on tags", {
  open3d()
  id1 <- points3d(1,1,1, tag = "id1")
  newSubscene3d()
  id2 <- points3d(2,2,2, tag = "id2")
  pop3d(tag = "id1")
  expect_equal(ids3d(subscene = 0, tags = TRUE),
               data.frame(id = as.numeric(id2), 
                          type = "points", tag = "id2"))
})
