context("get_gwl_data retrieves data")

test_that("get_gwl retrieves actual data", {
  expect_error(g <- get_gwl(well = "309", which = "recent"), NA)
  expect_is(g, "data.frame")
  expect_gt(nrow(g), 0)
  expect_is(g$Date, "POSIXct")
  expect_is(g$GWL, "numeric")
  expect_is(g$Historical_Daily_Average, "numeric")
  expect_is(g$Historical_Daily_Min, "numeric")
  expect_is(g$Historical_Daily_Max, "numeric")
  expect_is(g$Status, "character")
})

test_that("get_gwl retrieves `all` data", {
  expect_error(g <- get_gwl(well = "309"), NA)
  expect_true(min(g$Date) < as.Date("2015-01-01"))
})

test_that("get_gwl retrieves `recent` data", {
  expect_error(g <- get_gwl(well = "309", which = "recent"), NA)
  expect_true(min(g$Date) >= (Sys.Date() - (366*2)))
})

test_that("get_gwl retrieves `daily` data", {
  expect_error(g <- get_gwl(well = "309", which = "daily"), NA)
  expect_equal(length(unique(g$Date)), nrow(g))
})

test_that("get_gwl retrieves correct data", {
  expect_message(g <- get_gwl(well = "309"), "Retrieving data...")
  
  expect_equal(g$Date[1], as.POSIXct("1989-10-19 12:00:00", tz = "UTC"))
  expect_equal(g$GWL[1], 23.971)
  expect_true(all(g$Historical_Daily_Minimum >= 
                    g$Historical_Daily_Average, na.rm = TRUE))
  expect_true(all(g$Historical_Daily_Maximum <= 
                    g$Historical_Daily_Average, na.rm = TRUE))
  expect_true(all(g$Historical_Daily_Maximum <= 
                    g$Historical_Daily_Minimum, na.rm = TRUE))

  expect_equal(g$GWL[g$Date == as.POSIXct("1990-03-01 12:00:00", tz = "UTC")],
               24.429)
})