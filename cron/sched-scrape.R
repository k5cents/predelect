library(cronR)
library(here)
library(fs)

cmd = cron_rscript(
  rscript = here("code", "run-scrape.R"),
  rscript_log = here("cron", "bet-2020.log"),
  cmd = "/usr/lib/R/bin/Rscript",
  log_append = TRUE
)

cron_add(
  command = cmd,
  frequency = "daily",
  at = "12AM",
  id = "bet-2020",
  tags = "scrape",
  description = "Scrape PredicIt hourly markets",
)

# save all to crontab
cron_save(
  file = here("cron", "bet-2020.cron"),
  overwrite = TRUE
)
