library(visOmopResults)
library(readr)
library(omopgenerics)
library(ggplot2)
library(CohortCharacteristics)
library(stringr)
detach("package:zip", unload = TRUE)

source(here("Report", "functions.R"))

result_patterns <- c("time")
data <- readData(here()) %>% mergeData(result_patterns)

# overlap <- data$summarised_result |>
#   newSummarisedResult() |>
#   filterSettings(result_type == "cohort_overlap")
#
# overlap |>
#   splitGroup() |>
#   filter(grepl("atlas_", cohort_name_reference) & grepl("cc_", cohort_name_comparator)) |>
#   filter(gsub("atlas_", "", cohort_name_reference) == gsub("cc_", "", cohort_name_comparator)) |>
#   mutate(cohort_name_reference = "",
#          cohort_name_comparator = gsub("cc_", "", cohort_name_comparator)) |>
#   uniteGroup(cols = c("cohort_name_reference", "cohort_name_comparator")) |>
#   plotCohortOverlap(facet = "cdm_name") |>
#   ggsave(filename = "overlap.png", device = "png")

## By definition
data$time |>
  union_all(
    tibble(
      package_version = "0.2.1",
      cdm_name = "GOLD",
      msg = paste0(
        "atlas_",
        c("asthma_no_copd", "beta_blockers_hypertension", "covid", "covid_female",
          "covid_female_0_to_50", "covid_female_51_to_150", "covid_male",
          "covid_male_0_to_50", "covid_male_51_to_150", "endometriosis_procedure"
        )),
      tic = "0",
      toc = as.character(c(500.01, 53.61, 2857.13, 1615.47, 1110.53, 502.58, 1310.18, 840.35, 479.45, 49.1)),
      callback_msg = NA
    )
  ) |>
  distinct() |>
  filter(!grepl("male|set", msg)) |>
  mutate(
    cdm_name = "CPRD Gold",
    time = niceNum((as.numeric(toc) - as.numeric(tic))/60, 3),
    Tool = if_else(grepl("cc", msg), "CohortConstructor", "CIRCE"),
    "Cohort name" = str_to_sentence(gsub("_", " ", gsub("cc_|atlas_", "", msg)))
  ) |>
  pivot_wider(names_from = "cdm_name", values_from = "time", names_prefix = "[header]Time by database (minutes)\n[header_level]") |>
  # select(all_of(c("Cohort name", "Tool")), starts_with("[header]Time")) |>
  # just while there is 1 database
  select("Cohort name", "Tool", "Time (minutes)" = "[header]Time by database (minutes)\n[header_level]CPRD Gold") |>
  union_all(
    tibble(
      `Cohort name` = "First depression",
      `Time (minutes)` = "> 2880",
      "Tool" = "CIRCE"
    )
  ) |>
  mutate(
    "Cohort name" = case_when(
      grepl("Asthma", .data[["Cohort name"]]) ~ "Asthma without COPD",
      grepl("Covid", .data[["Cohort name"]]) ~ "COVID-19",
      grepl("eutropenia", .data[["Cohort name"]]) ~ "Acquired neutropenia or unspecified leukopenia",
      grepl("Hosp", .data[["Cohort name"]]) ~ "Inpatient hospitalisation",
      grepl("First", .data[["Cohort name"]]) ~ "First major depression",
      grepl("fluoro", .data[["Cohort name"]]) ~ "New fluoroquinolone users",
      grepl("Beta", .data[["Cohort name"]]) ~ "New users of beta blockers nested in essential hypertension",
      .default = .data[["Cohort name"]]
    )
  ) |>
  arrange(`Cohort name`) |>
  gtTable(colsToMergeRows = "all_columns") |>
  gt::cols_width(`Cohort name` ~ 300) |>
  gt::gtsave(filename = here("Report", "bycohort.png"), expand = 70)

## As a set
data$time |>
  union_all(
    tibble(
      package_version = "0.2.1",
      cdm_name = "GOLD",
      msg = paste0(
        "atlas_",
        c("asthma_no_copd", "beta_blockers_hypertension", "covid", "covid_female",
          "covid_female_0_to_50", "covid_female_51_to_150", "covid_male",
          "covid_male_0_to_50", "covid_male_51_to_150", "endometriosis_procedure"
        )),
      tic = "0",
      toc = as.character(c(500.01, 53.61, 2857.13, 1615.47, 1110.53, 502.58, 1310.18, 840.35, 479.45, 49.1)),
      callback_msg = NA
    )
  ) |>
  distinct() |>
  filter(grepl("atlas", msg)) |>
  filter(!grepl("male", msg)) |>
  group_by(cdm_name) |>
  summarise(time = niceNum(sum(as.numeric(toc) - as.numeric(tic))/60, 3)) |>
  mutate(Tool = "CIRCE") |>
  union_all(
    data$time |>
      filter(msg == "cc_set_no_strata") |>
      group_by(cdm_name) |>
      summarise(time = niceNum(sum(as.numeric(toc) - as.numeric(tic))/60, 3)) |>
      mutate(Tool = "CohortConstructor")
  ) |>
  pivot_wider(names_from = "Tool", values_from = "time", names_prefix = "[header]Time (minutes)\n[header_level]") |>
  select("Database" = "cdm_name", starts_with("[header]Time")) |>
  mutate("Database" = "CPRD Gold") |>
  gtTable(colsToMergeRows = "all_columns") |>
  gt::gtsave(filename = here("Report", "set.png"))


## Strata
data$time |>
  union_all(
    tibble(
      package_version = "0.2.1",
      cdm_name = "GOLD",
      msg = paste0(
        "atlas_",
        c("asthma_no_copd", "beta_blockers_hypertension", "covid", "covid_female",
          "covid_female_0_to_50", "covid_female_51_to_150", "covid_male",
          "covid_male_0_to_50", "covid_male_51_to_150", "endometriosis_procedure"
        )),
      tic = "0",
      toc = as.character(c(500.01, 53.61, 2857.13, 1615.47, 1110.53, 502.58, 1310.18, 840.35, 479.45, 49.1)),
      callback_msg = NA
    )
  ) |>
  distinct() |>
  filter(grepl("atlas_covid|set_strata", msg) | msg == "cc_covid") |>
  filter(msg != "atlas_covid") |>
  mutate(Tool = if_else(grepl("cc", msg), "CohortConstructor", "CIRCE")) |>
  group_by(cdm_name, Tool) |>
  summarise(time = niceNum(sum(as.numeric(toc) - as.numeric(tic))/60, 3), .groups = "drop") |>
  pivot_wider(names_from = "Tool", values_from = "time", names_prefix = "[header]Time (minutes)\n[header_level]") |>
  select("Database" = "cdm_name", starts_with("[header]Time")) |>
  gtTable(colsToMergeRows = "all_columns")|>
  gt::gtsave(filename = here("Report", "strata.png"))


