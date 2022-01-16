#' Download FB CTIS Daily Survey Data by date and file type.
#'
#' @param ctis_date Date of CTIS Survey in `YYYY-MM-DD` format
#' @param country Country. Optional parameter. If supplied, only the records of
#' that particular country will be returned.
#' @param ctis_type CTIS file type. Can be either `full` or `partial`.
#' @param dest Destination Location.
#' @param ctis_username Username for the CTIS microdata API. Defaults to value
#' supplied in environment variable `CTIS_USERNAME`
#' @param ctis_password Password for the CTIS microdata API. Defaults to value
#' supplied in environment variable `CTIS_PASSWORD`
#'
#' @import dplyr
#' @import vroom
#' @import tidyselect
#' @import curl
#' @importFrom rlang .data
#' @importFrom purrr possibly
#' @importFrom janitor clean_names
#' @importFrom lubridate month
#' @importFrom lubridate year
#' @importFrom crayon red
#' @import glue glue
#'
#' @export
#' @return A tibble.
ctis_get_micro <- function(ctis_date,
                           country = NA,
                           ctis_type = "full",
                           dest = "data/",
                           ctis_username = Sys.getenv("CTIS_USERNAME"),
                           ctis_password = Sys.getenv("CTIS_PASSWORD")) {

  if (is.na(ctis_username) | is.na(ctis_password)) {
    stop("Missing CTIS user details.")
  }

  if (!dir.exists(dest)) {
    dir.create(dest)
  }

  file <- glue(as.character(ctis_date), "_", ctis_type, ".csv.gz")

  destfile <- glue(dest, file)

  if (!file.exists(destfile)) {
    h <- curl::new_handle()
    curl::handle_setopt(
      handle = h,
      httpauth = 1,
      userpwd = glue(ctis_username,
                     ctis_password,
                     .sep = ":"))

    url_v17 <- "https://covidmap.umd.edu/fbsurvey/microdata/v1.7/"

    ctis_month_raw <- month(ctis_date)
    ctis_month <- case_when(ctis_month_raw < 10 ~ glue("0", as.character(ctis_month_raw)),
                            TRUE ~ as.character(ctis_month_raw))
    ctis_year <- year(ctis_date)

    url <- glue(url_v17, ctis_year, "/", ctis_month, "/", file)

    message(glue("Downloading CTIS file for the date: ", red(ctis_date)))

    possibly(.f = curl::curl_download(url,
                                      destfile = destfile,
                                      handle = h,
                                      quiet = TRUE),
             otherwise = "Download Error",
             quiet = F)
  }

  ctis_spec <- cols(
    weight = "d",
    #recorded_date = "T",
    survey_region = "c",
    survey_version = "c",
    q_language = "c",
    q_total_duration = "d",
    country_agg = "c",
    region_agg = "c",
    gid_0 = "c",
    gid_1 = "c",
    module = "c",
    b4 = "d",
    b2 = "d",
    #j1 = "d",
    e5 = "d",
    e7a = "d",
    name_0 = "c",
    name_1 = "c"
  )

  ctis_daily_colnames <- suppressMessages(vroom(destfile, n_max = 100, progress = F)) %>%
    clean_names() %>%
    colnames()

  if (is.na(country)) {
    ctis_daily_raw <- suppressMessages(vroom(destfile,
                                             col_types = ctis_spec,
                                             col_names = ctis_daily_colnames,
                                             skip = 1,
                                             progress = F))
  } else {
    ctis_daily_raw <- suppressMessages(vroom(destfile,
                                             col_types = ctis_spec,
                                             col_names = ctis_daily_colnames,
                                             skip = 1,
                                             progress = F)) %>%
      filter(.data$country_agg == {{country}})
  }

  ctis_daily <- ctis_daily_raw %>%
    mutate(date = ctis_date) %>%
    mutate_if(is.character,
              ~ case_when(.x == "-77.0" ~ "-77",
                          .x == "-88.0" ~ "-88",
                          .x == "-99.0" ~ "-99",
                          .x == "0.0" ~ "0",
                          .x == "1.0" ~ "1",
                          .x == "2.0" ~ "2",
                          .x == "3.0" ~ "3",
                          .x == "4.0" ~ "4",
                          .x == "5.0" ~ "5",
                          .x == "6.0" ~ "6",
                          .x == "7.0" ~ "7",
                          TRUE ~ .x))

  return(ctis_daily)

}
