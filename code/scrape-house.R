library(tidyverse)
library(lubridate)
library(predictr)
library(glue)
library(here)
library(fs)

house_dir <- dir_create(here("data", "house"))
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
  write_csv(path(house_dir, "house_markets.csv"))

# download 24 hour history from each
dir_create(path(house_dir, "states"))
pb <- txtProgressBar(max = nrow(hm), style = 3)
for (i in seq_along(hm$mid)) {
  path <- path(house_dir, "states", glue("{hm$race[i]}_{tnow}.csv"))
  market_history(hm$mid[i], hourly = TRUE) %>%
    mutate(race = hm$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path)
  Sys.sleep(5); setTxtProgressBar(pb, i)
}

# top line ----------------------------------------------------------------

# Who will control the House after 2020?
d <- dir_create(path(house_dir, "party"))
p <- path(d, glue("house_party_{tnow}.csv"))
party <- market_history(4365, hourly = TRUE, convert = FALSE)
write_csv(party, p)

# House seats won by Democrats in 2020?
d <- dir_create(path(house_dir, "dems"))
p <- path(d, glue("house_dems_{tnow}.csv"))
dems <- market_history(6669, hourly = TRUE, convert = FALSE)
write_csv(dems, p)
