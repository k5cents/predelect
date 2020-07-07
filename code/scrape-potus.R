library(tidyverse)
library(lubridate)
library(predictr)
library(glue)
library(here)
library(fs)

data_dir <- here("data", "potus")
tnow <- format(floor_date(now(), "hour"), "%Y%m%d%H%M")
message(now())

# individual hourly -------------------------------------------------------

# find relevant markets with regex
pm <- open_markets() %>%
  filter(str_detect(market, "Which party will win \\w{2}(.*)? (in )?2020")) %>%
  select(mid, market) %>%
  distinct() %>%
  extract(market, "race", "([:upper:]{2}(?:-\\d+)?)", FALSE) %>%
  mutate(race = str_replace(race, "0(?=\\d)", "P")) %>%
  mutate(code = if_else(str_detect(race, "-"), NA_character_, "P0")) %>%
  unite(race, race, code, sep = "-", na.rm = TRUE) %>%
  relocate(race, .before = mid) %>%
  arrange(race) %>%
  write_csv(path(data_dir, "ec_markets.csv"))

# Which party will win XX in 2020?
pb <- txtProgressBar(max = nrow(pm), style = 3)
for (i in seq_along(pm$mid)) {
  path <- path(data_dir, "states", glue("{pm$race[i]}_{tnow}.csv"))
  market_history(pm$mid[[i]], hourly = TRUE) %>%
    mutate(race = pm$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path)
  Sys.sleep(5); setTxtProgressBar(pb, i)
}

# top line ----------------------------------------------------------------

# Which party wins the Presidency in 2020?
party <- market_history(2721, hourly = TRUE, convert = FALSE) %>%
  write_csv(path(data_dir, "party", glue("potus_party_{tnow}.csv")))

# Electoral College margin of victory?
margin <- market_history(6653, hourly = TRUE, convert = FALSE) %>%
  write_csv(path(data_dir, "margin", glue("potus_ecv_{tnow}.csv")))

# Popular Vote margin of victory?
popvote <- market_history(6663, hourly = TRUE, convert = FALSE) %>%
  write_csv(path(data_dir, "popvote", glue("potus_popvote_{tnow}.csv")))
