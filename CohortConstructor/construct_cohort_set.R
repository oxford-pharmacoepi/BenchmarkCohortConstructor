# functions ----
getIds <- function(cohort, cohort_names) {
  settings(cohort) |>
    filter(.data$cohort_name %in% .env$cohort_names) |>
    pull("cohort_definition_id")
}

# CC set ----
tic(msg = "cc_set_no_strata")
## Measurement cohorts ----
info(logger, "Measurement cohorts")
cdm$cc_covid_test_positive <- measurementCohort(
  cdm = cdm,
  conceptSet = codes["sars_cov_2_test"],
  name = "cc_covid_test_positive",
  valueAsConcept = c(4126681, 45877985, 9191, 45884084, 4181412, 45879438)
)

cdm$cc_covid_test_negative <- measurementCohort(
  cdm = cdm,
  conceptSet = codes["sars_cov_2_test"],
  name = "cc_covid_test_negative",
  valueAsConcept = c(9189, 9190, 9191, 4132135, 3661867, 45878583, 45880296, 45884086)
)

cdm$cc_neutropenia_leukopenia_measurement <- measurementCohort(
  cdm = cdm,
  conceptSet = codes["neutrophil_absolute_count"],
  name = "cc_neutropenia_leukopenia_measurement",
  valueAsNumber = list(
    "9444" = c(0.01, 1.499), "8848" = c(0.01, 1.499), "8816" = c(0.01, 1.499),
    "8961" = c(0.01, 1.499), "44777588" = c(0.01, 1.499),
    "8784" = c(10, 1499), "8647" = c(10, 1499)
  )
)

cdm$cc_normal_neutrophil <- measurementCohort(
  cdm = cdm,
  conceptSet = codes["neutrophil_absolute_count"],
  name = "cc_normal_neutrophil",
  valueAsNumber = list(
    "9444" = c(4, 8.25), "8848" = c(4, 8.25), "8816" = c(4, 8.25),
    "8961" = c(4, 8.25), "44777588" = c(4, 8.25),
    "8784" = c(4000, 8250), "8647" = c(4000, 8250)
  )
)

## Concept cohorts ----
info(logger, "Concept cohorts")
conceptCohortCodes <- codes[!names(codes) %in% c("sars_cov_2_test", "neutrophil_absolute_count")]
cdm$cc_base <- conceptCohort(
  cdm = cdm,
  conceptSet = conceptCohortCodes,
  name = "cc_base"
)

## Get study cohorts ----
### cc_asthma_no_copd
info(logger, "- cc_asthma_no_copd")
cdm$cc_asthma_no_copd <- cdm$cc_base |>
  subsetCohorts(
    cohortId = getIds(cdm$cc_base, c("asthma_therapy", "asthma")),
    name = "cc_asthma_no_copd"
  ) |>
  requireAge(ageRange = list(c(0,54)), cohortId = getIds(cdm$cc_base, c("asthma_therapy"))) |>
  requireCohortIntersect(
    targetCohortTable = "cc_base",
    window = list(c(-365, -180)),
    intersections = c(1, Inf),
    cohortId = getIds(cdm$cc_base, c("asthma_therapy")),
    targetCohortId = getIds(cdm$cc_base, c("asthma_therapy"))
  ) |>
 CohortConstructor::unionCohorts(cohortName = "cc_asthma_no_copd") |>
  requireIsFirstEntry() |>
  requireCohortIntersect(
    targetCohortTable = "cc_base",
    targetCohortId = getIds(cdm$cc_base, c("chronic_obstructive_lung_disease")),
    window = list(c(-Inf,0)),
    intersections = 0
  ) |>
  requireCohortIntersect(
    targetCohortTable = "cc_base",
    targetCohortId = getIds(cdm$cc_base, c("long_acting_muscarinic_antagonists_lamas")),
    window = list(c(-Inf,0)),
    intersections = 0
  )

### cc_beta_blockers_hypertension
info(logger, "- cc_beta_blockers_hypertension")
cdm$cc_beta_blockers_hypertension <- cdm$cc_base |>
  subsetCohorts(
    cohortId = getIds(cdm$cc_base, "howoften_beta_blockers"),
    name = "cc_beta_blockers_hypertension"
  ) |>
  requirePriorObservation(minPriorObservation = 365) |>
  requireCohortIntersect(
    targetCohortTable = "cc_base",
    window = list(c(-Inf, 0)),
    intersections = c(1, Inf),
    targetCohortId = getIds(cdm$cc_base, "essential_hypertension"),
  ) |>
  collapseCohorts(gap = 90) |>
  requireIsFirstEntry()

