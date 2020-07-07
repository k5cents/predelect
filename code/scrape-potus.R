library(tidyverse)
library(lubridate)
library(predictr)
library(glue)
library(here)
library(fs)

prez_dir <- dir_create(here("data", "potus"))
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
  write_csv(path(prez_dir, "ec_markets.csv"))

# Which party will win XX in 2020?
dir_create(path(prez_dir, "states"))
pb <- txtProgressBar(max = nrow(pm), style = 3)
for (i in seq_along(pm$mid)) {
  path <- path(prez_dir, "states", glue("{pm$race[i]}_{tnow}.csv"))
  market_history(pm$mid[[i]], hourly = TRUE) %>%
    mutate(race = pm$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path)
  Sys.sleep(5); setTxtProgressBar(pb, i)
}

# top line ----------------------------------------------------------------

# Which party wins the Presidency in 2020?
d <- dir_create(path(prez_dir, "party"))
p <- path(d, glue("potus_party_{tnow}.csv"))
party <- market_history(2721, hourly = TRUE, convert = FALSE)
write_csv(party, p)

# Electoral College margin of victory?
d <- dir_create(path(prez_dir, "margin"))
p <- path(d, glue("potus_ecv_{tnow}.csv"))
margin <- market_history(6653, hourly = TRUE, convert = FALSE)
write_csv(margin, p)

# Popular Vote margin of victory?
d <- dir_create(path(prez_dir, "popvote"))
p <- path(d, glue("potus_popvote_{tnow}.csv"))
popvote <- market_history(6663, hourly = TRUE, convert = FALSE)
write_csv(popvote, p)
