library(tidyverse)
library(lubridate)
library(predictr)
library(rvest)
library(glue)
library(usa)

# individual hourly -------------------------------------------------------

# find relevant markets with regex
ec_rx <- "Which party will win \\w{2}(-\\d+)? (in )?2020"
ec_markets <- open_markets() %>%
  filter(str_detect(market, ec_rx)) %>%
  select(mid, market) %>%
  distinct() %>%
  extract(market, "race", "([:upper:]{2}(?:-\\d+)?)", FALSE) %>%
  mutate(race = str_replace(race, "0(?=\\d)", "P")) %>%
  mutate(code = if_else(str_detect(race, "-"), NA_character_, "P0")) %>%
  unite(race, race, code, sep = "-", na.rm = TRUE) %>%
  relocate(race, .before = mid) %>%
  arrange(race) %>%
  write_csv("data/potus/ec_markets.csv")

pb <- txtProgressBar(max = nrow(ec_markets), style = 3)
for (i in seq_along(ec_markets$mid)) {
  path <- glue("data/potus/states/{ec_markets$race[i]}_{today()}.csv")
  market_history(ec_markets$mid[[i]], hourly = TRUE) %>%
    mutate(race = ec_markets$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path)
  Sys.sleep(5); setTxtProgressBar(pb, i)
}

# top line ----------------------------------------------------------------

# Which party wins the Presidency in 2020?
party <- market_history(2721, hourly = TRUE, convert = FALSE) %>%
  write_csv(glue("data/potus/party/potus_party_{today()}.csv"))

# Electoral College margin of victory?
margin <- market_history(6653, hourly = TRUE, convert = FALSE) %>%
  write_csv(glue("data/potus/margin/potus_ecv_{today()}.csv"))

# Popular Vote margin of victory?
popvote <- market_history(6663, hourly = TRUE, convert = FALSE) %>%
  write_csv(glue("data/potus/popvote/sen_popvote_{today()}.csv"))



