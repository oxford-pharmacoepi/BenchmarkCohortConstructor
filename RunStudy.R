# Results folder ----
output_folder <- here(paste0("Results_", cdmName(cdm), "_", gsub("-", "", Sys.Date())))
if (!dir.exists(output_folder)) {
  dir.create(output_folder)
}

# create logger ----
log_file <- here(output_folder, paste0("log", "_", gsub("-", "", Sys.Date()), ".txt"))
if (file.exists(log_file)) {
  unlink(log_file)
}

logger <- create.logger()
logfile(logger) <- log_file
level(logger) <- "INFO"
info(logger, "Create logger")

# codelists ----
concept_sets <- c(
  "inpatient_visit",
  "howoften_beta_blockers",
  "symptoms_for_transverse_myelitis",
  "asthma_therapy",
  "howoften_fluoroquinolone_systemic",
  "congenital_or_genetic_neutropenia_leukopenia_or_agranulocytosis",
  "endometriosis",
  "chronic_obstructive_lung_disease",
  "essential_hypertension",
  "asthma",
  "neutropenia_agranulocytosis_or_unspecified_leukopenia",
  "dementia",
  "schizophrenia_not_including_paraphenia",
  "psychotic_disorder",
  "bipolar_disorder",
  "major_depressive_disorder",
  "transverse_myelitis",
  "schizoaffective_disorder",
  "endometriosis_related_laproscopic_procedures",
  "long_acting_muscarinic_antagonists_lamas",
  "neutrophilia",
  "covid_19",
  "major_non_cardiac_surgery",
  "sars_cov_2_test",
  "neutrophil_absolute_count"
)
codes <- as.list(rep(192836451920927, length(concept_sets))) # non real concept
names(codes) <- concept_sets

codes_cdm <- codesFromCohort(here("JSONCohorts"), cdm)
majorNonCardiacSurgery <- codesFromCohort(here("JSONCohorts/major_non_cardiac_surgery.json"), cdm)
codes_cdm <- codes_cdm[!names(codes_cdm) %in% names(majorNonCardiacSurgery)]
codes_cdm <- c(codes_cdm, list("major_non_cardiac_surgery" = unname(unlist(majorNonCardiacSurgery))))
names(codes_cdm) <- gsub("-", "_", gsub(",|\\(|\\)|\\[|\\]", "", gsub(" ", "_", tolower(names(codes_cdm)))))
# "howoften_inpatient_or_er_visit" == "inpatient_or_inpatient/er_visit"
# "pneumonectomy" == "lobectomy"
codes_cdm <- codes_cdm[!names(codes_cdm) %in% c("howoften_inpatient_or_er_visit", "lobectomy")]
names(codes_cdm)[names(codes_cdm) == "endometriosis_related_laproscopic_procedures_prevalent_procedures_for_1_endo_dx_cohort"] <- "endometriosis_related_laproscopic_procedures"

for (nm in names(codes_cdm)) {
  codes[nm] <- codes_cdm[nm]
}

# jsons ----
jsons <- readCohortSet(here("JSONCohorts"))

# jobs ----
if (runAtlas) {
  info(logger, "Start instantiating ATLAS cohorts")
  tic.clearlog()
  source(here("Atlas", "atlas_cohorts.R"))

} else {
  info(logger, "Read ATLAS cohorts")
  cdm <- cdmFromCon(
    con = db,
    cdmSchema = cdm_database_schema,
    writeSchema = c("schema" = results_database_schema, "prefix" = tolower(table_stem)),
    cohortTables = paste0("atlas_", jsons$cohort_name),
    cdmName = database_name,
    .softValidation = TRUE
  )
}

if (runCohortConstructorByCohort) {
  info(logger, "Start CohortConstructor by definition")
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

} else {
  info(logger, "Read CohortConstructor by definition")
  cdm <- cdmFromCon(
    con = db,
    cdmSchema = cdm_database_schema,
    writeSchema = c("schema" = results_database_schema, "prefix" = tolower(table_stem)),
    cohortTables = paste0("cc1_", jsons$cohort_name),
    cdmName = database_name,
    .softValidation = TRUE
  )
}

if (runCohortConstructorSet) {
  info(logger, "Start CohortConstructor by domain")
  tic.clearlog()
  source(here("CohortConstructor", "construct_cohort_set.R"))

} else {
  info(logger, "Read CohortConstructor by domain")
  cdm <- cdmFromCon(
    con = db,
    cdmSchema = cdm_database_schema,
    writeSchema = c("schema" = results_database_schema, "prefix" = tolower(table_stem)),
    cohortTables = paste0("cc_", jsons$cohort_name),
    cdmName = database_name,
    .softValidation = TRUE
  )
}

if (runEvaluateCohorts) {
  info(logger, "Evaluate overlap and timing")
  source("EvaluateCohorts", "cohort_similarity.R")
}

# Zip results ----
output_folder <- basename(output_folder)
zip(
  zipfile = paste0(output_folder, "_", gsub("-", "", Sys.Date()), ".zip"),
  files = list.files(output_folder, full.names = TRUE)
)