### cc_covid
info(logger, "- cc_covid")
cdm$cc_covid <- cdm$cc_base |>
  subsetCohorts(
    cohortId = getIds(cdm$cc_base, "covid_19"),
    name = "cc_covid"
  ) |>
  requireCohortIntersect(
    targetCohortTable = "cc_covid_test_negative",
    targetCohortId = 1,
    window = list(c(-3,3)),
    intersections = 0
  )

cdm <- omopgenerics::bind(cdm$cc_covid, cdm$cc_covid_test_positive, name = "cc_covid")

cdm$cc_covid <-  cdm$cc_covid |>
  CohortConstructor::unionCohorts() |>
  requireInDateRange(dateRange = c(as.Date("2019-12-02"), NA))

### cc_endometriosis_procedure
info(logger, "- cc_endometriosis_procedure")
endometriosis_id <- getIds(cdm$cc_base, "endometriosis")
cdm$cc_endometriosis_procedure <- cdm$cc_base |>
  subsetCohorts(
    cohortId = getIds(cdm$cc_base, "endometriosis_related_laproscopic_procedures"),
    name = "cc_endometriosis_procedure"
  ) |>
  requireCohortIntersect(
    targetCohortTable = "cc_base",
    window = list(c(-30, 30)),
    intersections = c(1, Inf),
    targetCohortId = endometriosis_id
  ) |>
  # 2 or more entrometiosis diagnosed
  requireCohortIntersect(
    targetCohortTable = "cc_base",
    window = list(c(0, Inf)),
    intersections = c(2, Inf),
    targetCohortId = endometriosis_id
  ) |>
  requireIsFirstEntry() |>
  requireDemographics(
    ageRange = list(c(15, 49)),
    sex = "Female"
  ) |>
  exitAtObservationEnd()

### cc_first_depression
# info(logger, "- cc_first_depression")
# cdm$cc_first_depression <- cdm$cc_base |>
#   subsetCohorts(
#     cohortId = getIds(cdm$cc_base, "major_depressive_disorder"),
#     name = "cc_first_depression"
#   ) |>
#   requireIsFirstEntry() |>
#   requireCohortIntersect(
#     targetCohortTable = "cc_base",
#     window = list(c(-Inf, 0)),
#     intersections = 0,
#     targetCohortId = getIds(cdm$cc_base, "bipolar_disorder")
#   ) |>
#   requireCohortIntersect(
#     targetCohortTable = "cc_base",
#     window = list(c(-Inf, 0)),
#     intersections = 0,
#     targetCohortId = getIds(cdm$cc_base, "schizoaffective_disorder")
#   ) |>
#   requireCohortIntersect(
#     targetCohortTable = "cc_base",
#     window = list(c(-Inf, 0)),
#     intersections = 0,
#     targetCohortId = getIds(cdm$cc_base, "schizophrenia_not_including_paraphenia")
#   ) |>
#   requireCohortIntersect(
#     targetCohortTable = "cc_base",
#     window = list(c(-Inf, 0)),
#     intersections = 0,
#     targetCohortId = getIds(cdm$cc_base, "dementia")
#   ) |>
#   requireCohortIntersect(
#     targetCohortTable = "cc_base",
#     window = list(c(-Inf, 0)),
#     intersections = 0,
#     targetCohortId = getIds(cdm$cc_base, "psychotic_disorder")
#   ) |>
#   exitAtObservationEnd()

### cc_hospitalisation
info(logger, "- cc_hospitalisation")
cdm$cc_hospitalisation <- cdm$cc_base |>
  subsetCohorts(
    cohortId = getIds(cdm$cc_base, "inpatient_visit"),
    name = "cc_hospitalisation"
  ) |>
  collapseCohorts(gap = 1) |>
  mutate(end_1 = as.Date(add_days(.data$cohort_end_date, 1))) |>
  addFutureObservation(futureObservationType = "date", name = "cc_hospitalisation") |>
  exitAtFirstDate(dateColumns = c("end_1", "future_observation"), returnReason = FALSE)

### cc_major_non_cardiac_surgery
info(logger, "- cc_major_non_cardiac_surgery")
cdm$cc_major_non_cardiac_surgery <- cdm$cc_base |>
  subsetCohorts(
    cohortId = getIds(cdm$cc_base, "major_non_cardiac_surgery"),
    name = "cc_major_non_cardiac_surgery"
  ) |>
  requireIsFirstEntry() |>
  requireAge(ageRange = list(c(18, 150))) |>
  exitAtObservationEnd()

### cc_neutropenia_leukopenia
info(logger, "- cc_neutropenia_leukopenia")
cdm$cc_neutropenia_leukopenia <- cdm$cc_base |>
  subsetCohorts(
    cohortId = getIds(cdm$cc_base, "neutropenia_agranulocytosis_or_unspecified_leukopenia"),
    name = "cc_neutropenia_leukopenia"
  )

cdm <- omopgenerics::bind(
  cdm$cc_neutropenia_leukopenia,
  cdm$cc_neutropenia_leukopenia_measurement,
  name = "cc_neutropenia_leukopenia"
)

