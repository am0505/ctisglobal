
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ctisglobal

This package offers a set of utility functions to fetch data and
documentation from Global COVID-19 Trends and Impact Survey (CTIS) using
R. CTIS was formerly known as COVID-19 Symptoms Survey (CSS).

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
```

Fetch all the available indicators for CTIS opendata, their
corresponding description, survey questions used in constructing the
indicator and ranges of dates for which the question is asked in the
survey.

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
