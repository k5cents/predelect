library(cronR)
library(here)
library(fs)

# clear all current crons
cron_clear(ask = FALSE)

cmd = cron_rscript(
  rscript = "~/Code/bet-2020/code/scrape_markets.R",
  # capture logging messages
  rscript_log = "~/Code/bet-2020/cron/scrape_markets.log",
  # bin found on pi and desktop
  cmd = "/usr/lib/R/bin/Rscript",
  log_append = TRUE
)

# create the schedule
cron_add(
  command = cmd,
  frequency = "daily",
  at = "11PM",
  id = "scrape-markets",
  tags = "bet2020",
  description = "Scrape PredicIt hourly markets",
)

# save to crontab
cron_save(
  file = "~/Code/bet-2020/cron/scrape_markets.cron",
  overwrite = TRUE
)
