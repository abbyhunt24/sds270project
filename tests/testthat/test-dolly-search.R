test_that("dolly_search returns info on the Barnstormer ride", {
  barnstormer <- dolly_search(rides_df, "name", "barnstormer")
  expect_equal(length(barnstormer), 8) #should return 8 elements
  expect_true(is.list(barnstormer))
})


test_that("ride_pic generates an image based on name of ride", {
  barnstormer_pic <- ride_pic(rides_df, "Barnstormer")
  expect_no_error(barnstormer_pic)
  expect_silent(barnstormer_pic)
})

