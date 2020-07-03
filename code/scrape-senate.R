library(tidyverse)
library(lubridate)
library(predictr)
library(jsonlite)
library(httr)
library(rvest)
library(glue)
library(usa)

# individual hourly -------------------------------------------------------

# find relevant markets regex
api <- fromJSON("https://www.predictit.org/api/marketdata/all/")$markets
sen_rx <- "^Which .* [:upper:]{2} Senate (race|special)\\?"
sen_markets <- as_tibble(api) %>%
  filter(shortName %>% str_detect(sen_rx)) %>%
  select(id, market = shortName) %>%
  extract(market, "state", "([:upper:]{2})", FALSE) %>%
  mutate(special = str_detect(market, "special")) %>%
  relocate(state, .after = id)

write_csv(
  x = sen_markets,
  path = "data/senate/sen_markets.csv"
)

# Which party will win the XX Senate race?
pb <- txtProgressBar(max = nrow(sen_markets), style = 3)
for (i in seq_along(sen_markets$id)) {
  state <- sen_markets$state[i]
  class <- str_c("S", as.integer(sen_markets$special[i]) + 2)
  path <- glue("data/senate/states/{state}{class}_{today()}.csv")
  market_history(sen_markets$id[i], hourly = TRUE) %>%
    extract(market, "state", "([:upper:]{2})", FALSE) %>%
    mutate(special = str_detect(market, "special")) %>%
    relocate(state, .before = mid) %>%
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
