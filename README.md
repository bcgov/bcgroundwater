# bcgroundwater

An [R](http://www.r-project.org) package to facilitate analysis and 
visualization of groundwater data from the British Columbia groundwater 
[observation well network](http://www.env.gov.bc.ca/wsd/data_searches/obswell/index.html).

This package was developed by [Environmental Reporting BC](http://www.env.gov.bc.ca/soe/) 
for the analysis of trends in groundwater levels. You can view the results of the 
analysis [here](http://www.env.gov.bc.ca/soe/indicators/water/wells/index.html?WT.ac=GH_wells).
The code for the actual analysis is available in its own [GitHub repository](https://github.com/bcgov/gwl_2013).

## Features

Core functions include:
- Import data (csv files) downloaded from the [Observation Well Network](http://www.env.gov.bc.ca/wsd/data_searches/obswell/map/obsWells.html)
- Summarize and plot monthly groundwater levels
- Interpolate missing values
- Perform Mann-Kendall trend tests with prewhitening on multiple datasets using 
  methods implemented in the 
  [zyp](http://cran.r-project.org/web/packages/zyp/index.html) package.
- Plot trends

## Usage

See the package [vignette](demo/bcgroundwater.md) for a simple demonstration.

After installing the package, use:

```R
browseVignettes("bcgroundwater")
```

## Requirements

## Installation

To install the package, you will need the `devtools` package if you don't 
already have it installed:

```R
install.packages("devtools")
```

Next, you can install the `bcgroundwater` package using `devtools::install_github()`;

```R
library("devtools")
install_github("bcgov/bcgroundwater")
```

## Project Status

The package works as is for its intended purpose, which was to provide a set of 
functions required for the analysis underlying the 
[indicator](http://www.env.gov.bc.ca/soe/indicators/water/wells/index.html?WT.ac=GH_wells).
We are not actively developing it at this time, but you can check the 
[issues](https://github.com/bcgov/bcgroundwater/isuues/) for things we would 
like to fix or work on.

## Goals/Roadmap

## Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/bcgroundwater/isuues/).

## How to Contribute

If you would like to contribute to the package, please see our 
[CONTRIBUTING](CONTRIBUTING.md) guidelines.

## License

Apache 2.0. See our [license](LICENSE) for more details.
