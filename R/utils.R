#' Check for valid DOI
#'
#' This helper function checks whether a DOI is valid. The regular expression
#' is based on the one provided by CrossRef as providing the highest coverage
#' (\url{https://bit.ly/doi-regex}).
#'
#' @param doi Digital Object Identifier (string)
#'
#' @return Boolean
#' @export
#'
#' @examples
#'   check_doi(doi = '10.1002/job.1787')
#'   check_doi(doi = '10.1111/j.1365-2044.2012.07128.x')

check_doi <- function (doi) {
  regex <- '^10\\.\\d{4,9}/[-._;()/:A-Z0-9]+$'

  return(grepl(x = doi, pattern = regex,
     perl = TRUE, ignore.case = TRUE))
}

#' OpenRetractions URL
#'
#' Helper function to easily maintain the API calls to
#' \url{http://openretractions.com}.
#'
#' @param doi Digital Object Identifier (string)
#'
#' @return URL (string)

construct_or_url <- function (doi) {
  return(sprintf('http://openretractions.com/api/doi/%s/data.json',
      doi))
}

#' Find DOIs in strings
#'
#' Helper function to find DOIs in strings. Can occasionally erroneously
#' extract DOIs (subset of another DOI for example). Regular expression
#' based on CrossRef (\url{http://bit.ly/doi-regex}; see also
#' \code{\link{check_doi}}).
#'
#' @param strings Vector of strings to check for DOIs
#'
#' @return Vector of DOIs
#' @export
#'
#' @examples
#'   find_doi('This contains 10.1111/j.1365-2044.2012.07128.x')

find_doi <- function (strings) {
  regex <- '10\\.\\d{4,9}/[-._;()/:A-Z0-9]+'
  doiLoc <- gregexpr(text = strings, pattern = regex,
     perl = TRUE, ignore.case = TRUE)

  i <- 1
  res <- NULL

  # for each in the doiLoc list check whether match (!-1)
  for ( i in 1:length(doiLoc) ) {
    if ( doiLoc[[i]][1] != -1 ) {
      for ( j in 1:length(doiLoc[[i]]) ) {
        res <- c(res,
          substring(strings[i],
          doiLoc[[i]][j], doiLoc[[i]][j] + attr(doiLoc[[i]], 'match.length')[j] - 1))
      }
    }
  }

  return(res)
}


#' Convert timestamp to Date
#'
#' Helper function to convert a timestamp from openretractions.com into a date.
#'
#' @param x Numeric timestamp
#' @param database Character. Database (currently only \code{or})
#'
#' @return a Date
#' @export

get_date <- function(x, database = 'or') {

  if (database == 'or') {
    as.Date(as.POSIXct(x / 1000, origin='1970-01-01'))
  } else {
    stop("database '", database, "' not supported.")
  }
}
