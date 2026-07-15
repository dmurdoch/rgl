library(rgl)

test_that("identify3d describes a single selection button", {
  local_mocked_bindings(
    par3d = function(...) {
      args <- list(...)
      if (identical(args, list("mouseMode")))
        return(c(left = "trackball"))
      invisible(NULL)
    },
    cur3d = function() 1L,
    rgl.setMouseCallbacks = function(...) invisible(NULL),
    .package = "rgl"
  )

  expect_output(
    identify3d(1, 2, 3, n = 0, buttons = "right"),
    "Use the right button to select",
    fixed = TRUE
  )
})
