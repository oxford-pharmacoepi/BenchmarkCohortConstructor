for (json in jsons$cohort_name) {
  tic(msg = paste0("atlas_", json))
  cdm <- generateCohortSet(
    cdm = cdm,
    cohortSet = jsons |> filter(cohort_name == .env$json),
    name = paste0("atlas_", json),
    computeAttrition = TRUE,
    overwrite = TRUE
  )
  toc(log = TRUE)
}

tic.log(format = FALSE) |>
  purrr::map_df(~as_tibble(.x)) |>
  mutate(cdm_name = cdmName(cdm), package_version = as.character(packageVersion("CohortConstructor"))) |>
  write_csv(file = here(output_folder, paste0("atlas_time_", database_name, ".csv")))


cohorts <- c("hospitalisation", "major_non_cardiac_surgery", "neutropenia_leukopenia", "new_fluoroquinolone", "transverse_myelitis")
