# the _targets.R file defines the entire data pipeline for the `targets` package, specifying the steps (targets), their inputs, and execution order
# NOTE: while this file can be sourced directly to load and define the pipeline structure in your R session, the pipeline is executed and managed using `targets`` commands like `targets::tar_make()`

# import targets library
library(targets)

# define packages needed to execute pipeline; package version included for reference
tar_option_set(
  packages = c(
    'tidyverse',            # 2.0.0 
    'dataRetrieval',        # 2.7.2
    'httr2',                # 1.2.1
    'tools',                # 4.5.1
    'sf',                   # 1.0.21
    'xml2',                 # 1.4.0
    'leaflet',              # 2.2.3
    'RColorBrewer',         # 1.1.3
    'htmlwidgets',          # 1.6.4
    'rnaturalearth',        # 1.1.0
    'withr'                 # 3.0.2
  )
)

# define inputs to pipeline
# USGS gage sites by ID
harvey_sites <- c('USGS-08211520','USGS-08188500','USGS-08030500','USGS-08162000','USGS-08014800')
# start date for retrieving stage data
start_date <- '2017-08-25'
# end date for retrieving stage data
end_date <- '2017-09-12'
# Hurricane Harvey inputs to feed into National Hurricane Center (NHC) query
ocean <- 'al'
storm_num <- '09'
year <- '2017'

# import workflow phase files containing ordered list of steps to execute each workflow phase
source('01_fetch.R')        # individual steps in fetch phase are defined (in order) in the list `p1` defined in `01_fetch.R`
source('02_process.R')      # individual steps in process phase are defined (in order) in the list `p2` defined in `02_process.R`
source('03_visualize.R')    # individual steps in visualize phase are defined (in order) in the list `p3` defined in `03_visualize.R`

# the final object must be a list of targets: this combines all phased steps in order
list(p1,p2,p3)