cdm$cc_neutropenia_leukopenia <- cdm$cc_neutropenia_leukopenia |>
  CohortConstructor::unionCohorts(cohortName = "cc_neutropenia_leukopenia") |>
  # No congenital or genetic neutropenia, leukopenia or agranulocytosis
  requireCohortIntersect(
    targetCohortTable = "cc_base",
    window = list(c(-Inf, 7)),
    intersections = 0,
    targetCohortId = getIds(cdm$cc_base, "congenital_or_genetic_neutropenia_leukopenia_or_agranulocytosis")
  ) |>
  # No Neutrophilia on index date
  requireCohortIntersect(
    targetCohortTable = "cc_base",
    window = list(c(0,0)),
    intersections = 0,
    targetCohortId = getIds(cdm$cc_base, "neutrophilia")
  ) |>
  # No Normal Neutrophil count on index date
  requireCohortIntersect(
    targetCohortTable = "cc_normal_neutrophil",
    window = list(c(0,0)),
    intersections = 0,
    targetCohortId = 1
  ) |>
  addCohortIntersectDate(
    targetCohortTable = "cc_normal_neutrophil",
    window = list(c(0,Inf)),
    nameStyle = "normal_count_date",
    name = "cc_neutropenia_leukopenia"
  ) |>
  exitAtFirstDate(dateColumns = c("cohort_end_date", "normal_count_date"), returnReason = FALSE)

### cc_new_fluoroquinolone
info(logger, "- cc_new_fluoroquinolone")
cdm$cc_new_fluoroquinolone <- cdm$cc_base |>
  subsetCohorts(
    cohortId = getIds(cdm$cc_base, "howoften_fluoroquinolone_systemic"),
    name = "cc_new_fluoroquinolone"
  ) |>
  requirePriorObservation(minPriorObservation = 365) |>
  collapseCohorts(gap = 30) |>
  requireIsFirstEntry()

### cc_transverse_myelitis
info(logger, "- cc_transverse_myelitis")
cdm$cc_transverse_myelitis <- cdm$cc_base |>
  subsetCohorts(
    cohortId = getIds(cdm$cc_base, c("transverse_myelitis", "symptoms_for_transverse_myelitis")),
    name = "cc_transverse_myelitis"
  )

cdm$cc_transverse_myelitis <- cdm$cc_transverse_myelitis |>
  requireCohortIntersect(
    targetCohortTable = "cc_base",
    window = list(c(0, 30)),
    intersections = c(1, Inf),
    cohortId = getIds(cdm$cc_transverse_myelitis, c("symptoms_for_transverse_myelitis")),
    targetCohortId = getIds(cdm$cc_base, c("transverse_myelitis"))
  )

if (nrow(settings(cdm$cc_transverse_myelitis)) > 0) {
  cdm$cc_transverse_myelitis <- cdm$cc_transverse_myelitis |>
   CohortConstructor::unionCohorts(
      cohortName = "cc_transverse_myelitis"
    ) |>
    requireCohortIntersect(
      targetCohortTable = "cc_base",
      window = list(c(-365, -1)),
      intersections = 0,
      targetCohortId = getIds(cdm$cc_base, c("transverse_myelitis"))
    ) |>
    collapseCohorts(gap = 1) |>
    mutate(start_1 = as.Date(add_days(.data$cohort_start_date, 1))) |>
    addFutureObservation(futureObservationType = "date", name = "cc_transverse_myelitis") |>
    exitAtFirstDate(dateColumns = c("start_1", "future_observation"), returnReason = FALSE)
}


toc(log = TRUE)

## Covid strata ----
info(logger, "- strata covid cohorts")
### cc_covid_female
### cc_covid_female_0_to_50
### cc_covid_female_51_to_150
### cc_covid_male
### cc_covid_male_0_to_50
### cc_covid_male_51_to_150

cdm$cc_covid <- cdm$cc_covid |>
  newCohortTable(
    cohortSetRef = tibble(cohort_definition_id = 1, cohort_name = "cc_covid")
  )

tic(msg = "cc_set_strata")
cdm$cc_covid_strata <- cdm$cc_covid |>
  addDemographics(
    ageGroup = list(c(0,50), c(51, 150)),
    priorObservation = FALSE,
    futureObservation = FALSE
  ) |>
  stratifyCohorts(strata = list("sex", "age_group", c("sex", "age_group")), name = "cc_covid_strata")
toc(log = TRUE)

tic.log(format = FALSE) |>
  purrr::map_df(~as_data_frame(.x)) |>
  mutate(cdm_name = cdmName(cdm), package_version = as.character(packageVersion("CohortConstructor"))) |>
  write_csv(file = here(output_folder, "cc_time_by_domain.csv"))
