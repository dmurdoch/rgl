library(rgl)

test_that("subsceneInfo rejects a modify mouseMode embedding", {
  open3d()

  expect_error(
    subsceneInfo(
      currentSubscene3d(),
      embeddings = c("inherit", "inherit", "inherit", "modify")
    ),
    "The mouseMode embedding cannot be 'modify'",
    fixed = TRUE
  )
})
