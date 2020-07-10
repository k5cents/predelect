# note where and when
house_dir <- dir_create(here("data", "house"))

# individual hourly -------------------------------------------------------

# find relevant markets with regex
hm <- all_markets %>%
  filter(str_detect(market, "Which party will win [:upper:]{2}-\\d{2}\\?")) %>%
  select(mid, market) %>%
  distinct() %>%
  extract(market, "race", "([:upper:]{2}-\\d{2})", FALSE) %>%
  relocate(race, .before = mid) %>%
  arrange(race) %>%
  write_csv(path(house_dir, "house_markets.csv"))

# 'Which party will win XX-DD?'
dir_create(path(house_dir, "states"))
for (i in seq_along(hm$mid)) {
  path <- path(house_dir, "states", glue("{hm$race[i]}_{tnow}.csv"))
  market_history(hm$mid[i], hourly = TRUE) %>%
    mutate(race = hm$race[i], .before = mid) %>%
    select(-market) %>%
    write_csv(path)
  Sys.sleep(30)
}

# top line ----------------------------------------------------------------

# 'Who will control the House after 2020?'
d <- dir_create(path(house_dir, "party"))
p <- path(d, glue("house_party_{tnow}.csv"))
party <- market_history(4365, hourly = TRUE)
write_csv(party, p)

# 'House seats won by Democrats in 2020?'
d <- dir_create(path(house_dir, "dems"))
p <- path(d, glue("house_dems_{tnow}.csv"))
dems <- market_history(6669, hourly = TRUE)
write_csv(dems, p)

# -------------------------------------------------------------------------

message(paste(now(), "house success"))
