#' retractcheck: Retraction scanner
#'
#' Using 'Digital Object Identifiers', check for retracted (or otherwise
#' updated) articles using 'Open Retractions' <http://openretractions.com>.
#'
#' @docType package
#' @name retractcheck
NULL

#' Check DOIs for retractions
#'
#' Using the \url{http://openretractions.com} API, this function
#' checks whether a DOI has been updated, when that update was made,
#' and what type of update was made. DOIs without updates are not returned.
#'
#' @param dois Vector of strings containing only DOIs
#'
#' @return \code{\link{retractcheck}} dataframe
#' @export
#' @examples \dontrun{
#'   retractcheck(c('10.1002/job.1787',
#'                  '10.1111/j.1365-2044.2012.07128.x'))
#' }

retractcheck <- function (dois) {
  listdf <- apply(t(dois), 2, function (doi) {
    if (!check_doi(doi)) {
      message(sprintf('%s is not a valid DOI', doi))
    } else {
      query_or(doi)
    }
  })
  df <- plyr::ldply(listdf, data.frame)

  if (dim(df)[1] == 0) {
    message('\nHOORAY *<(:)')
    message('None of the DOIs mentioned have indexed retractions or corrections.')
  } else {
    return(df)
  }
}

#' Check files in directory for retractions
#'
#' Check all HTML, DOCX, PDF, and RTF files in a directory for updates to
#' referenced DOIs.
#'
#' @param path Path to directory to check
#'
#' @return \code{\link{retractcheck}} dataframe with filenames
#' @export
#' @examples \dontrun{
#'   retractcheck_dir(path = '.')
#' }

retractcheck_dir <- function (path) {
  res <- NULL
  text <- textreadr::read_dir(path)

  for (file in unique(text$document)) {
    dois <- find_doi(text$content[text$document == file])

    updates <- retractcheck(dois)
    if (!is.null(dois)) res <- rbind(res, data.frame(file, updates))
  }

  return(res)
}

#' Check docx file for retractions
#'
#' Check a DOCX file for retractions.
#'
#' @param path Path to DOCX file to check
#'
#' @return \code{\link{retractcheck}} dataframe without filenames
#' @export
#' @examples \dontrun{
#'   retractcheck_docx('manuscript.docx')
#' }

retractcheck_docx <- function (path) {
  text <- textreadr::read_docx(path)
  dois <- find_doi(text)
  res <- retractcheck(dois)

  return(res)
}

#' Check pdf file for retractions
#'
#' Check a pdf file for retractions.
#'
#' @param path Path to pdf file to check
#'
#' @return \code{\link{retractcheck}} dataframe without filenames
#' @export
#' @examples \dontrun{
#'   retractcheck_pdf('manuscript.pdf')
#' }

retractcheck_pdf <- function (path) {
  text <- textreadr::read_pdf(path)
  dois <- find_doi(text)
  res <- retractcheck(dois)

  return(res)
}

#' Check rtf file for retractions
#'
#' Check a rtf file for retractions.
#'
#' @param path Path to rtf file to check
#'
#' @return \code{\link{retractcheck}} dataframe without filenames
#' @export
#' @examples \dontrun{
#'   retractcheck_rtf('manuscript.rtf')
#' }

retractcheck_rtf <- function (path) {
  text <- textreadr::read_rtf(path)
  dois <- find_doi(text)
  res <- retractcheck(dois)

  return(res)
}

#' Check html file for retractions
#'
#' Check a html file for retractions.
#'
#' @param path Path to html file to check
#'
#' @return \code{\link{retractcheck}} dataframe without filenames
#' @export
#' @examples \dontrun{
#'   retractcheck_html('manuscript.html')
#' }

retractcheck_html <- function (path) {
  text <- textreadr::read_html(path)
  dois <- find_doi(text)
  res <- retractcheck(dois)

  return(res)
}


#' Query \url{http://openretractions.com} for retractions
#'
#' Using the \url{http://openretractions.com} API, this function
#' checks whether a DOI has been updated, when that update was made,
#' and what type of update was made.
#'
#' @param doi Character. A digital object identifier (DOI).
#'
#' @return
#' @export
#'
#' @examples \dontrun{
#'   query_or('10.1002/job.1787')
#' }

query_or <- function(doi) {
  # Prepare output
  res <- data.frame(
    doi = doi
    , update_type = 'None found'
    , retracted = NA
    , update_doi = NA
    , publisher = NA
    , title = NA
    , published_original = NA
    , published_update = NA
    , updated_delay = NA
    , database = 'open_retractions'
  )

  # Query database
  or_call <- httr::GET(construct_or_url(doi))

  if (or_call$status_code == 404) {
    message(sprintf('No updates found for %s', doi))
  } else {
    or_html <- httr::content(or_call, encoding = "UTF-8")

    res$update_type <- or_html$updates[[1]]$type
    res$retracted <- or_html$retracted
    res$update_doi <- or_html$updates[[1]]$identifier$doi
    res$publisher <- or_html$publisher
    res$title <- or_html$title
    res$published_original <- get_date(or_html$timestamp)
    res$published_update <- get_date(or_html$updates[[1]]$timestamp)
    res$update_delay <- difftime(res$published_update, res$published_original)
  }

  res
}
