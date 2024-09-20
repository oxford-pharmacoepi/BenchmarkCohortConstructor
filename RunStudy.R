# functions ----
getIds <- function(cohort, cohort_names) {
  settings(cohort) |>
    filter(.data$cohort_name %in% .env$cohort_names) |>
    pull("cohort_definition_id")
}

# Checks ----
if (nchar(table_stem) > 10){
  cli::cli_abort(c("x" = "`table_stem` should be less than 10 characters."))
}

# Results folder ----
output_folder <- here(paste0("Results_", database_name))
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

# Create sink message file ----
# info(logger, "Create sink message file")
# zz <- file(here(output_folder, paste0("sink", "_", gsub("-", "", Sys.Date()), ".txt")), open = "wt")
# sink(zz)
# sink(zz, type = "message")

# jsons ----
jsons <- readCohortSet(here("JSONCohorts"))

# connecto to cdm ----
cohortsCreated <- c(
  paste0("atlas_", jsons$cohort_name),
  paste0("cc1_", jsons$cohort_name)
)
ccSet <- paste0("cc_", jsons$cohort_name)
ccSet <- ccSet[!grepl("covid_", ccSet)]
cohortsCreated <- c(cohortsCreated, ccSet, "cc_covid", "cc_covid_strata")
if (runAtlas) cohortsCreated <- cohortsCreated[!grepl("atlas_", cohortsCreated)]
if (runCohortConstructorByCohort) cohortsCreated <- cohortsCreated[!grepl("cc1_", cohortsCreated)]
if (runCohortConstructorSet) cohortsCreated <- cohortsCreated[!grepl("cc_", cohortsCreated)]
if (length(cohortsCreated) == 0) cohortsCreated <- NULL

cdm <- cdmFromCon(
  con = db,
  cdmSchema = cdm_database_schema,
  writeSchema = c("schema" = results_database_schema, "prefix" = tolower(table_stem)),
  cohortTables = cohortsCreated,
  cdmName = database_name,
  .softValidation = TRUE
)

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
codes <- as.list(rep(100001L, length(concept_sets))) # mock concept as pleace-holder
names(codes) <- concept_sets
codes_cdm <- codesFromCohort(here("JSONCohorts"), cdm)
majorNonCardiacSurgery <- codesFromCohort(here("JSONCohorts/major_non_cardiac_surgery.json"), cdm)
codes_cdm <- codes_cdm[!names(codes_cdm) %in% names(majorNonCardiacSurgery)]
codes_cdm <- c(codes_cdm, list("major_non_cardiac_surgery" = unname(unlist(majorNonCardiacSurgery))))
names(codes_cdm) <- gsub("-", "_", gsub(",|\\(|\\)|\\[|\\]", "", gsub(" ", "_", tolower(names(codes_cdm)))))
codes_cdm <- codes_cdm[!names(codes_cdm) %in% c("howoften_inpatient_or_er_visit", "lobectomy")]
names(codes_cdm)[names(codes_cdm) == "endometriosis_related_laproscopic_procedures_prevalent_procedures_for_1_endo_dx_cohort"] <- "endometriosis_related_laproscopic_procedures"
for (nm in names(codes_cdm)) {
  codes[nm] <- codes_cdm[nm]
}

# jobs ----
if (runAtlas) {
  info(logger, "Start instantiating ATLAS cohorts")
  tic.clearlog()
  source(here("Analysis", "atlas_cohorts.R"))
}

if (runCohortConstructorByCohort) {
  info(logger, "Start CohortConstructor by definition")
  tic.clearlog()
  files <- gsub(".R" , "", list.files(path = here("Analysis"), pattern = ".R"))
  for (json in jsons$cohort_name) {
    if (json %in% files) {
      tic(msg = paste0("cc_", json))
      source(here("Analysis", paste0(json, ".R")))
      toc(log = TRUE)
    }
  }
  source(here("Analysis", "covid_strata.R"))
  tic.log(format = FALSE) |>
    purrr::map_df(~as_tibble(.x)) |>
    mutate(cdm_name = cdmName(cdm), package_version = as.character(packageVersion("CohortConstructor"))) |>
    write_csv(file = here(output_folder, paste0("cc_time_by_definition_", database_name, ".csv")))
}

if (runCohortConstructorSet) {
  info(logger, "Start CohortConstructor by domain")
  tic.clearlog()
  source(here("Analysis", "construct_cohort_set.R"))
}

if (runEvaluateCohorts) {
  info(logger, "Evaluate overlap and timing")
  source(here("Analysis", "cohort_similarity.R"))
}

if (runGetOMOPDetails) {
  info(logger, "Get OMOP details")
  tabNames <- c(
    "person", "drug_exposure", "condition_occurrence", "procedure_occurrence",
    "visit_occurrence", "observation_period", "measurement", "observation",
    "death"
  )
  tableCounts <- NULL
  for (tab in tabNames) {
    tableCounts <- tableCounts |> union_all(tibble(table_name = tab, number_records = cdm[[tab]] |> tally() |> pull("n")))
  }
  tableCounts |>
    mutate(cdm_name = cdmName(cdm), package_version = as.character(packageVersion("CohortConstructor"))) |>
    write_csv(file = here(output_folder, paste0("omop_counts_", database_name, ".csv")))
}

dbType <- attr(attr(cdm$person, "tbl_source"), "source_type")
if (runEvaluateIndex & dbType == "postgresql") {
  info(logger, "Evaluate SQL index performance for Postgres")
  source(here("Analysis", "index_performance.R"))
}

# Close sink
# sink(type = "message")
# sink()

# Zip results ----
output_folder <- basename(output_folder)
zip(
  zipfile = paste0(output_folder, "_", gsub("-", "", Sys.Date()), ".zip"),
  files = list.files(output_folder, full.names = TRUE)
)

cdm <- dropTable(cdm = cdm, name = starts_with("temp_"))
cdmDisconnect(cdm)
