library(patchwork)
library(tidyverse)
library(lubridate)
library(jsonlite)
library(predictr)
library(magick)
library(scales)
library(rvest)
library(here)

# read britannica data ====================================================

# read past data from britannica
b <- read_html(paste0(
  "https://www.britannica.com/topic/",
  "United-States-Presidential-Election-Results-1788863"
))

past_elect <- as.character(b) %>%
  # remove super numbers
  str_remove_all("<sup>\\d+</sup>") %>%
  read_html() %>%
  html_node("table") %>%
  html_table(fill = TRUE, header = TRUE) %>%
  slice(-c(1:12)) %>%
  as_tibble() %>%
  select(year = 1, party = 3, ec = 4, pop = 5, prop = 6) %>%
  mutate(party = str_replace(party, "^Democrat$", "Democratic")) %>%
  filter(party %in% c("Democratic", "Republican")) %>%
  type_convert(
    col_types = cols(
      year = col_integer(),
      party = col_character(),
      pop = col_number(),
      prop = col_double()
    )
  )

# ec winners by year
winner <- past_elect %>%
  filter(year >= 1932) %>%
  pivot_wider(
    id_cols = c(year, party),
    names_from = party,
    values_from = ec,
    names_repair = tolower
  ) %>%
  mutate(winner = democratic > republican)

# prop pv diff
pv_diff <- past_elect %>%
  filter(year >= 1932) %>%
  pivot_wider(
    id_cols = c(year, party),
    names_from = party,
    values_from = prop,
    names_repair = tolower
  ) %>%
  mutate(
    diff = (democratic - republican)/100,
    winner = winner$winner
  )

# scrape predictit api ====================================================

pv_price <- market_price(6663) # popular vote
ec_price <- market_price(6653) # electoral college
to_price <- market_price(6882) # voter turnout

# calculate election date =================================================

# we use date to show 26th amendment
# first tue after first mon in nov
election_dates <- as.Date(character())
for (y in seq(1932, 2016, by = 4)) {
  elec_day <- ymd(paste(y, 11, 1))
  week_day <- wday(elec_day)
  while (week_day != 2) {
    elec_day <- elec_day + 1
    week_day <- wday(elec_day)
  }
  election_dates <- append(
    election_dates,
    elec_day + 1
  )
}

# pop vote past -----------------------------------------------------------

pv_past <- pv_diff %>%
  mutate(date = election_dates) %>%
  ggplot(aes(x = date, y = diff)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_line(size = 1) +
  geom_point(aes(color = diff, shape = winner), size = 5) +
  scale_shape_manual(values = c(17, 16), guide = FALSE) +
  scale_color_gradient2(mid = "grey40", midpoint = 0, guide = FALSE) +
  scale_y_continuous(labels = scales::percent) +
  scale_x_date(date_breaks = "8 years", labels = lubridate::year) +
  coord_cartesian(ylim = c(-0.25, 0.25)) +
  theme(
    legend.position = "bottom",
    axis.title.x = element_text(
      hjust = 1,
      margin = margin(t = 10)
    )
  ) +
  labs(
    title = "Popular Vote Margin in Past Presidential Elections",
    subtitle = "Difference in major party popular vote percentage",
    caption = "Source: Britannica",
    x = "Election Date",
    y = "Difference"
  )

# pop vote price rect -----------------------------------------------------

# calculate rect shape w/ low and high values
pv_shape <- pv_price %>%
  select(contract, last) %>%
  mutate(
    date = as.Date("2020-11-03"),
    range = str_extract_all(contract, "[0-9]+(?:\\.[0-9]+)?"),
    low = as.double(map_chr(range, `[`, 1)),
    high = as.double(map_chr(range, `[`, 2)),
    middle = coalesce(low + (low - high), low, high)/100
  ) %>%
  select(contract, low, high, last) %>%
  mutate(across(2:3, `/`, 100)) %>%
  mutate(
    low = ifelse(str_starts(contract, "GOP"), low * -1, low),
    high = ifelse(str_starts(contract, "GOP"), high * -1, high)
  )

# add range ends
# these brackets are open ended
pv_shape$high[8:9] <- 0
pv_shape$high[1] <- pv_shape$low[1]
pv_shape$low[1] <- pv_shape$low[1] - 0.015
pv_shape$high[16] <- pv_shape$low[16]  + 0.015

# get group price
pv_shape %>%
  group_by(party = str_sub(contract, 1, 3)) %>%
  summarise(sum = sum(last))

pv_rect <- pv_shape %>%
  mutate(mid = low + ((high - low)/2)) %>%
  ggplot() +
  geom_rect(
    mapping = aes(
      fill = low,
      ymin = low,
      ymax = high,
      xmin = 0,
      xmax = last
    )
  ) +
  scale_fill_gradient2(mid = "grey40", midpoint = 0, guide = FALSE) +
  coord_cartesian(ylim = c(-0.25, 0.25)) +
  labs(
    title = "Predicted Difference",
    subtitle = "Contract prices estimate probability",
    caption = "Source: PredictIt/6663",
    x = "Contract Price",
    y = "Bracket (open ended)"
  ) +
  scale_x_continuous(labels = dollar) +
  scale_y_continuous(position = "right") +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.title.y = element_text(margin = margin(l = 20)),
    axis.title.x = element_text(
      hjust = 1,
      margin = margin(t = 10)
    )
  )

