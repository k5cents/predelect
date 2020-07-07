library(tidyverse)
library(lubridate)
library(predictr)
library(glue)
library(here)
library(fs)

data_dir <- dir_create(here("data", "senate"))
tnow <- format(floor_date(now(), "hour"), "%Y%m%d%H%M")
message(now())

# individual hourly -------------------------------------------------------

# find relevant markets with regex
sm <- open_markets() %>%
  filter(str_detect(market, "^Which .* \\w{2} Senate (race|special)\\?")) %>%
  select(mid, market) %>%
  distinct() %>%
  extract(market, "state", "([:upper:]{2})", FALSE) %>%
  mutate(
    special = str_detect(market, "special"),
    race = str_c(state, "-S", as.integer(special) + 2),
    .before = mid
  ) %>%
  select(-special, -state) %>%
  write_csv(path(data_dir, "senate_markets.csv"))

# Which party will win the XX Senate race?
dir_create(path(data_dir, "states"))
pb <- txtProgressBar(max = nrow(sm), style = 3)
for (i in seq_along(sm$mid)) {
  path <- path(data_dir, "states", glue("{sm$race[i]}_{tnow}.csv"))
  market_history(sm$mid[i], hourly = TRUE) %>%
    mutate(race = sm$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path)
  Sys.sleep(5); setTxtProgressBar(pb, i)
}

# top line ----------------------------------------------------------------

# Who will control the Senate after 2020?
dir_create(path(data_dir, "majority"))
majority <- market_history(4366, hourly = TRUE) %>%
  write_csv(path(data_dir, "majority", glue("sen_majority_{tnow}.csv")))

# Net change in Senate seats?
dir_create(path(data_dir, "margin"))
margin <- market_history(6670, hourly = TRUE) %>%
  write_csv(path(data_dir, "margin", glue("sen_margin_{tnow}.csv")))

# Senate race with smallest MOV in 2020?
dir_create(path(data_dir, "smallest"))
smallest <- market_history(6737, hourly = TRUE) %>%
  write_csv(path(data_dir, "smallest", glue("sen_small_{tnow}.csv")))
