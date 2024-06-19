library(visOmopResults)
library(readr)
library(omopgenerics)
library(ggplot2)
library(CohortCharacteristics)
detach("package:zip", unload = TRUE)

source(here("", "functions.R"))

result_patterns <- c("cc_time_by_domain", "cc_time_by_definition")
data <- readData(here()) %>% mergeData(result_patterns)

overlap <- data$summarised_result |>
  newSummarisedResult() |>
  filterSettings(result_type == "cohort_overlap")

overlap |>
  splitGroup() |>
  filter(grepl("atlas_", cohort_name_reference) & grepl("cc_", cohort_name_comparator)) |>
  filter(gsub("atlas_", "", cohort_name_reference) == gsub("cc_", "", cohort_name_comparator)) |>
  mutate(cohort_name_reference = "",
         cohort_name_comparator = gsub("cc_", "", cohort_name_comparator)) |>
  uniteGroup(cols = c("cohort_name_reference", "cohort_name_comparator")) |>
  plotCohortOverlap(facet = "cdm_name") |>
  ggsave(filename = "overlap.png", device = "png")


data$timings
