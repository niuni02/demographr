# ---- Load libs ----
library(tidyverse)
library(geographr)
library(devtools)
library(httr2)

# ---- Load internal sysdata.rda file with URLs ----
load_all(".")

# ---- Download data ----
query_url <-
  query_urls |>
  filter(id == "ethnicity21_msoa21") |>
  pull(query)

download <- tempfile(fileext = ".zip")

request(query_url) |>
  req_perform(download)

unzip(download, exdir = tempdir())

list.files(tempdir())

raw <- read_csv(file.path(tempdir(), "census2021-ts022-msoa.csv"))

names(raw) <- str_remove(names(raw), "Ethnic group \\(detailed\\): ")

# ---- Detailed ethnic categories ----
ethnicity21_msoa21 <- 
  raw |> 
  select(msoa21_code = `geography code`, total_residents = `Total: All usual residents`, !contains(":"), -date, -geography) |> 
  pivot_longer(cols = -c(msoa21_code, total_residents), names_to = "ethnic_group", values_to = "n") |> 
  mutate(prop = n / total_residents)

ethnicity21_detailed_msoa21 <- 
  raw |> 
  select(msoa21_code = `geography code`, contains(":")) |> 
  rename(total_residents = `Total: All usual residents`) |> 
  pivot_longer(cols = -c(msoa21_code, total_residents), names_to = "ethnic_group", values_to = "n") |> 
  mutate(prop = n / total_residents)

# ---- Save output to data/ folder ----
usethis::use_data(ethnicity21_msoa21, overwrite = TRUE)
usethis::use_data(ethnicity21_detailed_msoa21, overwrite = TRUE)
