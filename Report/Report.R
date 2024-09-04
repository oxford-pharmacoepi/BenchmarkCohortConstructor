library(visOmopResults)
library(readr)
library(omopgenerics)
library(ggplot2)
library(CohortCharacteristics)
library(stringr)
library(here)
library(dplyr)
library(tidyr)
library(gt)
# detach("package:zip", unload = TRUE)

source(here("Report", "functions.R"))

result_patterns <- c("time", "comparison", "details")
data <- readData(here()) %>% mergeData(result_patterns)

## Cohort counts ----
cohortCount <- data$details |>
  filterSettings(result_type == "cohort_count") |>
  tidy(addSettings = FALSE) |>
  select(-variable_level, - result_id) |>
  # pivot_wider(values_from = "count", names_from = "variable_name")
cohortCount |>
  mutate(
    Tool = if_else(grepl("cc", cohort_name), "CohortConstructor", "CIRCE"),
    "Cohort name" = str_to_sentence(gsub("_", " ", gsub("cc_|atlas_", "", cohort_name))),
    variable_name = stringr::str_to_sentence(gsub("_", " ", .data$variable_name))
  ) |>
  select(-cohort_name) |>
  pivot_wider(names_from = c("cdm_name", "variable_name"), values_from = c("count"), names_prefix = "[header]Database name\n[header_level]", names_sep = "\n[header_level]") %>%
  visOmopResults::gtTable()

## By definition ----
header_prefix <- "[header]Time by database (minutes)\n[header_level]"
data$time |>
  distinct() |>
  filter(!grepl("male|set", msg)) |>
  mutate(
    time = niceNum((as.numeric(toc) - as.numeric(tic))/60, 2),
    Tool = if_else(grepl("cc", msg), "CohortConstructor", "CIRCE"),
    "Cohort name" = str_to_sentence(gsub("_", " ", gsub("cc_|atlas_", "", msg)))
  ) |>
  select(-c("tic", "toc", "msg", "callback_msg")) |>
  # inner_join(cohortCount |> rename("msg" = "cohort_name"), by = c("msg", "cdm_name")) |>
  pivot_wider(names_from = "cdm_name", values_from = "time", names_prefix = header_prefix) |>
  # select(all_of(c("Cohort name", "Tool")), starts_with("[header]Time")) |>
  # just while there is 1 database
  select(c("Cohort name", "Tool", paste0(header_prefix, data$time$cdm_name |> unique()))) |>
  # union_all(
  #   tibble(
  #     `Cohort name` = "First depression",
  #     `Time (minutes)` = "> 2880",
  #     "Tool" = "CIRCE"
  #   )
  # ) |>
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
  gt::gtsave(filename = here("Report", "ReportResults", "bycohort.png"), expand = 70)

## As a set ----
data$time |>
  distinct() |>
  filter(grepl("atlas", msg)) |>
  filter(!grepl("male", msg)) |>
  group_by(cdm_name) |>
  summarise(time = niceNum(sum(as.numeric(toc) - as.numeric(tic))/60, 2)) |>
  mutate(Tool = "CIRCE") |>
  union_all(
    data$time |>
      filter(msg == "cc_set_no_strata") |>
      group_by(cdm_name) |>
      summarise(time = niceNum(sum(as.numeric(toc) - as.numeric(tic))/60, 2)) |>
      mutate(Tool = "CohortConstructor")
  ) |>
  select("Tool", "Time (minutes)" = "time") |>
  # pivot_wider(names_from = "Tool", values_from = "time", names_prefix = "[header]Time (minutes)\n[header_level]") |>
  # select("Database" = "cdm_name", starts_with("[header]Time")) |>
  # mutate("Database" = "CPRD Gold") |>
  gtTable(colsToMergeRows = "all_columns") |>
  gt::cols_width(everything() ~ px(150)) |>
  gt::gtsave(filename = here("Report", "set.png"), expand = 70)


