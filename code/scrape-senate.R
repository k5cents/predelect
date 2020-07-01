library(tidyverse)
library(lubridate)
library(predictr)
library(rvest)
library(glue)
library(usa)

# individual hourly -------------------------------------------------------

sen_rx <- "[:upper:]{2} Senate (race|special)\\?"
open_markets() %>%
  filter(str_detect(market, sen_rx)) %>%
  filter(str_starts(market, "Which")) %>%
  select(mid, market) %>%
  distinct() %>%
  extract(market, "state", "([:upper:]{2})", FALSE) %>%
  mutate(special = str_detect(market, "special")) %>%
  relocate(state, .before = mid) %>%
  arrange(state, special) -> sen_markets

write_csv(
  x = sen_markets,
  path = "data/senate/sen_markets.csv"
)

pb <- txtProgressBar(max = nrow(sen_markets), style = 3)
for (i in seq_along(sen_markets$mid)) {
  market_history(sen_markets$mid[[i]], hourly = TRUE) %>%
    extract(market, "state", "([:upper:]{2})", FALSE) %>%
    mutate(special = str_detect(market, "special")) %>%
    relocate(state, .before = mid) %>%
    select(-market) -> s
  day <- min(unique(as_date(s$time)))
  state <- unique(s$state)
  class <- str_c("S", as.integer(unique(s$special)) + 2)
  write_csv(s,  glue("data/senate/states/{state}{class}_{day}.csv"))
  Sys.sleep(5); setTxtProgressBar(pb, i)
}

# top line ----------------------------------------------------------------

majority <- market_history(4366, hourly = TRUE, convert = FALSE)
day <- min(unique(as_date(majority$time)))
write_csv(majority, glue("data/senate/majority/sen_majority_{day}.csv"))

margin <- market_history(6670, hourly = TRUE, convert = FALSE)
day <- min(unique(as_date(margin$time)))
write_csv(margin, glue("data/senate/margin/sen_margin_{day}.csv"))

smallest <- market_history(6737, hourly = TRUE, convert = FALSE)
day <- min(unique(as_date(smallest$time)))
write_csv(smallest, glue("data/senate/smallest/sen_small_{day}.csv"))
