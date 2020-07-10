# load packages
pacman::p_load(readr, dplyr, tidyr, lubridate, stringr, here, fs, glue)
pacman::p_load_gh("kiernann/predictr")

# get all markets once
all_markets <- open_markets()

# note the run hour
tnow <- date()

# run all the scripts
message(x <- paste("#", tnow, "------------------------------"))
source(here("code", "scrape-house.R"))
source(here("code", "scrape-senate.R"))
source(here("code", "scrape-potus.R"))
message(rep("#", nchar(x)))
