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
#' and what type of update was made.
#'
#' @param dois Character. Vector of containing only DOIs
#' @param database Character. Abbreviation of the databases to search if
#'   (\code{or} for openretractions.com and \code{rw} for
#'   retractiondatabase.com). Note that in the absence of an API,
#'   searching retractiondatabase.com is rather slow.
#' @param return Character. If \code{all}, all databases are queried and all
#'   results are returned; if \code{unique}, the databases are queried in
#'   the order specified in \code{database} until either a correction or
#'   retraction notice is found or all databases have been queried.
#'
#' @return \code{\link{retractcheck}} data.frame
#' @export
#' @examples \dontrun{
#'   retractcheck(c('10.1002/job.1787',
#'                  '10.1111/j.1365-2044.2012.07128.x'))
#'
#'   retractcheck(c('10.1002/job.1787',
#'                  '10.1111/j.1365-2044.2012.07128.x'),
#'                  return = 'all')
#' }

retractcheck <- function (dois, database = c('or', 'rw'), return = 'unique') {
  listdf <- apply(t(dois), 2, function (doi) {
    if (!check_doi(doi)) {
      message(sprintf('%s is not a valid DOI', doi))
    } else {
      res <- NULL
      if (return == 'all') {
        if ('or' %in% database) res <- rbind(res, query_or(doi))
        if ('rw' %in% database) res <- rbind(res, query_rw(doi))
      } else if (return == 'unique') {
        for (i in database) {
          i_res <- switch(
            i
            , 'or' = query_or(doi)
            , 'rw' = query_rw(doi)
            , NULL
          )
          res <- rbind(res, i_res)

          if (i_res$update_type != "None found") {
            i_res <- NULL
            break
          }
        }

      } else {
        stop(
          "return = '", return, "' is not supported. Please use either 'unique'  or 'all'."
          , sep = ""
          , call. = FALSE
        )
      }

      res
    }
  })

  df <- plyr::ldply(listdf, data.frame)

  if (sum(df$update_type != "None found") == 0) {
    message('\nHOORAY *<(:)')
    message('None of the DOIs mentioned have indexed retractions or corrections.')
    return(invisible(df))
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
#' @inheritDotParams retractcheck -dois
#'
#' @return \code{\link{retractcheck}} dataframe with filenames
#' @export
#' @examples \dontrun{
#'   retractcheck_dir(path = '.')
#' }

retractcheck_dir <- function (path, ...) {
  res <- NULL
  text <- textreadr::read_dir(path)

  for (file in unique(text$document)) {
    dois <- find_doi(text$content[text$document == file])
    if (!is.null(dois)) {
      updates <- retractcheck(dois, ...)
      res <- rbind(res, data.frame(file, updates))
    }
  }

  return(res)
}

#' Check docx file for retractions
#'
#' Check a DOCX file for retractions.
#'
#' @param path Path to DOCX file to check
#' @inheritDotParams retractcheck -dois
#'
#' @return \code{\link{retractcheck}} dataframe without filenames
#' @export
#' @examples \dontrun{
#'   retractcheck_docx('manuscript.docx')
#' }

retractcheck_docx <- function (path, ...) {
  text <- textreadr::read_docx(path)
  dois <- find_doi(text)
  res <- retractcheck(dois, ...)

  return(res)
}

#' Check pdf file for retractions
#'
#' Check a pdf file for retractions.
#'
#' @param path Path to pdf file to check
#' @inheritDotParams retractcheck -dois
#'
#' @return \code{\link{retractcheck}} dataframe without filenames
#' @export
#' @examples \dontrun{
#'   retractcheck_pdf('manuscript.pdf')
#' }

retractcheck_pdf <- function (path, ...) {
  text <- textreadr::read_pdf(path)
  dois <- find_doi(text)
  res <- retractcheck(dois, ...)

  return(res)
}

#' Check rtf file for retractions
#'
#' Check a rtf file for retractions.
#'
#' @param path Path to rtf file to check
#' @inheritDotParams retractcheck -dois
#'
#' @return \code{\link{retractcheck}} dataframe without filenames
#' @export
#' @examples \dontrun{
#'   retractcheck_rtf('manuscript.rtf')
#' }

retractcheck_rtf <- function (path, ...) {
  text <- textreadr::read_rtf(path)
  dois <- find_doi(text)
  res <- retractcheck(dois, ...)

  return(res)
}

#' Check html file for retractions
#'
#' Check a html file for retractions.
#'
#' @param path Path to html file to check
#' @inheritDotParams retractcheck -dois
#'
#' @return \code{\link{retractcheck}} dataframe without filenames
#' @export
#' @examples \dontrun{
#'   retractcheck_html('manuscript.html')
#' }

retractcheck_html <- function (path, ...) {
  text <- textreadr::read_html(path)
  dois <- find_doi(text)
  res <- retractcheck(dois, ...)

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
    , database = 'open_retractions'
    , update_type = 'None found'
    , retracted = NA
    , update_doi = NA
    , publisher = NA
    , title = NA
    , published_original = NA
    , published_update = NA
    , update_delay = NA
  )

  # Query database
  or_call <- httr::GET(construct_or_url(doi))

  if (or_call$status_code != 404) {
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


#' Query \url{http://retractiondatabase.org} for retractions
#'
#' Using \url{http://retractiondatabase.org}, this function
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
#'   query_rw('10.1002/job.1787')
#' }

query_rw <- function (doi) {

  # Prepare output
  res <- data.frame(
    doi = doi
    , database = 'retraction_watch'
    , update_type = 'None found'
    , retracted = NA
    , update_doi = NA
    , publisher = NA
    , title = NA
    , published_original = NA
    , published_update = NA
    , update_delay = NA
  )

  # Check internet connection
  rw_call <- httr::GET('http://retractiondatabase.org/RetractionSearch.aspx')

  if (rw_call$status_code == 404) {
    warning("Unable to connect to Retraction Watch database. Can you access 'http://retractiondatabase.org/RetractionSearch.aspx' in your web browser?")
    return(res)
  } else {

    # Prepare Retraction Watch database query
    rw_cookies <- httr::cookies(rw_call)
    rw_query_cookies <- rw_cookies$value
    names(rw_query_cookies) <- rw_cookies$name

    rw_viewstate <- sub('.*id="__VIEWSTATE" value="([0-9a-zA-Z+/=]*).*', '\\1', rw_call)
    rw_viewstategenerator <- sub('.*id="__VIEWSTATEGENERATOR" value="([0-9a-zA-Z+/=]*).*', '\\1', rw_call)
    rw_eventvalidation <- sub('.*id="__EVENTVALIDATION" value="([0-9a-zA-Z+/=]*).*', '\\1', rw_call)

    rw_query_body <- list(
      '_LASTFOCUS' = ''
      , '__EVENTTARGET' = 'btnSearch'
      , '__EVENTARGUMENT' = ''
      , '__VIEWSTATE' = rw_viewstate
      , '__VIEWSTATEGENERATOR' = rw_viewstategenerator
      , '__VIEWSTATEENCRYPTED' = ''
      , '__EVENTVALIDATION' = rw_eventvalidation
      , 'txtEmail' = ''
      , 'txtPSWD' = ''
      , 'txtSrchAuthor' = ''
      , 'txtSrchCountry' = ''
      , 'txtSrchTitle' = ''
      , 'txtSrchReason' = ''
      , 'txtSrchSubject' = ''
      , 'txtSrchType' = ''
      , 'txtSrchJournal' = ''
      , 'txtSrchPublisher' = ''
      , 'txtSrchInstitution' = ''
      , 'txtSrchNotes' = ''
      , 'txtSrchAdminNotes' = ''
      , 'txtSrchURL' = ''
      , 'txtOriginalDateFrom' = ''
      , 'txtOriginalDateTo' = ''
      , 'txtOriginalPubMedID' = ''
      , 'txtOriginalDOI' = doi
      , 'txtFromDate' = ''
      , 'txtToDate' = ''
      , 'txtPubMedID' = ''
      , 'txtDOI' = ''
      , 'drpNature' = ''
      , 'drpSrchPaywalled' = ''
      , 'drpUser' = ''
      , 'txtCreateFromDate' = ''
      , 'txtCreateToDate' = ''
      , 'hidClearSearch' = ''
      , 'hidSqlParmNames' = ''
      , 'hidEmptySqlParmNames' = ''
    )

    # Query database
    rw_database_call <- httr::POST(
      'http://retractiondatabase.org/RetractionSearch.aspx'
      , body = rw_query_body
      , httr::set_cookies(rw_query_cookies)
    )

    # Scrape results
    rw_html <- httr::content(rw_database_call, encoding = "UTF-8")
    rw_update_table <- rvest::html_nodes(rw_html, '#grdRetraction')
    rw_update_table <- rvest::html_table(rw_update_table)
    rw_update_table <- as.data.frame(rw_update_table)

    if (!nrow(rw_update_table) == 0) {
      if (nrow(rw_update_table) > 1) {
        # If multiple entries are returned, expand data.frame to fit results
        res <- res[rep(1, nrow(rw_update_table)), ]
      }

      res$update_type <- ifelse(grepl('Retraction', rw_update_table$Article.Type.s.Nature.of.Notice), 'retraction', res$update_type)
      res$update_type <- ifelse(is.na(res$update_type) & grepl('Expression of concern', rw_update_table$Article.Type.s.Nature.of.Notice), 'expression of concern', res$update_type)
      res$update_type <- ifelse(is.na(res$update_type) & grepl('Correction', rw_update_table$Article.Type.s.Nature.of.Notice), 'correction', res$update_type)

      res$retracted <- ifelse(res$update_type == 'retraction', TRUE, FALSE)
      res$update_doi <- find_doi(rw_update_table$Retraction.or.Other.NoticesDate.PubMedID.DOI)

      # if("rcrossref" %in% installed.packages()) {
      #   update_cr <- rcrossref::cr_works(update_doi)$data
      #
      #   publisher <- update_cr$publisher
      #   title <- update_cr$title
      #   update_date <- update_cr$published.print
      # } else {

      res$publisher <- rvest::html_text(rvest::html_nodes(rw_html, '.rPublisher'))
      res$published_original <- get_date(rw_update_table$Original.PaperDate.PubMedID.DOI, database = 'rw')
      res$published_update <- get_date(rw_update_table$Retraction.or.Other.NoticesDate.PubMedID.DOI, database = 'rw')
      res$update_delay <- difftime(res$published_update, res$published_original)
      # }

    }

    res
  }
}
