
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ctisglobal

<!-- badges: start -->
<!-- badges: end -->

The goal of ctisglobal is to …

## Installation

You can install the development version of `ctisglobal` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("am0505/ctisglobal")
```

## Example

Load the package

``` r
library(ctisglobal)
## basic example code
```

Fetch all the available indicators for CTIS opendata and their
corresponding description and ranges of dates for which the question is
asked in the survey.

``` r
ctis_documentation <- ctis_get_public_apidoc()
```

Fetch available CTIS Country-Regions.

``` r
ctis_regions <- ctis_get_public_regions()
```

Fetch CTIS estimates for a range of dates.

``` r
ctis_public <- ctis_get_public_data(indicator = "covid_vaccine",
                                    type = "daily",
                                    country = "India",
                                    region = NA,
                                    date_start = "2020-04-23",
                                    date_end = "2021-12-31")
```
