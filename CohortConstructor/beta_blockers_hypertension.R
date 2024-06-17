cdm$cc1_beta_blockers_hypertension <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c("[howoften]_beta_blockers", "essential_hypertension")],
  name = "cc1_beta_blockers_hypertension"
) |>
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
  ) |>
  subsetCohorts(1) |>
  collapseCohorts(gap = 90) |>
  requireIsFirstEntry()

