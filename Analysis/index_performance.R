info(logger, "Assess index performance")
tic.clearlog()

conceptsIndexes <- codes[c(
  "howoften_beta_blockers", # drug
  "essential_hypertension", # condition
  "major_non_cardiac_surgery", # procedure
  "neutrophil_absolute_count", # measurement
  "asthma" # condition + observation
)]
obsInd <- conceptsIndexes$major_non_cardiac_surgery %in% c(915705)
conceptsIndexes$major_non_cardiac_surgery <-
  conceptsIndexes$major_non_cardiac_surgery[!obsInd]

# Get codes
# analysisId = c(401, # condition occurrence
#                701, # drug_exposure
#                801, # observation
#                60, # procedure_occurrence
# )
# achilles_results <- tbl(db, sql("SELECT * from results.achilles_results")) |> compute()
# achilles_results <-  achilles_results |>
#   filter(analysis_id %in% analysisId) |>
#   select("domain" = "analysis_id", "concept_id" = "stratum_1", "n" = "count_value") |>
#   collect()
# achilles_results |>
#   group_by(domain) |>
#   filter( n < 1100 & n > 900) |>
#   sample_n(20)

# NO index ----
tic(msg = "No index: drug domain")
# one table
cdm$no_index_1 <- conceptCohort(
  cdm = cdm,
  conceptSet = conceptsIndexes[1],
  name = "no_index_1"
)
toc(log = TRUE)

tic(msg = "No index: drug and condition domains")
# 2 tables
cdm$no_index_2 <- conceptCohort(
  cdm = cdm,
  conceptSet = conceptsIndexes[1:2],
  name = "no_index_2"
)
toc(log = TRUE)

tic(msg = "No index: drug, condition, procedure domains")
# >2 tables: drug, condition, procedure
cdm$no_index_3 <- conceptCohort(
  cdm = cdm,
  conceptSet = conceptsIndexes[1:3],
  name = "no_index_3"
)
toc(log = TRUE)

tic(msg = "No index: drug, condition, procedure and measurement domains")
# >2 tables: drug, condition, observation, procedure
cdm$no_index_4 <- conceptCohort(
  cdm = cdm,
  conceptSet = conceptsIndexes[1:4],
  name = "no_index_4"
)
toc(log = TRUE)

# Index ----
rlang::local_options("CohortConstructor.use_indexes" = TRUE)

tic(msg = "Index: drug domain")
# one table
cdm$index_1 <- conceptCohort(
  cdm = cdm,
  conceptSet = conceptsIndexes[1],
  name = "index_1"
)
toc(log = TRUE)

tic(msg = "Index: drug and condition domains")
# 2 tables
cdm$index_2 <- conceptCohort(
  cdm = cdm,
  conceptSet = conceptsIndexes[1:2],
  name = "index_2"
)
toc(log = TRUE)

tic(msg = "Index: drug, condition, procedure domains")
# >2 tables: drug, condition, procedure
cdm$index_3 <- conceptCohort(
  cdm = cdm,
  conceptSet = conceptsIndexes[1:3],
  name = "index_3"
)
toc(log = TRUE)

tic(msg = "Index: drug, condition, procedure and measurement domains")
# >2 tables: drug, condition, observation, procedure
cdm$index_4 <- conceptCohort(
  cdm = cdm,
  conceptSet = conceptsIndexes[1:4],
  name = "index_4"
)
toc(log = TRUE)

# Save results ----
tic.log(format = FALSE) |>
  purrr::map_df(~as_data_frame(.x)) |>
  mutate(cdm_name = cdmName(cdm), package_version = as.character(packageVersion("CohortConstructor"))) |>
  write_csv(file = here(output_folder, paste0("sql_indexes_", database_name, ".csv")))

omopgenerics::bind(summary(cdm$index_4), summary(cdm$no_index_4)) |>
  omopgenerics::exportSummarisedResult(
    path = output_folder, fileName = paste0("index_cohort_details_", database_name, ".csv")
  )
