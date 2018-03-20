
# bcgroundwater

<a rel="Delivery" href="https://github.com/BCDevExchange/assets/blob/master/README.md"><img alt="In production, but maybe in Alpha or Beta. Intended to persist and be supported." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/delivery.svg" title="In production, but maybe in Alpha or Beta. Intended to persist and be supported." /></a>[![Travis-CI Build Status](https://travis-ci.org/bcgov/bcgroundwater.svg?branch=master)](https://travis-ci.org/bcgov/bcgroundwater)


## Overview

An [R](http://www.r-project.org) package to facilitate analysis and 
visualization of groundwater data from the [British Columbia groundwater 
observation well network](https://www2.gov.bc.ca/gov/content?id=B03D0994BB5C4F98B6F7D4FD8610C836). The data is sourced from the [B.C. Data Catalogue](https://catalogue.data.gov.bc.ca/dataset/57c55f10-cf8e-40bb-aae0-2eff311f1685) distributed under the [Open Government Licence-British Columbia](https://www2.gov.bc.ca/gov/content?id=A519A56BC2BF44E4A008B33FCF527F61). The package provides functions for importing, cleaning, and summarizing groundwater data, analyzing long-term trends in groundwater levels, and visualizing analysis results. 

This package was developed by [Environmental Reporting BC](http://www2.gov.bc.ca/gov/content?id=FF80E0B985F245CEA62808414D78C41B) 
to support our 2013 analysis of [trends in groundwater levels](http://www.env.gov.bc.ca/soe/indicators/water/groundwater-levels.html). 
The code behind that analysis is available in its own GitHub [repository](https:/github.com/bcgov/groundwater-levels/).

## Features

Core functions include:

- Import data downloaded from the [B.C. Data Catalogue](https://catalogue.data.gov.bc.ca/dataset/57c55f10-cf8e-40bb-aae0-2eff311f1685)
- Summarize and plot monthly groundwater levels
- Interpolate missing values
- Perform Mann-Kendall trend tests with prewhitening on multiple datasets using 
  methods implemented in the 
  [zyp](http://cran.r-project.org/web/packages/zyp/index.html) package.
- Plot trends in groundwater levels

## Installation

You can install the package directly from this repository. To do so, you will 
need the [devtools](https://github.com/hadley/devtools/) package:

```R
install.packages("devtools")
```

Next, install the `bcgroundwater` package using `devtools::install_github()`:

```R
library("devtools")
install_github("bcgov/bcgroundwater")
```

## Usage

See the package [vignette](https://htmlpreview.github.com/?https://github.com/bcgov/bcgroundwater/master/inst/doc/bcgroundwater.html) 
for a simple demonstration. Or, after installing the package, use:

```R
browseVignettes("bcgroundwater")
```

## Project Status

The package works as is for its intended purpose, which was to provide a set of 
functions required for the analysis underlying the 
[indicator](http://www.env.gov.bc.ca/soe/indicators/water/groundwater-levels.html).
We are actively updating the package at this time, you can check the 
[issues](https://github.com/bcgov/bcgroundwater/issues/) for things we are fixing or working on.

## Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/bcgroundwater/issues/).

## How to Contribute

If you would like to contribute to the package, please see our 
[CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## License

    Copyright 2015 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at 

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.


This repository is maintained by [Environmental Reporting BC](http://www2.gov.bc.ca/gov/content?id=FF80E0B985F245CEA62808414D78C41B). Click [here](https://github.com/bcgov/EnvReportBC-RepoList) for a complete list of our repositories on GitHub.