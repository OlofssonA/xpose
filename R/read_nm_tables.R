#' NONMEM output table import function
#'
#' @description Quickly import NONMEM output tables into R.
#' When both \code{skip} and \code{header} are \code{NULL},
#' \code{read_nm_tables} will automatically detect the optimal
#' settings to import the tables. When more than one files are
#' provided for a same NONMEM run, they will be combined into
#' a single \code{data.frame}.
#'
#' @param files Path to the files.
#' @param rm_duplicates Logical value indicating whether duplicated columns should be removed.
#' @param index Logical value indiacating whether the data should be returned as a simple data.frame or 
#' a list containing the data and an index of the colum names.
#' @param verbose Logical, if \code{TRUE} messages are printed to the console
#' @param ... Additional arguments to be passed to the \code{\link[readr]{read_delim}} functions
#' @importFrom purrr %>%
#' @examples
#' \dontrun{
#' data <- read_nm_tables(files = '../models/pk/sdtab101')
#' }
#' @export
read_nm_tables <- function(files = NULL,
                           rm_duplicates = TRUE,
                           index = FALSE,
                           verbose = TRUE,
                           ...) {
  
  if (is.null(files) || !any(file.exists(files))) {
    msg('No table read.', verbose)
    return()
  }
  
  files <- files[file.exists(files)]
  msg(c('Reading:\n', paste(' *', files, collapse = '\n')), verbose)
  
  tables <- files %>% 
    purrr::map(readLines, n = 3) %>% 
    purrr::map2(files, read_args, verbose, ...) %>% 
    dplyr::bind_rows() %>% 
    {purrr::invoke_map(.$fun, .$params)}
  
  # Index datasets
  index_dat <- tables %>%
    purrr::map(colnames) %>%
    purrr::set_names(basename(files))
  
  # Combine data, ensure unique names and remove NA rows due to multiple headers
  tables <- dplyr::bind_cols(tables) %>% 
    purrr::set_names(make.unique(names(.))) %>% 
    stats::na.omit()
  
  # Remove duplicated columns to decrease xpdb size
  if (rm_duplicates) {
    tables <- dplyr::select(tables, dplyr::one_of(unique(unlist(index_dat))))
  }
  
  # Add index
  if (index) {
    tables <- list(data  = tables,
                   index = index_dat)
  }
  tables
}

read_funs <- function(fun) {
  c(csv = readr::read_csv,
    csv2 = readr::read_csv2,
    table = readr::read_table,
    table2 = readr::read_table2)[fun]
}

read_args <- function(x, y, verbose, col_types, ...) {
  if (missing(col_types)) {
    col_types <- readr::cols(.default = 'd')
  }
  fun <- dplyr::case_when(stringr::str_detect(x[3], '\\d,\\d+E[+-]\\d+\\s*;') ~ 'csv2',
                          stringr::str_detect(x[3], '\\d.\\d+E[+-]\\d+\\s*,') ~ 'csv', 
                          stringr::str_detect(x[3], '\\d,\\d+E[+-]\\d+\\s+') ~ 'table2',
                          TRUE ~ 'table')
  skip <- ifelse(stringr::str_detect(x[1], 'TABLE NO\\.\\s+\\d'), 1, 0)
  header <- ifelse(stringr::str_detect(x[1 + skip], '[A-z]{2,}+'), TRUE, FALSE)
  msg(c('No header detected in ', basename(y), 
        '. The use of $TABLE NOHEADER is not recommended!'), verbose = !header & verbose)
  dplyr::data_frame(fun    = read_funs(fun),
                    params = list(list(file = y, skip = skip, col_names = header, 
                                       col_types = col_types, ...)))
}