# https://github.com/kiernann/bet-2020
# Scheduled for 23:00 daily via cron
# Daily data appended to existing files

# -------------------------------------------------------------------------

# load packages
pacman::p_load(readr, dplyr, tidyr, stringr, lubridate, here, fs, glue)
pacman::p_load_gh("kiernann/predictr")

# note start time in log
message(glue("# Begin:    {date()} -----------------------"))
Sys.sleep(60)
# get all markets once
all_markets <- distinct(select(open_markets(), 1:3))

# create and define path to data directory
data_dir <- dir_create(path_expand("~/Code/bet-2020/data/"))
race_dir <- dir_create(path(data_dir, "races"))

# house markets -----------------------------------------------------------

hm <- all_markets %>%
  # find relevant state markets with regex
  filter(str_detect(market, "Which party will win [:upper:]{2}-\\d{2}\\?")) %>%
  # create unique race codes
  extract(market, "race", "([:upper:]{2}-\\d{2})", FALSE) %>%
  arrange(race) %>%
  # overwrite file
  write_csv(path(data_dir, "house_markets.csv"))

# 'Which party will win XX-DD?'
for (i in seq_along(hm$mid)) {
  path <- path(race_dir, glue("{hm$race[i]}.csv"))
  # get the last 24 hours of data
  market_history(hm$mid[i], hourly = TRUE) %>%
    # add unique race code
    mutate(race = hm$race[i], .before = mid) %>%
    select(-market) %>%
    # append to existing file
    write_csv(path, append = TRUE)
  # wait a random time
  Sys.sleep(runif(1, 20, 30))
}

# 'Who will control the House after 2020?'
write_csv(
  # scrape single markets on house data
  x = market_history(4365, hourly = TRUE),
  path = path(data_dir, "house_party.csv"),
  append = TRUE
)

# 'House seats won by Democrats in 2020?'
write_csv(
  x = market_history(6669, hourly = TRUE),
  path = path(data_dir, "house_dems.csv"),
  append = TRUE
)

# log how many files were saved and when
message(paste(nrow(hm) + 2, "house markets complete", format(now(), "%H:%M")))

# senate ------------------------------------------------------------------

sm <- all_markets %>%
  filter(str_detect(market, "^Which .* \\w{2} Senate (race|special)\\?")) %>%
  extract(market, "state", "([:upper:]{2})", FALSE) %>%
  mutate(
    special = str_detect(market, "special"),
    race = str_c(state, "-S", as.integer(special) + 2)
  ) %>%
  select(-special, -state) %>%
  write_csv(path(data_dir, "senate_markets.csv"))

# 'Which party will win the XX Senate race?'
for (i in seq_along(sm$mid)) {
  path <- path(race_dir, glue("{sm$race[i]}.csv"))
  market_history(sm$mid[i], hourly = TRUE) %>%
    mutate(race = sm$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path, append = TRUE)
  Sys.sleep(runif(1, 20, 30))
}

# 'Who will control the Senate after 2020?'
write_csv(
  x = market_history(4366, hourly = TRUE),
  path = path(data_dir, "sen_majority.csv"),
  append = TRUE
)

# 'Net change in Senate seats?'
write_csv(
  x = market_history(6670, hourly = TRUE),
  path = path(data_dir, "sen_margin.csv"),
  append = TRUE
)

# 'Senate race with smallest MOV in 2020?'
write_csv(
  x = market_history(6737, hourly = TRUE),
  path = path(data_dir, "sen_smallest.csv"),
  append = TRUE
)

message(paste(nrow(sm) + 3, "senate markets complete", format(now(), "%H:%M")))

# presidential ------------------------------------------------------------

pm <- all_markets %>%
  filter(str_detect(market, "Which party will win \\w{2}(.*)? (in )?2020")) %>%
  extract(market, "race", "([:upper:]{2}(?:-\\d+)?)", FALSE) %>%
  mutate(race = str_replace(race, "0(?=\\d)", "P")) %>%
  mutate(code = if_else(str_detect(race, "-"), NA_character_, "P0")) %>%
  unite(race, race, code, sep = "-", na.rm = TRUE) %>%
  arrange(race) %>%
  write_csv(path(data_dir, "potus_markets.csv"))

# 'Which party will win XX in 2020?'
for (i in seq_along(pm$mid)) {
  path <- path(race_dir, glue("{pm$race[i]}.csv"))
  market_history(pm$mid[[i]], hourly = TRUE) %>%
    mutate(race = pm$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path)
  Sys.sleep(runif(1, 20, 30))
}

# 'Which party wins the Presidency in 2020?'
write_csv(
  x = market_history(2721, hourly = TRUE),
  path = path(data_dir, "potus_party.csv"),
  append = TRUE
)

# 'Electoral College margin of victory?'
write_csv(
  x = market_history(6653, hourly = TRUE),
  path = path(data_dir, "potus_college.csv"),
  append = TRUE
)

# 'Popular Vote margin of victory?'
write_csv(
  x = market_history(6663, hourly = TRUE),
  path = path(data_dir, "potus_popvote.csv"),
  append = TRUE
)
message(paste(nrow(pm) + 3, "potus markets complete", format(now(), "%H:%M")))

# -------------------------------------------------------------------------

# note end time in log
message(glue("# Complete: {date()} -----------------------"))
