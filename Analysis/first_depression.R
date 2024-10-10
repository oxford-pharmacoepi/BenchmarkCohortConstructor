cdm$cc1_first_depression <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c(
    "major_depressive_disorder", "bipolar_disorder", "schizoaffective_disorder",
    "schizophrenia_not_including_paraphenia", "dementia", "psychotic_disorder"
  )],
  name = "cc1_first_depression"
)

cdm$cc1_first_depression <- cdm$cc1_first_depression |>
  requireIsFirstEntry(cohortId = 1) |>
  requireCohortIntersect(
    targetCohortTable = "cc1_first_depression",
    window = list(c(-Inf, 0)),
    intersections = 0,
    cohortId = 1,
    targetCohortId = getIds(cdm$cc1_first_depression, "bipolar_disorder"),
    targetEndDate = NULL
  ) |>
  requireCohortIntersect(
    targetCohortTable = "cc1_first_depression",
    window = list(c(-Inf, 0)),
    intersections = 0,
    cohortId = 1,
    targetCohortId = getIds(cdm$cc1_first_depression, "schizoaffective_disorder"),
    targetEndDate = NULL
  ) |>
  requireCohortIntersect(
    targetCohortTable = "cc1_first_depression",
    window = list(c(-Inf, 0)),
    intersections = 0,
    cohortId = 1,
    targetCohortId = getIds(cdm$cc1_first_depression, "schizophrenia_not_including_paraphenia"),
    targetEndDate = NULL
  ) |>
  requireCohortIntersect(
    targetCohortTable = "cc1_first_depression",
    window = list(c(-Inf, 0)),
    intersections = 0,
    cohortId = 1,
    targetCohortId = getIds(cdm$cc1_first_depression, "dementia"),
    targetEndDate = NULL
  ) |>
  requireCohortIntersect(
    targetCohortTable = "cc1_first_depression",
    window = list(c(-Inf, 0)),
    intersections = 0,
    cohortId = 1,
    targetCohortId =  getIds(cdm$cc1_first_depression, "psychotic_disorder"),
    targetEndDate = NULL
  ) |>
  subsetCohorts(cohortId = 1) |>
  exitAtObservationEnd()

cdm$cc1_first_depression <- cdm$cc1_first_depression |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_first_depression) |>
      mutate(cohort_name = "cc1_first_depression"),
    .softValidation = TRUE
  )
