cdm$cc1_transverse_myelitis_base <- conceptCohort(
  cdm = cdm,
  conceptSet = codes[c("transverse_myelitis", "symptoms_for_transverse_myelitis")],
  name = "cc1_transverse_myelitis_base"
)

cdm$cc1_transverse_myelitis_base <- cdm$cc1_transverse_myelitis_base |>
  requireCohortIntersect(
    targetCohortTable = "cc1_transverse_myelitis_base",
    window = list(c(0, 30)),
    intersections = c(1, Inf),
    cohortId = 2,
    targetCohortId = 1
  )

cdm$cc1_transverse_myelitis <- cdm$cc1_transverse_myelitis_base |>
  unionCohorts(
    cohortName = "cc1_transverse_myelitis",
    name = "cc1_transverse_myelitis"
  )

cdm$cc1_transverse_myelitis <- cdm$cc1_transverse_myelitis |>
  requireCohortIntersect(
    targetCohortTable = "cc1_transverse_myelitis",
    window = list(c(-365, -1)),
    intersections = 0,
    targetCohortId = 1
  ) |>
  collapseCohorts(gap = 1) |>
  mutate(start_1 = as.Date(add_days(.data$cohort_start_date, 1))) |>
  addFutureObservation(futureObservationType = "date", name = "cc1_transverse_myelitis") |>
  exitAtFirstDate(dateColumns = c("start_1", "future_observation"), returnReason = FALSE)
