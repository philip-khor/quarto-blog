library(arrow)
library(httr2)

request("https://archive-api.open-meteo.com") |> 
  req_url_path_append("v1") |> 
  req_url_path_append("archive") |> 
  req_url_query(
    latitude = 5.3729, 
    longitude = 100.2496, 
    start_date = "1940-01-01", 
    end_date = "2024-05-11", 
    hourly = c("temperature_2m", "relative_humidity_2m", "apparent_temperature"), 
    timezone = "Asia/Singapore",
    .multi = "comma" 
  ) -> req

resp <- req |> req_perform()
resp_ls <- resp |> resp_body_json() |> purrr::pluck("hourly") 

library(dplyr)
library(tidyr)
tibble::as_tibble(resp_ls) |> 
  unnest(everything()) |> 
  mutate(time = lubridate::ymd_hm(time), 
         time = lubridate::force_tz(time, "Asia/Singapore")) -> res

arrow::write_feather(res, "post/temp/penang.feather")


res |> 
  group_by(month = lubridate::month(time, label = TRUE), year = lubridate::year(time)) |> 
  summarize(apparent_temperature = max(apparent_temperature), temperature_2m = max(temperature_2m)) |> 
  pivot_longer(matches("temperature")) |> 
  ungroup() |> 
  mutate(colour = ifelse(year %in% c(2023:2024, 1949), year, 0) |> as.factor() |> forcats::fct_rev(),
         size = ifelse(year %in% c(2023:2024, 1949), 0.2, 0.1), 
         year = as.factor(year),
         year = forcats::fct_relevel(year, '2023', '2024', '1949', after = Inf)) |> 
  drop_na(month) |> 
  ggplot(aes(x = month, y = value, group = year, colour = colour, linewidth = size)) + 
  facet_wrap(vars(name), ncol = 1, scale = "free_y") + 
  geom_line(alpha = .7) + scale_colour_manual(values = c(`2024` = "red", `2023` = "orange", `0` = "grey80", `1949` = 'black') ) + 
  theme_minimal() + theme(panel.grid = element_blank()) + labs(y = "", x = "") +
  scale_linewidth(range = c(.1, 1))



# res |> 
#   group_by(time = lubridate::floor_date(time, unit = "day")) |> 
#   summarize(apparent_temperature  = max(apparent_temperature )) |> 
#   group_by(month = lubridate::month(time), year = lubridate::year(time)) |> 
#   summarize(
#     days_35  = sum(apparent_temperature > 35),
#     days_36  = sum(apparent_temperature > 36),
# 
#     days_37  = sum(apparent_temperature > 37),
#     days_38  = sum(apparent_temperature > 38)
#   ) |> 
#   pivot_longer(cols = starts_with("days_")) |> 
#   mutate(colour = year %in% 2023:2024) |> 
#   ggplot(aes(x = month, y = value, group = year, colour = colour)) + 
#   facet_wrap(vars(name)) + 
#   geom_line(alpha = .5) + scale_colour_manual(values = c(`TRUE` = "red", `FALSE` = "grey80") ) 
# 
# 
# res |> 
#   group_by(time = lubridate::floor_date(time, unit = "day")) |> 
#   summarize(temperature_2m  = max(temperature_2m )) |> 
#   group_by(month = lubridate::month(time), year = lubridate::year(time)) |> 
#   summarize(
#     days_28  = sum(temperature_2m > 28),
#     days_29  = sum(temperature_2m > 29),
#     days_30  = sum(temperature_2m > 30),
#     days_31  = sum(temperature_2m > 31),
#   ) |> 
#   pivot_longer(cols = starts_with("days_")) |> 
#   mutate(colour = year %in% 2023:2024) |> 
#   ggplot(aes(x = month, y = value, group = year, colour = colour)) + 
#   facet_wrap(vars(name)) + 
#   geom_line(alpha = .5) + scale_colour_manual(values = c(`TRUE` = "red", `FALSE` = "grey80") ) 
# plotly::ggplotly(p1)

           