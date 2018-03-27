check_doi <- function (doi) {
  # bit.ly/doi-regex inspired
  regex <- '^10.\\d{4,9}/[-._;()/:A-Z0-9]+$'
  return(grepl(x = doi, pattern = regex,
     perl = TRUE, ignore.case = TRUE))
}
# '10.1111/j.1365-2044.2012.07128.x' = 404
# '10.1002/job.1787' = 200

construct_url <- function (doi) {
  if (!check_doi(doi)) stop('Please input valid DOI.')
  return(sprintf('http://openretractions.com/api/doi/%s/data.json',
      doi))
}