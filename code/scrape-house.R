library(tidyverse)
library(lubridate)
library(predictr)
library(rvest)
library(glue)
library(usa)

# individual hourly -------------------------------------------------------

house_rx <- "Which party will win [:upper:]{2}-\\d{2}\\?"
open_markets() %>%
  filter(str_detect(market, house_rx)) %>%
  select(mid, market) %>%
  distinct() %>%
  extract(market, "race", "([:upper:]{2}-\\d{2})", FALSE) %>%
  relocate(race, .before = mid) %>%
  arrange(race) -> house_markets

write_csv(
  x = house_markets,
  path = "data/house/house_markets.csv"
)

pb <- txtProgressBar(max = nrow(house_markets), style = 3)
for (i in seq_along(house_markets$mid)) {
  market_history(house_markets$mid[[i]], hourly = TRUE) %>%
    extract(market, "race", "([:upper:]{2}-\\d{2})", FALSE) %>%
    relocate(race, .before = mid) %>%
    select(-market) -> s
  day <- min(unique(as_date(s$time)))
  race <- str_remove_all(unique(s$race), "[:punct:]")
  write_csv(s,  glue("data/house/states/{race}_{day}.csv"))
  Sys.sleep(5); setTxtProgressBar(pb, i)
}

# top line ----------------------------------------------------------------

party <- market_history(4365, hourly = TRUE, convert = FALSE)
day <- min(unique(as_date(party$time)))
write_csv(party, glue("data/house/party/house_party_{day}.csv"))

dems <- market_history(6669, hourly = TRUE, convert = FALSE)
day <- min(unique(as_date(dems$time)))
write_csv(dems, glue("data/house/dems/house_ecv_{day}.csv"))
