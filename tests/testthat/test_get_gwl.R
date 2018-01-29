context("get_gwl_data retrieves data")

test_that("get_gwl catches incorrect well formats", {
  
  error <- paste0("wells can be specified either by 'OW000' or '000'. ",
                  "Different formating cannot be mixed")

  expect_error(get_gwl(wells = c("309", "OW309")), error)
  expect_error(get_gwl(wells = c("dd309", "OW309")), error)
  expect_error(get_gwl(wells = c("dd309", "309")), error)
  expect_error(get_gwl(wells = c("O309")), error)
  
  expect_error(get_gwl(wells = c("OW309", "OW39")),
               paste0("Wells in format OW000 must have 5 characters ",
                      "\\(OW followed by a three-digit number, e.g. OW064\\)"))
  
})

test_that("get_gwl catches wells that don't exist", {
  expect_warning(g <- get_gwl(wells = 0))
  expect_null(g)
  
  expect_warning(g <- get_gwl(wells = c(0, 2), which = "recent"))
  expect_equal(unique(g$Well_Num), "002")
})
  

test_that("get_gwl retrieves `all` data", {
  expect_message(expect_error(g <- get_gwl(wells = 309), NA),
                 "Retrieving data...")
  
  expect_is(g, "data.frame")
  expect_gt(nrow(g), 0)
  expect_is(g$Date, "POSIXct")
  expect_is(g$GWL, "numeric")
  expect_is(g$Historical_Daily_Average, "numeric")
  expect_is(g$Historical_Daily_Min, "numeric")
  expect_is(g$Historical_Daily_Max, "numeric")
  expect_is(g$Status, "character")
  
  expect_true(min(g$Date) < as.POSIXct("2015-01-01", tz = "UTC"))
})

test_that("get_gwl retrieves `recent` data", {
  expect_error(g <- get_gwl(wells = "309", which = "recent"), NA)
  expect_silent(get_gwl(wells = "309", which = "recent", quiet = TRUE))
  
  expect_is(g, "data.frame")
  expect_gt(nrow(g), 0)
  expect_is(g$Date, "POSIXct")
  expect_is(g$GWL, "numeric")
  expect_is(g$Historical_Daily_Average, "numeric")
  expect_is(g$Historical_Daily_Min, "numeric")
  expect_is(g$Historical_Daily_Max, "numeric")
  expect_is(g$Status, "character")
  
  expect_true(min(g$Date) >= (Sys.Date() - (366*2)))
})

test_that("get_gwl retrieves `daily` data", {
  expect_error(g <- get_gwl(wells = "309", which = "daily"), NA)
  
  expect_is(g, "data.frame")
  expect_gt(nrow(g), 0)
  expect_is(g$Date, "Date")
  expect_is(g$GWL, "numeric")
  expect_is(g$Historical_Daily_Average, "numeric")
  expect_is(g$Historical_Daily_Min, "numeric")
  expect_is(g$Historical_Daily_Max, "numeric")
  expect_is(g$Status, "character")
  
  expect_equal(length(unique(g$Date)), nrow(g))
})


test_that("get_gwl retrieves `recent` data from multiple wells", {
  expect_silent(g <- get_gwl(wells = c("309", "89"), 
                             which = "recent", quiet = TRUE))
  expect_equal(length(unique(g$Well_Num)), 2)
  expect_true(all(unique(g$Well_num) %in% c(309, 89)))
  expect_true(min(g$Date) >= (Sys.Date() - (366*2)))
})

test_that("get_gwl retrieves `daily` data from multiple wells", {
  expect_silent(g <- get_gwl(wells = c("309", "89"), 
                             which = "daily", quiet = TRUE))
  expect_equal(length(unique(g$Well_Num)), 2)
  expect_true(all(unique(g$Well_num) %in% c(309, 89)))
  expect_lte(length(unique(g$Date)), nrow(g))
  expect_gte(length(unique(g$Date)), nrow(g)/2)
})

test_that("get_gwl `all` retrieves correct data", {
  expect_message(g <- get_gwl(wells = "309"), "Retrieving data...")
  
  expect_equal(g$Date[1], as.POSIXct("1989-10-19 12:00:00", tz = "UTC"))
  expect_equal(g$GWL[1], 23.971, tolerance = 0.0001)
  expect_true(all(g$Historical_Daily_Minimum >= 
                    g$Historical_Daily_Average, na.rm = TRUE))
  expect_true(all(g$Historical_Daily_Maximum <= 
                    g$Historical_Daily_Average, na.rm = TRUE))
  expect_true(all(g$Historical_Daily_Maximum <= 
                    g$Historical_Daily_Minimum, na.rm = TRUE))

  expect_equal(g$GWL[g$Date == as.POSIXct("1990-03-01 12:00:00", tz = "UTC")],
               24.429, tolerance = 0.0001)
  expect_equal(g$GWL[g$Date == as.POSIXct("2015-03-01 12:00:00", tz = "UTC")],
               23.8924, tolerance = 0.0001)
})

# Cannot test precise recent data because constantly changing the start date...

test_that("get_gwl `daily` retrieves correct data", {
  expect_message(g <- get_gwl(wells = "309", which = "daily"), "Retrieving data...")
  
  expect_equal(g$Date[1], as.Date("1989-10-19"))
  expect_equal(g$GWL[1], 23.971, tolerance = 0.0001)
  expect_true(all(g$Historical_Daily_Minimum >= 
                    g$Historical_Daily_Average, na.rm = TRUE))
  expect_true(all(g$Historical_Daily_Maximum <= 
                    g$Historical_Daily_Average, na.rm = TRUE))
  expect_true(all(g$Historical_Daily_Maximum <= 
                    g$Historical_Daily_Minimum, na.rm = TRUE))
  
  expect_equal(g$GWL[g$Date == as.Date("1990-03-01")],
               24.429, tolerance = 0.0001)
  expect_equal(g$GWL[g$Date == as.Date("2015-03-01")],
               23.89208, tolerance = 0.0001)
})