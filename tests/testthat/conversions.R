test_that("asEuclidean works", {
  expect_equal(asEuclidean(c(1,2,3)), asEuclidean(matrix(c(1,2,3), ncol = 3)))
  expect_equal(asEuclidean(c(1,2,3)), asEuclidean(matrix(c(1,2,3,1), ncol = 4)))
  expect_equal(asEuclidean(c(1,2,3)), asEuclidean(c(2,4,6,2)))
  expect_equal(dim(asEuclidean(1:24)), c(6,3))             
})

test_that("asEuclidean2 works", {
  expect_equal(asEuclidean2(c(1,2,3)), asEuclidean2(matrix(c(1,2,3), nrow = 3)))
  expect_equal(asEuclidean2(c(1,2,3)), asEuclidean2(matrix(c(1,2,3,1), nrow = 4)))
  expect_equal(asEuclidean2(c(1,2,3)), asEuclidean2(c(2,4,6,2)))
  expect_equal(dim(asEuclidean2(1:24)), c(3,6))                 
})

test_that("asHomogeneous works", {
  expect_equal(asHomogeneous(c(1,2,3)), asHomogeneous(matrix(c(1,2,3), ncol = 3)))
  expect_equal(asHomogeneous(c(1,2,3)), asHomogeneous(matrix(c(1,2,3,1), ncol = 4)))
  expect_equal(asHomogeneous(c(1,2,3)), asHomogeneous(c(1,2,3,1)))
  expect_equal(dim(asHomogeneous(1:24)), c(8,4))             
})

test_that("asHomogeneous2 works", {
  expect_equal(asHomogeneous2(c(1,2,3)), asHomogeneous2(matrix(c(1,2,3), nrow = 3)))
  expect_equal(asHomogeneous2(c(1,2,3)), asHomogeneous2(matrix(c(1,2,3,1), nrow = 4)))
  expect_equal(asHomogeneous2(c(1,2,3)), asHomogeneous2(c(1,2,3,1)))
  expect_equal(dim(asHomogeneous2(1:24)), c(4,8))
})
