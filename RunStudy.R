# Results folder
output_folder <- here(paste0("Results_", cdmName(cdm), "_", gsub("-", "", Sys.Date())))
if (!dir.exists(output_folder)) {
  dir.create(output_folder)
}

# prepare codelists ----
codes <- codesFromCohort(here("JSONCohorts"), cdm)
majorNonCardiacSurgery <- codesFromCohort(here("JSONCohorts/major_non_cardiac_surgery.json"), cdm)
codes <- codes[!names(codes) %in% names(majorNonCardiacSurgery)]
codes <- c(codes, list("major_non_cardiac_surgery" = unname(unlist(majorNonCardiacSurgery))))
names(codes) <- gsub(" ", "_", tolower(names(codes)))
# "[howoften]_inpatient_or_er_visit" == "inpatient_or_inpatient/er_visit"
# "pneumonectomy" == "lobectomy"
codes <- codes[!names(codes) %in% c("[howoften]_inpatient_or_er_visit", "lobectomy")]
names(codes)[names(codes) == "endometriosis_related_laproscopic_procedures_(prevalent_procedures_for_1_endo_dx_cohort)"] <- "endometriosis_related_laproscopic_procedures"

# jsons ----
jsons <- readCohortSet(here("JSONCohorts"))

# jobs ----
if (runAtlas) {
  tic.clearlog()
  source(here("Atlas", "atlas_cohorts.R"))
}

if (runCohortConstructorByCohort) {
  tic.clearlog()
  files <- gsub(".R" , "", list.files(path = here("CohortConstructor"), pattern = ".R"))
  for (json in jsons$cohort_name) {
    if (json %in% files) {
      tic(msg = paste0("cc_", json))
      source(here("CohortConstructor", paste0(json, ".R")))
      toc(log = TRUE)
    }
  }
  source(here("CohortConstructor", "covid_strata.R"))
  tic.log(format = FALSE) |>
    purrr::map_df(~as_data_frame(.x)) |>
    mutate(cdm_name = cdmName(cdm), package_version = as.character(packageVersion("CohortConstructor"))) |>
    write_csv(file = here(output_folder, "cc_time_by_definition.csv"))
}

if (runCohortConstructorSet) {
  tic.clearlog()
  source(here("CohortConstructor", "construct_cohort_set.R"))
}

if (runEvaluateCohorts) {
  source("EvaluateCohorts", "cohort_similarity.R")
}

# Zip results ----
output_folder <- basename(output_folder)
zip(
  zipfile = paste0(output_folder, "_", gsub("-", "", today()), ".zip"),
  files = list.files(output_folder, full.names = TRUE)
)
