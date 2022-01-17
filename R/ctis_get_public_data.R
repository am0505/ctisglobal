#' @title Get Aggregate Weighted and Unweighted CTIS Estimates.
#'
#' @description Provides Global COVID-19 Trends and Impact Survey's data for the
#' indicator, country, date and type specified from the  UMD's
#' [COVID-19 World Survey Open Data API](https://covidmap.umd.edu/api.html).
#'
#' @param indicator CTIS Indicator. Examples - "covid", "mask", "vaccine_acpt", etc.,
#' @param type daily or smoothed
#' @param country Country. Examples - "Italy", "India", "Australia", etc.,
#' @param region Region. Optional.
#' @param date_start Start Date. Defaults to the beginning of survey 2020-04-23.
#' @param date_end End Date. Optional. If specified `all`, fetches till the
#' maximum available data i.e., 6 day lag.
#'
#' @return A tibble with indicator data for the country and date specified from
#' the Global COVID-19 Trends and Impact Survey
#'
#' @export
#' @import dplyr
#' @importFrom rlang .data
#' @importFrom janitor clean_names
#' @importFrom dplyr %>%
#' @importFrom dplyr tibble
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET
#' @importFrom httr content
#' @importFrom httr status_code
#' @importFrom httr modify_url
#' @importFrom purrr map
#' @importFrom glue glue
#' @importFrom lubridate ymd
#' @importFrom stringr str_remove_all
#' @importFrom stringr str_remove
#' @examples
#' ctis_public <- ctis_get_public_data()
ctis_get_public_data <- function(indicator = "covid_vaccine",
                                 type = "daily",
                                 country = "India",
                                 region = NA,
                                 date_start = "2020-04-23",
                                 date_end = NA) {

  ##todo - add useragent maybe
  url_base <- "https://covidmap.umd.edu"

  latest_min_date <- Sys.Date() - 3

  if (is.na(date_end)) {
    date_range <- str_remove_all(date_start, "-")
  } else if (date_end == "all") {
    date_range <- glue(str_remove_all(date_start, "-"),
                       str_remove_all(as.character(latest_min_date), "-"),
                       .sep = "-")
  } else if (ymd(date_end) <= latest_min_date) {
    date_range <- glue(str_remove_all(date_start, "-"),
                       str_remove_all(date_end, "-"),
                       .sep = "-")
  } else if (ymd(date_end) > latest_min_date) {
    warning("Specified date out of range. Defaulting to latest available dates")
    date_range <- glue(str_remove_all(date_start, "-"),
                       str_remove_all(as.character(latest_min_date), "-"),
                       .sep = "-")
  } else {
    stop("Date range specified in incorrect format")
  }

  if (is.na(region)) {
    url_ctis <- modify_url(url = url_base,
                           path = "/api/resources",
                           query = list(indicator = indicator,
                                        type = type,
                                        country = country,
                                        daterange = date_range))
  } else {
    url_ctis <- modify_url(url = url_base,
                           path = "/api/resources",
                           query = list(indicator = indicator,
                                        type = type,
                                        country = country,
                                        region = region,
                                        daterange = date_range))
  }

  message(url_ctis)

  response <- GET(url = url_ctis)

  if (status_code(response) != 200) {
    stop("API request failed", call. = FALSE)
  }

  content <- content(response, as = "text", encoding = "UTF-8")

  ctis_aggregate_parsed <- jsonlite::fromJSON(content, flatten = TRUE)

  ## NOTE - Empty lists have no status code!
  if (length(ctis_aggregate_parsed$data) == 0) {

    ctis_aggregate <- tibble(status = "Estimates not available",
                             region = region,
                             indicator = indicator)

  }
  else {
    ctis_aggregate <- ctis_aggregate_parsed %>%
      data.frame() %>%
      as_tibble() %>%
      clean_names() %>%
      mutate(date = ymd(.data$data_survey_date)) %>%
      select(-.data$status) %>%
      select(.data$date, .data$data_country, everything()) %>%
      mutate(indicator = indicator)
    if (is.na(region)) {
      ctis_aggregate <- ctis_aggregate %>%
        mutate(region = "All Regions")
    }

    # names(ctis_aggregate) <- str_remove(names(ctis_aggregate),
    #                                     "data_")

    ctis_public_column_names <- c("date", "country", "wt_pct", "wt_pct_se", "uwt_pct", "uwt_pct_se", "sample_size", "iso_code", "gid_0", "survey_date", "indicator", "region")

    names(ctis_aggregate) <- ctis_public_column_names

  }

  return(ctis_aggregate)
}
