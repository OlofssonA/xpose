summarise_nm_model <- function(file, model, software, rounding) {
  dplyr::bind_rows(
    sum_software(software),                           # Software name
    sum_version(model, software),                     # Software version
    sum_file(file),                                   # Model file
    sum_run(file),                                    # Model run (model file without extension)
    sum_directory(file),                              # Model directory
    sum_reference(model, software),                   # Reference model
    sum_probn(model, software),                       # Problem no.
    sum_description(model, software),                 # Model description
    sum_input_data(model, software),                  # Model input data used
    sum_nobs(model, software),                        # Number of observations
    sum_nind(model, software),                        # Number of individuals
    sum_nsim(model, software),                        # Number of simulations
    sum_simseed(model, software),                     # Simulation seed
    sum_subroutine(model, software),                  # Des solver
    sum_runtime(model, software),                     # Estimation/Sim runtime
    sum_covtime(model, software),                     # Covariance matrix runtime
    sum_warnings(model, software),                    # Run warnings (e.g. boundary)
    sum_errors(model, software),                      # Run errors (e.g termination error)
    sum_nsig(model, software),                        # Number of significant digits
    sum_condnum(model, software),                     # Condition number
    sum_nnpde(model, software),                       # Number of NPDE
    sum_snpde(model, software),                       # NPDE seed number
    sum_ofv(model, software),                         # Objective function value
    sum_method(model, software),                      # Estimation method or sim
    sum_shk(model, software, 'eps', rounding),        # Epsilon shrinkage
    sum_shk(model, software, 'eta', rounding)         # Eta shrinkage
  )
}

# Default template for function output
sum_tpl <- function(label, value) {
  dplyr::tibble(problem = 0,
                subp    = 1,
                label   = label,
                value   = value)
}

# Software name
sum_software <- function(software) {
  sum_tpl('software', software)
}

# Software version
sum_version <- function(model, software) {
  if (software == 'nonmem') {
    x <- model %>% 
      dplyr::filter(.$problem == 0) %>%
      dplyr::filter(stringr::str_detect(.$code, 'NONLINEAR MIXED EFFECTS MODEL PROGRAM'))
    
    if (nrow(x) == 0) return(sum_tpl('version', 'na'))
    
    sum_tpl('version', stringr::str_match(x$code, 'VERSION\\s+(.+)$')[, 2])
  }
}

# Model file name
sum_file <- function(file) {
  sum_tpl('file', basename(file))
}

# Model run name
sum_run <- function(file) {
  sum_tpl('run', update_extension(basename(file), ''))
}

# Model file directory
sum_directory <- function(file) {
  sum_tpl('dir', dirname(file))
}

# Reference model
sum_reference <- function(model, software) {
  if (software == 'nonmem') {
    x <- model %>% 
      dplyr::filter(.$problem == 0) %>%
      dplyr::filter(stringr::str_detect(tolower(.$comment), stringr::regex('based on\\s*:', ignore_case = TRUE)))
    
    if (nrow(x) == 0) return(sum_tpl('ref', 'na'))
    
    sum_tpl('ref', stringr::str_match(x$comment, ':\\s*(.+)$')[1, 2]) # Note: only take the first match
  }
}

# Problem no.
sum_probn <- function(model, software) {
  if (software == 'nonmem') {
    x <- unique(model$problem[model$problem != 0]) 
      
    if (length(x) == 0) return(sum_tpl('probn', 'na'))
    
    dplyr::tibble(
      problem = x,
      subp    = 1,
      label   = 'probn',
      value   = as.character(x))
  }
}

# Model description
sum_description <- function(model, software) {
  if (software == 'nonmem') {
    x <- model %>% 
      dplyr::filter(.$subroutine == 'pro')
    
    if (nrow(x) == 0) return(sum_tpl('descr', 'na'))
    
    dplyr::transmute(.data = x, 
                     problem = quote(problem),
                     subp = 1,
                     label = 'descr',
                     value = quote(code))
  }
}

# Input data
sum_input_data <- function(model, software) {
  if (software == 'nonmem') {
    x <- model %>% 
      dplyr::filter(.$subroutine == 'dat')
    
    if (nrow(x) == 0) return(sum_tpl('data', 'na'))
    
    dplyr::transmute(.data = x, 
                     problem = quote(problem), 
                     subp = 1,
                     label = 'data',
                     value = stringr::str_match(quote(code), '^\\s*([^\\s]+)\\s+')[, 2])
  }
}

# Number of observations
sum_nobs <- function(model, software) {
  if (software == 'nonmem') {
    x <- model %>% 
      dplyr::filter(.$subroutine == 'lst') %>% 
      dplyr::filter(stringr::str_detect(.$code, stringr::fixed('TOT. NO. OF OBS RECS')))
    
    if (nrow(x) == 0) return(sum_tpl('nobs', 'na'))
    
    dplyr::transmute(.data = x, 
                     problem = quote(problem), 
                     subp = 1,
                     label = 'nobs',
                     value = stringr::str_match(quote(code), '\\d+'))
  }
}

# Number of individuals
sum_nind <- function(model, software) {
  if (software == 'nonmem') {
    x <- model %>% 
      dplyr::filter(.$subroutine == 'lst') %>% 
      dplyr::filter(stringr::str_detect(.$code, stringr::fixed('TOT. NO. OF INDIVIDUALS')))
    
    if (nrow(x) == 0) return(sum_tpl('nind', 'na'))
    
    dplyr::transmute(.data = x, 
                     problem = quote(problem), 
                     subp = 1,
                     label = 'nind',
                     value = stringr::str_match(quote(code), '\\d+'))
  }
}

