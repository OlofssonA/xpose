context('Check read_nm_tables')

# Define files to be tested -----------------------------------------------

test_tab <- read_nm_tables(files = 'sdtab001', quiet = TRUE)
ctrl_tab <- xpdb_ex_pk$data$data[[1]][, xpdb_ex_pk$data$index[[1]][xpdb_ex_pk$data$index[[1]]$tables == 'sdtab001',]$colnames[[1]] ]

test_file <- c("TABLE NO.  4",
               " ID          KA          CL          V           ALAG1       ETA1        ETA2        ETA3        DV          PRED        RES         WRES",
               "  1.1000E+02  4.1052E-01  2.5483E+01  1.4917E+02  2.3223E-01 -4.5845E-02 -3.5313E-03 -2.1460E+00  0.0000E+00 -3.6889E+00  0.0000E+00  0.0000E+00",
               "  1.1000E+02  4.1052E-01  2.5483E+01  1.4917E+02  2.3223E-01 -4.5845E-02 -3.5313E-03 -2.1460E+00 -2.4841E+00 -5.6877E-01 -1.9153E+00 -3.8853E+00")
ctrl_file <- xpdb_ex_pk$data$data[[1]][1:2, xpdb_ex_pk$data$index[[1]][xpdb_ex_pk$data$index[[1]]$tables == 'patab001',]$colnames[[1]] ]

firstonly_test <- as.nm.table.list(dplyr::tibble(problem   = 1, 
                                                 file      = c('sdtab001', 'patab001'),
                                                 firstonly = c(TRUE, FALSE),
                                                 simtab    = FALSE))

# Tests start here --------------------------------------------------------

test_that("message is returned when missing file argument", {
  expect_null(read_nm_tables(quiet = TRUE))
  expect_message(read_nm_tables(quiet = FALSE))
})

test_that("message is returned when all provided files are missing", {
  expect_null(read_nm_tables(files = 'fake_table.tab', quiet = TRUE))
  expect_message(read_nm_tables(files = 'fake_table.tab', quiet = FALSE), regexp = 'could be found')
})

test_that("message is returned when tables exist but are duplicated", {
  expect_null(read_nm_tables(files = c('sdtab001', 'patab001', 'sdtab001'), quiet = TRUE))
  expect_message(read_nm_tables(files = c('sdtab001', 'patab001', 'sdtab001'), quiet = FALSE), regexp = 'duplicated')
})

test_that("message is returned when missing table header", {
  files <- tempfile('tmp_header')
  on.exit(unlink(files))
  
  # Test with skip = 1 and header = FALSE
  writeLines(text = test_file[c(1, 3:4)], con = files[1])
  expect_message(read_nm_tables(files = files[1], quiet = FALSE), regexp = 'Dropped.+missing headers')
})

test_that("dot arguments are properly passed to readr", {
  expect_equal(nrow(read_nm_tables('sdtab001', n_max = 3, quiet = TRUE)), 3)
})

test_that("returns a tibble when user mode is used", {
  expect_equal(test_tab, ctrl_tab)
})

test_that("tables with firstonly are properly handled", {
  expect_message(read_nm_tables(firstonly_test, quiet = FALSE), regexp = 'Consolidating|Joining')
  expect_equal(read_nm_tables(firstonly_test, quiet = TRUE)$data[[1]], 
               xpdb_ex_pk$data$data[[1]][, unlist(xpdb_ex_pk$data$index[[1]][xpdb_ex_pk$data$index[[1]]$tables %in% c('sdtab001', 'patab001'),]$colnames) ])
})

test_that("properly assign skip and header arguments", {
  files <- tempfile(c('tmp_a', 'tmp_b'))
  on.exit(unlink(files))
  
  # Test with skip = 1 and header = TRUE
  writeLines(text = test_file[1:4], con = files[1])
  expect_equal(read_nm_tables(files = files[1]),  ctrl_file)
  
  # Test with skip = 0 and header = TRUE
  writeLines(text = test_file[2:4], con = files[2])
  expect_equal(read_nm_tables(files = files[2]),  ctrl_file)
})
