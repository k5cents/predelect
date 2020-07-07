library(cronR)
library(here)
library(fs)

cron_add(
  command = cron_rscript(
    rscript = here("code", "scrape-house.R"),
    rscript_log = here("cron", "scrape-house.log")
  ),
  frequency = "daily",
  at = "12AM",
  id = "scrape-house",
  tags = "bet",
  description = "Scrape PredicIt House markets",
)

cron_add(
  command = cron_rscript(
    rscript = here("code", "scrape-senate.R"),
    rscript_log = here("cron", "scrape-senate.log")
  ),
  frequency = "daily",
  at = "12AM",
  id = "scrape-senate",
  tags = "bet",
  description = "Scrape PredicIt Senate markets",
)

cron_add(
  command = cron_rscript(
    rscript = here("code", "scrape-potus.R"),
    rscript_log = here("cron", "scrape-potus.log")
  ),
  frequency = "daily",
  at = "12AM",
  id = "scrape-potus",
  tags = "bet",
  description = "Scrape PredicIt Presidential markets",
)

# save all to crontab
cron_save(
  file = here("cron", "bet-2020.cron"),
  overwrite = TRUE
)
