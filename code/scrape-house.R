library(tidyverse)
library(lubridate)
library(predictr)
library(glue)
library(here)
library(fs)

data_dir <- here("data", "house")
tnow <- format(floor_date(now(), "hour"), "%Y%m%d%H%M")
message(now())

# individual hourly -------------------------------------------------------

# find relevant markets with regex
hm <- open_markets() %>%
  filter(str_detect(market, "Which party will win [:upper:]{2}-\\d{2}\\?")) %>%
  select(mid, market) %>%
  distinct() %>%
  extract(market, "race", "([:upper:]{2}-\\d{2})", FALSE) %>%
  relocate(race, .before = mid) %>%
  arrange(race) %>%
  write_csv(path(data_dir, "house_markets.csv"))

# download 24 hour history from each
pb <- txtProgressBar(max = nrow(hm), style = 3)
for (i in seq_along(hm$mid)) {
  path <- path(data_dir, "states", glue("{hm$race[i]}_{tnow}.csv"))
  market_history(hm$mid[i], hourly = TRUE) %>%
    mutate(race = hm$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path)
  Sys.sleep(5); setTxtProgressBar(pb, i)
}

# top line ----------------------------------------------------------------

# Who will control the House after 2020?
party <- market_history(4365, hourly = TRUE, convert = FALSE) %>%
  write_csv(path(data_dir, "party", glue("house_party_{tnow}.csv")))

# House seats won by Democrats in 2020?
dems <- market_history(6669, hourly = TRUE, convert = FALSE) %>%
  write_csv(path(data_dir, "dems", glue("house_dems_{tnow}.csv")))
