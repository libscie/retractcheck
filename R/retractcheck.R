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
#' @param database Character. Abbreviation of the databases to search
#'     (\code{or} for openretractions.com).  # #' and \code{rw} for #
#'     #' retractiondatabase.com). Note that in the absence of an API,
#'     # #' searching retractiondatabase.com is rather slow.
#' @param return Character. If \code{all}, all DOIs are queried and
#'     all results are returned; if \code{unique}, the DOIs are
#'     queried in the order specified until either a correction or
#'     retraction notice is found or all databases have been queried.
#'
#' @return \code{\link{retractcheck}} data.frame
#' @export
#' @examples \donttest{
#'   retractcheck(c('10.1002/job.1787',
#'                  '10.1111/j.1365-2044.2012.07128.x'))
#'
#'   retractcheck(c('10.1002/job.1787',
#'                  '10.1111/j.1365-2044.2012.07128.x'),
#'                  return = 'all')
#' }

retractcheck <- function (dois, database = 'or', return = 'unique') { # c('or', 'rw')
    listdf <- apply(t(dois), 2, function (doi) {
        if (!check_doi(doi)) {
            message(sprintf('%s is not a valid DOI', doi))
        } else {
            res <- NULL
            res <- rbind(res, query_or(doi))
        }

        res
        
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
#' @examples \donttest{
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
#' @examples \donttest{
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
#' @examples \donttest{
#'   retractcheck_pdf(system.file("extdata", "manuscript.pdf", package = "retractcheck"))
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
#' @examples \donttest{
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
#' @examples \donttest{
#'   retractcheck_html('manuscript.html')
#' }

retractcheck_html <- function (path, ...) {
    text <- textreadr::read_html(path)
    dois <- find_doi(text)
    res <- retractcheck(dois, ...)

    return(res)
}

#' Check txt file for retractions
#'
#' Check a txt file for retractions.
#'
#' @param path Path to txt file to check
#' @inheritDotParams retractcheck -dois
#'
#' @return \code{\link{retractcheck}} dataframe without filenames
#' @export
#' @examples \donttest{
#'   retractcheck_txt('manuscript.txt')
#' }

retractcheck_txt <- function (path, ...) {
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
#' @return Data frame
#' @export
#'
#' @examples \donttest{
#'   query_or('10.1002/job.1787')
#' }

query_or <- function(doi) {
    res <- data.frame(
        doi = doi,
        database = 'open_retractions',
        update_type = 'None found',
        retracted = NA,
        update_doi = NA,
        publisher = NA,
        title = NA,
        published_original = NA,
        published_update = NA,
        update_delay = NA
    )

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