# combine plots
pv_both <- pv_past + pv_rect +
  plot_layout(widths = c(5, 2))

# save single plot
ggsave(
  filename = here("plots", "popvote.png"),
  plot = pv_both,
  height = 5,
  width = 10,
  dpi = "retina"
)

# repeat for electoral college ============================================

ec_diff <- past_elect %>%
  filter(year >= 1932) %>%
  pivot_wider(
    id_cols = c(year, party),
    names_from = party,
    values_from = ec,
    names_repair = tolower
  ) %>%
  mutate(
    diff = (democratic - republican),
    winner = winner$winner
  )

# college past ------------------------------------------------------------

ec_past <- ec_diff %>%
  mutate(date = election_dates) %>%
  ggplot(aes(x = date, y = diff)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_line(size = 1) +
  geom_point(aes(color = diff, shape = winner), size = 5) +
  scale_shape_manual(values = c(17, 16), guide = FALSE) +
  scale_color_gradient2(mid = "grey40", midpoint = 0, guide = FALSE) +
  scale_y_continuous(breaks = seq(-540, 540, by = 120)) +
  scale_x_date(date_breaks = "8 years", labels = lubridate::year) +
  coord_cartesian(ylim = c(-540, 540)) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.title.x = element_text(
      hjust = 1,
      margin = margin(t = 10)
    )
  ) +
  labs(
    title = "Electoral College Margin in Past Presidential Elections",
    subtitle = "Difference in major party electoral college votes",
    caption = "Source: Britannica.com",
    x = "Election Date",
    y = "Difference"
  )

# college rect ------------------------------------------------------------

ec_shape <- ec_price %>%
  select(contract, last) %>%
  mutate(
    date = as.Date("2020-11-03"),
    range = str_extract_all(contract, "[0-9]+(?:\\.[0-9]+)?"),
    low = as.double(map_chr(range, `[`, 1)),
    high = as.double(map_chr(range, `[`, 2)) + 1,
    middle = coalesce(low + (low - high), low, high)
  ) %>%
  select(contract, low, high, last) %>%
  mutate(
    low = ifelse(str_starts(contract, "GOP"), low * -1, low),
    high = ifelse(str_starts(contract, "GOP"), high * -1, high)
  )

ec_shape$high[1] <- ec_shape$low[1]
ec_shape$low[1] <- ec_shape$low[1] - 80
ec_shape$high[16] <- ec_shape$low[16]  + 80
ec_shape$low[8:9] <- 0.5

ec_rect <- ec_shape %>%
  mutate(mid = low + ((high - low)/2)) %>%
  ggplot() +
  geom_rect(
    mapping = aes(
      fill = low,
      ymin = low,
      ymax = high,
      xmin = 0,
      xmax = last
    )
  ) +
  scale_fill_gradient2(mid = "grey40", midpoint = 0, guide = FALSE) +
  coord_cartesian(ylim = c(-540, 540)) +
  labs(
    title = "Predicted Difference",
    subtitle = "Contract prices estimate probability",
    caption = "Source: PredictIt/6653",
    x = "Contract Price",
    y = "Bracket (open ended)"
  ) +
  scale_x_continuous(labels = dollar) +
  scale_y_continuous(position = "right") +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.title.y = element_text(margin = margin(l = 20)),
    axis.title.x = element_text(
      hjust = 1,
      margin = margin(t = 10)
    )
  )

# college save ------------------------------------------------------------

ec_both <- ec_past + ec_rect +
  plot_layout(widths = c(5, 2))

ggsave(
  filename = here("plots", "electcol.png"),
  plot = ec_both,
  height = 5,
  width = 10,
  dpi = "retina"
)

# repeat for turnout ======================================================

# read from census bureau
pop_est <- read_csv(file = "https://bit.ly/3mKlL6I")
# find nationwide total
pop <- pop_est$POPEST18PLUS2019[pop_est$NAME == "United States"]/1e6

