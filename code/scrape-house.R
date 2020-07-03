library(tidyverse)
library(lubridate)
library(predictr)
library(rvest)
library(glue)
library(usa)

# individual hourly -------------------------------------------------------

# find relevant markets with regex
house_rx <- "Which party will win [:upper:]{2}-\\d{2}\\?"
house_markets <- open_markets() %>%
  filter(str_detect(market, house_rx)) %>%
  select(mid, market) %>%
  distinct() %>%
  extract(market, "race", "([:upper:]{2}-\\d{2})", FALSE) %>%
  relocate(race, .before = mid) %>%
  arrange(race) %>%
  write_csv("data/house/house_markets.csv")

pb <- txtProgressBar(max = nrow(house_markets), style = 3)
for (i in seq_along(house_markets$mid)) {
  path <- glue("data/house/states/{house_markets$race[i]}_{today()}.csv")
  market_history(house_markets$mid[[i]], hourly = TRUE) %>%
    mutate(race = house_markets$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path)
  Sys.sleep(5); setTxtProgressBar(pb, i)
}

# top line ----------------------------------------------------------------

# Who will control the House after 2020?
party <- market_history(4365, hourly = TRUE, convert = FALSE) %>%
  write_csv(glue("data/house/party/house_party_{today()}.csv"))

# House seats won by Democrats in 2020?
dems <- market_history(6669, hourly = TRUE, convert = FALSE) %>%
  write_csv(glue("data/house/dems/house_ecv_{today()}.csv"))
