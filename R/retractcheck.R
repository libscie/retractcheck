retractcheck <- function (dois) {
  listdf <- apply(t(dois), 2, function (doi) {
    if (!check_doi(doi)) {
      message(sprintf('%s is not a valid DOI', doi))
    } else {
        call <- httr::GET(construct_url(doi))
    
        if (call$status_code == 404) {
          message(sprintf('No updates found for %s', doi))
        } else {
          obj <- httr::content(call)
    
          published_original <- as.Date(as.POSIXct(obj$timestamp / 1000,
           origin='1970-01-01'))
          published_update <- as.Date(as.POSIXct(obj$updates[[1]]$timestamp / 1000,
           origin='1970-01-01'))
          update_delay <- difftime(published_update, published_original)
    
          res <- data.frame(doi, 
            update_type = obj$updates[[1]]$type,
            retracted = obj$retracted,
            update_doi = obj$updates[[1]]$identifier$doi,
            publisher = obj$publisher,
            title = obj$title,
            published_original,
            published_update,
            update_delay)
          return(res)
        }
      }
  })
  df <- plyr::ldply(listdf, data.frame)

  if (dim(df)[1] == 0) {
    message('\nHOORAY *<(:)')
    message('No retractions or corrections to check out')
  } else {    
      return(df)
  }
}

retractcheck_dir <- function (path, ...) {
  text <- textreadr::read_dir(path, ...)$content
  dois <- find_doi(text)
  res <- retractcheck(dois)

  return(res)
}