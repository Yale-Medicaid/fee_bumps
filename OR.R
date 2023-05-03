library(tidyverse)
library(readxl)
library(arrow)

links <- c(
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/bh-fee-schedule0423.xlsx",
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/bh-fee-schedule0323.xlsx",
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/bh-fee-schedule1022.xlsx",
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/bh-fee-schedule0122.xlsx",
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/October%2030%202020%20Behavioral%20Health%20Fee%20Schedule.xlsx",
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/August%202020%20Behavioral%20Health%20Fee%20Schedule.xlsx",
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/July%202020%20Behavioral%20Health%20Fee%20Schedule.xlsx",
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/June%202020%20Behavioral%20Health%20Fee%20Schedule.xlsx",
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/May%202020%20Behavioral%20Health%20Fee%20Schedule.xlsx",
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/March%202020%20Behavioral%20Health%20Fee%20Schedule.xlsx",
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/January%202020%20Behavioral%20Health%20Fee%20Schedule.xlsx",
    "https://www.oregon.gov/oha/HSD/OHP/DataReportsDocs/October%202019%20Behavioral%20Health%20Fee%20Schedule.xlsx"
)

names <- as.Date(c("01-04-2023", "01-03-2023",
           # "01-07-2022", # set this one manually - was published 2 months after it took effect
           "01-10-2022",
           "01-01-2022", "01-10-2020",
           "01-8-2020", "01-7-2020", "01-6-2020",
           "01-5-2020", "01-3-2020", "01-1-2020",
           "01-10-2019"
           ), format = "%d-%m-%Y")
out_files <- paste0("data/OR/", names, ".xlsx")

walk2(links, out_files, download.file)

combined_data <- map(out_files, read_excel, sheet =2, range = "A7:G4000")   %>%
    map(~mutate(.x, Rate = as.numeric(Rate))) %>%
    map2_dfr(names, ~mutate(.x, date = .y)) %>%
    filter(!is.na(Rate), is.na(`Required modifiers1`))


combined_data %>%
    select(Code, Rate ,date) %>%
    rename_with(tolower) %>%
    rename(fee = rate) %>%
    mutate(state = "OR")  %>%
    write_parquet("data/OR.parquet")
