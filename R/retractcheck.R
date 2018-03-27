retractcheck <- function (doi) {
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
  }

  return(res)
}

# retracted
# updated
# update_type
# update_doi
# publisher
# title


# retracted = obj$retracted
# updated
# update_type
# update_doi
# publisher
# title
