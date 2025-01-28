cdm$cc1_beta_blockers_hypertension <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c("beta_blockers", "essential_hypertension")],
  name = "cc1_beta_blockers_hypertension"
)  |>
  collapseCohorts(
    gap = 90,
    cohortId = 1
  )

cdm$cc1_beta_blockers_hypertension <- cdm$cc1_beta_blockers_hypertension |>
  requireIsFirstEntry(cohortId = getIds(cdm$cc1_beta_blockers_hypertension, "beta_blockers")) |>
  requirePriorObservation(
    cohortId = getIds(cdm$cc1_beta_blockers_hypertension, "beta_blockers"),
    minPriorObservation = 365
  ) |>
  requireCohortIntersect(
    targetCohortTable = "cc1_beta_blockers_hypertension",
    window = list(c(-Inf, 0)),
    intersections = c(1, Inf),
    cohortId = getIds(cdm$cc1_beta_blockers_hypertension, "beta_blockers"),
    targetCohortId = getIds(cdm$cc1_beta_blockers_hypertension, "essential_hypertension"),
    targetEndDate = NULL
  ) |>
  subsetCohorts(getIds(cdm$cc1_beta_blockers_hypertension, "beta_blockers"))

cdm$cc1_beta_blockers_hypertension <- cdm$cc1_beta_blockers_hypertension |>
  newCohortTable(
    cohortSetRef = settings(cdm$cc1_beta_blockers_hypertension) |>
      mutate(cohort_name = "cc1_beta_blockers_hypertension"),
    .softValidation = TRUE
  )