# read past turnout from wikipedia
to_wiki <- read_html("https://w.wiki/dAj")
to_hist <- to_wiki %>%
  html_node(".wikitable") %>%
  html_table() %>%
  as_tibble() %>%
  set_names(c("election", "vap", "turnout", "prop")) %>%
  filter(vap != "No data") %>%
  type_convert(
    na = "",
    col_types = cols(
      prop = col_number()
    )
  )

# turnout labels ----------------------------------------------------------

# shorten contract names
to_labs <- to_price$contract %>%
  str_replace("Fewer than ", "< ") %>%
  str_replace("(160) mil. or more", "> \\1") %>%
  str_remove_all("[a-z]") %>%
  str_remove_all("\\.") %>%
  str_squish()

# reassign as ordered factor
to_price$contract <- factor(
  x = to_price$contract,
  labels = str_replace_all(
    string = to_labs,
    pattern = "\\d+",
    replacement = function(n, p = 255.2) {
      scales::percent(as.numeric(n)/p, 0.1)
    }
  )
)

# plot past turnout -------------------------------------------------------

# plot turnout history
to_past <- to_hist %>%
  filter(election >= 1932) %>%
  mutate(
    date = election_dates,
    prop = prop/100
  ) %>%
  ggplot(aes(date, prop)) +
  geom_vline(xintercept = as.Date("1971-07-01"), linetype = 2) +
  geom_line(size = 1) +
  geom_point(aes(color = prop), size = 5) +
  scale_size_continuous(labels = percent, range = c(1, 10), guide = FALSE) +
  scale_color_viridis_c(guide = FALSE, end = 0.75) +
  scale_y_continuous(labels = scales::percent) +
  scale_x_date(date_breaks = "8 years", labels = lubridate::year) +
  coord_cartesian(ylim = c(0.475, 0.65)) +
  geom_label(
    mapping = aes(
      x = as.Date("1984-01-01"),
      y = 0.5875,
      label = "26A lowers voting age"
    )
  ) +
  theme(
    legend.position = "bottom",
    axis.title.x = element_text(
      hjust = 1,
      margin = margin(t = 10)
    )
  ) +
  labs(
    title = "Voter Turnout in Past Presidential Elections",
    subtitle = "Percentage of voting age population",
    caption = "Source: US Census Bureau",
    x = "Election Date",
    y = "Turnout"
  )

# turnout rect ------------------------------------------------------------

# calculate rect shape
to_shape <- to_price %>%
  mutate(
    date = as.Date("2020-11-03"),
    range = str_extract_all(contract, "[0-9]{2}(?:\\.[0-9]+)?"),
    low = as.double(map_chr(range, `[`, 1)),
    high = as.double(map_chr(range, `[`, 2)),
    middle = coalesce(low + (low - high), low, high)/100
  ) %>%
  select(contract, low, high, last)

to_shape$high[1] <- to_shape$low[1]
to_shape$low[1] <- to_shape$low[1] - 1.2
to_shape$high[12] <- to_shape$low[12]  + 1.2

to_rect <- to_shape %>%
  mutate(across(2:3, `/`, 100)) %>%
  mutate(mid = low + ((high - low)/2)) %>%
  ggplot() +
  geom_rect(
    mapping = aes(
      fill = high,
      ymin = low,
      ymax = high,
      xmin = 0,
      xmax = last
    )
  ) +
  scale_fill_viridis_c(guide = FALSE, end = 0.75) +
  coord_cartesian(ylim = c(0.475, 0.65)) +
  labs(
    title = "Predicted Turnout",
    subtitle = "Contract prices estimate probability",
    caption = "Source: PredictIt/6882",
    x = "Contract Price",
    y = "Bracket (open ended)"
  ) +
  scale_x_continuous(labels = dollar) +
  scale_y_continuous(position = "right") +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.title.y = element_text(margin = margin(l = 20)),
    axis.title.x = element_text(
      hjust = 1,
      margin = margin(t = 10)
    )
  )

# save turnout ------------------------------------------------------------

to_both <- to_past + to_rect +
  plot_layout(widths = c(5, 2))

ggsave(
  filename = here("plots", "turnout.png"),
  plot = to_both,
  height = 5,
  width = 10,
  dpi = "retina"
)

# combine images ==========================================================

electcol <- image_read(here("plots", "electcol.png"))
popvote  <- image_read(here("plots", "popvote.png"))
turnout  <- image_read(here("plots", "turnout.png"))
imgs <- c(electcol, popvote, turnout)

image_write(
  # concatenate them top-to-bottom
  image = image_append(imgs, stack = TRUE),
  path = here("plots", "past-future.png"),
  format = "png",
  density = 320
)