# Simulation number
sum_nsim <- function(model, software) {
  if (software == 'nonmem') {
    sum_tpl('nsim', 'na') # To be added
  }
}

# Simulation seed
sum_simseed <- function(model, software) {
  if (software == 'nonmem') {
    sum_tpl('simseed', 'na') # To be added
  }
}

# DES solver
sum_subroutine <- function(model, software) {
  if (software == 'nonmem') {
    sum_tpl('subroutine', 'na') # To be added
  }
}

# Estimation/Sim runtime
sum_runtime <- function(model, software) {
  if (software == 'nonmem') {
    sum_tpl('runtime', 'na') # To be added
  }
}

# Covariance matrix runtime
sum_covtime <- function(model, software) {
  if (software == 'nonmem') {
    sum_tpl('covtime', 'na') # To be added
  }
}

# Run warnings (e.g. boundary)
sum_warnings <- function(model, software) {
  if (software == 'nonmem') {
    sum_tpl('warnings', 'na') # To be added
  }
}

# Run errors (e.g termination error)
sum_errors <- function(model, software) {
  if (software == 'nonmem') {
    sum_tpl('errors', 'na') # To be added
  }
}

# Number of significant digits
sum_nsig <- function(model, software) {
  if (software == 'nonmem') {
    sum_tpl('nsig', 'na') # To be added
  }
}

# Condition number
sum_condnum <- function(model, software) {
  if (software == 'nonmem') {
    sum_tpl('condnum', 'na') # To be added
  }
}

# Number of NPDE
sum_nnpde <- function(model, software) {
  if (software == 'nonmem') {
    sum_tpl('nnpde', 'na') # To be added
  }
}

# NPDE seed number
sum_snpde <- function(model, software) {
  if (software == 'nonmem') {
    sum_tpl('snpde', 'na') # To be added
  }
}

# Objective function value
sum_ofv <- function(model, software) {
  if (software == 'nonmem') {
    x <- model %>% 
      dplyr::filter(.$subroutine == 'lst') %>% 
      dplyr::filter(stringr::str_detect(.$code, stringr::fixed('#OBJV')))
    
    if (nrow(x) == 0) return(sum_tpl('ofv', 'na'))
    
    x %>% 
      dplyr::mutate(value = stringr::str_match(.$code, '\\*\\s+(.+)\\s+\\*')[, 2]) %>% 
      dplyr::group_by_(quote(problem)) %>% 
      dplyr::mutate(subp = 1:n(),
                    label = 'ofv') %>% 
      dplyr::select(one_of('problem', 'subp', 'label', 'value')) %>% 
      dplyr::ungroup()
  }
}

# Estimation method or sim
sum_method <- function(model, software) {
  if (software == 'nonmem') {
    x <- model %>% 
      dplyr::filter(.$subroutine == 'est') %>% 
      dplyr::filter(stringr::str_detect(.$code, stringr::fixed('METHOD')))
    
    if (nrow(x) == 0) return(sum_tpl('method', 'na'))
    
    x %>% 
      dplyr::mutate(value = stringr::str_match(.$code, 'METHOD\\s*=\\s*([^\\s]+)')[, 2],
                    inter = stringr::str_detect(.$code, 'INTER')) %>% 
      dplyr::mutate(value = dplyr::case_when(.$value == '0' ~ 'FO',
                                             .$value == '1' ~ 'FOCE',
                                             TRUE ~ .$value)) %>% 
      dplyr::mutate(value = stringr::str_c(stringr::str_to_lower(.$value), dplyr::if_else(.$inter, '-i', ''))) %>% 
      dplyr::group_by_(quote(problem)) %>% 
      dplyr::mutate(subp = 1:n(),
                    label = 'method') %>% 
      dplyr::select(one_of('problem', 'subp', 'label', 'value')) %>% 
      dplyr::ungroup()
  }
}

# Epsilon/Eta shrinkage
sum_shk <- function(model, software, type, rounding) {
  if (software == 'nonmem') {
    # Get shrinkage from: 1) psn, 2) shr file 3) nonmem lst
    ## Method 3 (worse one)
    x <- model %>% 
      dplyr::filter(.$subroutine == 'lst') %>% 
      dplyr::filter(stringr::str_detect(.$code, stringr::fixed(stringr::str_c(stringr::str_to_upper(type), 
                                                                              'shrink', sep = ''))))
    
    if (nrow(x) == 0) return(sum_tpl(stringr::str_c(type, 'shk'), 'na'))
    
    x %>% 
      dplyr::mutate(code = stringr::str_match(.$code, '\\Q(%):\\E\\s*(.+)')[, 2]) %>% 
      dplyr::mutate(code = stringr::str_split(.$code, '\\s+')) %>% 
      dplyr::mutate(value = purrr::map(.$code, ~round(as.numeric(.), digits = rounding)),
                    index = purrr::map(.$code, ~stringr::str_c(' [', 1:length(.), ']', sep = ''))) %>% 
      dplyr::group_by_(quote(problem)) %>% 
      dplyr::mutate(subp = 1:n()) %>% 
      dplyr::ungroup() %>% 
      tidyr::unnest_(unnest_cols = c(quote(value), quote(index))) %>% 
      dplyr::filter(.$value != 100) %>% 
      dplyr::mutate(value = stringr::str_c(.$value, .$index)) %>% 
      dplyr::group_by_(quote(problem), quote(subp)) %>% 
      tidyr::nest() %>% 
      dplyr::mutate(label = stringr::str_c(type, 'shk'),
                    value = purrr::map_chr(.$data, ~stringr::str_c(.$value, collapse = ', '))) %>% 
      dplyr::select(dplyr::one_of('problem', 'subp', 'label', 'value')) %>% 
      dplyr::ungroup()
  }
}
