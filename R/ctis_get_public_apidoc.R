#' @title Get CTIS Public API Documentation
#'
#' @description Extracts API Documentation about CTIS Public API from from UMD's
#' [COVID-19 World Survey Open Data API](https://covidmap.umd.edu/api.html)
#'
#' @return A tibble with CTIS API Indicators Documentation.
#'
#' @export
#' @importFrom janitor clean_names
#' @importFrom dplyr %>%
#' @importFrom httr GET
#' @importFrom rvest html_table
#' @importFrom purrr map
#'
#' @examples
#' ctis_documentation <- ctis_get_public_apidoc()
ctis_get_public_apidoc <- function() {

  ctis_url_apidoc <- "https://gisumd.github.io/COVID-19-API-Documentation/docs/indicators/indicators_all.html"

  response <- GET(ctis_url_apidoc)

  content <- content(response, encoding = "UTF-8")

  ctis_apidoc <- html_table(content) %>%
    map(clean_names)

  ctis_public_doc_df <- ctis_apidoc[[1]] %>%
    clean_names()

  return(ctis_public_doc_df)
}
