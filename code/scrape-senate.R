# load packages
pacman::p_load(readr, dplyr, tidyr, lubridate, stringr, here, fs, glue)
pacman::p_load_gh("kiernann/predictr")

# note where and when
sen_dir <- dir_create(here("data", "senate"))
tnow <- format(floor_date(now(), "hour"), "%Y%m%d%H%M")
message(now())

# individual hourly -------------------------------------------------------

# find relevant markets with regex
sm <- open_markets() %>%
  filter(str_detect(market, "^Which .* \\w{2} Senate (race|special)\\?")) %>%
  select(mid, market) %>%
  distinct() %>%
  extract(market, "state", "([:upper:]{2})", FALSE) %>%
  mutate(
    special = str_detect(market, "special"),
    race = str_c(state, "-S", as.integer(special) + 2),
    .before = mid
  ) %>%
  select(-special, -state) %>%
  write_csv(path(sen_dir, "senate_markets.csv"))

# 'Which party will win the XX Senate race?'
dir_create(path(sen_dir, "states"))
for (i in seq_along(sm$mid)) {
  path <- path(sen_dir, "states", glue("{sm$race[i]}_{tnow}.csv"))
  market_history(sm$mid[i], hourly = TRUE) %>%
    mutate(race = sm$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path)
  Sys.sleep(5); message(sm$race[i])
}

# top line ----------------------------------------------------------------

# 'Who will control the Senate after 2020?'
d <- dir_create(path(sen_dir, "majority"))
p <- path(d, glue("sen_majority_{tnow}.csv"))
majority <- market_history(4366, hourly = TRUE)
write_csv(majority, p)

# 'Net change in Senate seats?'
d <- dir_create(path(sen_dir, "margin"))
p <- path(d, glue("sen_margin_{tnow}.csv"))
margin <- market_history(6670, hourly = TRUE)
write_csv(margin, p)

# 'Senate race with smallest MOV in 2020?'
d <- dir_create(path(sen_dir, "smallest"))
p <- path(d, glue("sen_small_{tnow}.csv"))
smallest <- market_history(6737, hourly = TRUE)
write_csv(smallest, p)
