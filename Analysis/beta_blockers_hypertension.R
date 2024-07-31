cdm$cc1_beta_blockers_hypertension <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c("howoften_beta_blockers", "essential_hypertension")],
  name = "cc1_beta_blockers_hypertension"
)  |>
  collapseCohorts(gap = 90, cohortId = 1) |>
  requireIsFirstEntry(cohortId = 1) |>
  requirePriorObservation(
    cohortId = 1,
    minPriorObservation = 365
  )

cdm$cc1_beta_blockers_hypertension <- cdm$cc1_beta_blockers_hypertension |>
  requireCohortIntersect(
    targetCohortTable = "cc1_beta_blockers_hypertension",
    window = list(c(-Inf, 0)),
    intersections = c(1, Inf),
    cohortId = 1,
    targetCohortId = 2,
    targetEndDate = NULL
  ) |>
  subsetCohorts(1)

cdm$cc1_beta_blockers_hypertension <- cdm$cc1_beta_blockers_hypertension |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_beta_blockers_hypertension) |>
      mutate(cohort_name = "cc1_beta_blockers_hypertension"),
    .softValidation = TRUE
  )

