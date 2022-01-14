#' @title Get CTIS Country Regions
#'
#' @description Provides CTIS Country Regions from UMD's
#' [COVID-19 World Survey Open Data API](https://covidmap.umd.edu/api.html)
#'
#' @return A tibble with CTIS Country-Region pairs.
#'
#' @export
#' @importFrom janitor clean_names
#' @importFrom dplyr %>%
#' @importFrom dplyr as_tibble
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#' @importFrom httr content
#' @importFrom stringr str_remove
#'
#' @examples
#' ctis_regions <- ctis_get_public_regions()
ctis_get_public_regions <- function() {

  ctis_url_api_region <- "https://covidmap.umd.edu/api/region"

  response <- GET(ctis_url_api_region)

  content <- content(response, as = "text", encoding = "UTF-8")

  ctis_apidoc_regions <- fromJSON(content, flatten = TRUE) %>%
    data.frame() %>%
    as_tibble() %>%
    clean_names()

  names(ctis_apidoc_regions) <- str_remove(names(ctis_apidoc_regions),
                                           "data_")

  return(ctis_apidoc_regions)

}
