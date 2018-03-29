check_doi <- function (doi) {
  # bit.ly/doi-regex inspired
  regex <- '^10.\\d{4,9}/[-._;()/:A-Z0-9]+$'
  return(grepl(x = doi, pattern = regex,
     perl = TRUE, ignore.case = TRUE))
}
# '10.1111/j.1365-2044.2012.07128.x' = 404
# '10.1002/job.1787' = 200

construct_url <- function (doi) {
  return(sprintf('http://openretractions.com/api/doi/%s/data.json',
      doi))
}

find_doi <- function (strings) {
  # bit.ly/doi-regex inspired
  # Removed ^ and $ because it can happen
  # Some issues with trailing semi-colons sometimes
  regex <- '10.\\d{4,9}/[-._;()/:A-Z0-9]+'
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