library(tidyverse)
library(lubridate)
library(predictr)
library(rvest)
library(glue)
library(usa)

# individual hourly -------------------------------------------------------

ec_rx <- "Which party will win \\w{2}(-\\d+)? (in )?2020"
open_markets() %>%
  filter(str_detect(market, ec_rx)) %>%
  select(mid, market) %>%
  distinct() %>%
  extract(market, "state", "([:upper:]{2})", FALSE) %>%
  relocate(state, .before = mid) %>%
  arrange(state) -> ec_markets

write_csv(
  x = ec_markets,
  path = "data/potus/ec_markets.csv"
)

pb <- txtProgressBar(max = nrow(ec_markets), style = 3)
for (i in seq_along(ec_markets$mid)) {
  market_history(ec_markets$mid[[i]], hourly = TRUE) %>%
    extract(market, "state", "([:upper:]{2}(?:-\\d{2})?)", FALSE) %>%
    relocate(state, .before = mid) %>%
    select(-market) -> s
  day <- min(unique(as_date(s$time)))
  state <- str_remove_all(unique(s$state), "[:punct:]")
  write_csv(s,  glue("data/potus/states/{state}_{day}.csv"))
  Sys.sleep(5); setTxtProgressBar(pb, i)
}

# top line ----------------------------------------------------------------

party <- market_history(2721, hourly = TRUE, convert = FALSE)
day <- min(unique(as_date(party$time)))
write_csv(party, glue("data/potus/party/potus_party_{day}.csv"))

margin <- market_history(6653, hourly = TRUE, convert = FALSE)
day <- min(unique(as_date(margin$time)))
write_csv(margin, glue("data/potus/margin/potus_ecv_{day}.csv"))

popvote <- market_history(6663, hourly = TRUE, convert = FALSE)
day <- min(unique(as_date(popvote$time)))
write_csv(popvote, glue("data/potus/popvote/sen_popvote_{day}.csv"))