## Strata ----
data$time |>
  distinct() |>
  filter(grepl("atlas_covid|set_strata", msg) | msg == "cc_covid") |>
  filter(msg != "atlas_covid") |>
  mutate(Tool = if_else(grepl("cc", msg), "CohortConstructor", "CIRCE")) |>
  group_by(cdm_name, Tool) |>
  summarise(time = niceNum(sum(as.numeric(toc) - as.numeric(tic))/60, 2), .groups = "drop") |>
  select("Tool", "Time (minutes)" = "time") |>
  # pivot_wider(names_from = "Tool", values_from = "time", names_prefix = "[header]Time (minutes)\n[header_level]") |>
  # select("Database" = "cdm_name", starts_with("[header]Time")) |>
  # mutate("Database" = "CPRD Gold") |>
  gtTable(colsToMergeRows = "all_columns") |>
  gt::cols_width(everything() ~ px(150)) |>
  gt::gtsave(filename = here("Report", "strata.png"), expand = 70)


## Overlap ----
overlap <- data$comparison |>
  filterSettings(result_type == "cohort_overlap")

overlap |>
  splitGroup() |>
  filter(grepl("atlas_", cohort_name_reference) & grepl("cc_", cohort_name_comparator)) |>
  filter(gsub("atlas_", "", cohort_name_reference) == gsub("cc_", "", cohort_name_comparator)) |>
  # mutate(cohort_name_reference = "",
  #        cohort_name_comparator = gsub("cc_", "", cohort_name_comparator)) |>
  uniteGroup(cols = c("cohort_name_reference", "cohort_name_comparator")) |>
  plotCohortOverlap(facet = "cdm_name") +
  ggtitle("Atlas vs. CohortConstructor by domain")
  # ggsave(filename = "overlap_atlas_domain.png", device = "png")


overlap |>
  splitGroup() |>
  filter(grepl("cc1_", cohort_name_reference) & grepl("cc_", cohort_name_comparator)) |>
  filter(gsub("cc1_", "", cohort_name_reference) == gsub("cc_", "", cohort_name_comparator)) |>
  # mutate(cohort_name_reference = "",
  #        cohort_name_comparator = gsub("cc_", "", cohort_name_comparator)) |>
  uniteGroup(cols = c("cohort_name_reference", "cohort_name_comparator")) |>
  plotCohortOverlap(facet = "cdm_name") +
  ggtitle("CohortConstructor by definition vs. CohortConstructor by domain")

overlap |>
  splitGroup() |>
  filter(grepl("cc1_", cohort_name_reference) & grepl("atlas_", cohort_name_comparator)) |>
  filter(gsub("cc1_", "", cohort_name_reference) == gsub("atlas_", "", cohort_name_comparator)) |>
  # mutate(cohort_name_reference = "",
  #        cohort_name_comparator = gsub("cc_", "", cohort_name_comparator)) |>
  uniteGroup(cols = c("cohort_name_reference", "cohort_name_comparator")) |>
  plotCohortOverlap(facet = "cdm_name") +
  ggtitle("CohortConstructor by definition vs. Atlas")
#
# ## Density ----
# density <- data$comparison |>
#   filterSettings(result_type == "cohort_timing")
#
# density |> plotCohortTiming(colour = "group_level")
#   splitGroup() |>
#   filter(grepl("atlas_", cohort_name_reference) & grepl("cc_", cohort_name_comparator)) |>
#   filter(gsub("atlas_", "", cohort_name_reference) == gsub("cc_", "", cohort_name_comparator)) |>
#   # mutate(cohort_name_reference = "",
#   #        cohort_name_comparator = gsub("cc_", "", cohort_name_comparator)) |>
#   uniteGroup(cols = c("cohort_name_reference", "cohort_name_comparator")) |>
#   plotCohortTiming(facet = "cdm_name") +
#   ggtitle("Atlas vs. CohortConstructor by domain")
# # ggsave(filename = "overlap_atlas_domain.png", device = "png")
