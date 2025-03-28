test_that("shapelist3d works with col (issue #462)", {
  col <- 1:5
  open3d()
  shapelist3d(icosahedron3d(), x = 1:2, y = 1, z = 1, col = c("red", "blue"))
  expect_known_scene("shapelist3d")
})
