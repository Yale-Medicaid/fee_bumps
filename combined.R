library(arrow)
library(tidyverse)
library(readxl)

state_files <- list.files("data", "*.parquet", full.names = T)
data <- open_dataset(state_files) %>%
    collect()


hannah_data <- read_excel("data/psych_nonfac_fee_21_22_23.xlsx") %>%
    mutate(date = as.Date(start_date)) %>%
    select(state, date, code, fee) %>%
    mutate(code = as.character(code))

codes_to_keep <- c("99213", "99214", "90833", "90836", "90834")
full_codes_to_keep <- c(
                   "90785",	"90791",	"90792",	"90832",
                   "90833",	"90834",	"90836",	"90837",
                   "90838",	"90839",	"90840",	"90845",
                   "90847",	"90849",	"90853",	"90868",
                   "90870",	"90875",	"90876",	"90880",
                   "90882",	"90885",	"90887",	"90899",
                   "95970",	"99202",	"99203",	"99204",
                   "99205",	"99211",	"99212",	"99213",
                   "99214",	"99215",	"99354",	"99355"
)

treat_dates <-
    tibble(
           state = c("WA", "KS", "NJ", "MA", "MD", "OR"),
           treat_date = as.Date(c("10-01-2021", "07-01-2022",
                                  "07-01-2022", "07-01-2022",
                                  "07-01-2022", "07-01-2022"),
                                format = "%m-%d-%Y"
           )
    )

full_data <- bind_rows(data, hannah_data) %>%
    filter(code %in% codes_to_keep)  %>%
    full_join(treat_dates) %>%
    mutate(
           realtive_time = date - treat_date
           )

ggplot(data = full_data, aes(x=date,y=fee, col = code)) +
    geom_line() +
    geom_point() +
    scale_y_continuous(limits = c(0,200)) +
    geom_hline(yintercept = 0, linetype=2, col="grey") +
    facet_wrap(~state) +
    ggtitle("Medicaid Fee Bumps by State")  +
    theme_bw() +
    xlab("Date") +
    ylab("Reimbursement Amount")

ggplot(data = full_data, aes(x=realtive_time,y=fee, col = code)) +
    geom_line() +
    geom_point() +
    scale_y_continuous(limits = c(0,200)) +
    geom_hline(yintercept = 0, linetype=2, col="grey") +
    geom_vline(xintercept = 0, linetype=2, col="grey") +
    facet_wrap(~state) +
    ggtitle("Medicaid Fee Bumps by State")  +
    theme_bw() +
    xlab("Days Before / After Fee Bump") +
    ylab("Reimbursement Amount")

