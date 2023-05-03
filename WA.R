library(tidyverse)
library(readxl)
library(rvest)
library(arrow)

washington_schedule_pages <- c(
"https://www.hca.wa.gov/billers-providers-partners/forms-and-publications?combine=Mental+health+services+fee+schedule&field_billers_document_type_value_1=All&field_topic_tid=All&sort_bef_combine=name_DESC",
"https://www.hca.wa.gov/billers-providers-partners/forms-and-publications?combine=Mental%20health%20services%20fee%20schedule&field_billers_document_type_value_1=All&field_topic_tid=All&sort_bef_combine=name_DESC&page=1"#,
# "https://www.hca.wa.gov/billers-providers-partners/forms-and-publications?combine=Specialized+mental+health&field_billers_document_type_value_1=All&field_topic_tid=All&sort_bef_combine=name_DESC",
# "https://www.hca.wa.gov/billers-providers-partners/forms-and-publications?combine=Specialized%20mental%20health&field_billers_document_type_value_1=All&field_topic_tid=All&sort_bef_combine=name_DESC&page=1"
  )

relatve_links <- washington_schedule_pages %>%
    map(read_html) %>%
    map(html_elements, ".download") %>%
    map(html_elements, "a") %>%
    map(html_attr, "href")  %>%
    unlist()

links <- paste0("https://www.hca.wa.gov", relatve_links)

file_info <- tibble(
       link = links,
       date = as.Date(str_extract(link, "[0-9]+"), format = "%Y%m%d"),
       out_file = paste0("data/WA/", date, ".xlsx")
       )

walk2(file_info$link, file_info$out_file, download.file)

file_info <- file_info %>%
    mutate(
            skip5 = map_lgl(out_file,
                            ~!"Code" %in% names(read_excel(.x, skip=4))),
            df = map2(out_file, skip5,
                 ~read_excel(.x, skip = 4+.y,col_types = c("Code"="text") )
                )
           )


collected_df <- map2_df(file_info$df, file_info$date,
                        ~mutate(.x, date = .y))


collected_df <- collected_df %>%
    mutate(
           state = "WA",
           fee = `Maximum Allowable NFS Fee`
           )  %>%
    # select(date, Code, fee, state)  %>%
    mutate(fee = as.numeric(fee)) %>%
    rename_with(tolower)   %>%
    filter(is.na(modifier), is.na(comments))


write_parquet(collected_df, "data/WA.parquet")
