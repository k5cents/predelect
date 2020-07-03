library(tidyverse)
library(lubridate)
library(predictr)
library(jsonlite)
library(httr)
library(rvest)
library(glue)
library(usa)

# individual hourly -------------------------------------------------------

# find relevant markets with regex
sen_rx <- "^Which .* [:upper:]{2} Senate (race|special)\\?"
sen_markets <- all_markets %>%
  filter(market %>% str_detect(sen_rx)) %>%
  select(mid, market) %>%
  extract(market, "state", "([:upper:]{2})", FALSE) %>%
  mutate(
    special = str_detect(market, "special"),
    race = str_c(state, "-S", as.integer(special) + 2),
    .before = mid
  ) %>%
  select(-special, -state) %>%
  write_csv("data/senate/sen_markets.csv")

# Which party will win the XX Senate race?
pb <- txtProgressBar(max = nrow(sen_markets), style = 3)
for (i in seq_along(sen_markets$id)) {
  path <- glue("data/senate/states/{sen_markets$race[i]}_{today()}.csv")
  market_history(sen_markets$mid[i], hourly = TRUE) %>%
    mutate(race = sen_markets$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path)
  Sys.sleep(5); setTxtProgressBar(pb, i)
}

# top line ----------------------------------------------------------------

# Who will control the Senate after 2020?
majority <- market_history(4366, hourly = TRUE) %>%
  write_csv(glue("data/senate/majority/sen_majority_{today()}.csv"))

# Net change in Senate seats?
margin <- market_history(6670, hourly = TRUE) %>%
  write_csv(glue("data/senate/margin/sen_margin_{today()}.csv"))

# Senate race with smallest MOV in 2020?
smallest <- market_history(6737, hourly = TRUE) %>%
  write_csv(glue("data/senate/smallest/sen_small_{today()}.csv"))
