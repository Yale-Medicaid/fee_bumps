library(tidyverse)
library(arrow)

zip_files <- list.files("data/KS/", full.names = T)
walk(zip_files, unzip, exdir = "data/KS/")

text_files <- list.files("data/KS/", pattern = "*.txt$", full.names = T)
dates <- as.Date(str_extract(text_files, "[0-9]{2,}"), "%Y%m%d")

combined_file <- map(text_files, read_fwf, skip=2) %>%
    map(~mutate(.x, X9 = as.numeric(X9))) %>%
    map2(dates, ~mutate(.x, date = .y)) %>%
    map_df(filter, row_number() != 1)


names(combined_file) <- c(
          "code", "code2", "bnft_plan", "rate_type",
          "pricing_method", "mod",  "eff_date",  "end_date",
          "fee",  "rel_value",  "conv/adj", "%adj_adj",
          "factor", "date")

combined_file %>%
    filter(is.na(mod), is.na(factor)) %>%
    select(code, fee, date) %>%
    mutate(state = "KS") %>%
    write_parquet("data/KS.parquet")

